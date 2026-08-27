import { defineStore } from 'pinia';
import { reactive } from 'vue';
import { listPushNotice, readPushNotice } from '@/api/system/notice';
import { parseTime } from '@/utils/ruoyi';

export interface NoticeItem {
  noticeId?: string;
  title?: string;
  content?: string;
  type?: string;
  /** 列表项展示文本(公告标题), 兼容SSE/WebSocket推送的纯文本消息 */
  message: any;
  read: boolean;
  time: string;
}

export const useNoticeStore = defineStore('notice', () => {
  const state = reactive({
    notices: [] as NoticeItem[],
    loading: false
  });

  let requestInFlight = false;

  /**
   * 从后端Redis拉取当前用户的消息列表(登录/刷新/打开通知面板时调用)
   */
  const initNotices = async () => {
    if (requestInFlight) {
      return;
    }
    requestInFlight = true;
    state.loading = true;
    try {
      const res = await listPushNotice();
      const rows = res.data ?? [];
      state.notices = rows.map((row): NoticeItem => ({
        noticeId: String(row.noticeId),
        title: row.noticeTitle,
        content: row.noticeContent,
        type: row.noticeType,
        message: row.noticeTitle,
        read: !!row.isRead,
        time: parseTime(row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') ?? ''
      }));
    } finally {
      state.loading = false;
      requestInFlight = false;
    }
  };

  // 追加一条实时推送消息(SSE/WebSocket), 新消息排在前面
  const addNotice = (notice: NoticeItem) => {
    state.notices.unshift(notice);
  };

  const removeNotice = (notice: NoticeItem) => {
    state.notices.splice(state.notices.indexOf(notice), 1);
  };

  /**
   * 全部已读: 未读的写入Redis已读集合, 并更新本地状态
   */
  const readAll = async () => {
    const unreadIds = state.notices.filter((item) => !item.read && item.noticeId).map((item) => item.noticeId!);
    if (unreadIds.length > 0) {
      try {
        await readPushNotice(unreadIds);
      } catch (error) {
        console.error('标记全部已读失败', error);
      }
    }
    state.notices.forEach((item: NoticeItem) => {
      item.read = true;
    });
  };

  /**
   * 单条已读: 写入Redis已读集合并更新本地状态
   */
  const markRead = async (noticeId: string) => {
    await readPushNotice([noticeId]);
    const item = state.notices.find((n) => n.noticeId === noticeId);
    if (item) {
      item.read = true;
    }
  };

  const clearNotice = () => {
    state.notices = [];
  };
  return {
    state,
    initNotices,
    addNotice,
    removeNotice,
    readAll,
    markRead,
    clearNotice
  };
});
