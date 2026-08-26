package org.dromara.common.ai.config;

import com.zaxxer.hikari.HikariDataSource;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.ai.core.AiImageStore;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.chat.memory.repository.jdbc.JdbcChatMemoryRepository;
import org.springframework.ai.chat.memory.repository.jdbc.JdbcChatMemoryRepositoryDialect;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.embedding.EmbeddingModel;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.vectorstore.pgvector.PgVectorStore;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.init.DatabasePopulatorUtils;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;

import javax.sql.DataSource;

/**
 * AI 核心配置
 * <p>
 * 仅在 ai.enabled=true 时生效
 * PostgreSQL 数据源手动配置 用于会话记忆(JDBC)与 pgvector 向量库
 *
 * @author ruoyi
 */
@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(AiProperties.class)
@ConditionalOnProperty(prefix = "ai", name = "enabled", havingValue = "true")
public class AiConfiguration {

    private final AiProperties aiProperties;

    /**
     * AI 专用 PostgreSQL 数据源(手动配置 与业务主库隔离)
     * <p>
     * 注意: 不能注册为容器级 DataSource Bean 否则会被 MyBatis-Plus 自动装配
     * 误选为主数据源 导致所有业务表查询打到 AI 专用库 (relation "ai_conversation" does not exist)
     */
    private DataSource createAiDataSource() {
        AiProperties.Datasource config = aiProperties.getDatasource();
        HikariDataSource dataSource = new HikariDataSource();
        dataSource.setDriverClassName("org.postgresql.Driver");
        dataSource.setJdbcUrl(config.getUrl());
        dataSource.setUsername(config.getUsername());
        dataSource.setPassword(config.getPassword());
        dataSource.setPoolName("ai-pg-pool");
        dataSource.setMaximumPoolSize(10);
        dataSource.setMinimumIdle(2);
        dataSource.setConnectionTimeout(30000);
        return dataSource;
    }

    @Bean
    public JdbcTemplate aiJdbcTemplate() {
        return new JdbcTemplate(createAiDataSource());
    }

    /**
     * 会话记忆 JDBC 仓库 (PostgreSQL)
     */
    @Bean
    public JdbcChatMemoryRepository aiChatMemoryRepository(JdbcTemplate aiJdbcTemplate) {
        // 初始化 SPRING_AI_CHAT_MEMORY 表 使用 spring-ai 内置 postgresql 建表脚本 (幂等 可重复执行)
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator();
        populator.addScript(new ClassPathResource("org/springframework/ai/chat/memory/repository/jdbc/schema-postgresql.sql"));
        populator.setContinueOnError(true);
        DatabasePopulatorUtils.execute(populator, aiJdbcTemplate.getDataSource());
        log.info("AI 会话记忆表结构初始化完成");
        return JdbcChatMemoryRepository.builder()
            .jdbcTemplate(aiJdbcTemplate)
            .dialect(JdbcChatMemoryRepositoryDialect.from(aiJdbcTemplate.getDataSource()))
            .build();
    }

    /**
     * 会话记忆 滑动窗口策略
     */
    @Bean
    public ChatMemory aiChatMemory(JdbcChatMemoryRepository aiChatMemoryRepository) {
        return MessageWindowChatMemory.builder()
            .chatMemoryRepository(aiChatMemoryRepository)
            .maxMessages(aiProperties.getChat().getMaxMessages())
            .build();
    }

    /**
     * PostgreSQL pgvector 向量库
     */
    @Bean
    public VectorStore aiVectorStore(JdbcTemplate aiJdbcTemplate, EmbeddingModel embeddingModel) {
        AiProperties.Vector vector = aiProperties.getVector();
        return PgVectorStore.builder(aiJdbcTemplate, embeddingModel)
            .dimensions(vector.getDimensions())
            .distanceType(PgVectorStore.PgDistanceType.COSINE_DISTANCE)
            .indexType(PgVectorStore.PgIndexType.HNSW)
            .vectorTableName(vector.getTableName())
            .initializeSchema(vector.isInitializeSchema())
            .build();
    }

    /**
     * ChatClient (OpenAI ChatModel 由 spring-ai 自动配置提供)
     */
    @Bean
    public ChatClient aiChatClient(ChatModel chatModel) {
        return ChatClient.builder(chatModel).build();
    }

    /**
     * 上传图片临时存储
     */
    @Bean
    public AiImageStore aiImageStore() {
        return new AiImageStore();
    }

}
