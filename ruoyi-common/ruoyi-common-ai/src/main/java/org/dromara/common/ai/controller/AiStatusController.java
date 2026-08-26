package org.dromara.common.ai.controller;

import org.dromara.common.core.domain.R;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * AI 功能状态控制器
 * <p>
 * 注意: 该控制器不受 {@code ai.enabled} 开关控制 (不加 @ConditionalOnProperty),
 * 供前端在 AI 功能关闭时仍能查询状态并展示关闭提示页面
 *
 * @author dshiq
 */
@RestController
@RequestMapping("/ai")
public class AiStatusController {

    /**
     * AI 功能总开关 (application.yml -> ai.enabled)
     */
    @Value("${ai.enabled:false}")
    private boolean enabled;

    /**
     * 查询 AI 功能是否开启
     *
     * @return true 开启 / false 关闭
     */
    @GetMapping("/status")
    public R<Boolean> status() {
        return R.ok(enabled);
    }
}
