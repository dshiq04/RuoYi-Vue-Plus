package org.dromara.common.social.config;

import org.dromara.common.social.config.properties.SocialProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

/**
 * Social OAuth2配置
 */
@AutoConfiguration
@EnableConfigurationProperties(SocialProperties.class)
public class SocialAutoConfiguration {

}
