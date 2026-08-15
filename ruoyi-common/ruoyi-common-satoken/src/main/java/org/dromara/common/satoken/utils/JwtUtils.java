package org.dromara.common.satoken.utils;

import cn.hutool.core.util.StrUtil;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.dromara.common.core.constant.CacheConstants;
import org.dromara.common.core.domain.model.LoginUser;
import org.dromara.common.redis.utils.RedisUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT工具类 - 基于HMAC-SHA256手动实现，不依赖第三方JWT库
 */
@Component
public class JwtUtils {

    private static final String HMAC_SHA256 = "HmacSHA256";
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper()
        .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    @Value("${security.jwt.secret-key:abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz0123456789}")
    private String secretKey;

    @Value("${security.jwt.expiration:10080}")
    private long expiration;

    /**
     * 创建JWT Token
     */
    public String createToken(LoginUser loginUser) {
        try {
            long now = System.currentTimeMillis();
            long exp = now + expiration * 60 * 1000;

            // Header
            Map<String, Object> header = new HashMap<>();
            header.put("alg", "HS256");
            header.put("typ", "JWT");

            // Payload
            Map<String, Object> payload = new HashMap<>();
            payload.put(LoginHelper.LOGIN_USER_KEY, loginUser);
            payload.put(LoginHelper.TENANT_KEY, loginUser.getTenantId());
            payload.put(LoginHelper.USER_KEY, loginUser.getUserId());
            payload.put(LoginHelper.USER_NAME_KEY, loginUser.getUsername());
            payload.put(LoginHelper.DEPT_KEY, loginUser.getDeptId());
            payload.put(LoginHelper.DEPT_NAME_KEY, loginUser.getDeptName());
            payload.put(LoginHelper.DEPT_CATEGORY_KEY, loginUser.getDeptCategory());
            payload.put(LoginHelper.CLIENT_KEY, loginUser.getClientKey());
            payload.put("sub", loginUser.getLoginId());
            payload.put("iat", now / 1000);
            payload.put("exp", exp / 1000);

            String headerEncoded = base64UrlEncode(OBJECT_MAPPER.writeValueAsString(header));
            String payloadEncoded = base64UrlEncode(OBJECT_MAPPER.writeValueAsString(payload));
            String content = headerEncoded + "." + payloadEncoded;
            String signature = sign(content);

            return content + "." + signature;
        } catch (Exception e) {
            throw new RuntimeException("创建Token失败", e);
        }
    }

    /**
     * 解析Token获取Payload
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> parseToken(String token) {
        try {
            String[] parts = token.split("\\.");
            if (parts.length != 3) {
                throw new RuntimeException("无效的Token格式");
            }
            // 验证签名
            String content = parts[0] + "." + parts[1];
            String expectedSignature = sign(content);
            if (!expectedSignature.equals(parts[2])) {
                throw new RuntimeException("Token签名验证失败");
            }
            // 解析payload
            String payloadJson = base64UrlDecode(parts[1]);
            return OBJECT_MAPPER.readValue(payloadJson, Map.class);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("解析Token失败", e);
        }
    }

    /**
     * 从Token中获取LoginUser
     */
    @SuppressWarnings("unchecked")
    public LoginUser getLoginUserFromToken(String token) {
        Map<String, Object> payload = parseToken(token);
        Object loginUserObj = payload.get(LoginHelper.LOGIN_USER_KEY);
        if (loginUserObj instanceof Map) {
            try {
                return OBJECT_MAPPER.readValue(OBJECT_MAPPER.writeValueAsString(loginUserObj), LoginUser.class);
            } catch (Exception e) {
                throw new RuntimeException("LoginUser反序列化失败: " + e.getMessage(), e);
            }
        }
        throw new RuntimeException("Token中缺少loginUser信息");
    }

    /**
     * 检查Token是否过期
     */
    public boolean isTokenExpired(String token) {
        try {
            Map<String, Object> payload = parseToken(token);
            Object exp = payload.get("exp");
            if (exp instanceof Number) {
                return ((Number) exp).longValue() * 1000 < System.currentTimeMillis();
            }
            return true;
        } catch (Exception e) {
            return true;
        }
    }

    /**
     * 获取过期时间(分钟)
     */
    public long getExpiration() {
        return expiration;
    }

    /**
     * 销毁令牌（强制登出）
     * <p>
     * 删除redis中该令牌对应的登录用户信息与在线用户信息，使令牌即刻失效
     * </p>
     *
     * @param token 令牌
     */
    public void invalidateToken(String token) {
        if (StrUtil.isBlank(token)) {
            return;
        }
        RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);
        RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + token);
    }

    private String base64UrlEncode(String data) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(data.getBytes(StandardCharsets.UTF_8));
    }

    private String base64UrlDecode(String data) {
        return new String(Base64.getUrlDecoder().decode(data), StandardCharsets.UTF_8);
    }

    private String sign(String data) {
        try {
            Mac mac = Mac.getInstance(HMAC_SHA256);
            SecretKeySpec keySpec = new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), HMAC_SHA256);
            mac.init(keySpec);
            byte[] hash = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("签名失败", e);
        }
    }
}
