package org.dromara.system.domain.vo;

import org.dromara.common.translation.annotation.Translation;
import org.dromara.common.translation.constant.TransConstant;
import org.dromara.system.domain.SysNotice;
import io.github.linpeilie.annotations.AutoMapper;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.Date;



/**
 * 通知公告视图对象 sys_notice
 *
 * @author Michelle.Chung
 */
@Data
@AutoMapper(target = SysNotice.class)
public class SysNoticeVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 公告ID
     */
    private String noticeId;

    /**
     * 公告标题
     */
    private String noticeTitle;

    /**
     * 公告类型（1通知 2公告）
     */
    private String noticeType;

    /**
     * 公告内容
     */
    private String noticeContent;

    /**
     * 公告状态（0正常 1关闭）
     */
    private String status;

    /**
     * 发送对象（0本租户 1全体租户）
     */
    private String scope;

    /**
     * 备注
     */
    private String remark;

    /**
     * 创建者
     */
    private String createBy;

    /**
     * 创建人名称
     */
    @Translation(type = TransConstant.USER_ID_TO_NAME, mapper = "createBy")
    private String createByName;

    /**
     * 创建时间
     */
    private Date createTime;

    /**
     * 当前用户是否已读（仅推送消息列表接口返回）
     */
    private Boolean isRead;

    /**
     * 已读人数（仅管理列表接口返回）
     */
    private Long readCount;

    /**
     * 未读人数（仅管理列表接口返回）
     */
    private Long unreadCount;

}
