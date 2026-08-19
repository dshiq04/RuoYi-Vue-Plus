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
        DromaraApplication.log.info("----------------------------------------------------------");
    }

}
