package org.dromara.common.monitor.config;

import de.codecentric.boot.admin.server.config.AdminServerProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.LoginUrlAuthenticationEntryPoint;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.security.web.util.matcher.MediaTypeRequestMatcher;

/**
 * Spring Boot Admin 监控平台安全配置
 * <p>
 * 独立于业务 JWT 安全链的监控专用过滤链:
 * 仅匹配监控平台相关路径(Admin UI / instances / actuator 端点)
 * 采用表单登录(浏览器访问) + Basic 认证(客户端注册与端点轮询)
 * 账号密码来自 performance-monitor.username / password
 *
 * @author dromara
 */
@Configuration
@RequiredArgsConstructor
@ConditionalOnProperty(name = "performance-monitor.enabled", havingValue = "true")
public class MonitorSecurityConfig {

    private final AdminServerProperties adminServer;
    private final MonitorProperties monitorProperties;

    /**
     * 监控平台安全过滤链 优先于业务 JWT 过滤链匹配
     */
    @Bean
    @Order(1)
    public SecurityFilterChain monitorSecurityFilterChain(HttpSecurity http) throws Exception {
        // 登录成功后优先回到被拦截的监控页面 无记录时默认进入监控面板首页
        SavedRequestAwareAuthenticationSuccessHandler successHandler = new SavedRequestAwareAuthenticationSuccessHandler();
        successHandler.setDefaultTargetUrl(adminServer.path("/"));
        http
            // /monitor/** 整体归属监控链 (PathPattern 下同时匹配 /monitor 本身)
            // 覆盖 UI 页面/静态资源/instances/applications/actuator 及首页转发后的无尾斜杠路径
            .securityMatcher(adminServer.path("/**"))
            .authorizeHttpRequests(auth -> auth
                // Admin UI 静态资源与登录页放行
                .requestMatchers(adminServer.path("/assets/**"), adminServer.path("/login")).permitAll()
                // /monitor/actuator/** 为 actuator 端点基路径 (management.endpoints.web.base-path) 需 Basic 认证
                .requestMatchers(adminServer.path("/actuator/**")).authenticated()
                // 客户端注册与监控端点轮询通过 Basic 认证访问
                .requestMatchers(HttpMethod.POST, adminServer.path("/instances")).authenticated()
                // 其余监控平台页面需登录后访问
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage(adminServer.path("/login"))
                .successHandler(successHandler)
            )
            // 监控面板使用会话保持登录态 (业务 JWT 链为无状态 互不影响)
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED))
            .logout(logout -> logout.logoutUrl(adminServer.path("/logout")))
            .httpBasic(Customizer.withDefaults())
            // 浏览器访问未登录页面时 302 跳转登录页 AJAX/API 请求返回 401
            .exceptionHandling(ex -> ex
                .defaultAuthenticationEntryPointFor(
                    new LoginUrlAuthenticationEntryPoint(adminServer.path("/login")),
                    new MediaTypeRequestMatcher(MediaType.TEXT_HTML)
                )
            )
            .csrf(AbstractHttpConfigurer::disable);
        return http.build();
    }

    /**
     * 监控平台登录账号 (默认 admin / tomori 可通过 application.yml 修改)
     */
    @Bean
    public InMemoryUserDetailsManager monitorUserDetailsManager() {
        UserDetails user = User.withUsername(monitorProperties.getUsername())
            .password(new BCryptPasswordEncoder().encode(monitorProperties.getPassword()))
            .roles("ADMIN")
            .build();
        return new InMemoryUserDetailsManager(user);
    }

}
