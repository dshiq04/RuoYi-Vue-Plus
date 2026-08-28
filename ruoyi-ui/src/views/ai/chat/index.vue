<template>
  <div class="ai-chat">
    <!-- AI 功能关闭提示页 -->
    <el-result
      v-if="aiDisabled"
      class="disabled-result"
      icon="error"
      title="AI 功能已关闭"
      :sub-title="aiDisabledMsg"
    >
      <template #extra>
        <el-button type="primary" @click="init">刷新状态</el-button>
      </template>
    </el-result>
    <template v-else>
    <!-- 左侧会话列表 -->
    <el-card class="conversation-panel" shadow="never">
      <template #header>
        <div class="panel-header">
          <span>会话列表</span>
          <el-button type="primary" size="small" :icon="Plus" @click="handleCreateConversation">新建</el-button>
        </div>
      </template>
      <el-scrollbar class="conversation-list">
        <div
          v-for="item in conversations"
          :key="item.conversationId"
          class="conversation-item"
          :class="{ active: item.conversationId === currentId }"
          @click="handleSelect(item)"
        >
          <span class="title">{{ item.title }}</span>
          <el-icon class="delete" @click.stop="handleDeleteConversation(item)"><Delete /></el-icon>
        </div>
        <el-empty v-if="!conversations.length" description="暂无会话，点击新建开始" :image-size="60" />
      </el-scrollbar>
    </el-card>

    <!-- 右侧对话区 -->
    <el-card class="chat-panel" shadow="never">
      <el-scrollbar v-if="currentId" ref="scrollbarRef" class="message-area">
        <div class="message-list">
          <div v-for="(msg, index) in messages" :key="index" class="message-row" :class="msg.role">
            <div class="bubble">
              <div v-if="msg.images && msg.images.length" class="images">
                <el-image
                  v-for="(url, i) in msg.images"
                  :key="i"
                  :src="url"
                  fit="cover"
                  class="image"
                  :preview-src-list="msg.images"
                  :initial-index="i"
                />
              </div>
              <div class="content" v-html="renderMarkdown(msg.content)"></div>
              <div v-if="msg.role === 'assistant' && sending && index === messages.length - 1 && !msg.content" class="typing">AI 正在思考...</div>
            </div>
          </div>
        </div>
      </el-scrollbar>
      <el-empty v-else class="message-area" description="请在左侧新建或选择会话开始对话" />

      <div class="input-area">
        <div v-if="enableUpload && pendingImages.length" class="image-preview">
          <div v-for="img in pendingImages" :key="img.imageId" class="preview-item">
            <el-image :src="img.url" fit="cover" />
            <el-icon class="remove" @click="removePendingImage(img)"><CircleClose /></el-icon>
          </div>
        </div>
        <el-input
          v-model="input"
          type="textarea"
          :rows="3"
          resize="none"
          placeholder="请输入问题，Ctrl+Enter 发送"
          @keydown="handleKeydown"
        />
        <div class="toolbar">
          <input
            ref="imageInputRef"
            type="file"
            accept="image/jpeg,image/png,image/gif,image/webp"
            style="display: none"
            @change="handleImageChange"
          />
          <input ref="fileInputRef" type="file" accept=".pdf,.docx" style="display: none" @change="handleFileChange" />
          <!-- 附件上传暂时关闭 需要时可将 enableUpload 改为 true 恢复 -->
          <el-button v-if="enableUpload" size="small" :icon="Picture" :loading="imageUploading" @click="imageInputRef?.click()">上传图片</el-button>
          <el-button v-if="enableUpload" size="small" :icon="FolderAdd" :loading="fileUploading" @click="fileInputRef?.click()">上传知识库文件</el-button>
          <div class="flex-grow"></div>
          <el-button v-if="sending" size="small" type="danger" :icon="VideoPause" @click="stopStream">停止</el-button>
          <el-button
            v-else
            size="small"
            type="primary"
            :icon="Promotion"
            :disabled="!currentId || !input.trim()"
            @click="handleSend"
          >发送</el-button>
        </div>
      </div>
    </el-card>
    </template>
  </div>
</template>

<script setup lang="ts" name="AiChat">
import { ref, reactive, nextTick } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Plus, Delete, Picture, FolderAdd, Promotion, VideoPause, CircleClose } from '@element-plus/icons-vue';
import {
  createConversation,
  listConversations,
  delConversation,
  listMessages,
  uploadImage,
  uploadKnowledgeFile,
  streamChat,
  getAiStatus
} from '@/api/ai/chat';
import { AiConversationVO } from '@/api/ai/chat/types';

interface MsgItem {
  role: 'user' | 'assistant';
  content: string;
  images?: string[];
}

interface PendingImage {
  imageId: string;
  fileName: string;
  url: string;
}

const conversations = ref<AiConversationVO[]>([]);
const currentId = ref('');
const messages = ref<MsgItem[]>([]);
const input = ref('');
const sending = ref(false);
const imageUploading = ref(false);
const fileUploading = ref(false);
const pendingImages = ref<PendingImage[]>([]);
const scrollbarRef = ref<any>(null);
const imageInputRef = ref<HTMLInputElement>();
const fileInputRef = ref<HTMLInputElement>();
// 附件上传总开关 (暂时关闭)
const enableUpload = ref(false);
// AI 功能关闭状态 (后端 application.yml -> ai.enabled = false)
const aiDisabled = ref(false);
const aiDisabledMsg = ref('');
let abortFn: (() => void) | null = null;

/** HTML 转义 */
function escapeHtml(text: string): string {
  return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

/** 轻量 Markdown 渲染: 代码块、行内代码、加粗, 其余保留原文换行 */
function renderMarkdown(text: string): string {
  if (!text) {
    return '';
  }
  let html = escapeHtml(text);
  html = html.replace(/```(\w*)\n([\s\S]*?)```/g, '<pre class="md-code-block"><code>$2</code></pre>');
  html = html.replace(/`([^`\n]+)`/g, '<code class="md-code">$1</code>');
  html = html.replace(/\*\*([^*\n]+)\*\*/g, '<strong>$1</strong>');
  return html;
}

/** 滚动到底部 */
function scrollToBottom() {
  nextTick(() => {
    scrollbarRef.value?.setScrollTop(999999);
  });
}

/** 加载会话列表 */
async function loadConversations() {
  const res = await listConversations();
  conversations.value = res.data;
}

/** 新建会话 */
async function handleCreateConversation() {
  const res = await createConversation();
  await loadConversations();
  handleSelect(res.data);
}

/** 选中会话并加载历史消息 */
async function handleSelect(item: AiConversationVO) {
  if (sending.value) {
    stopStream();
  }
  currentId.value = item.conversationId;
  messages.value = [];
  const res = await listMessages(item.conversationId);
  messages.value = (res.data || []).map((m) => ({
    role: m.role === 'user' ? 'user' : 'assistant',
    content: m.content
  })) as MsgItem[];
  scrollToBottom();
}

/** 删除会话 */
async function handleDeleteConversation(item: AiConversationVO) {
  await ElMessageBox.confirm(`确定删除会话「${item.title}」吗？删除后历史记录不可恢复。`, '提示', { type: 'warning' });
  await delConversation(item.conversationId);
  if (currentId.value === item.conversationId) {
    currentId.value = '';
    messages.value = [];
  }
  await loadConversations();
}

/** 发送消息 (流式) */
async function handleSend() {
  const content = input.value.trim();
  if (!content || sending.value) {
    return;
  }
  let conversationId = currentId.value;
  // 未选中会话时自动创建
  if (!conversationId) {
    const res = await createConversation(content.length > 30 ? content.slice(0, 30) : content);
    conversationId = res.data.conversationId;
    currentId.value = conversationId;
    await loadConversations();
  }
  const images = pendingImages.value.map((i) => i.url);
  const imageIds = pendingImages.value.map((i) => i.imageId);
  messages.value.push({ role: 'user', content, images: images.length ? images : undefined });
  // 必须使用响应式代理对象 直接修改裸对象不会触发视图更新 导致流式内容无法实时渲染
  const assistantMsg = reactive<MsgItem>({ role: 'assistant', content: '' });
  messages.value.push(assistantMsg);
  input.value = '';
  pendingImages.value = [];
  sending.value = true;
  scrollToBottom();
  abortFn = streamChat(
    { conversationId, content, imageIds: imageIds.length ? imageIds : undefined },
    {
      onMessage: (chunk) => {
        assistantMsg.content += chunk;
        scrollToBottom();
      },
      onDone: () => {
        sending.value = false;
        abortFn = null;
        if (!assistantMsg.content) {
          assistantMsg.content = '（无回复内容）';
        }
        // 首条消息后端会自动生成标题, 刷新列表
        loadConversations();
        scrollToBottom();
      },
      onError: (msg) => {
        sending.value = false;
        abortFn = null;
        if (!assistantMsg.content) {
          messages.value.pop();
        }
        ElMessage.error(msg);
      }
    }
  );
}

/** 停止流式输出 */
function stopStream() {
  abortFn?.();
  abortFn = null;
  sending.value = false;
}

/** Ctrl+Enter 发送 */
function handleKeydown(e: KeyboardEvent) {
  if (e.ctrlKey && e.key === 'Enter') {
    handleSend();
  }
}

/** 选择图片上传 */
async function handleImageChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0];
  (e.target as HTMLInputElement).value = '';
  if (!file) {
    return;
  }
  imageUploading.value = true;
  try {
    const res = await uploadImage(file);
    pendingImages.value.push({
      imageId: res.data.imageId,
      fileName: res.data.fileName,
      url: URL.createObjectURL(file)
    });
    ElMessage.success('图片上传成功，发送消息时将一并提交');
  } finally {
    imageUploading.value = false;
  }
}

/** 移除待发送图片 */
function removePendingImage(img: PendingImage) {
  pendingImages.value = pendingImages.value.filter((i) => i.imageId !== img.imageId);
}

/** 选择知识库文件上传 (pdf / docx) */
async function handleFileChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0];
  (e.target as HTMLInputElement).value = '';
  if (!file) {
    return;
  }
  fileUploading.value = true;
  try {
    const res = await uploadKnowledgeFile(file);
    ElMessage.success(`文件「${res.data.fileName}」解析完成，共 ${res.data.chunkCount} 个分片写入知识库`);
  } finally {
    fileUploading.value = false;
  }
}

/** 检查 AI 功能状态, 关闭时抛出异常 */
async function checkAiStatus() {
  const res = await getAiStatus();
  if (res.data === false) {
    throw new Error('AI 功能已关闭，请等待再次开放');
  }
}

/** 页面初始化: 先校验 AI 功能状态, 开启时才加载会话列表 */
async function init() {
  aiDisabled.value = false;
  try {
    await checkAiStatus();
    await loadConversations();
  } catch (e: any) {
    aiDisabledMsg.value = e.message || 'AI 功能已关闭，请等待再次开放';
    aiDisabled.value = true;
    ElMessage.error(aiDisabledMsg.value);
  }
}

init();
</script>

<style lang="scss" scoped>
.ai-chat {
  display: flex;
  gap: 12px;
  height: calc(100vh - 100px);
  min-height: 480px;

  .disabled-result {
    width: 100%;
    margin: 0;
    align-self: center;
  }
}

.conversation-panel {
  width: 260px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;

  :deep(.el-card__body) {
    flex: 1;
    overflow: hidden;
    padding: 0;
  }

  .panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-weight: bold;
  }

  .conversation-list {
    height: 100%;
  }

  .conversation-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 14px;
    cursor: pointer;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .title {
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .delete {
      display: none;
      margin-left: 8px;
      color: var(--el-color-danger);
    }

    &:hover .delete {
      display: block;
    }

    &.active {
      background-color: var(--el-color-primary-light-9);
      color: var(--el-color-primary);
    }
  }
}

.chat-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;

  :deep(.el-card__body) {
    flex: 1;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    padding: 0;
  }

  .message-area {
    flex: 1;
  }

  .message-list {
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .message-row {
    display: flex;

    &.user {
      justify-content: flex-end;

      .bubble {
        background-color: var(--el-color-primary-light-9);
        border-radius: 10px 10px 2px 10px;
      }
    }

    &.assistant {
      justify-content: flex-start;

      .bubble {
        background-color: var(--el-fill-color-light);
        border-radius: 10px 10px 10px 2px;
      }
    }

    .bubble {
      max-width: 75%;
      padding: 10px 14px;
      word-break: break-word;

      .images {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        margin-bottom: 6px;

        .image {
          width: 90px;
          height: 90px;
          border-radius: 6px;
        }
      }

      .content {
        white-space: pre-wrap;
        line-height: 1.6;
      }

      .typing {
        color: var(--el-text-color-secondary);
      }

      :deep(.md-code-block) {
        margin: 6px 0;
        padding: 10px;
        background-color: var(--el-fill-color-darker, #1e1e1e);
        color: #d4d4d4;
        border-radius: 6px;
        overflow-x: auto;
        white-space: pre;
        font-size: 13px;
      }

      :deep(.md-code) {
        padding: 1px 5px;
        background-color: var(--el-fill-color);
        border-radius: 4px;
        font-size: 13px;
      }
    }
  }

  .input-area {
    border-top: 1px solid var(--el-border-color-lighter);
    padding: 12px 16px;

    .image-preview {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-bottom: 8px;

      .preview-item {
        position: relative;
        width: 60px;
        height: 60px;

        .el-image {
          width: 100%;
          height: 100%;
          border-radius: 6px;
        }

        .remove {
          position: absolute;
          top: -6px;
          right: -6px;
          font-size: 16px;
          color: var(--el-color-danger);
          cursor: pointer;
          background-color: var(--el-bg-color);
          border-radius: 50%;
        }
      }
    }

    .toolbar {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-top: 8px;

      .flex-grow {
        flex: 1;
      }
    }
  }
}
</style>
