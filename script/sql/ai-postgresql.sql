-- ----------------------------
-- AI 智能对话模块 PostgreSQL 一键初始化脚本 (整合版)
-- 目标库: application.yml 中 ai.datasource.url 指向的库 (如 192.168.150.10:5432/ruoyi_vue)
-- 说明:
--   1. SPRING_AI_CHAT_MEMORY 聊天记忆表 (Spring AI 官方 schema, 应用启动时也会自动初始化, 此处预建更稳妥)
--   2. ai_vector_store      pgvector 向量表 (与 application.yml ai.vector.table-name 一致,
--                           若 ai.vector.initialize-schema=true 应用启动时也会自动创建)
--   注意: ai_conversation 会话表由 MyBatis-Plus 读写 存在 MySQL 主库, 请执行 ai.sql
--   3. 本脚本全部使用 IF NOT EXISTS, 幂等可重复执行
-- 前置条件: 执行账号需具备 CREATE EXTENSION 权限 (通常为超级用户),
--           pgvector 扩展需已在 PostgreSQL 服务器安装 (apt install postgresql-16-pgvector / 编译安装)
-- ----------------------------

-- ----------------------------
-- 1. 扩展: pgvector / hstore / uuid-ossp (Spring AI 官方要求)
-- ----------------------------
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------
-- 2. 聊天记忆表 (Spring AI 2.0.1 官方 schema-postgresql.sql 原文)
-- ----------------------------
CREATE TABLE IF NOT EXISTS SPRING_AI_CHAT_MEMORY (
    conversation_id VARCHAR(36) NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(10) NOT NULL CHECK (type IN ('USER', 'ASSISTANT', 'SYSTEM', 'TOOL')),
    "timestamp" TIMESTAMP NOT NULL,
    sequence_id BIGINT NOT NULL
);

CREATE INDEX IF NOT EXISTS SPRING_AI_CHAT_MEMORY_CONVERSATION_ID_TIMESTAMP_IDX
    ON SPRING_AI_CHAT_MEMORY(conversation_id, "timestamp");

CREATE INDEX IF NOT EXISTS SPRING_AI_CHAT_MEMORY_CONVERSATION_ID_SEQUENCE_ID_IDX
    ON SPRING_AI_CHAT_MEMORY(conversation_id, sequence_id);

-- ----------------------------
-- 3. pgvector 向量表 (Spring AI PgVectorStore 官方 DDL 模板, 表名/维度与 application.yml 一致)
-- ----------------------------
CREATE TABLE IF NOT EXISTS ai_vector_store (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    content text,
    metadata json,
    embedding vector(1536)
);

-- HNSW 索引 + 余弦距离 (与 AiConfiguration 中 indexType/distanceType 一致)
CREATE INDEX IF NOT EXISTS spring_ai_vector_index
    ON ai_vector_store USING HNSW (embedding vector_cosine_ops);
