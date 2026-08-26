package org.dromara.common.monitor.config;

import de.codecentric.boot.admin.server.config.EnableAdminServer;
import org.dromara.common.monitor.controller.MonitorHomeController;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Spring Boot Admin 性能监控配置
 * <p>
 * 仅在 performance-monitor.enabled=true 时启用监控面板服务端
 * 客户端自注册开关由 spring.boot.admin.client.enabled 联动同一配置项控制
 * <p>
 * 注: 使用 @Configuration 由组件扫描发现 (而非 @AutoConfiguration)
 * 确保 @EnableAdminServer 注册的 Marker Bean 早于 SBA 自动配置的条件判断
 *
 * @author dromara
 */
@Configuration
@EnableAdminServer
@EnableConfigurationProperties(MonitorProperties.class)
@ConditionalOnProperty(name = "performance-monitor.enabled", havingValue = "true")
public class MonitorConfiguration {

    /**
     * 监控平台首页入口控制器 (带尾斜杠路径重定向适配)
     */
    @Bean
    public MonitorHomeController monitorHomeController() {
        return new MonitorHomeController();
    }

}
