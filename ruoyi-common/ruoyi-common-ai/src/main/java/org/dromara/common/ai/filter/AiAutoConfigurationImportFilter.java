package org.dromara.common.ai.filter;

import org.springframework.boot.autoconfigure.AutoConfigurationImportFilter;
import org.springframework.boot.autoconfigure.AutoConfigurationMetadata;
import org.springframework.context.EnvironmentAware;
import org.springframework.core.env.Environment;

/**
 * AI 总开关自动配置过滤器
 * <p>
 * 当 ai.enabled 为 false(默认) 时 过滤掉所有 org.springframework.ai 包下的自动配置类
 * 确保 AI 功能完全不加载 不影响项目正常启动
 *
 * @author ruoyi
 */
public class AiAutoConfigurationImportFilter implements AutoConfigurationImportFilter, EnvironmentAware {

    private static final String AI_AUTOCONFIG_PREFIX = "org.springframework.ai";

    private Environment environment;

    @Override
    public void setEnvironment(Environment environment) {
        this.environment = environment;
    }

    @Override
    public boolean[] match(String[] autoConfigurationClasses, AutoConfigurationMetadata autoConfigurationMetadata) {
        boolean enabled = environment != null
            && Boolean.parseBoolean(environment.getProperty("ai.enabled", "false"));
        boolean[] result = new boolean[autoConfigurationClasses.length];
        for (int i = 0; i < autoConfigurationClasses.length; i++) {
            String className = autoConfigurationClasses[i];
            // true 保留 / false 排除, 开关关闭时排除所有 spring-ai 自动配置
            result[i] = className == null || enabled || !className.startsWith(AI_AUTOCONFIG_PREFIX);
        }
        return result;
    }

}
