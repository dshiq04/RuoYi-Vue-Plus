package org.dromara.system.domain.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

/**
 * 通知公告已读/未读人员视图对象
 *
 * @author dromara
 */
@Data
public class NoticeReadListVo implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /**
     * 已读人员列表
     */
    private List<ReadUserInfo> readUsers;

    /**
     * 未读人员列表
     */
    private List<ReadUserInfo> unreadUsers;

    /**
     * 已读/未读人员信息
     */
    @Data
    public static class ReadUserInfo implements Serializable {

        @Serial
        private static final long serialVersionUID = 1L;

        /**
         * 租户编号
         */
        private String tenantId;

        /**
         * 租户名称
         */
        private String tenantName;

        /**
         * 用户昵称
         */
        private String nickName;
    }
}
