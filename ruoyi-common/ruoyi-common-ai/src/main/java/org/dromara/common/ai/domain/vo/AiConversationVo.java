package org.dromara.common.ai.domain.vo;

import lombok.Data;

import java.util.Date;

/**
 * AI 会话视图对象
 *
 * @author ruoyi
 */
@Data
public class AiConversationVo {

    /**
     * 会话ID
     */
    private String conversationId;

    /**
     * 会话标题
     */
    private String title;

    /**
     * 创建时间
     */
    private Date createTime;

}
