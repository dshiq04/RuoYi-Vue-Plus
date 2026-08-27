import request from '@/utils/request';
import { NoticeForm, NoticeQuery, NoticeVO } from './types';
import { AxiosPromise } from 'axios';
// 查询公告列表
export function listNotice(query: NoticeQuery): AxiosPromise<NoticeVO[]> {
  return request({
    url: '/system/notice/list',
    method: 'get',
    params: query
  });
}

// 查询公告详细
export function getNotice(noticeId: string | number): AxiosPromise<NoticeVO> {
  return request({
    url: '/system/notice/' + noticeId,
    method: 'get'
  });
}

// 新增公告
export function addNotice(data: NoticeForm) {
  return request({
    url: '/system/notice',
    method: 'post',
    data: data
  });
}

// 修改公告
export function updateNotice(data: NoticeForm) {
  return request({
    url: '/system/notice',
    method: 'put',
    data: data
  });
}

// 删除公告
export function delNotice(noticeId: string | number | Array<string | number>) {
  return request({
    url: '/system/notice/' + noticeId,
    method: 'delete'
  });
}

// 获取当前用户的通知消息列表(Redis)
export function listPushNotice(): AxiosPromise<NoticeVO[]> {
  return request({
    url: '/system/notice/push/list',
    method: 'get'
  });
}

// 标记通知消息已读(写入Redis已读集合)
export function readPushNotice(noticeIds: Array<string | number>) {
  return request({
    url: '/system/notice/push/read',
    method: 'put',
    data: noticeIds
  });
}
