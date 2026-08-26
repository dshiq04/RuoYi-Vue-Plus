package org.dromara.common.monitor.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Spring Boot Admin 监控平台首页入口适配
 * <p>
 * SBA UiController 的首页映射为不带尾斜杠的 /monitor (produces text/html)
 * 浏览器习惯访问带尾斜杠的 /monitor/ 此处将其 301 重定向到无斜杠形式
 * 由 UiController 经 Thymeleaf 渲染 SPA 外壳 保证 base href 与资源路径正确
 *
 * @author dromara
 */
@Controller
public class MonitorHomeController {

    /**
     * 带尾斜杠的首页入口 重定向到 SBA UiController 的无斜杠首页映射
     */
    @GetMapping("${spring.boot.admin.context-path:/monitor}/")
    public String home() {
        return "redirect:/monitor";
    }

}
