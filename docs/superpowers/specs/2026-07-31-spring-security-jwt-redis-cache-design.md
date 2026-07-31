# 设计文档：Spring Security JWT + Redis 令牌校验 与 Spring Cache 字典优化

日期：2026-07-31
状态：已确认
项目：RuoYi-Vue-Plus（master 分支）

## 背景

项目已从 Sa-Token 迁移到 Spring Security + 手写 JWT（HMAC-SHA256）。当前存在以下问题/需求：

1. JWT 过滤器解析失败只记日志放行，不做 Redis 校验，登出/强退后令牌仍可用。
2. 登录后令牌未写入 Redis，无法吊销/校验；`UserActionListener` 监听 `AuthenticationSuccessEvent`，但登录流程是手动 `SecurityContextHolder.setAuthentication`，该事件从不触发，导致在线用户、登录日志、最近登录 IP 全部失效。
3. 需要将"用户/角色全部权限"存入 Redis，供鉴权查询，权限不足返回 403。
4. 字典/配置缓存删除/更新仍在手动调用 `CacheUtils.evict`，未完全注解化。
5. Redis 键命名需要统一为大写 + 下划线 + 英文语义。

## 目标

- 登录成功后把 JWT 令牌与用户权限写入 Redis，有效期 7 天（JWT 与 Redis 一致）。
- 非登录请求鉴权链路：取令牌 → 无则 401 → 解析 JWT 失败则 401 → Redis 无此令牌则 401（提示"jwt 令牌不合法"）→ 从 Redis 载入用户+权限注入 SecurityContext → 正常鉴权，无权限 403。
- 登录等不需要 JWT 的路径忽略校验。
- 字典/配置缓存使用 Spring Cache 注解：查询 `@Cacheable`、删除 `@CacheEvict`、修改 `@CacheEvict`+`@CachePut`、插入 `@CachePut`。
- Redis 键全部重命名为大写 + 下划线。
- 完成后编译、测试、运行验证。

## 数据流设计

### 登录后（写 Redis）

5 个认证策略（Password/Email/Sms/Social/Xcx）创建 token 后统一调用新增方法
`SysLoginService.onLoginSuccess(LoginUser loginUser, String token)`：

1. `LOGIN_TOKEN:<token>` → 完整 `LoginUser`（内含 `menuPermission` 菜单权限 + `rolePermission` 角色权限），TTL 7 天。
   - 该条目同时承担"令牌存储"与"本用户/角色权限存储"两个职责，过滤器读一次 Redis 即可获得用户信息 + 全部权限。
2. `ONLINE_TOKENS:<token>` → `UserOnlineDTO`（IP/浏览器/操作系统/登录时间等），TTL 7 天。
   - 修复 `/monitor/online` 在线用户列表（当前因事件不触发而永远为空）。
3. 发布登录成功日志事件（`LogininforEvent`），调用 `recordLoginInfo(userId, ip)` 更新用户最近登录 IP/时间。

### 请求鉴权（JwtAuthenticationFilter 重写）

```
token = resolveToken(request)

无 token：
  - 路径命中排除列表（/auth/**、静态资源、/resource/sse、warm-flow 等）→ 直接放行（登录等不需要 JWT 的地方忽略）
  - 否则 → 返回 401 JSON，结束

有 token：
  - 解析 JWT（签名 + 过期时间），异常/过期 → 返回 401 JSON
  - Redis 判断 LOGIN_TOKEN:<token> 是否存在，不存在 → 返回 401 JSON，提示"jwt令牌不合法，请重新登录"
  - 从 Redis 读出 LoginUser（含全部权限），setToken，构建 LoginUserDetails 注入 SecurityContext
  - 放行，由 @PreAuthorize("hasAuthority('...')") 正常鉴权
```

鉴权结果：有权限放行；无权限由 `accessDeniedHandler` 返回 403"没有访问权限，请联系管理员授权"。

### 退出登录

`SysLoginService.logout()`：
- 直接从 `ServletUtils.getRequest()` 的 `Authorization` 头取 token（不依赖认证上下文，因为 `/auth/**` 已被排除）。
- 删除 `LOGIN_TOKEN:<token>` 与 `ONLINE_TOKENS:<token>`。
- 记录登出日志、清空 SecurityContext。

### 强退（在线用户模块）

`SysUserOnlineController.forceLogout` 目前只删 `ONLINE_TOKENS:<token>`。需同时删除 `LOGIN_TOKEN:<token>` 才能真正吊销令牌。

## JWT 有效期

- `application.yml` 与 `common-security.yml` 的 `security.jwt.expiration: 30` → `10080`（7 天，单位分钟）。
- `JwtUtils` 的 `@Value` 默认值 `expiration:30` → `10080`，保持一致。

## Redis 键重命名（大写 + 下划线 + 英文语义）

| 常量文件 | 现键 | 新键 |
|---|---|---|
| CacheConstants | `online_tokens:` | `ONLINE_TOKENS:` |
| CacheConstants | `sys_config:` | `SYS_CONFIG:` |
| CacheConstants | `sys_dict:` | `SYS_DICT:` |
| CacheConstants | `pwd_err_cnt:` | `PWD_ERR_CNT:` |
| CacheConstants（新增） | — | `LOGIN_TOKEN:` |
| CacheNames | `sys_dict` | `SYS_DICT` |
| CacheNames | `sys_dict_type` | `SYS_DICT_TYPE` |
| CacheNames | `sys_config` | `SYS_CONFIG` |
| CacheNames | `online_tokens` | `ONLINE_TOKENS` |
| CacheNames | 其余（demo:cache、sys_tenant、sys_client、sys_user_name、sys_nickname、sys_dept、sys_oss、sys_role_custom、sys_dept_and_child、sys_oss_config 等） | 同步转大写下划线 |
| GlobalConstants | `global:` 及派生（captcha_codes:、repeat_submit:、rate_limit:、social_auth_codes:） | `GLOBAL:` / `CAPTCHA_CODES:` / `REPEAT_SUBMIT:` / `RATE_LIMIT:` / `SOCIAL_AUTH_CODES:` |

说明：
- 全部通过常量引用自动生效，无硬编码。
- `PlusSpringCacheManager` 按 `#` 分隔缓存名与 TTL/参数，大写命名不影响解析（已核实）。
- 旧键在 Redis 中成为孤儿数据，开发环境可接受，可手动清库。

## 字典/配置缓存注解化（Spring Cache）

规则（字典 `SysDictDataServiceImpl` / `SysDictTypeServiceImpl`，同 pattern 应用配置 `SysConfigServiceImpl`）：

| 操作 | 注解 |
|---|---|
| 查询（首次按字典类型缓存） | `@Cacheable(cacheNames=SYS_DICT, key=#dictType)`（已有，保留） |
| 删除 | `@CacheEvict(cacheNames=SYS_DICT, allEntries=true)`（替换 `CacheUtils.evict`） |
| 修改 | `@Caching(evict=@CacheEvict(cacheNames=SYS_DICT, allEntries=true), put=@CachePut(cacheNames=SYS_DICT, key=#bo.dictType))` |
| 插入 | `@CachePut(cacheNames=SYS_DICT, key=#bo.dictType)`（已有，保留） |
| 重置缓存 | `@CacheEvict(cacheNames=..., allEntries=true)`（替换 `CacheUtils.clear`） |

细节：
- 删除/重置用 `allEntries=true`：字典数据量小，整组清空后由下次读取按需回填，正确且简单（Spring 保证 evict 先于 put 执行，`@Caching(evict, put)` 最终态为最新值）。
- `SysDictTypeServiceImpl.updateDictType` 存在"字典类型改名"场景：注解 evict+put 覆盖新 type 键，另需保留手动 `CacheUtils.evict` 清除旧 type 的 `SYS_DICT` 与 `SYS_DICT_TYPE` 键。
- `@Cacheable`/`@CachePut` 需经 AOP 代理调用（现有 `SpringUtils.getAopProxy(this)` 已满足）。
- 字典/配置缓存走 spring-cache 的 Redis（`PlusSpringCacheManager`）。

## 401 / 403 提示

- 无令牌（受保护路径）：401，消息"认证失败，请先登录"。
- JWT 解析失败/已过期：401，消息"jwt令牌不合法或已过期，请重新登录"。
- Redis 无此令牌（被吊销/登出/强退）：401，消息"jwt令牌不合法，请重新登录"。
- 无权限：403，消息"没有访问权限，请联系管理员授权"（现有 `accessDeniedHandler` 已具备）。
- 前端 `request.ts` 已对 401 弹出重新登录引导，无需改动。

## 改动文件清单

新增：
- `SysLoginService.onLoginSuccess(LoginUser, String)`（登录成功写 Redis + 日志 + 最近登录信息）

修改：
- `ruoyi-common-security/.../JwtAuthenticationFilter.java`：重写（无令牌 401 / 排除路径放行 / JWT 解析 / Redis 校验 / 注入上下文）
- `ruoyi-common-security/.../SecurityConfig.java`：过滤器注入 `SecurityProperties`
- `ruoyi-common-satoken/.../JwtUtils.java`：expiration 默认值 → 10080
- `ruoyi-admin/src/main/resources/application.yml`：`security.jwt.expiration` → 10080
- `ruoyi-common-satoken/src/main/resources/common-security.yml`：`expiration` → 10080
- `ruoyi-admin/.../web/service/SysLoginService.java`：logout 直接取头删 Redis
- 5 个认证策略：登录成功后调用 `onLoginSuccess(loginUser, token)`
- `CacheConstants.java`、`CacheNames.java`、`GlobalConstants.java`：键重命名 + 新增 `LOGIN_TOKEN_KEY`
- `SysDictDataServiceImpl.java`、`SysDictTypeServiceImpl.java`、`SysConfigServiceImpl.java`：注解化
- `SysUserOnlineController.java`：强退同时删 `LOGIN_TOKEN:<token>`

删除：
- `ruoyi-admin/.../web/listener/UserActionListener.java`（死代码，逻辑并入 `SysLoginService`）

## 验证计划

1. `mvn clean compile`：全模块编译通过。
2. `mvn test`：运行模块测试。
3. 启动 `ruoyi-admin`（`mvn spring-boot:run` 或打包运行）验证启动成功。
4. 手动验证链路（若环境允许）：登录 → Redis 出现 `LOGIN_TOKEN:*` 与 `ONLINE_TOKENS:*`（7 天 TTL）→ 携带令牌访问受保护接口 200 → 删除 Redis 令牌后访问返回 401 → 无令牌访问受保护接口 401 → 无权限用户访问需权限接口 403 → 登出后 Redis 键被删除。

注意：dev 环境数据库/Redis 指向 `192.168.150.10`，若环境不可达，验证步骤将如实报告受阻项。