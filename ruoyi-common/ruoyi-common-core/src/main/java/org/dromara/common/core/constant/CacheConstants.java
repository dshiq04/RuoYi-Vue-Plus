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
