import { defineStore } from 'pinia';
import { reactive } from 'vue';
import { ElNotification } from 'element-plus';
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

// 已知消息快照(key=noticeId, value="已读状态|标题|内容长度"):
// 只有快照发生变化的新未读才提醒——支持关闭后重新开启、修改内容再次触达;
// 无变化的重复拉取(打开面板/轮询)不会重复轰炸
const knownSnapshots = new Map<string, string>();

const buildSnapshot = (item: NoticeItem) => `${item.read ? 'r' : 'u'}:${item.title || ''}:${(item.content || '').length}`;

/**
 * 页面内提示(必然可见)
 */
const showPageTip = (unread: NoticeItem[]) => {
  const firstTitle = String(unread[0].title || unread[0].message);
  const multiple = unread.length > 1;
  ElNotification({
    title: multiple ? `您有 ${unread.length} 条未读通知公告` : '收到新的通知公告',
    message: multiple ? `「${firstTitle}」等` : firstTitle,
    type: 'success',
    duration: 4000
  });
};

/**
 * 浏览器系统级通知(仅当前面已授权时直接发送; 未授权时静默尝试申请, 下次生效)
 */
const showBrowserTip = (unread: NoticeItem[]) => {
  try {
    if (!('Notification' in window)) {
      return;
    }
    if (Notification.permission === 'default') {
      void Notification.requestPermission();
    }
    if (Notification.permission !== 'granted') {
      return;
    }
    const firstTitle = String(unread[0].title || unread[0].message);
    const body = unread.length > 1 ? `「${firstTitle}」等 ${unread.length} 条未读公告` : `「${firstTitle}」`;
    new Notification('RuoYi-Vue-Plus 通知公告', { body });
  } catch {
    /* 环境不支持时忽略 */
  }
};

export const useNoticeStore = defineStore('notice', () => {
  const state = reactive({
    notices: [] as NoticeItem[],
    loading: false
  });

  let requestInFlight = false;

  /**
   * 从后端Redis拉取当前用户的消息列表(登录/刷新/打开通知面板时调用)。
   * 拉取后检测新出现的未读消息, 通过页面弹窗与浏览器系统通知提醒用户
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
      console.debug('[notice] 拉取消息:', rows.length, '条');
      state.notices = rows.map((row): NoticeItem => ({
        noticeId: String(row.noticeId),
        title: row.noticeTitle,
        content: row.noticeContent,
        type: row.noticeType,
        message: row.noticeTitle,
        read: !!row.isRead,
        time: parseTime(row.createTime, '{y}-{m}-{d} {h}:{i}:{s}') ?? ''
      }));
      // 找出快照发生变化(新出现/重新开启/内容被修改)的未读消息并提醒;
      // 登录/刷新后的首次拉取全部未知快照, 未读即视为新到达
      const freshUnread = state.notices.filter((item) => !item.read && item.noticeId && knownSnapshots.get(item.noticeId) !== buildSnapshot(item));
      // 同步现存消息快照, 并清理已从列表消失的消息
      //(公告被关闭下架后清掉记录, 重新开启时能再次触发提醒)
      const aliveIds = new Set(state.notices.map((item) => item.noticeId));
      for (const id of Array.from(knownSnapshots.keys())) {
        if (!aliveIds.has(id)) {
          knownSnapshots.delete(id);
        }
      }
      state.notices.forEach((item) => {
        if (item.noticeId) {
          knownSnapshots.set(item.noticeId, buildSnapshot(item));
        }
      });
      if (freshUnread.length > 0) {
        console.debug('[notice] 本次新增未读:', freshUnread.length);
        showPageTip(freshUnread);
        showBrowserTip(freshUnread);
      }
    } catch (error) {
      // 失败可见化: 控制台输出原因(接口404/超时等), 便于排查为何没有提示
      console.error('[notice] 获取消息失败:', error);
    } finally {
      state.loading = false;
      requestInFlight = false;
    }
  };

  // 追加一条实时推送消息(SSE/WebSocket纯文本), 新消息排在前面
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
