package org.dromara.common.web.config;

/**
 * UndertowConfig 类因 Spring Boot 4 移除 Undertow 支持而禁用。
 * Spring Boot 4 默认使用 Tomcat 作为 Web 服务器。
 * 如需 Tomcat 等效配置，请参考 Spring Boot 4 文档。
 *
 * @author Lion Li
 * @deprecated Spring Boot 4 不再支持 Undertow，该类已废弃
 */
// @AutoConfiguration
public class UndertowConfig /* implements WebServerFactoryCustomizer<UndertowServletWebServerFactory> */ {
    // Undertow 已被 Spring Boot 4 移除，相关配置已禁用
    // 如需配置：
    // - 虚拟线程: spring.threads.virtual.enabled=true (已在 application.yml 中启用)
    // - HTTP 方法限制: 可通过 Spring Security 或 Tomcat 阀门配置
    // - multipart 配置: spring.servlet.multipart.max-file-size (已在 application.yml 中配置)
}
