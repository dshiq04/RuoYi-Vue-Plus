/**
 * AI 会话
 */
export interface AiConversationVO {
  conversationId: string;
  title: string;
  createTime?: string;
}

/**
 * AI 历史消息
 */
export interface AiMessageVO {
  role: string;
  content: string;
  createTime?: string;
}

/**
 * AI 对话请求
 */
export interface AiChatForm {
  conversationId: string;
  content: string;
  imageIds?: string[];
}

/**
 * 知识库文件上传结果
 */
export interface AiFileUploadVO {
  fileName: string;
  chunkCount: number;
}

/**
 * 图片上传结果
 */
export interface AiImageUploadVO {
  imageId: string;
  fileName: string;
  mimeType: string;
}
