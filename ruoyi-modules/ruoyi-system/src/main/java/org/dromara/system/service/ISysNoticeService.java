package org.dromara.system.service;

import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.system.domain.bo.SysNoticeBo;
import org.dromara.system.domain.vo.NoticeReadListVo;
import org.dromara.system.domain.vo.SysNoticeVo;

import java.util.List;

/**
 * 公告 服务层
 *
 * @author Lion Li
 */
public interface ISysNoticeService {

    /**
     * 分页查询通知公告列表
     *
     * @param notice    查询条件
     * @param pageQuery 分页参数
     * @return 通知公告分页列表
     */
    TableDataInfo<SysNoticeVo> selectPageNoticeList(SysNoticeBo notice, PageQuery pageQuery);

    /**
     * 查询公告信息
     *
     * @param noticeId 公告ID
     * @return 公告信息
     */
    SysNoticeVo selectNoticeById(String noticeId);

    /**
     * 查询公告列表
     *
     * @param notice 公告信息
     * @return 公告集合
     */
    List<SysNoticeVo> selectNoticeList(SysNoticeBo notice);

    /**
     * 新增公告
     *
     * @param bo 公告信息
     * @return 结果
     */
    int insertNotice(SysNoticeBo bo);

    /**
     * 修改公告
     *
     * @param bo 公告信息
     * @return 结果
     */
    int updateNotice(SysNoticeBo bo);

    /**
     * 删除公告信息
     *
     * @param noticeId 公告ID
     * @return 结果
     */
    int deleteNoticeById(String noticeId);

    /**
     * 批量删除公告信息
     *
     * @param noticeIds 需要删除的公告ID
     * @return 结果
     */
    int deleteNoticeByIds(String[] noticeIds);

    /**
     * 查询当前登录用户的通知推送消息列表(从Redis获取)
     *
     * @return 消息列表(新消息在前, 附带已读状态)
     */
    List<SysNoticeVo> selectPushNoticeList();

    /**
     * 标记通知公告为已读(写入Redis已读集合)
     *
     * @param noticeIds 公告ID集合
     * @return 标记条数
     */
    int markNoticeRead(List<String> noticeIds);

    /**
     * 启动时比对MySQL与Redis: Redis中无用户消息列表时, 将数据库中正常状态的公告全量同步到Redis
     */
    void syncNoticeMsgFromDb();

    /**
     * 查询通知公告的已读/未读人员明细(区分租户)
     *
     * @param noticeId 公告ID
     * @return 已读/未读人员列表
     */
    NoticeReadListVo selectNoticeReadUsers(String noticeId);
}
