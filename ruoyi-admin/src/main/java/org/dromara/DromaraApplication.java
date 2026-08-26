package org.dromara;

import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.utils.NetUtils;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.metrics.buffering.BufferingApplicationStartup;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

/**
 * 启动程序
 *
 * @author Lion Li
 */
@Slf4j
@SpringBootApplication
public class DromaraApplication {

    public static void main(String[] args) {
        SpringApplication application = new SpringApplication(DromaraApplication.class);
        application.setApplicationStartup(new BufferingApplicationStartup(2048));
        ConfigurableApplicationContext context = application.run(args);
        printStartupInfo(context.getEnvironment());
        System.out.println("(♥◠‿◠)ﾉﾞ  RuoYi-Vue-Plus启动成功   ლ(´ڡ`ლ)ﾞ");
    }

    /**
     * 启动信息：当前环境 + 本地/网络 swagger 接口文档地址
     */
    private static void printStartupInfo(Environment env) {
        String activeProfile = env.getProperty("spring.profiles.active", "dev");
        String port = env.getProperty("server.port", "8080");
        String contextPath = env.getProperty("server.servlet.context-path", "/");
        String prefix = "/".equals(contextPath) ? "" : contextPath;
        String localHost = "localhost";
        String networkHost;
        try {
            networkHost = NetUtils.getLocalhost().getHostAddress();
        } catch (Exception e) {
            networkHost = localHost;
        }
        DromaraApplication.log.info("----------------------------------------------------------");
        DromaraApplication.log.info("当前环境: {}", activeProfile);
        DromaraApplication.log.info("本地Swagger文档: http://{}:{}{}/swagger-ui/index.html", localHost, port, prefix);
        DromaraApplication.log.info("网络Swagger文档: http://{}:{}{}/swagger-ui/index.html", networkHost, port, prefix);
        printMonitorInfo(env, localHost, networkHost, port, prefix);
        DromaraApplication.log.info("----------------------------------------------------------");
    }

    /**
     * 性能监控信息：开关状态 + 内部/外部监控平台地址 (账号见 performance-monitor 配置)
     */
    private static void printMonitorInfo(Environment env, String localHost, String networkHost, String port, String prefix) {
        boolean monitorEnabled = env.getProperty("performance-monitor.enabled", Boolean.class, false);
        if (!monitorEnabled) {
            DromaraApplication.log.info("性能监控: 已关闭 (performance-monitor.enabled=false)");
            return;
        }
        String username = env.getProperty("performance-monitor.username", "admin");
        String monitorPath = env.getProperty("spring.boot.admin.context-path", "");
        DromaraApplication.log.info("性能监控 (Spring Boot Admin) 已启用 登录账号: {}", username);
        DromaraApplication.log.info("性能监控内部地址: http://{}:{}{}{}/", localHost, port, prefix, monitorPath);
        DromaraApplication.log.info("性能监控外部地址: http://{}:{}{}{}/", networkHost, port, prefix, monitorPath);
    }

}
