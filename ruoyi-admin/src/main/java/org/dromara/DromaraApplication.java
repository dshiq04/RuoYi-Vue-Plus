package org.dromara;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.metrics.buffering.BufferingApplicationStartup;

/**
 * 启动程序
 *
 * @author Lion Li
 */

/**
 * 现在修改角色、分配用户、分配角色、修改用户、修改用户密码、删除用户功能执行完成后再执行一个方法，这个方法功能向redis中删除有关、相关的用户信息，并且用令牌组件的功能销毁（invalid）令牌，强制登出，在登出功能做出在redis删除用户的信息、令牌，并销毁令牌
 */

@SpringBootApplication
public class DromaraApplication {

    public static void main(String[] args) {
        SpringApplication.run(DromaraApplication.class, args);
        System.out.println("(♥◠‿◠)ﾉﾞ  RuoYi-Vue-Plus启动成功   ლ(´ڡ`ლ)ﾞ");
    }

}
