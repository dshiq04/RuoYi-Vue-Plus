package org.dromara.common.security.config;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.http.HttpStatus;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.constant.CacheConstants;
import org.dromara.common.core.domain.R;
import org.dromara.common.core.domain.model.LoginUser;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.common.satoken.utils.JwtUtils;
import org.dromara.common.satoken.utils.LoginAuthenticationToken;
import org.dromara.common.satoken.utils.LoginUserDetails;
import org.dromara.common.security.config.properties.SecurityProperties;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtils jwtUtils;
    private final SecurityProperties securityProperties;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        // CORS预检请求直接放行
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            filterChain.doFilter(request, response);
            return;
        }
        String token = resolveToken(request);
        if (StrUtil.isBlank(token)) {
            // 无令牌：排除路径(登录/静态资源/sse等无需JWT)直接放行，其余返回401
            if (isExcludeUrl(request)) {
                filterChain.doFilter(request, response);
                return;
            }
            writeError(response, HttpStatus.HTTP_UNAUTHORIZED, "认证失败，请先登录");
            return;
        }
        try {
            // 解析JWT(校验签名) 失败返回401
            Map<String, Object> payload = jwtUtils.parseToken(token);
            Object expObj = payload.get("exp");
            if (expObj instanceof Number && ((Number) expObj).longValue() * 1000 < System.currentTimeMillis()) {
                // 令牌已过期 返回401
                writeError(response, HttpStatus.HTTP_UNAUTHORIZED, "jwt令牌不合法或已过期，请重新登录");
                return;
            }
        } catch (Exception e) {
            log.warn("JWT token解析失败: {}", e.getMessage());
            writeError(response, HttpStatus.HTTP_UNAUTHORIZED, "jwt令牌不合法，请重新登录");
            return;
        }
        // 查询redis中的令牌 不存在(已被吊销/登出/强退)则返回401
        LoginUser loginUser = RedisUtils.getCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token);
        if (ObjectUtil.isNull(loginUser)) {
            writeError(response, HttpStatus.HTTP_UNAUTHORIZED, "jwt令牌不合法，请重新登录");
            return;
        }
        // 从redis载入的用户信息含全部菜单/角色权限 注入springsecurity上下文
        loginUser.setToken(token);
        LoginUserDetails userDetails = new LoginUserDetails(loginUser);
        LoginAuthenticationToken authentication = new LoginAuthenticationToken(userDetails, userDetails.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(authentication);
        filterChain.doFilter(request, response);
    }

    /**
     * 判断当前请求路径是否在security排除列表(无需JWT)
     */
    private boolean isExcludeUrl(HttpServletRequest request) {
        String path = request.getRequestURI();
        return Arrays.stream(securityProperties.getExcludes())
            .anyMatch(pattern -> pathMatcher.match(pattern, path));
    }

    /**
     * 输出JSON错误响应
     */
    private void writeError(HttpServletResponse response, int code, String msg) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(code);
        response.getWriter().write(objectMapper.writeValueAsString(R.fail(code, msg)));
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
