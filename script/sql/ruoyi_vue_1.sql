/*
 Navicat Premium Dump SQL

 Source Server         : MySQL
 Source Server Type    : MySQL
 Source Server Version : 90701 (9.7.1)
 Source Host           : 192.168.150.10:3306
 Source Schema         : ruoyi_vue

 Target Server Type    : MySQL
 Target Server Version : 90701 (9.7.1)
 File Encoding         : 65001

 Date: 06/08/2026 12:40:37
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编号',
  `data_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '数据源名称',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------
INSERT INTO `gen_table` VALUES ('2083850298799267841', 'master', 'test_demo', '测试单表', NULL, NULL, 'TestDemo', 'crud', 'org.dromara.system', 'system', 'demo', '测试单', 'Lion Li', '0', '/', NULL, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02', NULL);

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '编号',
  `table_id` varchar(64) NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------
INSERT INTO `gen_table_column` VALUES ('2083846470339194881', '2083846469814906882', 'id', 'id', 'varchar', 'String', 'id', '1', '0', '1', NULL, '1', '1', NULL, 'EQ', 'input', '', 1, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470339194882', '2083846469814906882', 'tenant_id', '租户编号', 'varchar(20)', 'String', 'tenantId', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 2, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303745', '2083846469814906882', 'apply_code', '申请编号', 'varchar(50)', 'String', 'applyCode', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 3, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303746', '2083846469814906882', 'leave_type', '请假类型', 'varchar(255)', 'String', 'leaveType', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'select', '', 4, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303747', '2083846469814906882', 'start_date', '开始时间', 'datetime', 'Date', 'startDate', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'datetime', '', 5, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303748', '2083846469814906882', 'end_date', '结束时间', 'datetime', 'Date', 'endDate', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'datetime', '', 6, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303749', '2083846469814906882', 'leave_days', '请假天数', 'int', 'Long', 'leaveDays', '0', '0', '1', '1', '1', '1', '1', 'EQ', 'input', '', 7, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303750', '2083846469814906882', 'remark', '请假原因', 'varchar(255)', 'String', 'remark', '0', '0', '0', '1', '1', '1', NULL, 'EQ', 'input', '', 8, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303751', '2083846469814906882', 'status', '状态', 'varchar(255)', 'String', 'status', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'radio', '', 9, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303752', '2083846469814906882', 'create_dept', '创建部门', 'varchar', 'String', 'createDept', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 10, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303753', '2083846469814906882', 'create_by', '创建者', 'varchar', 'String', 'createBy', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 11, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303754', '2083846469814906882', 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'datetime', '', 12, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303755', '2083846469814906882', 'update_by', '更新者', 'varchar', 'String', 'updateBy', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 13, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846470406303756', '2083846469814906882', 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'datetime', '', 14, '103', '1', '2026-08-02 17:24:49', '1', '2026-08-02 17:24:49');
INSERT INTO `gen_table_column` VALUES ('2083846776271728642', '2083846775940378626', 'id', '主键', 'varchar', 'String', 'id', '1', '0', '1', NULL, '1', '1', NULL, 'EQ', 'input', '', 1, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776271728643', '2083846775940378626', 'tenant_id', '租户编号', 'varchar(20)', 'String', 'tenantId', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 2, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776271728644', '2083846775940378626', 'dept_id', '部门id', 'varchar', 'String', 'deptId', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 3, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837505', '2083846775940378626', 'user_id', '用户id', 'varchar', 'String', 'userId', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 4, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837506', '2083846775940378626', 'order_num', '排序号', 'int', 'Long', 'orderNum', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 5, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837507', '2083846775940378626', 'test_key', 'key键', 'varchar(255)', 'String', 'testKey', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 6, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837508', '2083846775940378626', 'value', '值', 'varchar(255)', 'String', 'value', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 7, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837509', '2083846775940378626', 'version', '版本', 'int', 'Long', 'version', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 8, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837510', '2083846775940378626', 'create_dept', '创建部门', 'varchar', 'String', 'createDept', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 9, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837511', '2083846775940378626', 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'datetime', '', 10, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837512', '2083846775940378626', 'create_by', '创建人', 'varchar', 'String', 'createBy', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 11, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837513', '2083846775940378626', 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'datetime', '', 12, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837514', '2083846775940378626', 'update_by', '更新人', 'varchar', 'String', 'updateBy', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 13, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083846776338837515', '2083846775940378626', 'del_flag', '删除标志', 'int', 'Long', 'delFlag', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 14, '103', '1', '2026-08-02 17:26:02', '1', '2026-08-02 17:26:02');
INSERT INTO `gen_table_column` VALUES ('2083850299533271042', '2083850298799267841', 'id', '主键', 'varchar', 'String', 'id', '1', '0', '1', NULL, '1', '1', NULL, 'EQ', 'input', '', 1, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299533271043', '2083850298799267841', 'tenant_id', '租户编号', 'varchar(20)', 'String', 'tenantId', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 2, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299533271044', '2083850298799267841', 'dept_id', '部门id', 'varchar', 'String', 'deptId', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 3, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299600379906', '2083850298799267841', 'user_id', '用户id', 'varchar', 'String', 'userId', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 4, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299600379907', '2083850298799267841', 'order_num', '排序号', 'int', 'Long', 'orderNum', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 5, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299600379908', '2083850298799267841', 'test_key', 'key键', 'varchar(255)', 'String', 'testKey', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 6, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299667488770', '2083850298799267841', 'value', '值', 'varchar(255)', 'String', 'value', '0', '0', '0', '1', '1', '1', '1', 'EQ', 'input', '', 7, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299667488771', '2083850298799267841', 'version', '版本', 'int', 'Long', 'version', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 8, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299667488772', '2083850298799267841', 'create_dept', '创建部门', 'varchar', 'String', 'createDept', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 9, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299667488773', '2083850298799267841', 'create_time', '创建时间', 'datetime', 'Date', 'createTime', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'datetime', '', 10, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299667488774', '2083850298799267841', 'create_by', '创建人', 'varchar', 'String', 'createBy', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 11, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299667488775', '2083850298799267841', 'update_time', '更新时间', 'datetime', 'Date', 'updateTime', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'datetime', '', 12, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299734597634', '2083850298799267841', 'update_by', '更新人', 'varchar', 'String', 'updateBy', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 13, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');
INSERT INTO `gen_table_column` VALUES ('2083850299734597635', '2083850298799267841', 'del_flag', '删除标志', 'int', 'Long', 'delFlag', '0', '0', '0', NULL, NULL, NULL, NULL, 'EQ', 'input', '', 14, '103', '1', '2026-08-02 17:40:02', '1', '2026-08-02 17:40:02');

-- ----------------------------
-- Table structure for sys_client
-- ----------------------------
DROP TABLE IF EXISTS `sys_client`;
CREATE TABLE `sys_client`  (
  `id` varchar(64) NOT NULL COMMENT 'id',
  `client_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户端id',
  `client_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户端key',
  `client_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '客户端秘钥',
  `grant_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '授权类型',
  `device_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '设备类型',
  `active_timeout` int NULL DEFAULT 1800 COMMENT 'token活跃超时时间',
  `timeout` int NULL DEFAULT 604800 COMMENT 'token固定超时',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统授权表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_client
-- ----------------------------
INSERT INTO `sys_client` VALUES ('1', 'e5cd7e4891bf95d1d19206ce24a7b32e', 'pc', 'pc123', 'password,social', 'pc', 1800, 604800, '0', '0', '103', '1', '2026-07-23 16:28:37', '1', '2026-07-23 16:28:37');
INSERT INTO `sys_client` VALUES ('2', '428a8310cd442757ae699df5d894f051', 'app', 'app123', 'password,sms,social', 'android', 1800, 604800, '0', '0', '103', '1', '2026-07-23 16:28:37', '1', '2026-07-23 16:28:37');

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` varchar(64) NOT NULL COMMENT '参数主键',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES ('1', '000000', '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES ('2', '000000', '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES ('3', '000000', '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES ('5', '000000', '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES ('11', '000000', 'OSS预览列表资源开关', 'sys.oss.previewListResource', 'true', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, 'true:开启, false:关闭');
INSERT INTO `sys_config` VALUES ('2083324098586677249', '545670', '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES ('2083324098586677250', '545670', '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '初始化密码 123456');
INSERT INTO `sys_config` VALUES ('2083324098586677251', '545670', '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '深色主题theme-dark，浅色主题theme-light');
INSERT INTO `sys_config` VALUES ('2083324098586677252', '545670', '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES ('2083324098632814594', '545670', 'OSS预览列表资源开关', 'sys.oss.previewListResource', 'true', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', 'true:开启, false:关闭');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` varchar(64) NOT NULL COMMENT '部门id',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `parent_id` varchar(64) NULL DEFAULT '0' COMMENT '父部门id',
  `ancestors` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `dept_category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '部门类别编码',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(64) NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES ('100', '000000', '0', '0', 'XXX科技', NULL, 0, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('101', '000000', '100', '0,100', '深圳总公司', NULL, 1, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('102', '000000', '100', '0,100', '长沙分公司', NULL, 2, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('103', '000000', '101', '0,100,101', '研发部门', NULL, 1, '1', '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('104', '000000', '101', '0,100,101', '市场部门', NULL, 2, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('105', '000000', '101', '0,100,101', '测试部门', NULL, 3, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('106', '000000', '101', '0,100,101', '财务部门', NULL, 4, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('107', '000000', '101', '0,100,101', '运维部门', NULL, 5, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('108', '000000', '102', '0,100,102', '市场部门', NULL, 1, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('109', '000000', '102', '0,100,102', '财务部门', NULL, 2, NULL, '15888888888', 'xxx@qq.com', '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_dept` VALUES ('2083324098108526594', '545670', '0', '0', 'DALIAN-INTERNATIONAL', NULL, 0, '2083324098372767745', NULL, NULL, '0', '0', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06');

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` varchar(64) NOT NULL COMMENT '字典编码',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES ('1', '000000', 1, '男', '0', 'sys_user_sex', '', '', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES ('2', '000000', 2, '女', '1', 'sys_user_sex', '', '', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES ('3', '000000', 3, '未知', '2', 'sys_user_sex', '', '', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES ('4', '000000', 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES ('5', '000000', 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES ('6', '000000', 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES ('7', '000000', 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES ('12', '000000', 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES ('13', '000000', 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES ('14', '000000', 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '通知');
INSERT INTO `sys_dict_data` VALUES ('15', '000000', 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '公告');
INSERT INTO `sys_dict_data` VALUES ('16', '000000', 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES ('17', '000000', 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES ('18', '000000', 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES ('19', '000000', 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES ('20', '000000', 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES ('21', '000000', 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES ('22', '000000', 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES ('23', '000000', 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES ('24', '000000', 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES ('25', '000000', 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES ('26', '000000', 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES ('27', '000000', 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES ('28', '000000', 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES ('29', '000000', 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES ('30', '000000', 0, '密码认证', 'password', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '密码认证');
INSERT INTO `sys_dict_data` VALUES ('31', '000000', 0, '短信认证', 'sms', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '短信认证');
INSERT INTO `sys_dict_data` VALUES ('32', '000000', 0, '邮件认证', 'email', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '邮件认证');
INSERT INTO `sys_dict_data` VALUES ('33', '000000', 0, '小程序认证', 'xcx', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '小程序认证');
INSERT INTO `sys_dict_data` VALUES ('34', '000000', 0, '三方登录认证', 'social', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '三方登录认证');
INSERT INTO `sys_dict_data` VALUES ('35', '000000', 0, 'PC', 'pc', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, 'PC');
INSERT INTO `sys_dict_data` VALUES ('36', '000000', 0, '安卓', 'android', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '安卓');
INSERT INTO `sys_dict_data` VALUES ('37', '000000', 0, 'iOS', 'ios', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, 'iOS');
INSERT INTO `sys_dict_data` VALUES ('38', '000000', 0, '小程序', 'xcx', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '小程序');
INSERT INTO `sys_dict_data` VALUES ('39', '000000', 1, '已撤销', 'cancel', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '已撤销');
INSERT INTO `sys_dict_data` VALUES ('40', '000000', 2, '草稿', 'draft', 'wf_business_status', '', 'info', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '草稿');
INSERT INTO `sys_dict_data` VALUES ('41', '000000', 3, '待审核', 'waiting', 'wf_business_status', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '待审核');
INSERT INTO `sys_dict_data` VALUES ('42', '000000', 4, '已完成', 'finish', 'wf_business_status', '', 'success', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '已完成');
INSERT INTO `sys_dict_data` VALUES ('43', '000000', 5, '已作废', 'invalid', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '已作废');
INSERT INTO `sys_dict_data` VALUES ('44', '000000', 6, '已退回', 'back', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '已退回');
INSERT INTO `sys_dict_data` VALUES ('45', '000000', 7, '已终止', 'termination', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '已终止');
INSERT INTO `sys_dict_data` VALUES ('46', '000000', 1, '自定义表单', 'static', 'wf_form_type', '', 'success', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '自定义表单');
INSERT INTO `sys_dict_data` VALUES ('47', '000000', 2, '动态表单', 'dynamic', 'wf_form_type', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '动态表单');
INSERT INTO `sys_dict_data` VALUES ('48', '000000', 1, '撤销', 'cancel', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '撤销');
INSERT INTO `sys_dict_data` VALUES ('49', '000000', 2, '通过', 'pass', 'wf_task_status', '', 'success', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '通过');
INSERT INTO `sys_dict_data` VALUES ('50', '000000', 3, '待审核', 'waiting', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '待审核');
INSERT INTO `sys_dict_data` VALUES ('51', '000000', 4, '作废', 'invalid', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '作废');
INSERT INTO `sys_dict_data` VALUES ('52', '000000', 5, '退回', 'back', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '退回');
INSERT INTO `sys_dict_data` VALUES ('53', '000000', 6, '终止', 'termination', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '终止');
INSERT INTO `sys_dict_data` VALUES ('54', '000000', 7, '转办', 'transfer', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '转办');
INSERT INTO `sys_dict_data` VALUES ('55', '000000', 8, '委托', 'depute', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '委托');
INSERT INTO `sys_dict_data` VALUES ('56', '000000', 9, '抄送', 'copy', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '抄送');
INSERT INTO `sys_dict_data` VALUES ('57', '000000', 10, '加签', 'sign', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '加签');
INSERT INTO `sys_dict_data` VALUES ('58', '000000', 11, '减签', 'sign_off', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '减签');
INSERT INTO `sys_dict_data` VALUES ('59', '000000', 11, '超时', 'timeout', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '超时');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791169', '545670', 1, '男', '0', 'sys_user_sex', '', '', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '性别男');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791170', '545670', 2, '女', '1', 'sys_user_sex', '', '', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '性别女');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791171', '545670', 3, '未知', '2', 'sys_user_sex', '', '', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '性别未知');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791172', '545670', 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '显示菜单');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791173', '545670', 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791174', '545670', 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '正常状态');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791175', '545670', 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '停用状态');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791176', '545670', 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '系统默认是');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791177', '545670', 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '系统默认否');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791178', '545670', 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '通知');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791179', '545670', 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '公告');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791180', '545670', 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '正常状态');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791181', '545670', 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '关闭状态');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791182', '545670', 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '新增操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791183', '545670', 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '修改操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791184', '545670', 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '删除操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791185', '545670', 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '授权操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791186', '545670', 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '导出操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791187', '545670', 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '导入操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791188', '545670', 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '强退操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791189', '545670', 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '生成操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791190', '545670', 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '清空操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791191', '545670', 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '正常状态');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791192', '545670', 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '停用状态');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791193', '545670', 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '其他操作');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791194', '545670', 0, '密码认证', 'password', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '密码认证');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791195', '545670', 0, '短信认证', 'sms', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '短信认证');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791196', '545670', 0, '邮件认证', 'email', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '邮件认证');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791197', '545670', 0, '小程序认证', 'xcx', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '小程序认证');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791198', '545670', 0, '三方登录认证', 'social', 'sys_grant_type', 'el-check-tag', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '三方登录认证');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791199', '545670', 0, 'PC', 'pc', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', 'PC');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791200', '545670', 0, '安卓', 'android', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '安卓');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791201', '545670', 0, 'iOS', 'ios', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', 'iOS');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791202', '545670', 0, '小程序', 'xcx', 'sys_device_type', '', 'default', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '小程序');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791203', '545670', 1, '已撤销', 'cancel', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '已撤销');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791204', '545670', 2, '草稿', 'draft', 'wf_business_status', '', 'info', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '草稿');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791205', '545670', 3, '待审核', 'waiting', 'wf_business_status', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '待审核');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791206', '545670', 4, '已完成', 'finish', 'wf_business_status', '', 'success', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '已完成');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791207', '545670', 5, '已作废', 'invalid', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '已作废');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791208', '545670', 6, '已退回', 'back', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '已退回');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791209', '545670', 7, '已终止', 'termination', 'wf_business_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '已终止');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791210', '545670', 1, '自定义表单', 'static', 'wf_form_type', '', 'success', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '自定义表单');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791211', '545670', 2, '动态表单', 'dynamic', 'wf_form_type', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '动态表单');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791212', '545670', 1, '撤销', 'cancel', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '撤销');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791213', '545670', 2, '通过', 'pass', 'wf_task_status', '', 'success', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '通过');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791214', '545670', 3, '待审核', 'waiting', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '待审核');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791215', '545670', 4, '作废', 'invalid', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '作废');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791216', '545670', 5, '退回', 'back', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '退回');
INSERT INTO `sys_dict_data` VALUES ('2083324098502791217', '545670', 6, '终止', 'termination', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '终止');
INSERT INTO `sys_dict_data` VALUES ('2083324098569900034', '545670', 7, '转办', 'transfer', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '转办');
INSERT INTO `sys_dict_data` VALUES ('2083324098569900035', '545670', 8, '委托', 'depute', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '委托');
INSERT INTO `sys_dict_data` VALUES ('2083324098574094338', '545670', 9, '抄送', 'copy', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '抄送');
INSERT INTO `sys_dict_data` VALUES ('2083324098574094339', '545670', 10, '加签', 'sign', 'wf_task_status', '', 'primary', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '加签');
INSERT INTO `sys_dict_data` VALUES ('2083324098574094340', '545670', 11, '减签', 'sign_off', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '减签');
INSERT INTO `sys_dict_data` VALUES ('2083324098574094341', '545670', 11, '超时', 'timeout', 'wf_task_status', '', 'danger', 'N', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '超时');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` varchar(64) NOT NULL COMMENT '字典主键',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `tenant_id`(`tenant_id` ASC, `dict_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES ('1', '000000', '用户性别', 'sys_user_sex', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES ('2', '000000', '菜单状态', 'sys_show_hide', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES ('3', '000000', '系统开关', 'sys_normal_disable', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES ('6', '000000', '系统是否', 'sys_yes_no', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES ('7', '000000', '通知类型', 'sys_notice_type', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES ('8', '000000', '通知状态', 'sys_notice_status', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES ('9', '000000', '操作类型', 'sys_oper_type', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES ('10', '000000', '系统状态', 'sys_common_status', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '登录状态列表');
INSERT INTO `sys_dict_type` VALUES ('11', '000000', '授权类型', 'sys_grant_type', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '认证授权类型');
INSERT INTO `sys_dict_type` VALUES ('12', '000000', '设备类型', 'sys_device_type', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '客户端设备类型');
INSERT INTO `sys_dict_type` VALUES ('13', '000000', '业务状态', 'wf_business_status', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '业务状态列表');
INSERT INTO `sys_dict_type` VALUES ('14', '000000', '表单类型', 'wf_form_type', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '表单类型列表');
INSERT INTO `sys_dict_type` VALUES ('15', '000000', '任务状态', 'wf_task_status', '103', '1', '2026-07-23 16:28:44', NULL, NULL, '任务状态');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682306', '545670', '系统状态', 'sys_common_status', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '登录状态列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682307', '545670', '设备类型', 'sys_device_type', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '客户端设备类型');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682308', '545670', '授权类型', 'sys_grant_type', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '认证授权类型');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682309', '545670', '系统开关', 'sys_normal_disable', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '系统开关列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682310', '545670', '通知状态', 'sys_notice_status', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '通知状态列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682311', '545670', '通知类型', 'sys_notice_type', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '通知类型列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682312', '545670', '操作类型', 'sys_oper_type', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '操作类型列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682313', '545670', '菜单状态', 'sys_show_hide', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682314', '545670', '用户性别', 'sys_user_sex', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '用户性别列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682315', '545670', '系统是否', 'sys_yes_no', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '系统是否列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682316', '545670', '业务状态', 'wf_business_status', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '业务状态列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682317', '545670', '表单类型', 'wf_form_type', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '表单类型列表');
INSERT INTO `sys_dict_type` VALUES ('2083324098435682318', '545670', '任务状态', 'wf_task_status', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', '任务状态');

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` varchar(64) NOT NULL COMMENT '访问ID',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户账号',
  `client_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '客户端',
  `device_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '设备类型',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES ('2080212176790216706', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-07-23 16:43:26');
INSERT INTO `sys_logininfor` VALUES ('2080232787616792577', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-07-23 18:05:20');
INSERT INTO `sys_logininfor` VALUES ('2080232901089492993', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '退出成功', '2026-07-23 18:05:47');
INSERT INTO `sys_logininfor` VALUES ('2080265871074643970', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-07-23 20:16:48');
INSERT INTO `sys_logininfor` VALUES ('2083150942655762434', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:21:02');
INSERT INTO `sys_logininfor` VALUES ('2083151228128481282', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:22:11');
INSERT INTO `sys_logininfor` VALUES ('2083151287637266433', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:22:25');
INSERT INTO `sys_logininfor` VALUES ('2083151629028446210', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:23:46');
INSERT INTO `sys_logininfor` VALUES ('2083151823040172034', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:24:32');
INSERT INTO `sys_logininfor` VALUES ('2083151823853867010', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:24:33');
INSERT INTO `sys_logininfor` VALUES ('2083151941134995457', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:25:01');
INSERT INTO `sys_logininfor` VALUES ('2083152350033498114', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '1', '密码输入错误1次', '2026-07-31 19:26:38');
INSERT INTO `sys_logininfor` VALUES ('2083153507107737601', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:31:14');
INSERT INTO `sys_logininfor` VALUES ('2083154142918086657', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:33:45');
INSERT INTO `sys_logininfor` VALUES ('2083154925558435842', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:36:52');
INSERT INTO `sys_logininfor` VALUES ('2083157343801184258', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:46:29');
INSERT INTO `sys_logininfor` VALUES ('2083157386188820481', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:46:39');
INSERT INTO `sys_logininfor` VALUES ('2083157449673805826', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:46:54');
INSERT INTO `sys_logininfor` VALUES ('2083157450562998273', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '退出成功', '2026-07-31 19:46:54');
INSERT INTO `sys_logininfor` VALUES ('2083157542162403330', '000000', 'admin', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:47:16');
INSERT INTO `sys_logininfor` VALUES ('2083157645375836162', '000000', 'test', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:47:41');
INSERT INTO `sys_logininfor` VALUES ('2083157695011229697', '000000', 'test', '', '', '0:0:0:0:0:0:0:1', '内网IP', 'Unknown', 'Unknown', '0', '登录成功', '2026-07-31 19:47:52');
INSERT INTO `sys_logininfor` VALUES ('2083161507398684674', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-07-31 20:03:01');
INSERT INTO `sys_logininfor` VALUES ('2083161618421911554', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '退出成功', '2026-07-31 20:03:28');
INSERT INTO `sys_logininfor` VALUES ('2083161725133393922', '000000', 'test', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-07-31 20:03:53');
INSERT INTO `sys_logininfor` VALUES ('2083162108090126337', '000000', 'test', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '退出成功', '2026-07-31 20:05:25');
INSERT INTO `sys_logininfor` VALUES ('2083162265472995329', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-07-31 20:06:02');
INSERT INTO `sys_logininfor` VALUES ('2083324269512953857', '545670', 'dalian', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-08-01 06:49:47');
INSERT INTO `sys_logininfor` VALUES ('2083843137843093505', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '1', '验证码错误', '2026-08-02 17:11:35');
INSERT INTO `sys_logininfor` VALUES ('2083843158105776129', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-08-02 17:11:39');
INSERT INTO `sys_logininfor` VALUES ('2083846233759477762', '000000', 'admin', 'pc', 'pc', '0:0:0:0:0:0:0:1', '内网IP', 'Chrome', 'Windows 10 or Windows Server 2016', '0', '登录成功', '2026-08-02 17:23:53');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` varchar(64) NOT NULL COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `parent_id` varchar(64) NULL DEFAULT '0' COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '组件路径',
  `query_param` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由参数',
  `is_frame` int NULL DEFAULT 1 COMMENT '是否为外链（0是 1否）',
  `is_cache` int NULL DEFAULT 0 COMMENT '是否缓存（0缓存 1不缓存）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '显示状态（0显示 1隐藏）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0正常 1停用）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES ('1', '系统管理', '0', 1, 'system', NULL, '', 1, 0, 'M', '0', '0', '', 'system', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES ('2', '系统监控', '0', 3, 'monitor', NULL, '', 1, 0, 'M', '0', '0', '', 'monitor', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '系统监控目录');
INSERT INTO `sys_menu` VALUES ('3', '系统工具', '0', 4, 'tool', NULL, '', 1, 0, 'M', '0', '0', '', 'tool', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '系统工具目录');
INSERT INTO `sys_menu` VALUES ('6', '租户管理', '0', 2, 'tenant', NULL, '', 1, 0, 'M', '0', '0', '', 'chart', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '租户管理目录');
INSERT INTO `sys_menu` VALUES ('100', '用户管理', '1', 1, 'user', 'system/user/index', '', 1, 0, 'C', '0', '0', 'system:user:list', 'user', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES ('101', '角色管理', '1', 2, 'role', 'system/role/index', '', 1, 0, 'C', '0', '0', 'system:role:list', 'peoples', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES ('102', '菜单管理', '1', 3, 'menu', 'system/menu/index', '', 1, 0, 'C', '0', '0', 'system:menu:list', 'tree-table', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES ('103', '部门管理', '1', 4, 'dept', 'system/dept/index', '', 1, 0, 'C', '0', '0', 'system:dept:list', 'tree', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '部门管理菜单');
INSERT INTO `sys_menu` VALUES ('104', '岗位管理', '1', 5, 'post', 'system/post/index', '', 1, 0, 'C', '0', '0', 'system:post:list', 'post', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '岗位管理菜单');
INSERT INTO `sys_menu` VALUES ('105', '字典管理', '1', 6, 'dict', 'system/dict/index', '', 1, 0, 'C', '0', '0', 'system:dict:list', 'dict', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES ('106', '参数设置', '1', 7, 'config', 'system/config/index', '', 1, 0, 'C', '0', '0', 'system:config:list', 'edit', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '参数设置菜单');
INSERT INTO `sys_menu` VALUES ('107', '通知公告', '1', 8, 'notice', 'system/notice/index', '', 1, 0, 'C', '0', '0', 'system:notice:list', 'message', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '通知公告菜单');
INSERT INTO `sys_menu` VALUES ('108', '日志管理', '1', 9, 'log', '', '', 1, 0, 'M', '0', '0', '', 'log', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES ('109', '在线用户', '2', 1, 'online', 'monitor/online/index', '', 1, 0, 'C', '0', '0', 'monitor:online:list', 'online', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES ('113', '缓存监控', '2', 5, 'cache', 'monitor/cache/index', '', 1, 0, 'C', '0', '0', 'monitor:cache:list', 'redis', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES ('115', '代码生成', '3', 2, 'gen', 'tool/gen/index', '', 1, 0, 'C', '0', '0', 'tool:gen:list', 'code', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES ('116', '修改生成配置', '3', 2, 'gen-edit/index/:tableId', 'tool/gen/editTable', '', 1, 1, 'C', '1', '0', 'tool:gen:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '/tool/gen');
INSERT INTO `sys_menu` VALUES ('118', '文件管理', '1', 10, 'oss', 'system/oss/index', '', 1, 0, 'C', '0', '0', 'system:oss:list', 'upload', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '文件管理菜单');
INSERT INTO `sys_menu` VALUES ('121', '租户管理', '6', 1, 'tenant', 'system/tenant/index', '', 1, 0, 'C', '0', '0', 'system:tenant:list', 'list', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '租户管理菜单');
INSERT INTO `sys_menu` VALUES ('122', '租户套餐管理', '6', 2, 'tenantPackage', 'system/tenantPackage/index', '', 1, 0, 'C', '0', '0', 'system:tenantPackage:list', 'form', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '租户套餐管理菜单');
INSERT INTO `sys_menu` VALUES ('123', '客户端管理', '1', 11, 'client', 'system/client/index', '', 1, 0, 'C', '0', '0', 'system:client:list', 'international', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '客户端管理菜单');
INSERT INTO `sys_menu` VALUES ('130', '分配用户', '1', 2, 'role-auth/user/:roleId', 'system/role/authUser', '', 1, 1, 'C', '1', '0', 'system:role:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '/system/role');
INSERT INTO `sys_menu` VALUES ('131', '分配角色', '1', 1, 'user-auth/role/:userId', 'system/user/authRole', '', 1, 1, 'C', '1', '0', 'system:user:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '/system/user');
INSERT INTO `sys_menu` VALUES ('132', '字典数据', '1', 6, 'dict-data/index/:dictId', 'system/dict/data', '', 1, 1, 'C', '1', '0', 'system:dict:list', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '/system/dict');
INSERT INTO `sys_menu` VALUES ('133', '文件配置管理', '1', 10, 'oss-config/index', 'system/oss/config', '', 1, 1, 'C', '1', '0', 'system:ossConfig:list', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '/system/oss');
INSERT INTO `sys_menu` VALUES ('500', '操作日志', '108', 1, 'operlog', 'monitor/operlog/index', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list', 'form', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES ('501', '登录日志', '108', 2, 'logininfor', 'monitor/logininfor/index', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES ('1001', '用户查询', '100', 1, '', '', '', 1, 0, 'F', '0', '0', 'system:user:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1002', '用户新增', '100', 2, '', '', '', 1, 0, 'F', '0', '0', 'system:user:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1003', '用户修改', '100', 3, '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1004', '用户删除', '100', 4, '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1005', '用户导出', '100', 5, '', '', '', 1, 0, 'F', '0', '0', 'system:user:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1006', '用户导入', '100', 6, '', '', '', 1, 0, 'F', '0', '0', 'system:user:import', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1007', '重置密码', '100', 7, '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1008', '角色查询', '101', 1, '', '', '', 1, 0, 'F', '0', '0', 'system:role:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1009', '角色新增', '101', 2, '', '', '', 1, 0, 'F', '0', '0', 'system:role:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1010', '角色修改', '101', 3, '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1011', '角色删除', '101', 4, '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1012', '角色导出', '101', 5, '', '', '', 1, 0, 'F', '0', '0', 'system:role:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1013', '菜单查询', '102', 1, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1014', '菜单新增', '102', 2, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1015', '菜单修改', '102', 3, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1016', '菜单删除', '102', 4, '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1017', '部门查询', '103', 1, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1018', '部门新增', '103', 2, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1019', '部门修改', '103', 3, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1020', '部门删除', '103', 4, '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1021', '岗位查询', '104', 1, '', '', '', 1, 0, 'F', '0', '0', 'system:post:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1022', '岗位新增', '104', 2, '', '', '', 1, 0, 'F', '0', '0', 'system:post:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1023', '岗位修改', '104', 3, '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1024', '岗位删除', '104', 4, '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1025', '岗位导出', '104', 5, '', '', '', 1, 0, 'F', '0', '0', 'system:post:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1026', '字典查询', '105', 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1027', '字典新增', '105', 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1028', '字典修改', '105', 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1029', '字典删除', '105', 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1030', '字典导出', '105', 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:dict:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1031', '参数查询', '106', 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1032', '参数新增', '106', 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1033', '参数修改', '106', 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1034', '参数删除', '106', 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1035', '参数导出', '106', 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:config:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1036', '公告查询', '107', 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1037', '公告新增', '107', 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1038', '公告修改', '107', 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1039', '公告删除', '107', 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1040', '操作查询', '500', 1, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1041', '操作删除', '500', 2, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1042', '日志导出', '500', 4, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1043', '登录查询', '501', 1, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1044', '登录删除', '501', 2, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1045', '日志导出', '501', 3, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1046', '在线查询', '109', 1, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1047', '批量强退', '109', 2, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1048', '单条强退', '109', 3, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1050', '账户解锁', '501', 4, '#', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1055', '生成查询', '115', 1, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1056', '生成修改', '115', 2, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1057', '生成删除', '115', 3, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1058', '导入代码', '115', 2, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1059', '预览代码', '115', 4, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1060', '生成代码', '115', 5, '#', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1061', '客户端管理查询', '123', 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:client:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1062', '客户端管理新增', '123', 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:client:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1063', '客户端管理修改', '123', 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:client:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1064', '客户端管理删除', '123', 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:client:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1065', '客户端管理导出', '123', 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:client:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1600', '文件查询', '118', 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:oss:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1601', '文件上传', '118', 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:oss:upload', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1602', '文件下载', '118', 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:oss:download', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1603', '文件删除', '118', 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:oss:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1606', '租户查询', '121', 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenant:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1607', '租户新增', '121', 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenant:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1608', '租户修改', '121', 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenant:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1609', '租户删除', '121', 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenant:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1610', '租户导出', '121', 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenant:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1611', '租户套餐查询', '122', 1, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenantPackage:query', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1612', '租户套餐新增', '122', 2, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenantPackage:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1613', '租户套餐修改', '122', 3, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenantPackage:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1614', '租户套餐删除', '122', 4, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenantPackage:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1615', '租户套餐导出', '122', 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:tenantPackage:export', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1620', '配置列表', '118', 5, '#', '', '', 1, 0, 'F', '0', '0', 'system:ossConfig:list', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1621', '配置添加', '118', 6, '#', '', '', 1, 0, 'F', '0', '0', 'system:ossConfig:add', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1622', '配置编辑', '118', 6, '#', '', '', 1, 0, 'F', '0', '0', 'system:ossConfig:edit', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_menu` VALUES ('1623', '配置删除', '118', 6, '#', '', '', 1, 0, 'F', '0', '0', 'system:ossConfig:remove', '#', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` varchar(64) NOT NULL COMMENT '公告ID',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES ('1', '000000', '温馨提醒：2018-07-01 新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '管理员');
INSERT INTO `sys_notice` VALUES ('2', '000000', '维护通知：2018-07-01 系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '管理员');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` varchar(64) NOT NULL COMMENT '日志主键',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(4000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status` ASC) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES ('2080266548828033025', '000000', '用户管理', 5, 'org.dromara.system.controller.system.SysUserController.export()', 'POST', 1, 'admin', '研发部门', '/system/user/export', '0:0:0:0:0:0:0:1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', '', 0, '', '2026-07-23 20:19:29', 1996);
INSERT INTO `sys_oper_log` VALUES ('2080266983286624258', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/5', '0:0:0:0:0:0:0:1', '内网IP', '5', '{\"code\":601,\"msg\":\"存在子菜单,不允许删除\",\"data\":null}', 0, '', '2026-07-23 20:21:13', 26);
INSERT INTO `sys_oper_log` VALUES ('2080267002442010625', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/1500', '0:0:0:0:0:0:0:1', '内网IP', '1500', '{\"code\":601,\"msg\":\"存在子菜单,不允许删除\",\"data\":null}', 0, '', '2026-07-23 20:21:18', 8);
INSERT INTO `sys_oper_log` VALUES ('2080267094234353666', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/cascade/4,5,1500,1501,1502,1503,1504,1505,1506,1507,1508,1509,1510,1511,11638,11639,11640,11641,11642,11643', '0:0:0:0:0:0:0:1', '内网IP', '[4,5,1500,1501,1502,1503,1504,1505,1506,1507,1508,1509,1510,1511,11638,11639,11640,11641,11642,11643]', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-07-23 20:21:39', 120);
INSERT INTO `sys_oper_log` VALUES ('2080267142485626881', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/cascade/11618,11629,11619,11632,11633', '0:0:0:0:0:0:0:1', '内网IP', '[11618,11629,11619,11632,11633]', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-07-23 20:21:51', 36);
INSERT INTO `sys_oper_log` VALUES ('2080267253697597442', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/117', '0:0:0:0:0:0:0:1', '内网IP', '117', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-07-23 20:22:17', 28);
INSERT INTO `sys_oper_log` VALUES ('2080267264846057473', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/120', '0:0:0:0:0:0:0:1', '内网IP', '120', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-07-23 20:22:20', 25);
INSERT INTO `sys_oper_log` VALUES ('2080274621629997058', '000000', '参数管理', 5, 'org.dromara.system.controller.system.SysConfigController.export()', 'POST', 1, 'admin', '研发部门', '/system/config/export', '0:0:0:0:0:0:0:1', '内网IP', '{\"pageSize\":\"10\",\"pageNum\":\"1\"}', '', 0, '', '2026-07-23 20:51:34', 2014);
INSERT INTO `sys_oper_log` VALUES ('2083161604207415298', '000000', '用户管理', 2, 'org.dromara.system.controller.system.SysUserController.resetPwd()', 'PUT', 1, 'admin', '研发部门', '/system/user/resetPwd', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"userId\":3,\"deptId\":null,\"userName\":null,\"nickName\":null,\"userType\":null,\"email\":null,\"phonenumber\":null,\"sex\":null,\"status\":null,\"remark\":null,\"roleIds\":null,\"postIds\":null,\"roleId\":null,\"userIds\":null,\"excludeUserIds\":null,\"superAdmin\":false}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-07-31 20:03:24', 160);
INSERT INTO `sys_oper_log` VALUES ('2083164261793927170', '000000', '租户套餐', 1, 'org.dromara.system.controller.system.SysTenantPackageController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant/package', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"packageId\":\"2083164261731012610\",\"packageName\":\"初始\",\"menuIds\":[11616,11622,11623,11624,11625,11626,11627,11801,11802,11803,11804,11805,11806,11620,11644,11645,11646,11647,11648,11649,11650,11651,11652,11630,11621,11653,11654,11655,11656,11657,11658,11659,11631,11660,11700,11701],\"remark\":\"\",\"menuCheckStrictly\":true,\"status\":null}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-07-31 20:13:58', 54);
INSERT INTO `sys_oper_log` VALUES ('2083164366852853761', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083164366785744898\",\"tenantId\":null,\"contactUserName\":\"1312\",\"contactPhone\":\"11232423\",\"companyName\":\"dalian\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083164261731012600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, '套餐不存在', '2026-07-31 20:14:23', 33);
INSERT INTO `sys_oper_log` VALUES ('2083164386813546498', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083164386746437634\",\"tenantId\":null,\"contactUserName\":\"1312\",\"contactPhone\":\"11232423\",\"companyName\":\"dalian\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083164261731012600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, '套餐不存在', '2026-07-31 20:14:28', 34);
INSERT INTO `sys_oper_log` VALUES ('2083165352778543105', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083165352514301954\",\"tenantId\":null,\"contactUserName\":\"123\",\"contactPhone\":\"142342342\",\"companyName\":\"DALIAN FIREFOX\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083164261731012600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, '套餐不存在', '2026-07-31 20:18:18', 91);
INSERT INTO `sys_oper_log` VALUES ('2083319374714040322', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083319374508519425\",\"tenantId\":null,\"contactUserName\":\"董仕清\",\"contactPhone\":\"141324232\",\"companyName\":\"DALIAN-INTERNATIONAL\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083164261731012600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, '套餐不存在', '2026-08-01 06:30:20', 80);
INSERT INTO `sys_oper_log` VALUES ('2083320442147672066', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083320441921179650\",\"tenantId\":null,\"contactUserName\":\"董仕清\",\"contactPhone\":\"141324232\",\"companyName\":\"DALIAN-INTERNATIONAL\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083164261731012600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, '套餐不存在', '2026-08-01 06:34:34', 176);
INSERT INTO `sys_oper_log` VALUES ('2083320800995463170', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083320620267098113\",\"tenantId\":null,\"contactUserName\":\"董仕清\",\"contactPhone\":\"141324232\",\"companyName\":\"DALIAN-INTERNATIONAL\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083164261731012600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, '套餐不存在', '2026-08-01 06:36:00', 43127);
INSERT INTO `sys_oper_log` VALUES ('2083321430132666370', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083321377796141058\",\"tenantId\":null,\"contactUserName\":\"董仕清\",\"contactPhone\":\"141324232\",\"companyName\":\"DALIAN-INTERNATIONAL\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083164261731012600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, '套餐不存在', '2026-08-01 06:38:30', 12585);
INSERT INTO `sys_oper_log` VALUES ('2083321465620672514', '000000', '租户套餐', 3, 'org.dromara.system.controller.system.SysTenantPackageController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/tenant/package/2083164261731012600', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083164261731012600\"]', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-01 06:38:38', 72);
INSERT INTO `sys_oper_log` VALUES ('2083321479004696577', '000000', '租户套餐', 2, 'org.dromara.system.controller.system.SysTenantPackageController.changeStatus()', 'PUT', 1, 'admin', '研发部门', '/system/tenant/package/changeStatus', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"packageId\":\"2083164261731012600\",\"packageName\":null,\"menuIds\":null,\"remark\":null,\"menuCheckStrictly\":null,\"status\":\"1\"}', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-01 06:38:42', 20);
INSERT INTO `sys_oper_log` VALUES ('2083321551520018434', '000000', '租户套餐', 3, 'org.dromara.system.controller.system.SysTenantPackageController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/tenant/package/2083164261731012600', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083164261731012600\"]', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-01 06:38:59', 27);
INSERT INTO `sys_oper_log` VALUES ('2083321677609185282', '000000', '租户套餐', 3, 'org.dromara.system.controller.system.SysTenantPackageController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/tenant/package/2083164261731012600', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083164261731012600\"]', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-01 06:39:29', 30);
INSERT INTO `sys_oper_log` VALUES ('2083322209262387202', '000000', '租户套餐', 1, 'org.dromara.system.controller.system.SysTenantPackageController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant/package', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"packageId\":\"2083322209035894786\",\"packageName\":\"TEST\",\"menuIds\":[1,100,1001,1002,1003,1004,1005,1006,1007,131,101,1008,1009,1010,1011,1012,130,102,1013,1014,1015,1016,103,1017,1018,1019,1020,104,1021,1022,1023,1024,1025,105,1026,1027,1028,1029,1030,132,106,1031,1032,1033,1034,1035,107,1036,1037,1038,1039,108,500,1040,1041,1042,501,1043,1044,1045,1050,118,1600,1601,1602,1603,1620,1621,1622,1623,133,123,1061,1062,1063,1064,1065,3,115,1055,1056,1058,1057,1059,1060,116,11616,11622,11623,11624,11625,11626,11627,11801,11802,11803,11804,11805,11806,11620,11644,11645,11646,11647,11648,11649,11650,11651,11652,11630,11621,11653,11654,11655,11656,11657,11658,11659,11631,11660,11700,11701],\"remark\":\"\",\"menuCheckStrictly\":true,\"status\":null}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-01 06:41:36', 109);
INSERT INTO `sys_oper_log` VALUES ('2083322840467390466', '000000', '租户套餐', 1, 'org.dromara.system.controller.system.SysTenantPackageController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant/package', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"packageId\":\"2083322840400281601\",\"packageName\":\"TEST\",\"menuIds\":[1,100,1001,1002,1003,1004,1005,1006,1007,131,101,1008,1009,1010,1011,1012,130,102,1013,1014,1015,1016,103,1017,1018,1019,1020,104,1021,1022,1023,1024,1025,105,1026,1027,1028,1029,1030,132,106,1031,1032,1033,1034,1035,107,1036,1037,1038,1039,108,500,1040,1041,1042,501,1043,1044,1045,1050,118,1600,1601,1602,1603,1620,1621,1622,1623,133,123,1061,1062,1063,1064,1065,3,115,1055,1056,1058,1057,1059,1060,116,11616,11622,11623,11624,11625,11626,11627,11801,11802,11803,11804,11805,11806,11620,11644,11645,11646,11647,11648,11649,11650,11651,11652,11630,11621,11653,11654,11655,11656,11657,11658,11659,11631,11660,11700,11701],\"remark\":\"\",\"menuCheckStrictly\":true,\"status\":null}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-01 06:44:06', 31);
INSERT INTO `sys_oper_log` VALUES ('2083323049620553735', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083323037025058818\",\"tenantId\":null,\"contactUserName\":\"测试\",\"contactPhone\":\"143232432\",\"companyName\":\"DALIAN-INTERNATIONAL\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083322840400281600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '', 1, 'No qualifying bean of type \'org.dromara.common.core.service.WorkflowService\' available', '2026-08-01 06:44:56', 3027);
INSERT INTO `sys_oper_log` VALUES ('2083323719891357698', '000000', '租户套餐', 2, 'org.dromara.system.controller.system.SysTenantPackageController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/tenant/package', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"packageId\":\"2083322840400281600\",\"packageName\":\"TEST\",\"menuIds\":[1,100,1001,1002,1003,1004,1005,1006,1007,131,101,1008,1009,1010,1011,1012,130,102,1013,1014,1015,1016,103,1017,1018,1019,1020,104,1021,1022,1023,1024,1025,105,1026,1027,1028,1029,1030,132,106,1031,1032,1033,1034,1035,107,1036,1037,1038,1039,108,500,1040,1041,1042,501,1043,1044,1045,1050,118,1600,1601,1602,1603,1620,1621,1622,1623,133,123,1061,1062,1063,1064,1065,3,115,1055,1056,1058,1057,1059,1060,116],\"remark\":\"\",\"menuCheckStrictly\":true,\"status\":\"0\"}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-01 06:47:36', 105);
INSERT INTO `sys_oper_log` VALUES ('2083323904096800770', '000000', '租户套餐', 2, 'org.dromara.system.controller.system.SysTenantPackageController.edit()', 'PUT', 1, 'admin', '研发部门', '/system/tenant/package', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"packageId\":\"2083322840400281600\",\"packageName\":\"TEST\",\"menuIds\":[1,100,1001,1002,1003,1004,1005,1006,1007,131,101,1008,1009,1010,1011,1012,130,102,1013,1014,1015,1016,103,1017,1018,1019,1020,104,1021,1022,1023,1024,1025,105,1026,1027,1028,1029,1030,132,106,1031,1032,1033,1034,1035,107,1036,1037,1038,1039,108,500,1040,1041,1042,501,1043,1044,1045,1050,118,1600,1601,1602,1603,1620,1621,1622,1623,133,123,1061,1062,1063,1064,1065,3,115,1055,1056,1058,1057,1059,1060,116],\"remark\":\"\",\"menuCheckStrictly\":true,\"status\":\"0\"}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-01 06:48:20', 26);
INSERT INTO `sys_oper_log` VALUES ('2083324098670563330', '000000', '租户管理', 1, 'org.dromara.system.controller.system.SysTenantController.add()', 'POST', 1, 'admin', '研发部门', '/system/tenant', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083324090562973697\",\"tenantId\":null,\"contactUserName\":\"dalian\",\"contactPhone\":\"133242342\",\"companyName\":\"DALIAN-INTERNATIONAL\",\"username\":\"dalian\",\"licenseNumber\":\"\",\"address\":\"\",\"domain\":\"\",\"intro\":\"\",\"remark\":\"\",\"packageId\":\"2083322840400281600\",\"expireTime\":null,\"accountCount\":20,\"status\":\"0\"}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-01 06:49:06', 1960);
INSERT INTO `sys_oper_log` VALUES ('2083845978204729345', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/11616', '0:0:0:0:0:0:0:1', '内网IP', '11616', '{\"code\":601,\"msg\":\"存在子菜单,不允许删除\",\"data\":null}', 0, '', '2026-08-02 17:22:52', 37);
INSERT INTO `sys_oper_log` VALUES ('2083845994990333953', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/11622', '0:0:0:0:0:0:0:1', '内网IP', '11622', '{\"code\":601,\"msg\":\"存在子菜单,不允许删除\",\"data\":null}', 0, '', '2026-08-02 17:22:56', 8);
INSERT INTO `sys_oper_log` VALUES ('2083846022010040321', '000000', '菜单管理', 3, 'org.dromara.system.controller.system.SysMenuController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/menu/cascade/11616,11622,11623,11624,11625,11626,11627,11801,11802,11803,11804,11805,11806,11620,11644,11645,11646,11647,11648,11649,11650,11651,11652,11630,11621,11653,11654,11655,11656,11657,11658,11659,11631,11660,11700,11701', '0:0:0:0:0:0:0:1', '内网IP', '[11616,11622,11623,11624,11625,11626,11627,11801,11802,11803,11804,11805,11806,11620,11644,11645,11646,11647,11648,11649,11650,11651,11652,11630,11621,11653,11654,11655,11656,11657,11658,11659,11631,11660,11700,11701]', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:23:02', 112);
INSERT INTO `sys_oper_log` VALUES ('2083846126410461185', '000000', '用户管理', 2, 'org.dromara.system.controller.system.SysUserController.changeStatus()', 'PUT', 1, 'admin', '研发部门', '/system/user/changeStatus', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"userId\":3,\"deptId\":null,\"userName\":null,\"nickName\":null,\"userType\":null,\"email\":null,\"phonenumber\":null,\"sex\":null,\"status\":\"1\",\"remark\":null,\"roleIds\":null,\"postIds\":null,\"roleId\":null,\"userIds\":null,\"excludeUserIds\":null,\"superAdmin\":false}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:23:27', 19);
INSERT INTO `sys_oper_log` VALUES ('2083846470536327169', '000000', '代码生成', 6, 'org.dromara.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '0:0:0:0:0:0:0:1', '内网IP', '{\"tables\":\"test_leave\",\"dataName\":\"master\"}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:24:49', 240);
INSERT INTO `sys_oper_log` VALUES ('2083846611234254856', '000000', '代码生成', 8, 'org.dromara.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '0:0:0:0:0:0:0:1', '内网IP', '{\"tableIdStr\":\"2083846469814907000\"}', '', 1, 'Cannot invoke \"org.dromara.generator.domain.GenTable.setMenuIds(java.util.List)\" because \"table\" is null', '2026-08-02 17:25:23', 8);
INSERT INTO `sys_oper_log` VALUES ('2083846640107843585', '000000', '代码生成', 3, 'org.dromara.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/2083846469814907000', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083846469814907000\"]', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:25:30', 25);
INSERT INTO `sys_oper_log` VALUES ('2083846664493527041', '000000', '代码生成', 3, 'org.dromara.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/2083846469814907000', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083846469814907000\"]', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:25:35', 14);
INSERT INTO `sys_oper_log` VALUES ('2083846696068247553', '000000', '代码生成', 3, 'org.dromara.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/2083846469814907000', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083846469814907000\"]', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:25:43', 14);
INSERT INTO `sys_oper_log` VALUES ('2083846776401752066', '000000', '代码生成', 6, 'org.dromara.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '0:0:0:0:0:0:0:1', '内网IP', '{\"tables\":\"test_demo\",\"dataName\":\"master\"}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:26:02', 132);
INSERT INTO `sys_oper_log` VALUES ('2083846855296610312', '000000', '代码生成', 8, 'org.dromara.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '0:0:0:0:0:0:0:1', '内网IP', '{\"tableIdStr\":\"2083846469814907000\"}', '', 1, 'Cannot invoke \"org.dromara.generator.domain.GenTable.setMenuIds(java.util.List)\" because \"table\" is null', '2026-08-02 17:26:21', 4);
INSERT INTO `sys_oper_log` VALUES ('2083848368249217025', '000000', '代码生成', 8, 'org.dromara.generator.controller.GenController.batchGenCode()', 'GET', 1, 'admin', '研发部门', '/tool/gen/batchGenCode', '0:0:0:0:0:0:0:1', '内网IP', '{\"tableIdStr\":\"2083846775940378600\"}', '', 1, 'Cannot invoke \"org.dromara.generator.domain.GenTable.setMenuIds(java.util.List)\" because \"table\" is null', '2026-08-02 17:32:22', 109);
INSERT INTO `sys_oper_log` VALUES ('2083850269434945538', '000000', '代码生成', 3, 'org.dromara.generator.controller.GenController.remove()', 'DELETE', 1, 'admin', '研发部门', '/tool/gen/2083846775940378600,2083846469814907000', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083846775940378600\",\"2083846469814907000\"]', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:39:55', 101);
INSERT INTO `sys_oper_log` VALUES ('2083850299864621058', '000000', '代码生成', 6, 'org.dromara.generator.controller.GenController.importTableSave()', 'POST', 1, 'admin', '研发部门', '/tool/gen/importTable', '0:0:0:0:0:0:0:1', '内网IP', '{\"tables\":\"test_demo\",\"dataName\":\"master\"}', '{\"code\":200,\"msg\":\"操作成功\",\"data\":null}', 0, '', '2026-08-02 17:40:02', 328);
INSERT INTO `sys_oper_log` VALUES ('2085223647925972994', '000000', '租户管理', 3, 'org.dromara.system.controller.system.SysTenantController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/tenant/2083324090562973700', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083324090562973700\"]', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-06 12:37:14', 86);
INSERT INTO `sys_oper_log` VALUES ('2085223660974452738', '000000', '租户管理', 3, 'org.dromara.system.controller.system.SysTenantController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/tenant/2083324090562973700', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083324090562973700\"]', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-06 12:37:17', 13);
INSERT INTO `sys_oper_log` VALUES ('2085223745028304897', '000000', '租户管理', 3, 'org.dromara.system.controller.system.SysTenantController.remove()', 'DELETE', 1, 'admin', '研发部门', '/system/tenant/2083324090562973700', '0:0:0:0:0:0:0:1', '内网IP', '[\"2083324090562973700\"]', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-06 12:37:37', 13);
INSERT INTO `sys_oper_log` VALUES ('2085223913773543425', '000000', '租户管理', 2, 'org.dromara.system.controller.system.SysTenantController.changeStatus()', 'PUT', 1, 'admin', '研发部门', '/system/tenant/changeStatus', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083324090562973700\",\"tenantId\":\"545670\",\"contactUserName\":null,\"contactPhone\":null,\"companyName\":null,\"username\":null,\"licenseNumber\":null,\"address\":null,\"domain\":null,\"intro\":null,\"remark\":null,\"packageId\":null,\"expireTime\":null,\"accountCount\":null,\"status\":\"1\"}', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-06 12:38:17', 24);
INSERT INTO `sys_oper_log` VALUES ('2085223960334512130', '000000', '租户管理', 2, 'org.dromara.system.controller.system.SysTenantController.changeStatus()', 'PUT', 1, 'admin', '研发部门', '/system/tenant/changeStatus', '0:0:0:0:0:0:0:1', '内网IP', '{\"createDept\":null,\"createBy\":null,\"createTime\":null,\"updateBy\":null,\"updateTime\":null,\"id\":\"2083324090562973700\",\"tenantId\":\"545670\",\"contactUserName\":null,\"contactPhone\":null,\"companyName\":null,\"username\":null,\"licenseNumber\":null,\"address\":null,\"domain\":null,\"intro\":null,\"remark\":null,\"packageId\":null,\"expireTime\":null,\"accountCount\":null,\"status\":\"1\"}', '{\"code\":500,\"msg\":\"操作失败\",\"data\":null}', 0, '', '2026-08-06 12:38:28', 11);

-- ----------------------------
-- Table structure for sys_oss
-- ----------------------------
DROP TABLE IF EXISTS `sys_oss`;
CREATE TABLE `sys_oss`  (
  `oss_id` varchar(64) NOT NULL COMMENT '对象存储主键',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件名',
  `original_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '原名',
  `file_suffix` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '文件后缀名',
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'URL地址',
  `ext1` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '扩展字段',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '上传人',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新人',
  `service` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'minio' COMMENT '服务商',
  PRIMARY KEY (`oss_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'OSS对象存储表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oss
-- ----------------------------

-- ----------------------------
-- Table structure for sys_oss_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_oss_config`;
CREATE TABLE `sys_oss_config`  (
  `oss_config_id` varchar(64) NOT NULL COMMENT '主键',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `config_key` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '配置key',
  `access_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'accessKey',
  `secret_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '秘钥',
  `bucket_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '桶名称',
  `prefix` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '前缀',
  `endpoint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '访问站点',
  `domain` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '自定义域名',
  `is_https` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否https（Y=是,N=否）',
  `region` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '域',
  `access_policy` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '1' COMMENT '桶权限类型(0=private 1=public 2=custom)',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否默认（0=是,1=否）',
  `ext1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '扩展字段',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`oss_config_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '对象存储配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oss_config
-- ----------------------------
INSERT INTO `sys_oss_config` VALUES ('1', '000000', 'minio', 'ruoyi', 'ruoyi123', 'ruoyi', '', '127.0.0.1:9000', '', 'N', '', '1', '0', '', '103', '1', '2026-07-23 16:28:37', '1', '2026-07-23 16:28:37', NULL);
INSERT INTO `sys_oss_config` VALUES ('2', '000000', 'qiniu', 'XXXXXXXXXXXXXXX', 'XXXXXXXXXXXXXXX', 'ruoyi', '', 's3-cn-north-1.qiniucs.com', '', 'N', '', '1', '1', '', '103', '1', '2026-07-23 16:28:37', '1', '2026-07-23 16:28:37', NULL);
INSERT INTO `sys_oss_config` VALUES ('3', '000000', 'aliyun', 'XXXXXXXXXXXXXXX', 'XXXXXXXXXXXXXXX', 'ruoyi', '', 'oss-cn-beijing.aliyuncs.com', '', 'N', '', '1', '1', '', '103', '1', '2026-07-23 16:28:37', '1', '2026-07-23 16:28:37', NULL);
INSERT INTO `sys_oss_config` VALUES ('4', '000000', 'qcloud', 'XXXXXXXXXXXXXXX', 'XXXXXXXXXXXXXXX', 'ruoyi-1240000000', '', 'cos.ap-beijing.myqcloud.com', '', 'N', 'ap-beijing', '1', '1', '', '103', '1', '2026-07-23 16:28:37', '1', '2026-07-23 16:28:37', NULL);
INSERT INTO `sys_oss_config` VALUES ('5', '000000', 'image', 'ruoyi', 'ruoyi123', 'ruoyi', 'image', '127.0.0.1:9000', '', 'N', '', '1', '1', '', '103', '1', '2026-07-23 16:28:37', '1', '2026-07-23 16:28:37', NULL);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` varchar(64) NOT NULL COMMENT '岗位ID',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `dept_id` varchar(64) NOT NULL COMMENT '部门id',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位编码',
  `post_category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '岗位类别编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES ('1', '000000', '103', 'ceo', NULL, '董事长', 1, '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_post` VALUES ('2', '000000', '100', 'se', NULL, '项目经理', 2, '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_post` VALUES ('3', '000000', '100', 'hr', NULL, '人力资源', 3, '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_post` VALUES ('4', '000000', '100', 'user', NULL, '普通员工', 4, '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` varchar(64) NOT NULL COMMENT '角色ID',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限 5：仅本人数据权限 6：部门及以下或本人数据权限）',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `dept_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '部门树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES ('1', '000000', '超级管理员', 'superadmin', 1, '1', 1, 1, '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '超级管理员');
INSERT INTO `sys_role` VALUES ('3', '000000', '本部门及以下', 'test1', 3, '4', 1, 1, '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_role` VALUES ('4', '000000', '仅本人', 'test2', 4, '5', 1, 1, '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL, '');
INSERT INTO `sys_role` VALUES ('2083324097974308866', '545670', '管理员', 'admin', 1, '1', 1, 1, '0', '0', '103', '1', '2026-08-01 06:49:06', '1', '2026-08-01 06:49:06', NULL);

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` varchar(64) NOT NULL COMMENT '角色ID',
  `dept_id` varchar(64) NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES ('2083324097974308866', '2083324098108526594');

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` varchar(64) NOT NULL COMMENT '角色ID',
  `menu_id` varchar(64) NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES ('1', '1');
INSERT INTO `sys_role_menu` VALUES ('1', '2');
INSERT INTO `sys_role_menu` VALUES ('1', '3');
INSERT INTO `sys_role_menu` VALUES ('1', '6');
INSERT INTO `sys_role_menu` VALUES ('1', '100');
INSERT INTO `sys_role_menu` VALUES ('1', '101');
INSERT INTO `sys_role_menu` VALUES ('1', '102');
INSERT INTO `sys_role_menu` VALUES ('1', '103');
INSERT INTO `sys_role_menu` VALUES ('1', '104');
INSERT INTO `sys_role_menu` VALUES ('1', '105');
INSERT INTO `sys_role_menu` VALUES ('1', '106');
INSERT INTO `sys_role_menu` VALUES ('1', '107');
INSERT INTO `sys_role_menu` VALUES ('1', '108');
INSERT INTO `sys_role_menu` VALUES ('1', '109');
INSERT INTO `sys_role_menu` VALUES ('1', '113');
INSERT INTO `sys_role_menu` VALUES ('1', '115');
INSERT INTO `sys_role_menu` VALUES ('1', '116');
INSERT INTO `sys_role_menu` VALUES ('1', '118');
INSERT INTO `sys_role_menu` VALUES ('1', '121');
INSERT INTO `sys_role_menu` VALUES ('1', '122');
INSERT INTO `sys_role_menu` VALUES ('1', '123');
INSERT INTO `sys_role_menu` VALUES ('1', '130');
INSERT INTO `sys_role_menu` VALUES ('1', '131');
INSERT INTO `sys_role_menu` VALUES ('1', '132');
INSERT INTO `sys_role_menu` VALUES ('1', '133');
INSERT INTO `sys_role_menu` VALUES ('1', '500');
INSERT INTO `sys_role_menu` VALUES ('1', '501');
INSERT INTO `sys_role_menu` VALUES ('1', '1001');
INSERT INTO `sys_role_menu` VALUES ('1', '1002');
INSERT INTO `sys_role_menu` VALUES ('1', '1003');
INSERT INTO `sys_role_menu` VALUES ('1', '1004');
INSERT INTO `sys_role_menu` VALUES ('1', '1005');
INSERT INTO `sys_role_menu` VALUES ('1', '1006');
INSERT INTO `sys_role_menu` VALUES ('1', '1007');
INSERT INTO `sys_role_menu` VALUES ('1', '1008');
INSERT INTO `sys_role_menu` VALUES ('1', '1009');
INSERT INTO `sys_role_menu` VALUES ('1', '1010');
INSERT INTO `sys_role_menu` VALUES ('1', '1011');
INSERT INTO `sys_role_menu` VALUES ('1', '1012');
INSERT INTO `sys_role_menu` VALUES ('1', '1013');
INSERT INTO `sys_role_menu` VALUES ('1', '1014');
INSERT INTO `sys_role_menu` VALUES ('1', '1015');
INSERT INTO `sys_role_menu` VALUES ('1', '1016');
INSERT INTO `sys_role_menu` VALUES ('1', '1017');
INSERT INTO `sys_role_menu` VALUES ('1', '1018');
INSERT INTO `sys_role_menu` VALUES ('1', '1019');
INSERT INTO `sys_role_menu` VALUES ('1', '1020');
INSERT INTO `sys_role_menu` VALUES ('1', '1021');
INSERT INTO `sys_role_menu` VALUES ('1', '1022');
INSERT INTO `sys_role_menu` VALUES ('1', '1023');
INSERT INTO `sys_role_menu` VALUES ('1', '1024');
INSERT INTO `sys_role_menu` VALUES ('1', '1025');
INSERT INTO `sys_role_menu` VALUES ('1', '1026');
INSERT INTO `sys_role_menu` VALUES ('1', '1027');
INSERT INTO `sys_role_menu` VALUES ('1', '1028');
INSERT INTO `sys_role_menu` VALUES ('1', '1029');
INSERT INTO `sys_role_menu` VALUES ('1', '1030');
INSERT INTO `sys_role_menu` VALUES ('1', '1031');
INSERT INTO `sys_role_menu` VALUES ('1', '1032');
INSERT INTO `sys_role_menu` VALUES ('1', '1033');
INSERT INTO `sys_role_menu` VALUES ('1', '1034');
INSERT INTO `sys_role_menu` VALUES ('1', '1035');
INSERT INTO `sys_role_menu` VALUES ('1', '1036');
INSERT INTO `sys_role_menu` VALUES ('1', '1037');
INSERT INTO `sys_role_menu` VALUES ('1', '1038');
INSERT INTO `sys_role_menu` VALUES ('1', '1039');
INSERT INTO `sys_role_menu` VALUES ('1', '1040');
INSERT INTO `sys_role_menu` VALUES ('1', '1041');
INSERT INTO `sys_role_menu` VALUES ('1', '1042');
INSERT INTO `sys_role_menu` VALUES ('1', '1043');
INSERT INTO `sys_role_menu` VALUES ('1', '1044');
INSERT INTO `sys_role_menu` VALUES ('1', '1045');
INSERT INTO `sys_role_menu` VALUES ('1', '1046');
INSERT INTO `sys_role_menu` VALUES ('1', '1047');
INSERT INTO `sys_role_menu` VALUES ('1', '1048');
INSERT INTO `sys_role_menu` VALUES ('1', '1050');
INSERT INTO `sys_role_menu` VALUES ('1', '1055');
INSERT INTO `sys_role_menu` VALUES ('1', '1056');
INSERT INTO `sys_role_menu` VALUES ('1', '1057');
INSERT INTO `sys_role_menu` VALUES ('1', '1058');
INSERT INTO `sys_role_menu` VALUES ('1', '1059');
INSERT INTO `sys_role_menu` VALUES ('1', '1060');
INSERT INTO `sys_role_menu` VALUES ('1', '1061');
INSERT INTO `sys_role_menu` VALUES ('1', '1062');
INSERT INTO `sys_role_menu` VALUES ('1', '1063');
INSERT INTO `sys_role_menu` VALUES ('1', '1064');
INSERT INTO `sys_role_menu` VALUES ('1', '1065');
INSERT INTO `sys_role_menu` VALUES ('1', '1600');
INSERT INTO `sys_role_menu` VALUES ('1', '1601');
INSERT INTO `sys_role_menu` VALUES ('1', '1602');
INSERT INTO `sys_role_menu` VALUES ('1', '1603');
INSERT INTO `sys_role_menu` VALUES ('1', '1606');
INSERT INTO `sys_role_menu` VALUES ('1', '1607');
INSERT INTO `sys_role_menu` VALUES ('1', '1608');
INSERT INTO `sys_role_menu` VALUES ('1', '1609');
INSERT INTO `sys_role_menu` VALUES ('1', '1610');
INSERT INTO `sys_role_menu` VALUES ('1', '1611');
INSERT INTO `sys_role_menu` VALUES ('1', '1612');
INSERT INTO `sys_role_menu` VALUES ('1', '1613');
INSERT INTO `sys_role_menu` VALUES ('1', '1614');
INSERT INTO `sys_role_menu` VALUES ('1', '1615');
INSERT INTO `sys_role_menu` VALUES ('1', '1620');
INSERT INTO `sys_role_menu` VALUES ('1', '1621');
INSERT INTO `sys_role_menu` VALUES ('1', '1622');
INSERT INTO `sys_role_menu` VALUES ('1', '1623');
INSERT INTO `sys_role_menu` VALUES ('3', '1');
INSERT INTO `sys_role_menu` VALUES ('3', '100');
INSERT INTO `sys_role_menu` VALUES ('3', '101');
INSERT INTO `sys_role_menu` VALUES ('3', '102');
INSERT INTO `sys_role_menu` VALUES ('3', '103');
INSERT INTO `sys_role_menu` VALUES ('3', '104');
INSERT INTO `sys_role_menu` VALUES ('3', '105');
INSERT INTO `sys_role_menu` VALUES ('3', '106');
INSERT INTO `sys_role_menu` VALUES ('3', '107');
INSERT INTO `sys_role_menu` VALUES ('3', '108');
INSERT INTO `sys_role_menu` VALUES ('3', '118');
INSERT INTO `sys_role_menu` VALUES ('3', '123');
INSERT INTO `sys_role_menu` VALUES ('3', '130');
INSERT INTO `sys_role_menu` VALUES ('3', '131');
INSERT INTO `sys_role_menu` VALUES ('3', '132');
INSERT INTO `sys_role_menu` VALUES ('3', '133');
INSERT INTO `sys_role_menu` VALUES ('3', '500');
INSERT INTO `sys_role_menu` VALUES ('3', '501');
INSERT INTO `sys_role_menu` VALUES ('3', '1001');
INSERT INTO `sys_role_menu` VALUES ('3', '1002');
INSERT INTO `sys_role_menu` VALUES ('3', '1003');
INSERT INTO `sys_role_menu` VALUES ('3', '1004');
INSERT INTO `sys_role_menu` VALUES ('3', '1005');
INSERT INTO `sys_role_menu` VALUES ('3', '1006');
INSERT INTO `sys_role_menu` VALUES ('3', '1007');
INSERT INTO `sys_role_menu` VALUES ('3', '1008');
INSERT INTO `sys_role_menu` VALUES ('3', '1009');
INSERT INTO `sys_role_menu` VALUES ('3', '1010');
INSERT INTO `sys_role_menu` VALUES ('3', '1011');
INSERT INTO `sys_role_menu` VALUES ('3', '1012');
INSERT INTO `sys_role_menu` VALUES ('3', '1013');
INSERT INTO `sys_role_menu` VALUES ('3', '1014');
INSERT INTO `sys_role_menu` VALUES ('3', '1015');
INSERT INTO `sys_role_menu` VALUES ('3', '1016');
INSERT INTO `sys_role_menu` VALUES ('3', '1017');
INSERT INTO `sys_role_menu` VALUES ('3', '1018');
INSERT INTO `sys_role_menu` VALUES ('3', '1019');
INSERT INTO `sys_role_menu` VALUES ('3', '1020');
INSERT INTO `sys_role_menu` VALUES ('3', '1021');
INSERT INTO `sys_role_menu` VALUES ('3', '1022');
INSERT INTO `sys_role_menu` VALUES ('3', '1023');
INSERT INTO `sys_role_menu` VALUES ('3', '1024');
INSERT INTO `sys_role_menu` VALUES ('3', '1025');
INSERT INTO `sys_role_menu` VALUES ('3', '1026');
INSERT INTO `sys_role_menu` VALUES ('3', '1027');
INSERT INTO `sys_role_menu` VALUES ('3', '1028');
INSERT INTO `sys_role_menu` VALUES ('3', '1029');
INSERT INTO `sys_role_menu` VALUES ('3', '1030');
INSERT INTO `sys_role_menu` VALUES ('3', '1031');
INSERT INTO `sys_role_menu` VALUES ('3', '1032');
INSERT INTO `sys_role_menu` VALUES ('3', '1033');
INSERT INTO `sys_role_menu` VALUES ('3', '1034');
INSERT INTO `sys_role_menu` VALUES ('3', '1035');
INSERT INTO `sys_role_menu` VALUES ('3', '1036');
INSERT INTO `sys_role_menu` VALUES ('3', '1037');
INSERT INTO `sys_role_menu` VALUES ('3', '1038');
INSERT INTO `sys_role_menu` VALUES ('3', '1039');
INSERT INTO `sys_role_menu` VALUES ('3', '1040');
INSERT INTO `sys_role_menu` VALUES ('3', '1041');
INSERT INTO `sys_role_menu` VALUES ('3', '1042');
INSERT INTO `sys_role_menu` VALUES ('3', '1043');
INSERT INTO `sys_role_menu` VALUES ('3', '1044');
INSERT INTO `sys_role_menu` VALUES ('3', '1045');
INSERT INTO `sys_role_menu` VALUES ('3', '1050');
INSERT INTO `sys_role_menu` VALUES ('3', '1061');
INSERT INTO `sys_role_menu` VALUES ('3', '1062');
INSERT INTO `sys_role_menu` VALUES ('3', '1063');
INSERT INTO `sys_role_menu` VALUES ('3', '1064');
INSERT INTO `sys_role_menu` VALUES ('3', '1065');
INSERT INTO `sys_role_menu` VALUES ('3', '1600');
INSERT INTO `sys_role_menu` VALUES ('3', '1601');
INSERT INTO `sys_role_menu` VALUES ('3', '1602');
INSERT INTO `sys_role_menu` VALUES ('3', '1603');
INSERT INTO `sys_role_menu` VALUES ('3', '1620');
INSERT INTO `sys_role_menu` VALUES ('3', '1621');
INSERT INTO `sys_role_menu` VALUES ('3', '1622');
INSERT INTO `sys_role_menu` VALUES ('3', '1623');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '3');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '100');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '101');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '102');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '103');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '104');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '105');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '106');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '107');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '108');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '115');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '116');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '118');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '123');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '130');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '131');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '132');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '133');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '500');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '501');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1001');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1002');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1003');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1004');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1005');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1006');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1007');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1008');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1009');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1010');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1011');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1012');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1013');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1014');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1015');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1016');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1017');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1018');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1019');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1020');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1021');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1022');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1023');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1024');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1025');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1026');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1027');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1028');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1029');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1030');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1031');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1032');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1033');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1034');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1035');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1036');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1037');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1038');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1039');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1040');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1041');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1042');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1043');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1044');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1045');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1050');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1055');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1056');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1057');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1058');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1059');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1060');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1061');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1062');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1063');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1064');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1065');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1600');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1601');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1602');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1603');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1620');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1621');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1622');
INSERT INTO `sys_role_menu` VALUES ('2083324097974308866', '1623');

-- ----------------------------
-- Table structure for sys_social
-- ----------------------------
DROP TABLE IF EXISTS `sys_social`;
CREATE TABLE `sys_social`  (
  `id` varchar(64) NOT NULL COMMENT '主键',
  `user_id` varchar(64) NOT NULL COMMENT '用户ID',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户id',
  `auth_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '平台+平台唯一id',
  `source` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户来源',
  `open_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '平台编号唯一id',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户昵称',
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像地址',
  `access_token` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户的授权令牌',
  `expire_in` int NULL DEFAULT NULL COMMENT '用户的授权令牌的有效期，部分平台可能没有',
  `refresh_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '刷新令牌，部分平台可能没有',
  `access_code` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '平台的授权信息，部分平台可能没有',
  `union_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户的 unionid',
  `scope` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '授予的权限，部分平台可能没有',
  `token_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '个别平台的授权信息，部分平台可能没有',
  `id_token` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'id token，部分平台可能没有',
  `mac_algorithm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '小米平台用户的附带属性，部分平台可能没有',
  `mac_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '小米平台用户的附带属性，部分平台可能没有',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '用户的授权code，部分平台可能没有',
  `oauth_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Twitter平台用户的附带属性，部分平台可能没有',
  `oauth_token_secret` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Twitter平台用户的附带属性，部分平台可能没有',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '社会化关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_social
-- ----------------------------

-- ----------------------------
-- Table structure for sys_tenant
-- ----------------------------
DROP TABLE IF EXISTS `sys_tenant`;
CREATE TABLE `sys_tenant`  (
  `id` varchar(64) NOT NULL COMMENT 'id',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户编号',
  `contact_user_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `company_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '企业名称',
  `license_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '统一社会信用代码',
  `address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址',
  `intro` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '企业简介',
  `domain` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '域名',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `package_id` varchar(64) NULL DEFAULT NULL COMMENT '租户套餐编号',
  `expire_time` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `account_count` int NULL DEFAULT -1 COMMENT '用户数量（-1不限制）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '租户状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '租户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_tenant
-- ----------------------------
INSERT INTO `sys_tenant` VALUES ('1', '000000', '管理组', '15888888888', 'XXX有限公司', NULL, NULL, '多租户通用后台管理管理系统', NULL, NULL, NULL, NULL, -1, '0', '0', '103', '1', '2026-07-23 16:28:37', NULL, NULL);
INSERT INTO `sys_tenant` VALUES ('2083324090562973697', '545670', 'dalian', '133242342', 'DALIAN-INTERNATIONAL', '', '', '', '', '', '2083322840400281600', NULL, 20, '0', '0', '103', '1', '2026-08-01 06:49:04', '1', '2026-08-01 06:49:04');

-- ----------------------------
-- Table structure for sys_tenant_package
-- ----------------------------
DROP TABLE IF EXISTS `sys_tenant_package`;
CREATE TABLE `sys_tenant_package`  (
  `package_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '租户套餐id',
  `package_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '套餐名称',
  `menu_ids` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联菜单id',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  `menu_check_strictly` tinyint(1) NULL DEFAULT 1 COMMENT '菜单树选择项是否关联显示',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`package_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '租户套餐表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_tenant_package
-- ----------------------------
INSERT INTO `sys_tenant_package` VALUES ('2083322840400281601', 'TEST', '1,100,1001,1002,1003,1004,1005,1006,1007,131,101,1008,1009,1010,1011,1012,130,102,1013,1014,1015,1016,103,1017,1018,1019,1020,104,1021,1022,1023,1024,1025,105,1026,1027,1028,1029,1030,132,106,1031,1032,1033,1034,1035,107,1036,1037,1038,1039,108,500,1040,1041,1042,501,1043,1044,1045,1050,118,1600,1601,1602,1603,1620,1621,1622,1623,133,123,1061,1062,1063,1064,1065,3,115,1055,1056,1058,1057,1059,1060,116', '', 1, '0', '0', '103', '1', '2026-08-01 06:44:06', '1', '2026-08-01 06:48:20');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` varchar(64) NOT NULL COMMENT '用户ID',
  `tenant_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '000000' COMMENT '租户编号',
  `dept_id` varchar(64) NULL DEFAULT NULL COMMENT '部门ID',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户账号',
  `nick_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户昵称',
  `user_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'sys_user' COMMENT '用户类型（sys_user系统用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(64) NULL DEFAULT NULL COMMENT '头像地址',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 1代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `create_dept` varchar(64) NULL DEFAULT NULL COMMENT '创建部门',
  `create_by` varchar(64) NULL DEFAULT NULL COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) NULL DEFAULT NULL COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES ('1', '000000', '103', 'admin', '疯狂的狮子Li', 'sys_user', 'crazyLionLi@163.com', '15888888888', '1', NULL, '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '0:0:0:0:0:0:0:1', '2026-08-02 17:23:53', '103', '1', '2026-07-23 16:28:37', '1', '2026-08-02 17:23:53', '管理员');
INSERT INTO `sys_user` VALUES ('3', '000000', '108', 'test', '本部门及以下 密码666666', 'sys_user', '', '', '0', NULL, '$2a$10$mgbqjVpKi0uDN7NM4JVViObn5l8qFFbb1TeOL168U5GnoCIXz1PfS', '1', '0', '0:0:0:0:0:0:0:1', '2026-07-31 20:03:53', '103', '1', '2026-07-23 16:28:37', '3', '2026-07-31 20:03:53', NULL);
INSERT INTO `sys_user` VALUES ('4', '000000', '102', 'test1', '仅本人 密码666666', 'sys_user', '', '', '0', NULL, '$2a$10$b8yUzN0C71sbz.PhNOCgJe.Tu1yWC3RNrTyjSQ8p1W0.aaUXUJ.Ne', '0', '0', '127.0.0.1', '2026-07-23 16:28:37', '103', '1', '2026-07-23 16:28:37', '4', '2026-07-23 16:28:37', NULL);
INSERT INTO `sys_user` VALUES ('2083324098372767745', '545670', '2083324098108526594', 'dalian', 'dalian', 'sys_user', '', '', '0', NULL, '$2a$10$bG6iLi4e6r.JpasqoXjgs.7FcdB1QO1vBDDlJoCHP7a2SwaRpBqLa', '0', '0', '0:0:0:0:0:0:0:1', '2026-08-01 06:49:47', '103', '1', '2026-08-01 06:49:06', '2083324098372767745', '2026-08-01 06:49:47', NULL);

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` varchar(64) NOT NULL COMMENT '用户ID',
  `post_id` varchar(64) NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES ('1', '1');

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` varchar(64) NOT NULL COMMENT '用户ID',
  `role_id` varchar(64) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES ('1', '1');
INSERT INTO `sys_user_role` VALUES ('3', '3');
INSERT INTO `sys_user_role` VALUES ('4', '4');
INSERT INTO `sys_user_role` VALUES ('2083324098372767745', '2083324097974308866');

SET FOREIGN_KEY_CHECKS = 1;
