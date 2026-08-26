package org.dromara.common.ai.service;

import org.dromara.common.ai.domain.bo.AiChatBo;
import org.dromara.common.ai.domain.vo.AiConversationVo;
import org.dromara.common.ai.domain.vo.AiFileUploadVo;
import org.dromara.common.ai.domain.vo.AiImageUploadVo;
import org.dromara.common.ai.domain.vo.AiMessageVo;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;

/**
 * AI 对话 服务层
 *
 * @author ruoyi
 */
public interface IAiChatService {

    /**
     * 创建会话
     *
     * @param title 会话标题(可为空)
     * @return 会话信息
     */
    AiConversationVo createConversation(String title);

    /**
     * 当前用户的会话列表
     */
    List<AiConversationVo> listConversations();

    /**
     * 删除会话(同时清除会话记忆)
     */
    void deleteConversation(String conversationId);

    /**
     * 查询会话历史消息
     */
    List<AiMessageVo> historyMessages(String conversationId);

    /**
     * 流式对话
     */
    void chatStream(AiChatBo bo, SseEmitter emitter);

    /**
     * 上传知识库文件(PDF/DOCX) 解析并写入 pgvector 向量库
     */
    AiFileUploadVo uploadFile(MultipartFile file);

    /**
     * 上传图片 临时缓存 发送消息时构造多模态请求
     */
    AiImageUploadVo uploadImage(MultipartFile file);

}
