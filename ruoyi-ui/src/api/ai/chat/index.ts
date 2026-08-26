import request, { globalHeaders } from '@/utils/request';
import { AxiosPromise } from 'axios';
import { AiChatForm, AiConversationVO, AiFileUploadVO, AiImageUploadVO, AiMessageVO } from './types';

/**
 * 创建会话
 */
export function createConversation(title?: string): AxiosPromise<AiConversationVO> {
  return request({
    url: '/ai/chat/conversations',
    method: 'post',
    data: { title }
  });
}

/**
 * 当前用户的会话列表
 */
export function listConversations(): AxiosPromise<AiConversationVO[]> {
  return request({
    url: '/ai/chat/conversations',
    method: 'get'
  });
}

/**
 * 删除会话
 */
export function delConversation(conversationId: string) {
  return request({
    url: '/ai/chat/conversations/' + conversationId,
    method: 'delete'
  });
}

/**
 * 会话历史消息
 */
export function listMessages(conversationId: string): AxiosPromise<AiMessageVO[]> {
  return request({
    url: '/ai/chat/conversations/' + conversationId + '/messages',
    method: 'get'
  });
}

/**
 * 上传知识库文件 (pdf / docx)
 */
export function uploadKnowledgeFile(file: File): AxiosPromise<AiFileUploadVO> {
  const formData = new FormData();
  formData.append('file', file);
  return request({
    url: '/ai/chat/upload/file',
    method: 'post',
    data: formData,
    headers: { repeatSubmit: false }
  });
}

/**
 * 上传图片 (多模态对话)
 */
export function uploadImage(file: File): AxiosPromise<AiImageUploadVO> {
  const formData = new FormData();
  formData.append('file', file);
  return request({
    url: '/ai/chat/upload/image',
    method: 'post',
    data: formData,
    headers: { repeatSubmit: false }
  });
}

export interface StreamChatHandlers {
  /** 收到一段流式文本 */
  onMessage: (chunk: string) => void;
  /** 流式输出完成 */
  onDone: () => void;
  /** 发生错误 */
  onError: (msg: string) => void;
}

/**
 * 流式对话 (SSE)
 * 使用原生 fetch 读取 ReadableStream, 逐事件解析后端 SseEmitter 输出
 *
 * @returns 中断函数 调用后终止流式输出
 */
export function streamChat(data: AiChatForm, handlers: StreamChatHandlers): () => void {
  const controller = new AbortController();
  fetch(import.meta.env.VITE_APP_BASE_API + '/ai/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...globalHeaders() },
    body: JSON.stringify(data),
    signal: controller.signal
  })
    .then(async (response) => {
      if (!response.ok || !response.body) {
        handlers.onError('请求失败: HTTP ' + response.status);
        return;
      }
      const reader = response.body.getReader();
      const decoder = new TextDecoder('utf-8');
      let buffer = '';
      // 按 SSE 事件块 (空行分隔) 逐块解析
      while (true) {
        const { done, value } = await reader.read();
        if (done) {
          break;
        }
        buffer += decoder.decode(value, { stream: true });
        const blocks = buffer.split('\n\n');
        buffer = blocks.pop() || '';
        for (const block of blocks) {
          if (!block.trim()) {
            continue;
          }
          let eventName = 'message';
          const dataLines: string[] = [];
          for (const line of block.split('\n')) {
            if (line.startsWith('event:')) {
              eventName = line.slice(6).trim();
            } else if (line.startsWith('data:')) {
              dataLines.push(line.slice(5).replace(/^ /, ''));
            }
          }
          const payload = dataLines.join('\n');
          if (eventName === 'error') {
            handlers.onError(payload || 'AI 服务异常');
            return;
          }
          if (payload === '[DONE]') {
            handlers.onDone();
            return;
          }
          if (payload) {
            handlers.onMessage(payload);
          }
        }
      }
      handlers.onDone();
    })
    .catch((e: Error) => {
      if (e.name !== 'AbortError') {
        handlers.onError(e.message || '网络异常');
      }
    });
  return () => controller.abort();
}
