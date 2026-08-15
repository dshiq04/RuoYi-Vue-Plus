package org.dromara.system.controller.monitor;

import org.springframework.security.access.prepost.PreAuthorize;
import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.constant.CacheConstants;
import org.dromara.common.core.domain.R;
import org.dromara.common.core.domain.dto.UserOnlineDTO;
import org.dromara.common.core.utils.StreamUtils;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.common.satoken.utils.JwtUtils;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.common.web.core.BaseController;
import org.dromara.system.domain.SysUserOnline;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 在线用户监控
 *
 * @author Lion Li
 */
@RequiredArgsConstructor
@RestController
@RequestMapping("/monitor/online")
public class SysUserOnlineController extends BaseController {

    private final JwtUtils jwtUtils;

    /**
     * 获取在线用户监控列表
     *
     * @param ipaddr   IP地址
     * @param userName 用户名
     */
    @PreAuthorize("hasAuthority('monitor:online:list')")
    @GetMapping("/list")
    public TableDataInfo<SysUserOnline> list(String ipaddr, String userName) {
        // 获取所有未过期的 token
        Collection<String> keys = RedisUtils.keys(CacheConstants.ONLINE_TOKEN_KEY + "*");
        List<UserOnlineDTO> userOnlineDTOList = new ArrayList<>();
        for (String key : keys) {
            String token = StringUtils.substringAfterLast(key, ":");
            // 如果已经过期则跳过
            UserOnlineDTO onlineDTO = RedisUtils.getCacheObject(key);
            if (onlineDTO == null) {
                continue;
            }
            userOnlineDTOList.add(onlineDTO);
        }
        if (StringUtils.isNotEmpty(ipaddr) && StringUtils.isNotEmpty(userName)) {
            userOnlineDTOList = StreamUtils.filter(userOnlineDTOList, userOnline ->
                StringUtils.equals(ipaddr, userOnline.getIpaddr()) &&
                    StringUtils.equals(userName, userOnline.getUserName())
            );
        } else if (StringUtils.isNotEmpty(ipaddr)) {
            userOnlineDTOList = StreamUtils.filter(userOnlineDTOList, userOnline ->
                StringUtils.equals(ipaddr, userOnline.getIpaddr())
            );
        } else if (StringUtils.isNotEmpty(userName)) {
            userOnlineDTOList = StreamUtils.filter(userOnlineDTOList, userOnline ->
                StringUtils.equals(userName, userOnline.getUserName())
            );
        }
        Collections.reverse(userOnlineDTOList);
        userOnlineDTOList.removeAll(Collections.singleton(null));
        List<SysUserOnline> userOnlineList = BeanUtil.copyToList(userOnlineDTOList, SysUserOnline.class);
        return TableDataInfo.build(userOnlineList);
    }

    /**
     * 强退用户
     *
     * @param tokenId token值
     */
    @PreAuthorize("hasAuthority('monitor:online:forceLogout')")
    @Log(title = "在线用户", businessType = BusinessType.FORCE)
    @RepeatSubmit()
    @DeleteMapping("/{tokenId}")
    public R<Void> forceLogout(@PathVariable String tokenId) {
        try {
            forceLogoutToken(tokenId);
        } catch (Exception ignored) {
        }
        return R.ok();
    }

    /**
     * 获取当前用户登录在线设备
     */
    @GetMapping()
    public TableDataInfo<SysUserOnline> getInfo() {
        // 获取当前用户的所有在线token
        String username = LoginHelper.getUsername();
        Collection<String> keys = RedisUtils.keys(CacheConstants.ONLINE_TOKEN_KEY + "*");
        List<UserOnlineDTO> userOnlineDTOList = keys.stream()
            .map(key -> (UserOnlineDTO) RedisUtils.getCacheObject(key))
            .filter(dto -> dto != null && StringUtils.equals(username, dto.getUserName()))
            .collect(Collectors.toList());
        //复制和处理 SysUserOnline 对象列表
        Collections.reverse(userOnlineDTOList);
        userOnlineDTOList.removeAll(Collections.singleton(null));
        List<SysUserOnline> userOnlineList = BeanUtil.copyToList(userOnlineDTOList, SysUserOnline.class);
        return TableDataInfo.build(userOnlineList);
    }

    /**
     * 强退当前在线设备
     *
     * @param tokenId token值
     */
    @Log(title = "在线设备", businessType = BusinessType.FORCE)
    @RepeatSubmit()
    @DeleteMapping("/myself/{tokenId}")
    public R<Void> remove(@PathVariable("tokenId") String tokenId) {
        try {
            // 获取当前用户的所有在线token
            String username = LoginHelper.getUsername();
            Collection<String> keys = RedisUtils.keys(CacheConstants.ONLINE_TOKEN_KEY + "*");
            keys.stream()
                .map(key -> (UserOnlineDTO) RedisUtils.getCacheObject(key))
                .filter(dto -> dto != null && StringUtils.equals(username, dto.getUserName()) && StringUtils.equals(tokenId, dto.getTokenId()))
                .findFirst()
                .ifPresent(dto -> forceLogoutToken(tokenId));
        } catch (Exception ignored) {
        }
        return R.ok();
    }

    /**
     * 强退指定令牌
     * <p>
     * 如果该用户剩余的 ONLINE_TOKENS 只剩 1 个或者已经没有，则直接在 redis 删除该用户的
     * 全部 ONLINE_TOKENS 信息并将令牌注销；否则仅注销当前令牌。
     * </p>
     *
     * @param tokenId token值
     */
    private void forceLogoutToken(String tokenId) {
        Collection<String> keys = RedisUtils.keys(CacheConstants.ONLINE_TOKEN_KEY + "*");
        if (CollUtil.isEmpty(keys)) {
            // 没有任何在线记录 直接注销令牌
            jwtUtils.invalidateToken(tokenId);
            return;
        }
        String username = resolveUserName(keys, tokenId);
        // 统计该用户剩余的在线令牌数量
        long onlineCount = countOnlineToken(keys, username);
        if (onlineCount <= 1) {
            // 该用户的 ONLINE_TOKENS 只剩 1 个或没有 直接删除该用户的全部在线信息并注销令牌
            keys.stream()
                .map(key -> (UserOnlineDTO) RedisUtils.getCacheObject(key))
                .filter(dto -> dto != null && StringUtils.equals(username, dto.getUserName()))
                .forEach(dto -> {
                    RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + dto.getTokenId());
                    RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + dto.getTokenId());
                });
        } else {
            // 还有其他在线设备 仅注销当前令牌
            jwtUtils.invalidateToken(tokenId);
        }
    }

    /**
     * 定位令牌对应的用户名
     */
    private String resolveUserName(Collection<String> keys, String tokenId) {
        for (String key : keys) {
            UserOnlineDTO dto = RedisUtils.getCacheObject(key);
            if (dto != null && StringUtils.equals(tokenId, dto.getTokenId())) {
                return dto.getUserName();
            }
        }
        return null;
    }

    /**
     * 统计该用户剩余的在线令牌数量
     */
    private long countOnlineToken(Collection<String> keys, String username) {
        return keys.stream()
            .map(key -> (UserOnlineDTO) RedisUtils.getCacheObject(key))
            .filter(dto -> dto != null && StringUtils.equals(username, dto.getUserName()))
            .count();
    }

}
