package org.dromara.common.monitor.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 性能监控配置属性
 * <p>
 * performance-monitor.enabled 为 true 时启动 Spring Boot Admin 性能监控
 * 为 false 时不启动监控服务
 *
 * @author dromara
 */
@Data
@ConfigurationProperties(prefix = "performance-monitor")
public class MonitorProperties {

    /**
     * 性能监控开关 true-启动监控 false-不启动
     */
    private boolean enabled = false;

    /**
     * 监控平台登录用户名
     */
    private String username = "admin";

    /**
     * 监控平台登录密码
     */
    private String password;

}
