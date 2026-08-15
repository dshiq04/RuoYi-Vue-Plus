package org.dromara;

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
        System.out.println("----------------------------------------------------------");
        System.out.println("当前环境(spring.profiles.active): " + activeProfile);
        System.out.println("本地Swagger文档: http://" + localHost + ":" + port + prefix + "/swagger-ui/index.html");
        System.out.println("网络Swagger文档: http://" + networkHost + ":" + port + prefix + "/swagger-ui/index.html");
        System.out.println("----------------------------------------------------------");
    }

}
