# Spring Security JWT + Redis 令牌校验 与 Spring Cache 字典优化 — 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 登录后将 JWT 令牌与用户/角色权限写入 Redis（7 天），非登录请求经"无令牌401 → 解析JWT → Redis校验 → 注入上下文 → 正常鉴权"链路，字典/配置缓存完全注解化，Redis 键统一重命名为大写+下划线。

**Architecture:** 登录成功时由 `SysLoginService.onLoginSuccess(LoginUser, String)` 将完整 `LoginUser`（内含 menuPermission/rolePermission）写入 `LOGIN_TOKEN:<token>`、在线用户 DTO 写入 `ONLINE_TOKENS:<token>`，均 7 天 TTL。`JwtAuthenticationFilter` 对非排除路径执行令牌校验并注入 SecurityContext，后续由 `@PreAuthorize("hasAuthority(...)")` 鉴权（无权限→403）。字典/配置缓存改用 `@Cacheable/@CacheEvict/@CachePut` 注解。

**Tech Stack:** Java 21、Spring Boot 4、Spring Security 6、Redisson、Spring Cache、Maven 3.9。

## Global Constraints

- Redis 键全部大写 + 下划线 + 英文语义（如 `LOGIN_TOKEN:`、`SYS_DICT`）。
- JWT 有效期与 Redis TTL 均为 7 天（`expiration: 10080` 分钟）。
- 登录/静态资源/sse 等排除路径（`security.excludes`）不要求 JWT；带令牌时仍需校验。
- 权限鉴权沿用现有 `@PreAuthorize("hasAuthority('...')")`，无权限由 `accessDeniedHandler` 返回 403。
- 字典/配置缓存规则：查询 `@Cacheable`、删除 `@CacheEvict(allEntries=true)`、修改 `@Caching(evict+put)`、插入 `@CachePut`。
- 旧 Redis 键为孤儿数据，开发环境可手动清库，不做迁移。

---
---

### Task 1: Redis 键常量重命名

**Files:**
- Modify: `ruoyi-common/ruoyi-common-core/src/main/java/org/dromara/common/core/constant/CacheConstants.java`
- Modify: `ruoyi-common/ruoyi-common-core/src/main/java/org/dromara/common/core/constant/CacheNames.java`
- Modify: `ruoyi-common/ruoyi-common-core/src/main/java/org/dromara/common/core/constant/GlobalConstants.java`

**Interfaces:**
- Consumes: 无。
- Produces: `CacheConstants.LOGIN_TOKEN_KEY`（新增）、`CacheConstants.ONLINE_TOKEN_KEY`、`CacheConstants.SYS_CONFIG_KEY`、`CacheConstants.SYS_DICT_KEY`、`CacheConstants.PWD_ERR_CNT_KEY`；`CacheNames.SYS_CONFIG`、`CacheNames.SYS_DICT`、`CacheNames.SYS_DICT_TYPE`、`CacheNames.ONLINE_TOKEN` 等；`GlobalConstants.GLOBAL_REDIS_KEY` 等。后续任务全部通过这些常量引用。

- [ ] **Step 1: 重写 CacheConstants.java 全文**

```java
package org.dromara.common.core.constant;

/**
 * 缓存的key 常量
 *
 * @author Lion Li
 */
public interface CacheConstants {

    /**
     * 登录令牌 redis key
     */
    String LOGIN_TOKEN_KEY = "LOGIN_TOKEN:";

    /**
     * 在线用户 redis key
     */
    String ONLINE_TOKEN_KEY = "ONLINE_TOKENS:";

    /**
     * 参数管理 cache key
     */
    String SYS_CONFIG_KEY = "SYS_CONFIG:";

    /**
     * 字典管理 cache key
     */
    String SYS_DICT_KEY = "SYS_DICT:";

    /**
     * 登录账户密码错误次数 redis key
     */
    String PWD_ERR_CNT_KEY = "PWD_ERR_CNT:";

}
```

- [ ] **Step 2: 重写 CacheNames.java 全文**

```java
package org.dromara.common.core.constant;

/**
 * 缓存组名称常量
 * <p>
 * key 格式为 cacheNames#ttl#maxIdleTime#maxSize#local
 * <p>
 * ttl 过期时间 如果设置为0则不过期 默认为0
 * maxIdleTime 最大空闲时间 根据LRU算法清理空闲数据 如果设置为0则不检测 默认为0
 * maxSize 组最大长度 根据LRU算法清理溢出数据 如果设置为0则无限长 默认为0
 * local 默认开启本地缓存为1 关闭本地缓存为0
 * <p>
 * 例子: test#60s、test#0#60s、test#0#1m#1000、test#1h#0#500、test#1h#0#500#0
 *
 * @author Lion Li
 */
public interface CacheNames {

    /**
     * 演示案例
     */
    String DEMO_CACHE = "DEMO_CACHE#60s#10m#20";

    /**
     * 系统配置
     */
    String SYS_CONFIG = "SYS_CONFIG";

    /**
     * 数据字典
     */
    String SYS_DICT = "SYS_DICT";

    /**
     * 数据字典类型
     */
    String SYS_DICT_TYPE = "SYS_DICT_TYPE";

    /**
     * 租户
     */
    String SYS_TENANT = GlobalConstants.GLOBAL_REDIS_KEY + "SYS_TENANT#30d";

    /**
     * 客户端
     */
    String SYS_CLIENT = GlobalConstants.GLOBAL_REDIS_KEY + "SYS_CLIENT#30d";

    /**
     * 用户账户
     */
    String SYS_USER_NAME = "SYS_USER_NAME#30d";

    /**
     * 用户昵称
     */
    String SYS_NICKNAME = "SYS_NICKNAME#30d";

    /**
     * 部门
     */
    String SYS_DEPT = "SYS_DEPT#30d";

    /**
     * OSS内容
     */
    String SYS_OSS = "SYS_OSS#30d";

    /**
     * 角色自定义权限
     */
    String SYS_ROLE_CUSTOM = "SYS_ROLE_CUSTOM#30d";

    /**
     * 部门及以下权限
     */
    String SYS_DEPT_AND_CHILD = "SYS_DEPT_AND_CHILD#30d";

    /**
     * OSS配置
     */
    String SYS_OSS_CONFIG = GlobalConstants.GLOBAL_REDIS_KEY + "SYS_OSS_CONFIG";

    /**
     * 在线用户
     */
    String ONLINE_TOKEN = "ONLINE_TOKENS";

}
```

- [ ] **Step 3: 重写 GlobalConstants.java 全文**

```java
package org.dromara.common.core.constant;

/**
 * 全局的key常量 (业务无关的key)
 *
 * @author Lion Li
 */
public interface GlobalConstants {

    /**
     * 全局 redis key (业务无关的key)
     */
    String GLOBAL_REDIS_KEY = "GLOBAL:";

    /**
     * 验证码 redis key
     */
    String CAPTCHA_CODE_KEY = GLOBAL_REDIS_KEY + "CAPTCHA_CODES:";

    /**
     * 防重提交 redis key
     */
    String REPEAT_SUBMIT_KEY = GLOBAL_REDIS_KEY + "REPEAT_SUBMIT:";

    /**
     * 限流 redis key
     */
    String RATE_LIMIT_KEY = GLOBAL_REDIS_KEY + "RATE_LIMIT:";

    /**
     * 三方认证 redis key
     */
    String SOCIAL_AUTH_CODE_KEY = GLOBAL_REDIS_KEY + "SOCIAL_AUTH_CODES:";
}
```

- [ ] **Step 4: 编译验证**

Run: `mvn -q -T 1C -pl ruoyi-common/ruoyi-common-core compile`
Expected: `BUILD SUCCESS`

- [ ] **Step 5: 提交**

```bash
git add ruoyi-common/ruoyi-common-core/src/main/java/org/dromara/common/core/constant/CacheConstants.java ruoyi-common/ruoyi-common-core/src/main/java/org/dromara/common/core/constant/CacheNames.java ruoyi-common/ruoyi-common-core/src/main/java/org/dromara/common/core/constant/GlobalConstants.java
git commit -m "refactor: redis缓存键统一重命名为大写下划线格式"
```

---
---

### Task 2: JWT 有效期改为 7 天

**Files:**
- Modify: `ruoyi-common/ruoyi-common-satoken/src/main/java/org/dromara/common/satoken/utils/JwtUtils.java:31`
- Modify: `ruoyi-admin/src/main/resources/application.yml:106-111`
- Modify: `ruoyi-common/ruoyi-common-satoken/src/main/resources/common-security.yml`

**Interfaces:**
- Consumes: 无。
- Produces: `JwtUtils.getExpiration()` 返回 10080，`LoginVo.expireIn = 604800` 秒（7 天）。

- [ ] **Step 1: JwtUtils 默认值改为 7 天**

将 `ruoyi-common/ruoyi-common-satoken/src/main/java/org/dromara/common/satoken/utils/JwtUtils.java` 第 31 行：

```java
    @Value("${security.jwt.expiration:30}")
    private long expiration;
```

改为：

```java
    @Value("${security.jwt.expiration:10080}")
    private long expiration;
```

- [ ] **Step 2: application.yml 改为 7 天**

将 `ruoyi-admin/src/main/resources/application.yml` 中：

```yaml
  jwt:
    # jwt秘钥 (至少256位 / 32字符 for HS256)
    secret-key: abcdefghijklmnopqrstuvwxyz0123456789
    # token有效期(分钟)
    expiration: 30
```

改为：

```yaml
  jwt:
    # jwt秘钥 (至少256位 / 32字符 for HS256)
    secret-key: abcdefghijklmnopqrstuvwxyz0123456789
    # token有效期(分钟) 7天
    expiration: 10080
```

- [ ] **Step 3: common-security.yml 改为 7 天**

将 `ruoyi-common/ruoyi-common-satoken/src/main/resources/common-security.yml` 中 `expiration: 30` 改为 `expiration: 10080`。

- [ ] **Step 4: 编译验证**

Run: `mvn -q -T 1C -pl ruoyi-common/ruoyi-common-satoken compile`
Expected: `BUILD SUCCESS`

- [ ] **Step 5: 提交**

```bash
git add ruoyi-common/ruoyi-common-satoken/src/main/java/org/dromara/common/satoken/utils/JwtUtils.java ruoyi-admin/src/main/resources/application.yml ruoyi-common/ruoyi-common-satoken/src/main/resources/common-security.yml
git commit -m "feat: jwt令牌有效期调整为7天"
```

---
---

### Task 3: 登录成功写 Redis + 修复在线用户 + 注销改造

**Files:**
- Modify: `ruoyi-admin/src/main/java/org/dromara/web/service/SysLoginService.java`
- Modify: `ruoyi-admin/src/main/java/org/dromara/web/service/impl/PasswordAuthStrategy.java:74`
- Modify: `ruoyi-admin/src/main/java/org/dromara/web/service/impl/EmailAuthStrategy.java:62`
- Modify: `ruoyi-admin/src/main/java/org/dromara/web/service/impl/SmsAuthStrategy.java:62`
- Modify: `ruoyi-admin/src/main/java/org/dromara/web/service/impl/SocialAuthStrategy.java:84`
- Modify: `ruoyi-admin/src/main/java/org/dromara/web/service/impl/XcxAuthStrategy.java:60`
- Delete: `ruoyi-admin/src/main/java/org/dromara/web/listener/UserActionListener.java`

**Interfaces:**
- Consumes: `CacheConstants.LOGIN_TOKEN_KEY`、`CacheConstants.ONLINE_TOKEN_KEY`（Task 1）。
- Produces: `SysLoginService.onLoginSuccess(LoginUser loginUser, String token)` —— 登录成功后写令牌/在线用户到 Redis（7 天）、记录登录日志、更新最近登录信息。5 个策略在 `createToken` 后调用。

- [ ] **Step 1: SysLoginService 新增 onLoginSuccess 并改造 logout**

在 `ruoyi-admin/src/main/java/org/dromara/web/service/SysLoginService.java` 顶部新增 import（在现有 import 之后）：

```java
import cn.hutool.core.util.StrUtil;
import cn.hutool.http.useragent.UserAgent;
import cn.hutool.http.useragent.UserAgentUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.dromara.common.core.constant.CacheConstants;
import org.dromara.common.core.domain.dto.UserOnlineDTO;
import org.dromara.common.core.utils.ip.AddressUtils;
```

将 `logout()` 方法整体替换为：

```java
    /**
     * 退出登录
     */
    public void logout() {
        try {
            LoginUser loginUser = LoginHelper.getLoginUser();
            String token = resolveToken(ServletUtils.getRequest());
            if (ObjectUtil.isNull(loginUser) && StrUtil.isNotBlank(token)) {
                // 认证上下文为空时 尝试从redis取用户信息
                loginUser = RedisUtils.getCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token);
            }
            if (ObjectUtil.isNull(loginUser)) {
                return;
            }
            if (TenantHelper.isEnable() && LoginHelper.isSuperAdmin()) {
                // 超级管理员 登出清除动态租户
                TenantHelper.clearDynamic();
            }
            String tenantId = loginUser.getTenantId();
            TenantHelper.dynamic(tenantId, () -> {
                // 删除登录令牌与在线用户信息
                RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);
                RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + token);
            });
            recordLogininfor(tenantId, loginUser.getUsername(), Constants.LOGOUT, MessageUtils.message("user.logout.success"));
        } catch (Exception ignored) {
        } finally {
            SecurityContextHolder.clearContext();
        }
    }

    /**
     * 从请求头或请求参数中解析JWT令牌
     */
    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StrUtil.isNotBlank(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        bearerToken = request.getParameter("Authorization");
        if (StrUtil.isNotBlank(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
```

在 `logout()` 方法之后（`recordLogininfor` 方法之前）新增 `onLoginSuccess` 方法：

```java
    /**
     * 登录成功后处理：存储令牌与用户/角色权限到redis、记录在线用户、写入登录日志、更新最近登录信息
     *
     * @param loginUser 登录用户
     * @param token     JWT令牌
     */
    public void onLoginSuccess(LoginUser loginUser, String token) {
        loginUser.setToken(token);
        HttpServletRequest request = ServletUtils.getRequest();
        UserAgent userAgent = UserAgentUtil.parse(request.getHeader("User-Agent"));
        String ip = ServletUtils.getClientIP();
        // 1. 令牌与用户/角色权限存入redis 有效期7天
        // 2. 在线用户信息存入redis 有效期7天
        TenantHelper.dynamic(loginUser.getTenantId(), () -> {
            RedisUtils.setCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token, loginUser, Duration.ofDays(7));
            UserOnlineDTO dto = new UserOnlineDTO();
            dto.setIpaddr(ip);
            dto.setLoginLocation(AddressUtils.getRealAddressByIP(ip));
            dto.setBrowser(userAgent.getBrowser().getName());
            dto.setOs(userAgent.getOs().getName());
            dto.setLoginTime(System.currentTimeMillis());
            dto.setTokenId(token);
            dto.setUserName(loginUser.getUsername());
            dto.setClientKey(loginUser.getClientKey());
            dto.setDeviceType(loginUser.getDeviceType());
            dto.setDeptName(loginUser.getDeptName());
            RedisUtils.setCacheObject(CacheConstants.ONLINE_TOKEN_KEY + token, dto, Duration.ofDays(7));
        });
        // 3. 记录登录日志
        recordLogininfor(loginUser.getTenantId(), loginUser.getUsername(), Constants.LOGIN_SUCCESS, MessageUtils.message("user.login.success"));
        // 4. 更新最近登录信息
        recordLoginInfo(loginUser.getUserId(), ip);
        log.info("user doLogin, userId:{}, token:***{}", loginUser.getUserId(), StringUtils.right(token, 8));
    }
```

注：`SysLoginService` 第 20 行已有 `import org.dromara.common.core.utils.*;` 通配符导入，`ServletUtils`/`StringUtils`/`MessageUtils` 无需额外导入；第 23 行已导入 `RedisUtils`；第 36 行已导入 `Duration`。`DataPermissionHelper`、`SysUser`、`SysUserMapper` 已导入（`recordLoginInfo` 使用）。

- [ ] **Step 2: 5 个认证策略登录成功后调用 onLoginSuccess**

对以下 5 个文件，在 `String token = jwtUtils.createToken(loginUser);` 与下一行之间插入 `loginService.onLoginSuccess(loginUser, token);`：

- `ruoyi-admin/src/main/java/org/dromara/web/service/impl/PasswordAuthStrategy.java`（第 74 行后）
- `ruoyi-admin/src/main/java/org/dromara/web/service/impl/EmailAuthStrategy.java`（第 62 行后）
- `ruoyi-admin/src/main/java/org/dromara/web/service/impl/SmsAuthStrategy.java`（第 62 行后）
- `ruoyi-admin/src/main/java/org/dromara/web/service/impl/SocialAuthStrategy.java`（第 84 行后）
- `ruoyi-admin/src/main/java/org/dromara/web/service/impl/XcxAuthStrategy.java`（第 60 行后）

以 PasswordAuthStrategy 为例，编辑后应为：

```java
        LoginHelper.login(loginUser);
        String token = jwtUtils.createToken(loginUser);
        // 登录成功后写入redis令牌与权限
        loginService.onLoginSuccess(loginUser, token);
```

其余 4 个文件做相同插入（其 `loginService` 字段均已注入，已核实）。

- [ ] **Step 3: 删除死代码 UserActionListener**

删除文件 `ruoyi-admin/src/main/java/org/dromara/web/listener/UserActionListener.java`（其逻辑已并入 `SysLoginService.onLoginSuccess` 与 `logout`）。

Run: `git rm ruoyi-admin/src/main/java/org/dromara/web/listener/UserActionListener.java`

- [ ] **Step 4: 编译验证**

Run: `mvn -q -T 1C -pl ruoyi-admin -am compile`
Expected: `BUILD SUCCESS`

- [ ] **Step 5: 提交**

```bash
git add ruoyi-admin/src/main/java/org/dromara/web/service/SysLoginService.java ruoyi-admin/src/main/java/org/dromara/web/service/impl/PasswordAuthStrategy.java ruoyi-admin/src/main/java/org/dromara/web/service/impl/EmailAuthStrategy.java ruoyi-admin/src/main/java/org/dromara/web/service/impl/SmsAuthStrategy.java ruoyi-admin/src/main/java/org/dromara/web/service/impl/SocialAuthStrategy.java ruoyi-admin/src/main/java/org/dromara/web/service/impl/XcxAuthStrategy.java
git add -u ruoyi-admin/src/main/java/org/dromara/web/listener/UserActionListener.java
git commit -m "feat: 登录成功将jwt令牌与权限写入redis(7天) 修复在线用户记录与注销删除令牌"
```

---
---

### Task 4: 重写 JwtAuthenticationFilter + SecurityConfig 注入

**Files:**
- Modify: `ruoyi-common/ruoyi-common-security/src/main/java/org/dromara/common/security/config/JwtAuthenticationFilter.java`
- Modify: `ruoyi-common/ruoyi-common-security/src/main/java/org/dromara/common/security/config/SecurityConfig.java:44-47`

**Interfaces:**
- Consumes: `CacheConstants.LOGIN_TOKEN_KEY`（Task 1）、`SecurityProperties.getExcludes()`、`JwtUtils`。
- Produces: 无（过滤器内部行为：非排除路径无令牌→401；令牌解析失败/过期→401；Redis 无令牌→401"jwt令牌不合法"；否则注入 SecurityContext 放行）。

- [ ] **Step 1: 重写 JwtAuthenticationFilter.java 全文**

```java
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
```

说明：`ruoyi-common-security` 通过 `ruoyi-common-satoken` 传递依赖 `ruoyi-common-redis`，可直接使用 `RedisUtils`（已核实 pom）。原过滤器中的 clientId 匹配仅打 debug 日志且恒放行，已移除。

- [ ] **Step 2: SecurityConfig 传入 SecurityProperties**

将 `ruoyi-common/ruoyi-common-security/src/main/java/org/dromara/common/security/config/SecurityConfig.java` 第 44-47 行：

```java
    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter(jwtUtils);
    }
```

改为：

```java
    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter(jwtUtils, securityProperties);
    }
```

（`securityProperties` 字段已存在，无需新增。）

- [ ] **Step 3: 编译验证**

Run: `mvn -q -T 1C -pl ruoyi-common/ruoyi-common-security -am compile`
Expected: `BUILD SUCCESS`

- [ ] **Step 4: 提交**

```bash
git add ruoyi-common/ruoyi-common-security/src/main/java/org/dromara/common/security/config/JwtAuthenticationFilter.java ruoyi-common/ruoyi-common-security/src/main/java/org/dromara/common/security/config/SecurityConfig.java
git commit -m "feat: jwt过滤器增加redis令牌校验 无令牌/解析失败/已吊销返回401"
```

---
---

### Task 5: 令牌吊销联动（强退 + 角色/用户清理）

**Files:**
- Modify: `ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/controller/monitor/SysUserOnlineController.java`
- Modify: `ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysRoleServiceImpl.java`

**Interfaces:**
- Consumes: `CacheConstants.LOGIN_TOKEN_KEY`、`CacheConstants.ONLINE_TOKEN_KEY`（Task 1）。
- Produces: 无（删除令牌使目标用户立即 401）。

- [ ] **Step 1: SysUserOnlineController 强退同时删除登录令牌**

`SysUserOnlineController.java` 第 86-92 行 `forceLogout` 方法：

```java
    @DeleteMapping("/{tokenId}")
    public R<Void> forceLogout(@PathVariable String tokenId) {
        try {
            RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + tokenId);
            RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + tokenId);
        } catch (Exception ignored) {
        }
        return R.ok();
    }
```

第 128-131 行 `remove`（强退当前在线设备）的 `.ifPresent(...)` 块改为：

```java
                .ifPresent(dto -> {
                    RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + tokenId);
                    RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + tokenId);
                });
```

- [ ] **Step 2: SysRoleServiceImpl 角色/用户清理同步删除登录令牌**

`SysRoleServiceImpl.java` `cleanOnlineUserByRole`（约 552-557 行）：

```java
            if (loginUser.getRoles().stream().anyMatch(r -> r.getRoleId().equals(roleId))) {
                try {
                    RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);
                    RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + token);
                } catch (Exception ignored) {
                }
            }
```

`cleanOnlineUser`（约 589-593 行）：

```java
            if (userIds.contains(loginUser.getUserId())) {
                try {
                    RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + token);
                    RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + token);
                } catch (Exception ignored) {
                }
            }
```

- [ ] **Step 3: 编译验证**

Run: `mvn -q -T 1C -pl ruoyi-modules/ruoyi-system -am compile`
Expected: `BUILD SUCCESS`

- [ ] **Step 4: 提交**

```bash
git add ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/controller/monitor/SysUserOnlineController.java ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysRoleServiceImpl.java
git commit -m "fix: 强退/角色变更/用户清理时同步删除redis登录令牌"
```

---
---

### Task 6: 字典/配置缓存注解化

**Files:**
- Modify: `ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysDictDataServiceImpl.java`
- Modify: `ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysDictTypeServiceImpl.java`
- Modify: `ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysConfigServiceImpl.java`

**Interfaces:**
- Consumes: `CacheNames.SYS_DICT`、`CacheNames.SYS_DICT_TYPE`、`CacheNames.SYS_CONFIG`（Task 1）。
- Produces: 字典/配置缓存全部走 Spring Cache 注解；删除/重置用 `@CacheEvict(allEntries=true)`，修改用 `@Caching(evict + put)`。

- [ ] **Step 1: SysDictDataServiceImpl 注解化**

a) 替换 import：将 `import org.dromara.common.redis.utils.CacheUtils;` 删除，新增：

```java
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Caching;
```

b) `deleteDictDataByIds`（约 103-108 行）替换为：

```java
    @CacheEvict(cacheNames = CacheNames.SYS_DICT, allEntries = true)
    @Override
    public void deleteDictDataByIds(List<Long> dictCodes) {
        baseMapper.deleteByIds(dictCodes);
    }
```

c) `updateDictData`（约 133-134 行）将原 `@CachePut` 注解替换为：

```java
    @Caching(
        evict = @CacheEvict(cacheNames = CacheNames.SYS_DICT, allEntries = true),
        put = @CachePut(cacheNames = CacheNames.SYS_DICT, key = "#bo.dictType")
    )
    @Override
    public List<SysDictDataVo> updateDictData(SysDictDataBo bo) {
```

（方法体不变；`insertDictData` 的 `@CachePut` 保留。）

- [ ] **Step 2: SysDictTypeServiceImpl 注解化**

a) 替换 import：删除 `import org.dromara.common.redis.utils.CacheUtils;`，新增：

```java
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Caching;
```

b) `deleteDictTypeByIds`（约 139-154 行）替换为：

```java
    @Caching(evict = {
        @CacheEvict(cacheNames = CacheNames.SYS_DICT, allEntries = true),
        @CacheEvict(cacheNames = CacheNames.SYS_DICT_TYPE, allEntries = true)
    })
    @Override
    public void deleteDictTypeByIds(List<Long> dictIds) {
        List<SysDictType> list = baseMapper.selectByIds(dictIds);
        list.forEach(x -> {
            boolean assigned = dictDataMapper.exists(new LambdaQueryWrapper<SysDictData>()
                .eq(SysDictData::getDictType, x.getDictType()));
            if (assigned) {
                throw new ServiceException("{}已分配,不能删除", x.getDictName());
            }
        });
        baseMapper.deleteByIds(dictIds);
    }
```

c) `resetDictCache`（约 158-163 行）替换为：

```java
    @Caching(evict = {
        @CacheEvict(cacheNames = CacheNames.SYS_DICT, allEntries = true),
        @CacheEvict(cacheNames = CacheNames.SYS_DICT_TYPE, allEntries = true)
    })
    @Override
    public void resetDictCache() {
    }
```

d) `updateDictType`（约 189-205 行）将原 `@CachePut` 注解替换为 `@Caching`，并删除方法体内的 `CacheUtils.evict` 两行：

```java
    @Caching(
        evict = {
            @CacheEvict(cacheNames = CacheNames.SYS_DICT, allEntries = true),
            @CacheEvict(cacheNames = CacheNames.SYS_DICT_TYPE, allEntries = true)
        },
        put = @CachePut(cacheNames = CacheNames.SYS_DICT, key = "#bo.dictType")
    )
    @Override
    @Transactional(rollbackFor = Exception.class)
    public List<SysDictDataVo> updateDictType(SysDictTypeBo bo) {
        SysDictType dict = MapstructUtils.convert(bo, SysDictType.class);
        SysDictType oldDict = baseMapper.selectById(dict.getDictId());
        dictDataMapper.update(null, new LambdaUpdateWrapper<SysDictData>()
            .set(SysDictData::getDictType, dict.getDictType())
            .eq(SysDictData::getDictType, oldDict.getDictType()));
        int row = baseMapper.updateById(dict);
        if (row > 0) {
            return dictDataMapper.selectDictDataByType(dict.getDictType());
        }
        throw new ServiceException("操作失败");
    }
```

（说明：`allEntries=true` 会整组清空 `SYS_DICT`/`SYS_DICT_TYPE`，旧 type 键与新 type 键都覆盖，故原先针对 `oldDict.getDictType()` 的两行手动 `CacheUtils.evict` 可安全删除。）

e) `selectDictDataByType`/`selectDictTypeByType` 的 `@Cacheable`、`insertDictType` 的 `@CachePut` 均保留不变。

- [ ] **Step 3: SysConfigServiceImpl 注解化**

a) 替换 import：删除 `import org.dromara.common.redis.utils.CacheUtils;`，新增：

```java
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Caching;
```

b) `deleteConfigByIds`（约 173-183 行）替换为：

```java
    @CacheEvict(cacheNames = CacheNames.SYS_CONFIG, allEntries = true)
    @Override
    public void deleteConfigByIds(List<Long> configIds) {
        List<SysConfig> list = baseMapper.selectByIds(configIds);
        list.forEach(config -> {
            if (StringUtils.equals(SystemConstants.YES, config.getConfigType())) {
                throw new ServiceException("内置参数【{}】不能删除", config.getConfigKey());
            }
        });
        baseMapper.deleteByIds(configIds);
    }
```

c) `updateConfig`（约 146-166 行）将原 `@CachePut` 注解替换为 `@Caching`，并删除方法体内的 `CacheUtils.evict` 分支：

```java
    @Caching(
        evict = @CacheEvict(cacheNames = CacheNames.SYS_CONFIG, allEntries = true),
        put = @CachePut(cacheNames = CacheNames.SYS_CONFIG, key = "#bo.configKey")
    )
    @Override
    public String updateConfig(SysConfigBo bo) {
        int row = 0;
        SysConfig config = MapstructUtils.convert(bo, SysConfig.class);
        if (config.getConfigId() != null) {
            row = baseMapper.updateById(config);
        } else {
            row = baseMapper.update(config, new LambdaQueryWrapper<SysConfig>()
                .eq(SysConfig::getConfigKey, config.getConfigKey()));
        }
        if (row > 0) {
            return config.getConfigValue();
        }
        throw new ServiceException("操作失败");
    }
```

（说明：`allEntries=true` 整组清空 `SYS_CONFIG`，原 key 变更时对旧 key 的 `CacheUtils.evict` 冗余，删除。`configId != null` 分支中原 `SysConfig temp = baseMapper.selectById(...)` 亦不再需要。）

d) `resetConfigCache`（约 188-191 行）替换为：

```java
    @CacheEvict(cacheNames = CacheNames.SYS_CONFIG, allEntries = true)
    @Override
    public void resetConfigCache() {
    }
```

e) `selectConfigByKey` 的 `@Cacheable`、`insertConfig` 的 `@CachePut` 保留不变。

- [ ] **Step 4: 全局编译验证**

Run: `mvn -q -T 1C compile`
Expected: `BUILD SUCCESS`

- [ ] **Step 5: 提交**

```bash
git add ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysDictDataServiceImpl.java ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysDictTypeServiceImpl.java ruoyi-modules/ruoyi-system/src/main/java/org/dromara/system/service/impl/SysConfigServiceImpl.java
git commit -m "refactor: 字典与配置缓存改用spring cache注解(@CacheEvict/@CachePut/@Cacheable)"
```

---
---

### Task 7: 编译、测试、运行验证

**Files:**
- 无（验证任务）。

**Interfaces:**
- Consumes: 以上全部任务的产物。

- [ ] **Step 1: 全量编译**

Run: `mvn -q -T 1C clean compile`
Expected: `BUILD SUCCESS`（退出码 0，无 ERROR）

- [ ] **Step 2: 运行模块测试**

Run: `mvn -q -pl ruoyi-admin -am test`
Expected: 测试通过（`Tests run: N, Failures: 0, Errors: 0, Skipped: 0`；现有测试为纯单元测试 `AssertUnitTest`/`DemoUnitTest`/`ParamUnitTest`/`TagUnitTest`，不依赖 DB/Redis）

- [ ] **Step 3: 启动验证**

Run: `cd ruoyi-admin && mvn -q spring-boot:run`（后台运行，观察启动日志约 30-60 秒）

Expected: 应用启动成功，出现 `Started RuoYiApplication`（或等价启动完成日志）。

若 `192.168.150.10` 的 MySQL/Redis 不可达导致启动失败，如实记录报错（如连接超时），并说明需要可用环境进行运行期验证。

- [ ] **Step 4: 运行期冒烟验证（若环境可达）**

用 curl 按顺序验证（Redis 需开启）：

1. 无令牌访问受保护接口 → 401：
   `curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/system/user/list` → 期望 `401`
2. 登录获取令牌：
   `curl -s -X POST http://localhost:8080/auth/login -H "Content-Type: application/json" -d '{"clientId":"e5cd7e4891bf95d1d19206ce24a7b32e","grantType":"password","tenantId":"000000","username":"admin","password":"admin123","code":"","uuid":""}'` → 期望返回 `accessToken`（验证码开启时需先调用 `/auth/code` 获取）
3. Redis 校验：`redis-cli -h 192.168.150.10 -a tomori KEYS "LOGIN_TOKEN:*"` → 期望出现 1 条，TTL≈604800 秒；`KEYS "ONLINE_TOKENS:*"` → 1 条
4. 携带令牌访问受保护接口 → 200
5. 删除 Redis 令牌后携带同一令牌访问 → 401，提示"jwt令牌不合法，请重新登录"
6. 无权限用户访问需权限接口 → 403

- [ ] **Step 5: 汇总验证结果并提交最终说明**

将验证结果如实汇报给用户（哪些通过、哪些因环境不可达受阻）。如需更新 README 或文档则一并提交。

```bash
git add -A
git commit -m "chore: 完成JWT+Redis鉴权与缓存注解化改造的编译测试验证" --allow-empty
```

---
---

## Self-Review 记录

**1. Spec coverage：**
- 需求1（JWT 校验时查 Redis，无则拒绝）→ Task 4 过滤器 Redis 校验。
- 需求2（登录后令牌+权限入 Redis 7 天、失效跳登录、权限不足 403）→ Task 3 写 Redis；Task 4 401；现有 `accessDeniedHandler` 403；前端 `request.ts` 401 跳登录。
- 需求3（非登录请求：无令牌 401 → 解析失败 401 → Redis 无令牌 401"不合法" → 权限注入上下文 → 正常鉴权/403）→ Task 4。
- 需求4（字典 spring-cache：@Cacheable/@CacheEvict/@CachePut）→ Task 6。
- 需求5（Redis 键大写+下划线+英文）→ Task 1。
- 需求6（编译、测试、运行）→ Task 7。
- 设计文档中的附加项：修复在线用户模块 → Task 3；强退/角色清理联动删除令牌 → Task 5；JWT 7 天 → Task 2。

**2. Placeholder scan：** 无 TBD/TODO；每个改动均含完整代码。

**3. Type consistency：** `onLoginSuccess(LoginUser, String)` 在 Task 3 定义并在 5 个策略调用，签名一致；`CacheConstants.LOGIN_TOKEN_KEY` 在 Task 1 定义，Task 3/4/5 引用一致；`R.fail(int, String)` 已在 R.java 核实存在（第 70 行）；`jwtUtils.parseToken` 返回 `Map<String, Object>`，`payload.get("exp")` 为 `Number` 分支已处理。

## 实施过程中发现并修复的问题（运行时验证后追加）

1. **多租户 Redis 键前缀隔离导致令牌校验失败**：本项目启用 `tenant.enable=true`，Redisson 使用 `TenantKeyPrefixHandler` 给 Redis 键加 `<tenantId>:` 前缀。登录写令牌在 `TenantHelper.dynamic(tenantId, ...)` 内执行（键变为 `000000:LOGIN_TOKEN:<token>`），而过滤器读取时无租户上下文（键保持 `LOGIN_TOKEN:<token>`），键不匹配导致有效令牌一律 401。**修复**：将 `CacheConstants.LOGIN_TOKEN_KEY` 改为 `GlobalConstants.GLOBAL_REDIS_KEY + "LOGIN_TOKEN:"`（即 `GLOBAL:LOGIN_TOKEN:`）。`TenantKeyPrefixHandler` 对含 `GLOBAL:` 的键不做租户前缀，令牌本身全局唯一，过滤器无需租户上下文即可读写；`ONLINE_TOKENS` 保持租户隔离（在线用户列表按租户区分）。该模式与现有 `CacheNames.SYS_CLIENT`/`SYS_OSS_CONFIG` 一致。
2. **本地仓库陈旧 jar 导致运行旧代码**：本机 Maven 本地仓库实际为 `E:\Maven_files`。`mvn spring-boot:run` 在 ruoyi-admin 单模块运行时从本地仓库解析兄弟模块 jar，需先 `mvn install` 才会使用新编译产物。
3. **无权限返回形态**：`@PreAuthorize` 无权限时由 `GlobalExceptionHandler` 捕获并返回业务码 403（HTTP 200 + `{"code":403,...}`），前端按业务码弹出错误提示，符合 RuoYi 约定，满足"报错403并提示用户"。

