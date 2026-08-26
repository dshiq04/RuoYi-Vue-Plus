package org.dromara.common.ai.service.impl;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.ai.config.AiProperties;
import org.dromara.common.ai.core.AiImageStore;
import org.dromara.common.ai.domain.AiConversation;
import org.dromara.common.ai.domain.bo.AiChatBo;
import org.dromara.common.ai.domain.vo.AiConversationVo;
import org.dromara.common.ai.domain.vo.AiFileUploadVo;
import org.dromara.common.ai.domain.vo.AiImageUploadVo;
import org.dromara.common.ai.domain.vo.AiMessageVo;
import org.dromara.common.ai.mapper.AiConversationMapper;
import org.dromara.common.ai.service.IAiChatService;
import org.dromara.common.ai.utils.AiFileParseUtils;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.satoken.utils.LoginHelper;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.repository.jdbc.JdbcChatMemoryRepository;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.MessageType;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.content.Media;
import org.springframework.ai.document.Document;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.filter.FilterExpressionBuilder;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * AI 对话 服务实现
 * <p>
 * 会话按用户隔离: 会话归属校验 + 会话ID由服务端生成
 * 对话记忆存储于 PostgreSQL (spring-ai chat-memory jdbc)
 * 知识库文档存储于 PostgreSQL pgvector 检索时按用户过滤
 *
 * @author ruoyi
 */
@Slf4j
@Service
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "ai", name = "enabled", havingValue = "true")
public class AiChatServiceImpl implements IAiChatService {

    /**
     * 知识库检索结果注入的系统提示词
     */
    private static final String RAG_SYSTEM_PROMPT = """
        你是一个企业知识库助手。请优先根据下方提供的参考资料回答用户问题。
        如果参考资料中没有相关内容, 请基于你自身的知识回答, 并说明资料中未涉及。
        参考资料:
        """;

    /**
     * 文本分片长度
     */
    private static final int CHUNK_SIZE = 800;

    /**
     * 文本分片重叠长度
     */
    private static final int CHUNK_OVERLAP = 100;

    private static final List<String> ALLOWED_IMAGE_TYPES = List.of("image/jpeg", "image/png", "image/gif", "image/webp");

    private final AiConversationMapper conversationMapper;
    private final ChatClient aiChatClient;
    private final ChatMemory aiChatMemory;
    private final VectorStore aiVectorStore;
    private final AiImageStore aiImageStore;
    private final AiProperties aiProperties;

    @Override
    public AiConversationVo createConversation(String title) {
        AiConversation conversation = new AiConversation();
        conversation.setConversationId(IdUtil.getSnowflakeNextIdStr());
        conversation.setUserId(LoginHelper.getUserId());
        conversation.setTitle(StringUtils.isBlank(title) ? "新的对话" : title);
        conversationMapper.insert(conversation);
        return conversationMapper.selectVoById(conversation.getConversationId());
    }

    @Override
    public List<AiConversationVo> listConversations() {
        LambdaQueryWrapper<AiConversation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(AiConversation::getUserId, LoginHelper.getUserId())
            .orderByDesc(AiConversation::getCreateTime);
        return conversationMapper.selectVoList(wrapper);
    }

    @Override
    public void deleteConversation(String conversationId) {
        AiConversation conversation = checkOwnership(conversationId);
        conversationMapper.deleteById(conversation.getConversationId());
        // 清除会话记忆
        try {
            aiChatMemory.clear(conversationId);
        } catch (Exception e) {
            log.warn("清除会话记忆失败: {}", conversationId, e);
        }
    }

    @Override
    public List<AiMessageVo> historyMessages(String conversationId) {
        checkOwnership(conversationId);
        List<Message> messages = aiChatMemory.get(conversationId);
        List<AiMessageVo> result = new ArrayList<>();
        for (Message message : messages) {
            // 过滤系统提示词 仅展示用户与助手消息
            if (MessageType.SYSTEM.equals(message.getMessageType())) {
                continue;
            }
            AiMessageVo vo = new AiMessageVo();
            vo.setRole(message.getMessageType().getValue());
            vo.setContent(message.getText());
            Object ts = message.getMetadata().get(JdbcChatMemoryRepository.CONVERSATION_TS);
            if (ts instanceof Instant instant) {
                vo.setCreateTime(Date.from(instant));
            }
            result.add(vo);
        }
        return result;
    }

    @Override
    public void chatStream(AiChatBo bo, SseEmitter emitter) {
        AiConversation conversation = checkOwnership(bo.getConversationId());
        String conversationId = conversation.getConversationId();

        // 组装消息: 历史记忆 + 知识库检索上下文 + 当前用户消息
        List<Message> messages = new ArrayList<>(aiChatMemory.get(conversationId));
        String ragContext = retrieveContext(bo.getContent());
        if (StringUtils.isNotBlank(ragContext)) {
            messages.add(new SystemMessage(RAG_SYSTEM_PROMPT + ragContext));
        }
        List<Media> medias = aiImageStore.take(bo.getImageIds());
        UserMessage userMessage = medias.isEmpty()
            ? new UserMessage(bo.getContent())
            : UserMessage.builder().text(bo.getContent()).media(medias).build();
        messages.add(userMessage);

        StringBuilder fullContent = new StringBuilder();
        boolean firstMessage = CollUtil.isEmpty(aiChatMemory.get(conversationId));
        aiChatClient.prompt()
            .messages(messages)
            .stream()
            .content()
            .doOnNext(chunk -> {
                fullContent.append(chunk);
                sendData(emitter, chunk);
            })
            .doOnComplete(() -> {
                // 保存会话记忆: 用户消息(图片以占位符记录)与助手完整回复
                String memoryText = medias.isEmpty() ? bo.getContent() : "[图片] " + bo.getContent();
                aiChatMemory.add(conversationId, new UserMessage(memoryText));
                aiChatMemory.add(conversationId, new AssistantMessage(fullContent.toString()));
                // 首条消息自动生成会话标题
                if (firstMessage && "新的对话".equals(conversation.getTitle())) {
                    updateTitle(conversation, bo.getContent());
                }
                sendData(emitter, "[DONE]");
                emitter.complete();
            })
            .doOnError(e -> {
                log.error("AI 对话流式调用失败", e);
                sendError(emitter, "AI 服务调用失败: " + e.getMessage());
                emitter.complete();
            })
            .subscribe();
    }

    @Override
    public AiFileUploadVo uploadFile(MultipartFile file) {
        String fileName = file.getOriginalFilename();
        if (StringUtils.isBlank(fileName)) {
            throw new ServiceException("文件名不能为空");
        }
        String suffix = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
        String text;
        try {
            if ("pdf".equals(suffix)) {
                text = AiFileParseUtils.parsePdf(file.getBytes());
            } else if ("docx".equals(suffix)) {
                text = AiFileParseUtils.parseDocx(file.getBytes());
            } else {
                throw new ServiceException("仅支持 pdf、docx 格式的文件");
            }
        } catch (IOException e) {
            throw new ServiceException("文件读取失败");
        }
        if (StringUtils.isBlank(text)) {
            throw new ServiceException("文件未解析到任何文本内容");
        }
        // 分片并写入向量库 附带用户标识用于隔离检索
        List<String> chunks = AiFileParseUtils.split(text, CHUNK_SIZE, CHUNK_OVERLAP);
        List<Document> documents = new ArrayList<>(chunks.size());
        for (String chunk : chunks) {
            Map<String, Object> metadata = Map.of(
                "user_id", LoginHelper.getUserId(),
                "file_name", fileName
            );
            documents.add(new Document(chunk, metadata));
        }
        aiVectorStore.add(documents);
        log.info("用户[{}]上传文件[{}] 解析分片[{}]个并写入向量库", LoginHelper.getUserId(), fileName, chunks.size());
        AiFileUploadVo vo = new AiFileUploadVo();
        vo.setFileName(fileName);
        vo.setChunkCount(chunks.size());
        return vo;
    }

    @Override
    public AiImageUploadVo uploadImage(MultipartFile file) {
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_IMAGE_TYPES.contains(contentType)) {
            throw new ServiceException("仅支持 jpeg、png、gif、webp 格式的图片");
        }
        try {
            String imageId = aiImageStore.put(file.getBytes(), contentType, file.getOriginalFilename());
            AiImageUploadVo vo = new AiImageUploadVo();
            vo.setImageId(imageId);
            vo.setFileName(file.getOriginalFilename());
            vo.setMimeType(contentType);
            return vo;
        } catch (IOException e) {
            throw new ServiceException("图片读取失败");
        }
    }

    /**
     * 知识库相似度检索(仅检索当前用户上传的文档)
     */
    private String retrieveContext(String query) {
        try {
            FilterExpressionBuilder builder = new FilterExpressionBuilder();
            SearchRequest request = SearchRequest.builder()
                .query(query)
                .topK(aiProperties.getVector().getTopK())
                .filterExpression(builder.eq("user_id", LoginHelper.getUserId()).build())
                .build();
            List<Document> documents = aiVectorStore.similaritySearch(request);
            if (CollUtil.isEmpty(documents)) {
                return null;
            }
            StringBuilder sb = new StringBuilder();
            for (Document document : documents) {
                sb.append("【").append(document.getMetadata().get("file_name")).append("】\n")
                    .append(document.getText()).append("\n\n");
            }
            return sb.toString();
        } catch (Exception e) {
            log.warn("知识库检索失败, 跳过RAG上下文", e);
            return null;
        }
    }

    /**
     * 校验会话归属当前用户
     */
    private AiConversation checkOwnership(String conversationId) {
        AiConversation conversation = conversationMapper.selectById(conversationId);
        if (conversation == null || !Objects.equals(conversation.getUserId(), LoginHelper.getUserId())) {
            throw new ServiceException("会话不存在或无权访问");
        }
        return conversation;
    }

    /**
     * 首条消息更新会话标题
     */
    private void updateTitle(AiConversation conversation, String content) {
        try {
            AiConversation update = new AiConversation();
            update.setConversationId(conversation.getConversationId());
            update.setTitle(content.length() > 20 ? content.substring(0, 20) + "..." : content);
            conversationMapper.updateById(update);
        } catch (Exception e) {
            log.warn("更新会话标题失败", e);
        }
    }

    private void sendData(SseEmitter emitter, String data) {
        try {
            emitter.send(SseEmitter.event().data(data));
        } catch (IOException e) {
            log.warn("SSE 推送失败, 客户端可能已断开连接");
        }
    }

    private void sendError(SseEmitter emitter, String message) {
        try {
            emitter.send(SseEmitter.event().name("error").data(message));
        } catch (IOException e) {
            log.warn("SSE 错误推送失败, 客户端可能已断开连接");
        }
    }

}
