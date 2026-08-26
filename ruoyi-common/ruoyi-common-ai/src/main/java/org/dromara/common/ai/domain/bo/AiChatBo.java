package org.dromara.common.ai.domain.bo;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;

/**
 * AI 对话请求业务对象
 *
 * @author ruoyi
 */
@Data
public class AiChatBo {

    /**
     * 会话ID
     */
    @NotBlank(message = "会话ID不能为空")
    private String conversationId;

    /**
     * 用户输入内容
     */
    @NotBlank(message = "消息内容不能为空")
    private String content;

    /**
     * 上传的图片ID列表(多模态)
     */
    private List<String> imageIds;

}
