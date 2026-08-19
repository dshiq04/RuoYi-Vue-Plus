package org.dromara.common.core.constant;

/**
 * 缓存的key 常量
 *
 * @author Lion Li
 */
public interface CacheConstants {

    /**
     * 登录令牌 redis key
     * 使用GLOBAL前缀 避免被租户前缀隔离 令牌本身全局唯一
     */
    String LOGIN_TOKEN_KEY = GlobalConstants.GLOBAL_REDIS_KEY + "LOGIN_TOKEN:";

    /**
     * 在线用户 redis key
     * 按租户隔离：登录时在 TenantHelper.dynamic(tenantId) 内写入，会被自动加上租户前缀；
     * 过滤器校验与复用扫描也必须处于对应租户上下文(TenantHelper.dynamic)下执行，
     * 保证写入与读取的 key 前缀一致。与 LOGIN_TOKEN_KEY(全局)不同，此处刻意保留租户隔离。
     */
    String ONLINE_TOKEN_KEY = "ONLINE_TOKEN:";

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

    /**
     * 停用用户名单 redis key(Set集合) 存停用用户的userId
     * 使用GLOBAL前缀 避免被租户前缀隔离 停用校验必须跨租户生效
     */
    String SYS_USER_DISABLE_KEY = GlobalConstants.GLOBAL_REDIS_KEY + "SYS_USER_DISABLE:";

}
