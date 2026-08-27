import { getToken } from '@/utils/auth';
import { ElNotification } from 'element-plus';
import { useNoticeStore } from '@/store/modules/notice';

// 初始化
export const initSSE = (url: any) => {
  if (import.meta.env.VITE_APP_SSE === 'false') {
    return;
  }

  url = url + '?Authorization=Bearer ' + getToken() + '&clientid=' + import.meta.env.VITE_APP_CLIENT_ID;
  const { data, error } = useEventSource(url, [], {
    autoReconnect: {
      retries: 5,
      delay: 5000,
      onFailed() {
        console.log('Failed to connect after 5 retries');
      }
    }
  });

  watch(error, () => {
    console.log('SSE connection error:', error.value);
    error.value = null;
  });

  watch(data, () => {
    if (!data.value) return;
    // 后端通知公告的刷新提醒(JSON格式): 从Redis重拉消息列表,
    // 新出现的未读由store统一触发页面弹窗与浏览器系统通知
    let handled = false;
    if (data.value.startsWith('{')) {
      try {
        const msg = JSON.parse(data.value);
        if (msg && msg.type === 'notice') {
          handled = true;
          useNoticeStore().initNotices();
        }
      } catch {
        /* 非JSON文本按原逻辑处理 */
      }
    }
    if (!handled) {
      useNoticeStore().addNotice({
        message: data.value,
        read: false,
        time: new Date().toLocaleString()
      });
      ElNotification({
        title: '消息',
        message: data.value,
        type: 'success',
        duration: 3000
      });
    }
    data.value = null;
  });
};
