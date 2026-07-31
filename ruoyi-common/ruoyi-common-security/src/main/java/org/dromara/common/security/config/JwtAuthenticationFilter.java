package org.dromara.common.security.config;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.domain.model.LoginUser;
import org.dromara.common.satoken.utils.JwtUtils;
import org.dromara.common.satoken.utils.LoginAuthenticationToken;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.common.satoken.utils.LoginUserDetails;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String token = resolveToken(request);
        if (StrUtil.isNotBlank(token)) {
            try {
                LoginUser loginUser = jwtUtils.getLoginUserFromToken(token);
                if (loginUser != null) {
                    loginUser.setToken(token);
                    LoginUserDetails userDetails = new LoginUserDetails(loginUser);
                    // 校验header中的clientId与token中的是否一致
                    String headerCid = request.getHeader(LoginHelper.CLIENT_KEY);
                    if (StrUtil.isNotBlank(headerCid) && !StrUtil.equals(loginUser.getClientKey(), headerCid)) {
                        // 不匹配但仍然放行（兼容处理）
                        log.debug("客户端ID与Token不匹配 headerCid={} tokenClientId={}", headerCid, loginUser.getClientKey());
                    }
                    LoginAuthenticationToken authentication = new LoginAuthenticationToken(userDetails, userDetails.getAuthorities());
                    SecurityContextHolder.getContext().setAuthentication(authentication);
                } else {
                    log.warn("JWT token解析返回null, token前缀: {}...", token.length() > 20 ? token.substring(0, 20) : token);
                }
            } catch (Exception e) {
                log.warn("JWT token解析失败: {}", e.getMessage());
            }
        }
        filterChain.doFilter(request, response);
    }

    private String resolveToken(HttpServletRequest request) {
        // 优先从 Header 中获取 token
        String bearerToken = request.getHeader("Authorization");
        if (StrUtil.isNotBlank(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        // 兼容 SSE (EventSource 不支持自定义 Header，token 通过 query 参数传递)
        bearerToken = request.getParameter("Authorization");
        if (StrUtil.isNotBlank(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
