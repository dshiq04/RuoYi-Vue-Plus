-- ----------------------------
-- 超级管理员角色菜单权限初始化脚本
-- ----------------------------
-- 说明：
--   原项目中超级管理员(role_id=1)在代码层面通过通配符 *:*:* 跳过权限校验，
--   迁移到 Spring Security 后，hasAuthority 为精确匹配，不识别通配符，
--   导致管理员访问任何受 @PreAuthorize 保护的接口都会返回 403 Access Denied。
--
--   本脚本将 sys_menu 中的全部菜单分配给超级管理员角色(role_id=1)，
--   使其在数据库层面拥有完整的角色-菜单关联，保证数据状态正确。
--   （代码层面已在 SysPermissionServiceImpl 中让超级管理员加载全部菜单权限标识）
--
-- 使用方式：在已初始化 ry_vue_5.X.sql 的数据库上执行本脚本即可
-- ----------------------------

-- 1. 清理超级管理员角色的旧菜单关联（避免主键冲突）
delete from sys_role_menu where role_id = 1;

-- 2. 将所有菜单分配给超级管理员角色（动态获取，新增菜单后重跑本脚本即可生效）
insert into sys_role_menu (role_id, menu_id)
select 1, menu_id from sys_menu;
