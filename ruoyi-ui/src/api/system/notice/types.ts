export interface NoticeVO extends BaseEntity {
  noticeId: number;
  noticeTitle: string;
  noticeType: string;
  noticeContent: string;
  status: string;
  scope: string;
  remark: string;
  createByName: string;
  /** 当前用户是否已读（推送消息列表接口返回） */
  isRead?: boolean;
  /** 已读人数（管理列表接口返回） */
  readCount?: number;
  /** 未读人数（管理列表接口返回） */
  unreadCount?: number;
}

export interface NoticeQuery extends PageQuery {
  noticeTitle: string;
  createByName: string;
  status: string;
  noticeType: string;
}

export interface NoticeForm {
  noticeId: number | string | undefined;
  noticeTitle: string;
  noticeType: string;
  noticeContent: string;
  status: string;
  scope: string;
  remark: string;
  createByName: string;
}
