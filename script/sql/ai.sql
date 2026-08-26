-- ----------------------------
-- AI 智能对话模块 SQL (MySQL 主库)
-- 说明:
--   1. ai_conversation 会话表存储在业务主库 (MySQL)
--   2. 聊天记忆表 SPRING_AI_CHAT_MEMORY 与向量表 ai_vector_store
--      存储在 AI 专用 PostgreSQL (由 application.yml ai.datasource 配置, 自动初始化)
-- ----------------------------

-- ----------------------------
-- 会话表
-- ----------------------------
DROP TABLE IF EXISTS `ai_conversation`;
CREATE TABLE `ai_conversation` (
  `conversation_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '会话ID',
  `user_id`         varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '所属用户ID',
  `title`           varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '新的对话' COMMENT '会话标题',
  `tenant_id`       varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '000000' COMMENT '租户编号',
  `create_dept`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建部门',
  `create_by`       varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '创建者',
  `create_time`     datetime DEFAULT NULL COMMENT '创建时间',
  `update_by`       varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '更新者',
  `update_time`     datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`conversation_id`) USING BTREE,
  KEY `idx_ai_conversation_user` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC COMMENT='AI 会话表';

-- ----------------------------
-- 菜单: AI 助手目录 + AI 对话菜单 (幂等, 可重复执行)
-- ----------------------------
DELETE FROM `sys_role_menu` WHERE `menu_id` IN ('9000', '9001');
DELETE FROM `sys_menu` WHERE `menu_id` IN ('9000', '9001');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query_param`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('9000', 'AI 助手', '0', 9, 'ai', NULL, '', '1', '0', 'M', '0', '0', '', 'education', '103', '1', sysdate(), NULL, NULL, 'AI 助手目录');
INSERT INTO `sys_menu` (`menu_id`, `menu_name`, `parent_id`, `order_num`, `path`, `component`, `query_param`, `is_frame`, `is_cache`, `menu_type`, `visible`, `status`, `perms`, `icon`, `create_dept`, `create_by`, `create_time`, `update_by`, `update_time`, `remark`)
VALUES ('9001', 'AI 对话', '9000', 1, 'chat', 'ai/chat/index', '', '1', '0', 'C', '0', '0', 'ai:chat:list', 'message', '103', '1', sysdate(), NULL, NULL, 'AI 对话菜单');

-- 为角色授权 (超级管理员 admin 默认拥有所有菜单无需处理)
-- 已有角色授权示例 (role_id 替换为实际角色):
-- INSERT INTO `sys_role_menu` (`role_id`, `menu_id`) VALUES ('2090358936082690050', '9000'), ('2090358936082690050', '9001');
-- 或一键给 000000 租户下所有角色授权:
INSERT INTO `sys_role_menu` (`role_id`, `menu_id`)
SELECT r.`role_id`, m.`menu_id`
FROM `sys_role` r, `sys_menu` m
WHERE r.`tenant_id` = '000000' AND r.`del_flag` = '0'
  AND m.`menu_id` IN ('9000', '9001')
  AND NOT EXISTS (
    SELECT 1 FROM `sys_role_menu` rm
    WHERE rm.`role_id` = r.`role_id` AND rm.`menu_id` = m.`menu_id`
  );
