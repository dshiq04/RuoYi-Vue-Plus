package org.dromara.common.social.config.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Social 配置属性
 *
 * @author thiszhc
 */
@Data
@Component
@ConfigurationProperties(prefix = "spring.security.oauth2.client.social")
public class SocialProperties {

    /**
     * OAuth2 提供商配置
     * key 为 registrationId，value 为对应提供商配置
     */
    private Map<String, SocialLoginConfigProperties> provider;

}
