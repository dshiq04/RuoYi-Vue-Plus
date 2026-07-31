package org.dromara.common.social.utils;

import lombok.extern.slf4j.Slf4j;

/**
 * OAuth2社交登录工具类
 */
@Slf4j
public class OAuth2SocialUtils {

    /**
     * 根据source和code构建authId
     */
    public static String buildAuthId(String source, String code) {
        return source + code;
    }
}
