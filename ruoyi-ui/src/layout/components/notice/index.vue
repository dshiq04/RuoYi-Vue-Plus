<template>
  <div class="layout-navbars-breadcrumb-user-news">
    <div class="head-box">
      <div class="head-box-title">通知公告</div>
      <div class="head-box-btn" @click="handleReadAll">全部已读</div>
    </div>
    <div v-loading="loading" class="content-box">
      <template v-if="newsList.length > 0">
        <div v-for="(v, k) in newsList" :key="v.noticeId || k" class="content-box-item" @click="onNewsClick(v)">
          <div class="item-conten">
            <div>{{ v.message }}</div>
            <div class="content-box-msg"></div>
            <div class="content-box-time">{{ v.time }}</div>
          </div>
          <!-- 已读/未读 -->
          <span v-if="v.read" class="el-tag el-tag--success el-tag--mini read">已读</span>
          <span v-else class="el-tag el-tag--danger el-tag--mini read">未读</span>
        </div>
      </template>
      <el-empty v-else :description="'消息为空'"></el-empty>
    </div>
    <div v-if="newsList.length > 0" class="foot-box" @click="onGoToGiteeClick">前往gitee</div>

    <!-- 消息内容弹窗 -->
    <el-dialog v-model="dialog.visible" :title="dialog.title || '通知公告'" width="520px" append-to-body>
      <div class="notice-detail">
        <div class="notice-detail-time">{{ dialog.time }}</div>
        <div class="notice-detail-content" v-html="dialog.content"></div>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" :disabled="dialog.read" @click="handleMarkRead">{{ dialog.read ? '已读' : '我 已 阅 读' }}</el-button>
          <el-button @click="dialog.visible = false">关 闭</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts" name="layoutBreadcrumbUserNews">
import { storeToRefs } from 'pinia';
import { useNoticeStore, NoticeItem } from '@/store/modules/notice';

const noticeStore = useNoticeStore();
const { state } = storeToRefs(noticeStore);

const newsList = computed(() => state.value.notices);
const loading = computed(() => state.value.loading);

// 消息内容弹窗
const dialog = reactive({
  visible: false,
  title: '',
  content: '',
  time: '',
  read: false,
  noticeId: ''
});

/**
 * 点击消息: 弹出消息内容
 */
const onNewsClick = (item: NoticeItem) => {
  dialog.title = item.title ?? '';
  dialog.content = item.content ?? '';
  dialog.time = item.time;
  dialog.read = item.read;
  dialog.noticeId = item.noticeId ?? '';
  dialog.visible = true;
};

/** 弹窗内点击已读按钮: 写入Redis已读集合 */
const handleMarkRead = async () => {
  if (!dialog.noticeId || dialog.read) return;
  try {
    await noticeStore.markRead(dialog.noticeId);
    dialog.read = true;
  } catch (error) {
    console.error('标记已读失败', error);
  }
};

/** 全部已读 */
const handleReadAll = () => {
  noticeStore.readAll();
};

// 前往通知中心点击
const onGoToGiteeClick = () => {
  window.open('https://gitee.com/dromara/RuoYi-Vue-Plus/tree/5.X/');
};

onMounted(() => {
  // 兜底刷新(登录守卫中已拉取过, 打开面板时Navbar会再触发)
  noticeStore.initNotices();
});
</script>

<style lang="scss" scoped>
.layout-navbars-breadcrumb-user-news {
  .head-box {
    display: flex;
    border-bottom: 1px solid var(--el-border-color-lighter);
    box-sizing: border-box;
    color: var(--el-text-color-primary);
    justify-content: space-between;
    height: 35px;
    align-items: center;
    .head-box-btn {
      color: var(--el-color-primary);
      font-size: 13px;
      cursor: pointer;
      opacity: 0.8;
      &:hover {
        opacity: 1;
      }
    }
  }
  .content-box {
    height: 300px;
    overflow: auto;
    font-size: 13px;
    .content-box-item {
      padding-top: 12px;
      display: flex;
      cursor: pointer;
      &:last-of-type {
        padding-bottom: 12px;
      }
      .content-box-msg {
        color: var(--el-text-color-secondary);
        margin-top: 5px;
        margin-bottom: 5px;
      }
      .content-box-time {
        color: var(--el-text-color-secondary);
      }
      .item-conten {
        width: 100%;
        display: flex;
        flex-direction: column;
      }
    }
  }
  .foot-box {
    height: 35px;
    color: var(--el-color-primary);
    font-size: 13px;
    cursor: pointer;
    opacity: 0.8;
    display: flex;
    align-items: center;
    justify-content: center;
    border-top: 1px solid var(--el-border-color-lighter);
    &:hover {
      opacity: 1;
    }
  }
  :deep(.el-empty__description p) {
    font-size: 13px;
  }

  .notice-detail {
    .notice-detail-time {
      color: var(--el-text-color-secondary);
      font-size: 12px;
      margin-bottom: 10px;
    }
    .notice-detail-content {
      max-height: 400px;
      overflow: auto;
      line-height: 1.7;
    }
  }
}
</style>
