package org.dromara.common.social.utils;

import lombok.Data;

/**
 * OAuth2用户信息
 */
@Data
public class OAuth2UserInfo {
    /**
     * 来源平台
     */
    private String source;
    /**
     * 第三方用户唯一标识
     */
    private String uuid;
    /**
     * 用户名
     */
    private String username;
    /**
     * 昵称
     */
    private String nickname;
    /**
     * 头像
     */
    private String avatar;
    /**
     * access_token
     */
    private String accessToken;
}
