package org.dromara.common.social.config.properties;

import lombok.Data;

import java.util.List;

/**
 * 社交登录配置
 *
 * @author thiszhc
 */
@Data
public class SocialLoginConfigProperties {

    /**
     * OAuth2 提供商的 Issuer URI
     */
    private String issuerUri;

    /**
     * 客户端 ID
     */
    private String clientId;

    /**
     * 客户端密钥
     */
    private String clientSecret;

    /**
     * 回调地址
     */
    private String redirectUri;

    /**
     * 请求范围
     */
    private List<String> scopes;

    /**
     * 客户端名称
     */
    private String clientName;

}
