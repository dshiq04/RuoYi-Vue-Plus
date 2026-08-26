package org.dromara.common.ai.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * AI 功能配置属性
 * <p>
 * 总开关 ai.enabled 为 false 时 不加载任何 AI 相关功能 不影响正常启动
 *
 * @author ruoyi
 */
@Data
@ConfigurationProperties(prefix = "ai")
public class AiProperties {

    /**
     * AI 功能总开关
     */
    private boolean enabled = false;

    /**
     * AI 专用 PostgreSQL 数据源 (会话记忆 + 向量库 手动配置)
     */
    private Datasource datasource = new Datasource();

    /**
     * 会话配置
     */
    private Chat chat = new Chat();

    /**
     * 向量库配置
     */
    private Vector vector = new Vector();

    @Data
    public static class Datasource {
        /**
         * JDBC 连接地址
         */
        private String url;
        /**
         * 用户名
         */
        private String username;
        /**
         * 密码
         */
        private String password;
    }

    @Data
    public static class Chat {
        /**
         * 会话记忆窗口大小(条数)
         */
        private int maxMessages = 30;
    }

    @Data
    public static class Vector {
        /**
         * 向量表名
         */
        private String tableName = "ai_vector_store";
        /**
         * 向量维度 需与 Embedding 模型输出维度一致
         */
        private Integer dimensions = 1536;
        /**
         * 相似度检索 topK
         */
        private int topK = 4;
        /**
         * 是否自动初始化向量表结构(含 vector 扩展)
         */
        private boolean initializeSchema = true;
    }

}
