package org.dromara.common.ai.controller;

import lombok.RequiredArgsConstructor;
import org.dromara.common.ai.domain.bo.AiChatBo;
import org.dromara.common.ai.domain.vo.AiConversationVo;
import org.dromara.common.ai.domain.vo.AiFileUploadVo;
import org.dromara.common.ai.domain.vo.AiImageUploadVo;
import org.dromara.common.ai.domain.vo.AiMessageVo;
import org.dromara.common.ai.service.IAiChatService;
import org.dromara.common.core.domain.R;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;

/**
 * AI 智能对话
 * <p>
 * 仅在 ai.enabled=true 时注册 关闭开关时所有 AI 接口不可用且不影响系统启动
 *
 * @author ruoyi
 */
@Validated
@RestController
@RequestMapping("/ai/chat")
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "ai", name = "enabled", havingValue = "true")
public class AiChatController {

    private final IAiChatService aiChatService;

    /**
     * 创建会话
     */
    @PostMapping("/conversations")
    public R<AiConversationVo> createConversation(@RequestBody(required = false) Map<String, String> body) {
        String title = body == null ? null : body.get("title");
        return R.ok(aiChatService.createConversation(title));
    }

    /**
     * 当前用户的会话列表
     */
    @GetMapping("/conversations")
    public R<List<AiConversationVo>> listConversations() {
        return R.ok(aiChatService.listConversations());
    }

    /**
     * 删除会话
     */
    @DeleteMapping("/conversations/{conversationId}")
    public R<Void> deleteConversation(@PathVariable String conversationId) {
        aiChatService.deleteConversation(conversationId);
        return R.ok();
    }

    /**
     * 会话历史消息
     */
    @GetMapping("/conversations/{conversationId}/messages")
    public R<List<AiMessageVo>> historyMessages(@PathVariable String conversationId) {
        return R.ok(aiChatService.historyMessages(conversationId));
    }

    /**
     * 流式对话 (SSE)
     */
    @PostMapping(value = "/completions", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter completions(@Validated @RequestBody AiChatBo bo) {
        SseEmitter emitter = new SseEmitter(5 * 60 * 1000L);
        aiChatService.chatStream(bo, emitter);
        return emitter;
    }

    /**
     * 上传知识库文件 (pdf / docx) 解析后写入向量库
     */
    @PostMapping("/upload/file")
    public R<AiFileUploadVo> uploadFile(@RequestParam("file") MultipartFile file) {
        return R.ok(aiChatService.uploadFile(file));
    }

    /**
     * 上传图片 用于多模态对话
     */
    @PostMapping("/upload/image")
    public R<AiImageUploadVo> uploadImage(@RequestParam("file") MultipartFile file) {
        return R.ok(aiChatService.uploadImage(file));
    }

}
