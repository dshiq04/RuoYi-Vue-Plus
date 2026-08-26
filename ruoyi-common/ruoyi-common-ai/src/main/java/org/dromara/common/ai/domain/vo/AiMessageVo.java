package org.dromara.common.ai.domain.vo;

import lombok.Data;

import java.util.Date;

/**
 * AI 历史消息视图对象
 *
 * @author ruoyi
 */
@Data
public class AiMessageVo {

    /**
     * 角色 user / assistant / system
     */
    private String role;

    /**
     * 消息内容
     */
    private String content;

    /**
     * 消息时间
     */
    private Date createTime;

}
