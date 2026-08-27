/**
 * 首页数据文件
 * 所有静态数据均在此本地文件中维护，页面组件通过 import 直接引用
 */

export interface HomeLink {
  label: string;
  url: string;
}

export interface ProjectVO {
  id: number;
  name: string;
  description: string;
  version: string;
  features: string[];
  links: HomeLink[];
}

export type TechCategory = '前端' | '后端' | '中间件' | '数据库' | '部署' | '监控';

export interface TechItem {
  name: string;
  desc: string;
  icon: string;
  category: TechCategory;
}

export interface StatItem {
  title: string;
  value: number;
  suffix: string;
  icon: string;
  color: string;
}

export interface QuickLink {
  title: string;
  desc: string;
  icon: string;
  color: string;
  path: string;
  /** 访问该入口所需权限，为空则不做权限过滤 */
  permission?: string;
}

/** 时间段问候语配置，start 为起始小时（含） */
const greetings: Array<{ start: number; text: string }> = [
  { start: 5, text: '清晨好' },
  { start: 8, text: '早上好' },
  { start: 11, text: '上午好' },
  { start: 13, text: '中午好' },
  { start: 14, text: '下午好' },
  { start: 18, text: '傍晚好' },
  { start: 22, text: '夜深了' }
];

/** 根据当前小时获取问候语 */
export const getGreeting = (hour: number): string => {
  return [...greetings].reverse().find((item) => hour >= item.start)?.text ?? '你好';
};

/** 顶部数据概览卡片 */
export const stats: StatItem[] = [
  { title: '总访问量', value: 6281, suffix: '', icon: 'View', color: '#409eff' },
  { title: 'Star 数', value: 4000, suffix: '+', icon: 'Star', color: '#e6a23c' },
  { title: 'Fork 数', value: 1800, suffix: '+', icon: 'Share', color: '#67c23a' },
  { title: '贡献者', value: 120, suffix: '+', icon: 'User', color: '#f56c6c' }
];

/** 快捷导航入口（按用户权限动态显示） */
export const quickLinks: QuickLink[] = [
  { title: 'AI 对话', desc: '智能助手随时待命', icon: 'ChatDotRound', color: '#722ed1', path: '/ai/chat', permission: 'ai:chat:list' },
  { title: '用户管理', desc: '账号与角色分配', icon: 'User', color: '#409eff', path: '/system/user', permission: 'system:user:list' },
  { title: '角色管理', desc: '角色与菜单授权', icon: 'Avatar', color: '#67c23a', path: '/system/role', permission: 'system:role:list' },
  { title: '菜单管理', desc: '系统菜单配置', icon: 'Menu', color: '#e6a23c', path: '/system/menu', permission: 'system:menu:list' },
  { title: '代码生成', desc: '一键生成前后端代码', icon: 'MagicStick', color: '#f56c6c', path: '/tool/gen', permission: 'tool:gen:list' },
  { title: '缓存监控', desc: 'Redis 运行状态', icon: 'Cpu', color: '#13c2c2', path: '/monitor/cache', permission: 'monitor:cache:list' },
  { title: '在线用户', desc: '实时会话管理', icon: 'Headset', color: '#fa8c16', path: '/monitor/online', permission: 'monitor:online:list' },
  { title: '操作日志', desc: '系统操作留痕审计', icon: 'Document', color: '#52c41a', path: '/monitor/operlog', permission: 'monitor:operlog:list' },
  { title: '登录日志', desc: '登录行为记录查询', icon: 'Key', color: '#eb2f96', path: '/monitor/logininfor', permission: 'monitor:logininfor:list' },
  { title: '通知公告', desc: '平台消息发布', icon: 'Bell', color: '#2f54eb', path: '/system/notice', permission: 'system:notice:list' },
  { title: '参数设置', desc: '系统参数调优', icon: 'Setting', color: '#8b5cf6', path: '/system/config', permission: 'system:config:list' },
  { title: '字典管理', desc: '业务枚举统一维护', icon: 'Collection', color: '#36cfc9', path: '/system/dict', permission: 'system:dict:list' }
];

/** 项目列表 */
export const projects: ProjectVO[] = [
  {
    id: 1,
    name: 'RuoYi-Vue-Plus',
    version: 'v5.6.2',
    description: 'RuoYi-Vue-Plus 是基于 RuoYi-Vue 针对分布式集群场景升级（不兼容原框架）的后台权限管理系统',
    features: [
      '前端开发框架 Vue3、TS、Element Plus',
      '后端开发框架 Spring Boot',
      '容器框架 Undertow 基于 Netty 的高性能容器',
      '权限认证框架 Sa-Token 支持多终端认证系统',
      '关系数据库 MySQL 适配 8.X 最低 5.7',
      '缓存数据库 Redis 适配 6.X 最低 4.X',
      '数据库框架 Mybatis-Plus 快速 CRUD 增加开发效率',
      '多数据源框架 dynamic-datasource 支持主从与多种类数据库异构',
      '分布式限流 Redisson 全局、请求IP、集群ID 多种限流',
      '分布式锁 Lock4j 注解锁、工具锁 多种多样',
      '分布式链路追踪 SkyWalking 支持链路追踪、网格分析、度量聚合、可视化',
      '分布式任务调度 SnailJob 高性能 高可靠 易扩展',
      '文件存储 Minio 本地存储',
      '文件存储 七牛、阿里、腾讯 云存储',
      '监控框架 SpringBoot-Admin 全方位服务监控',
      'Excel框架 FastExcel(原Alibaba EasyExcel) 性能优异 扩展性强',
      '代码生成器 适配MP、SpringDoc规范化代码 一键生成前后端代码',
      '部署方式 Docker 容器编排 一键部署业务集群'
    ],
    links: [
      { label: '访问码云', url: 'https://gitee.com/dromara/RuoYi-Vue-Plus' },
      { label: '访问GitHub', url: 'https://github.com/dromara/RuoYi-Vue-Plus' },
      { label: '更新日志', url: 'https://plus-doc.dromara.org/#/ruoyi-vue-plus/changlog' }
    ]
  },
  {
    id: 2,
    name: 'RuoYi-Cloud-Plus',
    version: 'v2.6.2',
    description: 'RuoYi-Cloud-Plus 微服务通用权限管理系统 重写 RuoYi-Cloud 全方位升级（不兼容原框架）',
    features: [
      '微服务开发框架 Spring Cloud、Spring Cloud Alibaba',
      '容器框架 Undertow 基于 XNIO 的高性能容器',
      '权限认证框架 Sa-Token、Jwt 支持多终端认证系统',
      '关系数据库 MySQL 适配 8.X 最低 5.7',
      '关系数据库 Oracle 适配 11g 12c',
      '关系数据库 PostgreSQL 适配 13 14',
      '关系数据库 SQLServer 适配 2017 2019',
      '分布式注册中心 Alibaba Nacos 采用2.X 基于GRPC通信高性能',
      '分布式配置中心 Alibaba Nacos 采用2.X 基于GRPC通信高性能',
      '服务网关 Spring Cloud Gateway 响应式高性能网关',
      '负载均衡 Spring Cloud Loadbalancer 负载均衡处理',
      'RPC远程调用 Apache Dubbo 原生态使用体验、高性能',
      '分布式限流熔断 Alibaba Sentinel 无侵入、高扩展',
      '分布式事务 Alibaba Seata 无侵入、高扩展 支持 四种模式',
      '分布式消息队列 Apache Kafka 高性能高速度',
      '分布式消息队列 Apache RocketMQ 高可用功能多样',
      '分布式搜索引擎 ElasticSearch 业界知名',
      '分布式链路追踪 Apache SkyWalking 链路追踪、网格分析、度量聚合、可视化',
      '分布式监控 Prometheus、Grafana 全方位性能监控'
    ],
    links: [
      { label: '访问码云', url: 'https://gitee.com/dromara/RuoYi-Cloud-Plus' },
      { label: '访问GitHub', url: 'https://github.com/dromara/RuoYi-Cloud-Plus' },
      { label: '更新日志', url: 'https://plus-doc.dromara.org/#/ruoyi-cloud-plus/changlog' }
    ]
  }
];

/** 技术栈卡片 */
export const techStack: TechItem[] = [
  { name: 'Vue3', desc: '渐进式前端框架', icon: 'ElementPlus', category: '前端' },
  { name: 'TypeScript', desc: 'JavaScript 的超集', icon: 'Monitor', category: '前端' },
  { name: 'Element Plus', desc: '企业级 UI 组件库', icon: 'Box', category: '前端' },
  { name: 'Vite', desc: '下一代前端构建工具', icon: 'Lightning', category: '前端' },
  { name: 'Pinia', desc: 'Vue 生态状态管理', icon: 'DataLine', category: '前端' },
  { name: 'Vue Router', desc: 'Vue 官方路由', icon: 'Guide', category: '前端' },
  { name: 'Spring Boot', desc: '后端开发框架', icon: 'Cpu', category: '后端' },
  { name: 'Sa-Token', desc: '轻量级权限认证框架', icon: 'Key', category: '后端' },
  { name: 'Mybatis-Plus', desc: '快速 CRUD 开发增强', icon: 'Coin', category: '后端' },
  { name: 'Redis', desc: '高性能缓存数据库', icon: 'Connection', category: '中间件' },
  { name: 'Redisson', desc: 'Redis 客户端 性能强劲', icon: 'SetUp', category: '中间件' },
  { name: 'MySQL', desc: '关系数据库', icon: 'Coin', category: '数据库' },
  { name: 'Docker', desc: '容器编排 一键部署', icon: 'Platform', category: '部署' },
  { name: 'SkyWalking', desc: '分布式链路追踪', icon: 'Aim', category: '监控' }
];
