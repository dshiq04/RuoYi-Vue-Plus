package org.dromara.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import cn.hutool.core.collection.CollUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.constant.GlobalConstants;
import org.dromara.common.core.constant.SystemConstants;
import org.dromara.common.core.constant.TenantConstants;
import org.dromara.common.core.utils.MapstructUtils;
import org.dromara.common.core.utils.ObjectUtils;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.json.utils.JsonUtils;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.common.sse.dto.SseMessageDto;
import org.dromara.common.sse.utils.SseMessageUtils;
import org.dromara.common.tenant.helper.TenantHelper;
import org.dromara.system.domain.SysNotice;
import org.dromara.system.domain.SysUser;
import org.dromara.system.domain.bo.SysNoticeBo;
import org.dromara.system.domain.bo.SysTenantBo;
import org.dromara.system.domain.vo.NoticeReadListVo;
import org.dromara.system.domain.vo.SysNoticeVo;
import org.dromara.system.domain.vo.SysTenantVo;
import org.dromara.system.domain.vo.SysUserVo;
import org.dromara.system.mapper.SysNoticeMapper;
import org.dromara.system.mapper.SysUserMapper;
import org.dromara.system.service.ISysNoticeService;
import org.dromara.system.service.ISysTenantService;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 公告 服务层实现
 *
 * @author Lion Li
 */
@Slf4j
@RequiredArgsConstructor
@Service
public class SysNoticeServiceImpl implements ISysNoticeService {

    /**
     * 发送对象: 本租户
     */
    public static final String SCOPE_TENANT = "0";

    /**
     * 发送对象: 全体租户
     */
    public static final String SCOPE_ALL = "1";

    /**
     * SSE提醒消息类型标识: 通知公告刷新(前端据此重拉Redis列表并弹窗提醒)
     */
    private static final String NOTICE_SSE_TYPE = "notice";

    /**
     * 用户消息列表 redis key 前缀, 完整key: GLOBAL:NOTICE_MSG:{tenantId}:{userId}
     */
    private static final String NOTICE_MSG_KEY = GlobalConstants.GLOBAL_REDIS_KEY + "NOTICE_MSG:";

    /**
     * 公告已读集合 redis key 前缀, 完整key: GLOBAL:NOTICE_READ:{noticeId}, member: {tenantId}:{userId}
     */
    private static final String NOTICE_READ_KEY = GlobalConstants.GLOBAL_REDIS_KEY + "NOTICE_READ:";

    /**
     * 消息与已读记录保留时长
     */
    private static final Duration NOTICE_EXPIRE = Duration.ofDays(30);

    /**
     * 启动全量同步锁 key, 防止多实例同时启动时重复同步导致消息重复
     */
    private static final String NOTICE_MSG_SYNC_LOCK_KEY = GlobalConstants.GLOBAL_REDIS_KEY + "NOTICE_MSG_SYNC_LOCK";

    private final SysNoticeMapper baseMapper;
    private final SysUserMapper userMapper;
    private final ISysTenantService tenantService;

    /**
     * 分页查询通知公告列表
     *
     * @param notice    查询条件
     * @param pageQuery 分页参数
     * @return 通知公告分页列表
     */
    @Override
    public TableDataInfo<SysNoticeVo> selectPageNoticeList(SysNoticeBo notice, PageQuery pageQuery) {
        LambdaQueryWrapper<SysNotice> lqw = buildQueryWrapper(notice);
        Page<SysNoticeVo> page = baseMapper.selectVoPage(pageQuery.build(), lqw);
        fillReadCount(page.getRecords());
        return TableDataInfo.build(page);
    }

    /**
     * 查询公告信息
     *
     * @param noticeId 公告ID
     * @return 公告信息
     */
    @Override
    public SysNoticeVo selectNoticeById(String noticeId) {
        return baseMapper.selectVoById(noticeId);
    }

    /**
     * 查询公告列表
     *
     * @param notice 公告信息
     * @return 公告集合
     */
    @Override
    public List<SysNoticeVo> selectNoticeList(SysNoticeBo notice) {
        LambdaQueryWrapper<SysNotice> lqw = buildQueryWrapper(notice);
        return baseMapper.selectVoList(lqw);
    }

    private LambdaQueryWrapper<SysNotice> buildQueryWrapper(SysNoticeBo bo) {
        LambdaQueryWrapper<SysNotice> lqw = Wrappers.lambdaQuery();
        lqw.like(StringUtils.isNotBlank(bo.getNoticeTitle()), SysNotice::getNoticeTitle, bo.getNoticeTitle());
        lqw.eq(StringUtils.isNotBlank(bo.getNoticeType()), SysNotice::getNoticeType, bo.getNoticeType());
        if (StringUtils.isNotBlank(bo.getCreateByName())) {
            SysUserVo sysUser = userMapper.selectVoOne(new LambdaQueryWrapper<SysUser>().eq(SysUser::getUserName, bo.getCreateByName()));
            lqw.eq(SysNotice::getCreateBy, ObjectUtils.notNullGetter(sysUser, SysUserVo::getUserId));
        }
        lqw.orderByAsc(SysNotice::getNoticeId);
        return lqw;
    }

    /**
     * 新增公告并按发送对象投递到 Redis:
     * 本租户消息写入当前租户下全部用户的消息列表; 全体消息遍历所有正常租户投递。
     *
     * @param bo 公告信息
     * @return 结果
     */
    @Override
    public int insertNotice(SysNoticeBo bo) {
        // 发送对象只有超级管理员可发布全体, 其余用户一律强制本租户
        if (!LoginHelper.isSuperAdmin() || StringUtils.isBlank(bo.getScope())) {
            bo.setScope(SCOPE_TENANT);
        }
        SysNotice notice = MapstructUtils.convert(bo, SysNotice.class);
        int rows = baseMapper.insert(notice);
        if (rows > 0) {
            publishNoticeToRedis(notice);
        }
        return rows;
    }

    /**
     * 修改公告并同步Redis:
     * 状态改为关闭时将消息从所有目标用户的消息列表中移除并清空该通知的已读集合,
     * 其他内容的修改则以最新数据替换用户消息列表中的对应消息
     */
    @Override
    public int updateNotice(SysNoticeBo bo) {
        SysNotice notice = MapstructUtils.convert(bo, SysNotice.class);
        int rows = baseMapper.updateById(notice);
        if (rows > 0) {
            syncNoticeUpdateToRedis(notice.getNoticeId());
        }
        return rows;
    }

    /**
     * 删除公告对象: 先删除MySQL, 成功后再清理Redis中的消息与已读集合
     *
     * @param noticeId 公告ID
     * @return 结果
     */
    @Override
    public int deleteNoticeById(String noticeId) {
        return deleteNoticesWithRedis(Collections.singletonList(noticeId));
    }

    /**
     * 批量删除公告信息: 先删除MySQL, 成功后再逐条清理Redis
     *
     * @param noticeIds 需要删除的公告ID
     * @return 结果
     */
    @Override
    public int deleteNoticeByIds(String[] noticeIds) {
        return deleteNoticesWithRedis(Arrays.asList(noticeIds));
    }

    /**
     * 删除公告: 先删除MySQL, 删除成功后遍历目标用户的消息列表移除该消息并清空其已读集合
     */
    private int deleteNoticesWithRedis(List<String> noticeIds) {
        int rows = 0;
        for (String noticeId : noticeIds) {
            // 先取出公告定位受众(删除前查询), 再删库, 最后清Redis
            SysNotice notice = TenantHelper.ignore(() -> baseMapper.selectById(noticeId));
            int r = baseMapper.deleteById(noticeId);
            if (r > 0) {
                rows += r;
                removeNoticeFromRedis(notice);
            }
        }
        return rows;
    }

    /**
     * 查询当前登录用户的通知推送消息列表(从Redis获取)
     */
    @Override
    public List<SysNoticeVo> selectPushNoticeList() {
        String tenantId = currentTenantId();
        String userId = LoginHelper.getUserId();
        if (StringUtils.isBlank(userId)) {
            return Collections.emptyList();
        }
        List<SysNoticeVo> msgs = RedisUtils.getCacheList(NOTICE_MSG_KEY + tenantId + ":" + userId);
        if (msgs == null || msgs.isEmpty()) {
            return Collections.emptyList();
        }
        String member = readMember(tenantId, userId);
        for (SysNoticeVo msg : msgs) {
            msg.setIsRead(RedisUtils.containsCacheSet(NOTICE_READ_KEY + msg.getNoticeId(), member));
        }
        // 最新消息排在前面
        msgs.sort(Comparator.comparing(SysNoticeVo::getCreateTime, Comparator.nullsLast(Comparator.reverseOrder())));
        return msgs;
    }

    /**
     * 标记通知公告为已读(写入Redis已读集合 GLOBAL:NOTICE_READ:{noticeId})
     */
    @Override
    public int markNoticeRead(List<String> noticeIds) {
        if (noticeIds == null || noticeIds.isEmpty()) {
            return 0;
        }
        String member = readMember(currentTenantId(), LoginHelper.getUserId());
        for (String noticeId : noticeIds) {
            String readKey = NOTICE_READ_KEY + noticeId;
            RedisUtils.addCacheSet(readKey, member);
            RedisUtils.expire(readKey, NOTICE_EXPIRE);
        }
        return noticeIds.size();
    }

    /**
     * 将公告投递到用户消息列表并通过SSE提醒客户端。
     * 消息体直接存整条内容, 铃铛列表展示无需回查数据库
     */
    private void publishNoticeToRedis(SysNotice notice) {
        // 关闭状态的公告不下发
        if (SystemConstants.DISABLE.equals(notice.getStatus())) {
            return;
        }
        List<String> userIds = deliverToUsers(buildPushVo(notice), resolveTenantIds(notice));
        // SSE实时通知在线客户端刷新未读消息
        notifyUsersBySse(userIds, notice.getNoticeTitle());
    }

    /**
     * 构造投递的消息体, 提前翻译创建人昵称, 推送列表不再依赖翻译注解查库
     */
    private SysNoticeVo buildPushVo(SysNotice notice) {
        SysNoticeVo msg = MapstructUtils.convert(notice, SysNoticeVo.class);
        SysUserVo creator = userMapper.selectVoOne(new LambdaQueryWrapper<SysUser>().eq(SysUser::getUserId, notice.getCreateBy()));
        msg.setCreateByName(ObjectUtils.notNullGetter(creator, SysUserVo::getNickName));
        return msg;
    }

    /**
     * 解析公告的目标租户: 本租户消息取公告所属租户, 全体消息遍历所有正常状态租户
     */
    private List<String> resolveTenantIds(SysNotice notice) {
        List<String> tenantIds = new ArrayList<>();
        if (SCOPE_ALL.equals(notice.getScope())) {
            // 全体消息: 遍历所有正常状态租户
            SysTenantBo tenantBo = new SysTenantBo();
            tenantBo.setStatus(SystemConstants.NORMAL);
            List<SysTenantVo> tenants = TenantHelper.ignore(() -> tenantService.queryList(tenantBo));
            tenants.forEach(tenant -> tenantIds.add(tenant.getTenantId()));
        } else {
            String tenantId = StringUtils.isNotBlank(notice.getTenantId()) ? notice.getTenantId() : currentTenantId();
            tenantIds.add(tenantId);
        }
        return tenantIds;
    }

    /**
     * 将消息逐条写入目标租户下全部正常用户的消息列表, 返回实际投递的用户ID集合
     */
    private List<String> deliverToUsers(SysNoticeVo msg, List<String> tenantIds) {
        List<String> deliveredUserIds = new ArrayList<>();
        for (String tenantId : tenantIds) {
            for (String userId : loadTenantUserIds(tenantId)) {
                String key = NOTICE_MSG_KEY + tenantId + ":" + userId;
                RedisUtils.addCacheList(key, msg);
                RedisUtils.expire(key, NOTICE_EXPIRE);
                deliveredUserIds.add(userId);
            }
        }
        return deliveredUserIds;
    }

    /**
     * 加载指定租户下全部正常状态用户的ID列表(忽略租户插件)
     */
    private List<String> loadTenantUserIds(String tenantId) {
        return TenantHelper.ignore(() ->
            userMapper.selectList(new LambdaQueryWrapper<SysUser>()
                    .select(SysUser::getUserId)
                    .eq(SysUser::getTenantId, tenantId)
                    .eq(SysUser::getStatus, SystemConstants.NORMAL))
                .stream().map(SysUser::getUserId).toList());
    }

    /**
     * 修改公告后同步Redis到目标用户:
     * 先从每个目标用户的消息列表移除旧消息; 关闭状态不回写(等于删除),
     * 其他修改则以最新内容回写覆盖
     */
    private void syncNoticeUpdateToRedis(String noticeId) {
        SysNotice notice = TenantHelper.ignore(() -> baseMapper.selectById(noticeId));
        if (notice == null) {
            return;
        }
        boolean closed = SystemConstants.DISABLE.equals(notice.getStatus());
        SysNoticeVo msg = closed ? null : buildPushVo(notice);
        List<String> deliveredUserIds = new ArrayList<>();
        for (String tenantId : resolveTenantIds(notice)) {
            for (String userId : loadTenantUserIds(tenantId)) {
                String key = NOTICE_MSG_KEY + tenantId + ":" + userId;
                removeMessageFromUser(key, noticeId);
                if (!closed) {
                    RedisUtils.addCacheList(key, msg);
                    RedisUtils.expire(key, NOTICE_EXPIRE);
                    deliveredUserIds.add(userId);
                }
            }
        }
        if (closed) {
            // 公告关闭后同时清空该通知的已读集合
            RedisUtils.deleteObject(NOTICE_READ_KEY + noticeId);
        } else {
            // 修改内容或恢复为正常状态后SSE提醒在线客户端刷新未读消息
            notifyUsersBySse(deliveredUserIds, notice.getNoticeTitle());
        }
    }

    /**
     * 通过SSE向目标用户推送通知刷新提醒(JSON格式), 前端收到后自动从Redis重拉铃铛消息列表并弹窗提示。
     * 离线用户不在线连接、无影响, 下次登录自然从Redis读到未读消息
     */
    private void notifyUsersBySse(List<String> userIds, String noticeTitle) {
        if (!SseMessageUtils.isEnable() || CollUtil.isEmpty(userIds)) {
            return;
        }
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("type", NOTICE_SSE_TYPE);
        payload.put("title", noticeTitle);
        SseMessageDto dto = new SseMessageDto();
        dto.setMessage(JsonUtils.toJsonString(payload));
        dto.setUserIds(userIds);
        SseMessageUtils.publishMessage(dto);
    }

    /**
     * 从Redis中清除指定公告的所有痕迹: 目标用户消息列表中的消息 + 该通知的已读集合
     */
    private void removeNoticeFromRedis(SysNotice notice) {
        if (notice == null) {
            return;
        }
        for (String tenantId : resolveTenantIds(notice)) {
            for (String userId : loadTenantUserIds(tenantId)) {
                removeMessageFromUser(NOTICE_MSG_KEY + tenantId + ":" + userId, notice.getNoticeId());
            }
        }
        RedisUtils.deleteObject(NOTICE_READ_KEY + notice.getNoticeId());
    }

    /**
     * 从单个用户的消息列表中移除指定公告的消息。
     * 消息列表按用户维度整体存储, 只有确实发生变化时才重写列表, 减少并发冲突窗口
     */
    private void removeMessageFromUser(String key, String noticeId) {
        List<SysNoticeVo> msgs = RedisUtils.getCacheList(key);
        if (msgs == null || msgs.isEmpty()) {
            return;
        }
        List<SysNoticeVo> remain = msgs.stream()
            .filter(msg -> !noticeId.equals(msg.getNoticeId()))
            .toList();
        if (remain.size() != msgs.size()) {
            RedisUtils.deleteObject(key);
            if (!remain.isEmpty()) {
                RedisUtils.setCacheList(key, remain);
            }
        }
    }

    /**
     * 统计每条公告的已读/未读人数: 已读数 = 受众 ∩ Redis已读集合 的交集大小,
     * 未读数 = 受众总数 - 已读数。与已读人员明细接口使用同一套受众口径,
     * 全体消息的受众为所有租户的正常用户, 本租户消息仅统计当前租户
     */
    private void fillReadCount(List<SysNoticeVo> records) {
        if (records == null || records.isEmpty()) {
            return;
        }
        // 同页公告只可能来自当前租户, 受众用户一次加载复用
        Map<String, SysUser> allAudience = loadAudience(null);
        for (SysNoticeVo vo : records) {
            Set<String> members = RedisUtils.getCacheSet(NOTICE_READ_KEY + vo.getNoticeId());
            Map<String, SysUser> audience = SCOPE_ALL.equals(vo.getScope())
                ? allAudience : audienceOfTenant(allAudience, currentTenantId());
            long readCount = audience.keySet().stream().filter(members::contains).count();
            vo.setReadCount(readCount);
            vo.setUnreadCount(Math.max(audience.size() - readCount, 0L));
        }
    }

    /**
     * 加载受众用户(key为 {tenantId}:{userId}), tenantId为空时加载全部租户的正常状态用户
     */
    private Map<String, SysUser> loadAudience(String tenantId) {
        LambdaQueryWrapper<SysUser> lqw = new LambdaQueryWrapper<SysUser>()
            .select(SysUser::getTenantId, SysUser::getUserId, SysUser::getNickName)
            .eq(SysUser::getStatus, SystemConstants.NORMAL);
        if (StringUtils.isNotBlank(tenantId)) {
            lqw.eq(SysUser::getTenantId, tenantId);
        }
        List<SysUser> users = TenantHelper.ignore(() -> userMapper.selectList(lqw));
        Map<String, SysUser> audience = new LinkedHashMap<>();
        for (SysUser user : users) {
            audience.put(readMember(StringUtils.defaultString(user.getTenantId()), user.getUserId()), user);
        }
        return audience;
    }

    /**
     * 从全量受众中筛出指定租户的受众
     */
    private static Map<String, SysUser> audienceOfTenant(Map<String, SysUser> allAudience, String tenantId) {
        Map<String, SysUser> result = new LinkedHashMap<>();
        String prefix = tenantId + ":";
        allAudience.forEach((key, user) -> {
            if (key.startsWith(prefix)) {
                result.put(key, user);
            }
        });
        return result;
    }

    /**
     * 查询通知公告的已读/未读人员明细(区分租户, 显示租户名称与用户昵称)。
     * 受众口径与统计列一致: 正常状态用户, 全体消息为所有租户, 本租户消息为公告所属租户
     */
    @Override
    public NoticeReadListVo selectNoticeReadUsers(String noticeId) {
        NoticeReadListVo result = new NoticeReadListVo();
        result.setReadUsers(new ArrayList<>());
        result.setUnreadUsers(new ArrayList<>());
        SysNotice notice = TenantHelper.ignore(() -> baseMapper.selectById(noticeId));
        if (ObjectUtils.isNull(notice)) {
            return result;
        }
        boolean allScope = SCOPE_ALL.equals(notice.getScope());
        Map<String, SysUser> audience = loadAudience(allScope ? null
            : (StringUtils.isNotBlank(notice.getTenantId()) ? notice.getTenantId() : currentTenantId()));
        Set<String> members = RedisUtils.getCacheSet(NOTICE_READ_KEY + noticeId);

        Set<String> tenantIds = new HashSet<>();
        for (Map.Entry<String, SysUser> entry : audience.entrySet()) {
            String memberKey = entry.getKey();
            String tenantId = memberKey.split(":", 2)[0];
            NoticeReadListVo.ReadUserInfo info = new NoticeReadListVo.ReadUserInfo();
            info.setTenantId(tenantId);
            info.setNickName(entry.getValue().getNickName());
            if (members.contains(memberKey)) {
                result.getReadUsers().add(info);
            } else {
                result.getUnreadUsers().add(info);
            }
            tenantIds.add(tenantId);
        }

        // 填充租户名称(全体消息涉及多个租户)
        if (!tenantIds.isEmpty()) {
            SysTenantBo tenantBo = new SysTenantBo();
            tenantBo.setStatus(SystemConstants.NORMAL);
            Map<String, String> nameMap = new HashMap<>();
            TenantHelper.ignore(() -> tenantService.queryList(tenantBo))
                .stream()
                .filter(tenant -> tenantIds.contains(tenant.getTenantId()))
                .forEach(tenant -> nameMap.put(tenant.getTenantId(), ObjectUtils.notNullGetter(tenant, SysTenantVo::getCompanyName)));
            List<NoticeReadListVo.ReadUserInfo> allInfos = new ArrayList<>(result.getReadUsers());
            allInfos.addAll(result.getUnreadUsers());
            for (NoticeReadListVo.ReadUserInfo info : allInfos) {
                info.setTenantName(nameMap.getOrDefault(info.getTenantId(), info.getTenantId()));
            }
        }
        return result;
    }

    /**
     * 启动时比对MySQL与Redis: 若Redis中不存在任何用户消息列表
     * (如Redis被清空或数据丢失), 则将数据库中正常状态的公告按发布时间正序全量重新投递,
     * 避免用户消息因缓存丢失而消失
     */
    @Override
    public void syncNoticeMsgFromDb() {
        // Redis中还有用户消息列表则不做同步, 防止重复投递
        if (!RedisUtils.keys(NOTICE_MSG_KEY + "*").isEmpty()) {
            log.info("通知公告: Redis中已存在用户消息列表, 跳过MySQL同步");
            return;
        }
        // 抢占同步锁(自动过期), 多实例同时启动时只有一个实例执行同步
        boolean claimed = RedisUtils.setObjectIfAbsent(NOTICE_MSG_SYNC_LOCK_KEY, "1", Duration.ofMinutes(5));
        if (!claimed) {
            log.info("通知公告: 其他实例正在执行消息同步, 跳过");
            return;
        }
        List<SysNotice> notices = TenantHelper.ignore(() ->
            baseMapper.selectList(new LambdaQueryWrapper<SysNotice>()
                .eq(SysNotice::getStatus, SystemConstants.NORMAL)));
        // 按创建时间正序重建, 保证用户消息列表顺序与发布顺序一致
        notices.sort(Comparator.comparing(SysNotice::getCreateTime, Comparator.nullsLast(Comparator.naturalOrder())));
        for (SysNotice notice : notices) {
            deliverToUsers(buildPushVo(notice), resolveTenantIds(notice));
        }
        log.info("通知公告: MySQL同步到Redis完成, 共投递{}条公告", notices.size());
    }

    /**
     * 已读集合的 member: {tenantId}:{userId}, 不同租户的同名用户ID可区分
     */
    private static String readMember(String tenantId, String userId) {
        return tenantId + ":" + userId;
    }

    /**
     * 当前租户编号(未开启多租户时回退默认租户, 保证redis key稳定)
     */
    private static String currentTenantId() {
        String tenantId = TenantHelper.getTenantId();
        if (StringUtils.isBlank(tenantId)) {
            return TenantConstants.DEFAULT_TENANT_ID;
        }
        return tenantId;
    }
}
