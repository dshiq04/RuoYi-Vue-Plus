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
