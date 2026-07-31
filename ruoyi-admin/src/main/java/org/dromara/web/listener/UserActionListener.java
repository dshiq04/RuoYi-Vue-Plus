package org.dromara.web.listener;

import cn.hutool.http.useragent.UserAgent;
import cn.hutool.http.useragent.UserAgentUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.constant.CacheConstants;
import org.dromara.common.core.constant.Constants;
import org.dromara.common.core.domain.dto.UserOnlineDTO;
import org.dromara.common.core.domain.model.LoginUser;
import org.dromara.common.core.utils.MessageUtils;
import org.dromara.common.core.utils.ServletUtils;
import org.dromara.common.core.utils.SpringUtils;
import org.dromara.common.core.utils.StringUtils;
import org.dromara.common.core.utils.ip.AddressUtils;
import org.dromara.common.log.event.LogininforEvent;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.common.tenant.helper.TenantHelper;
import org.dromara.web.service.SysLoginService;
import org.springframework.context.event.EventListener;
import org.springframework.security.authentication.event.AuthenticationSuccessEvent;
import org.springframework.security.authentication.event.LogoutSuccessEvent;
import org.springframework.stereotype.Component;

import java.time.Duration;

/**
 * 用户行为 侦听器的实现
 *
 * @author Lion Li
 */
@RequiredArgsConstructor
@Component
@Slf4j
public class UserActionListener {

    private final SysLoginService loginService;

    /**
     * 每次登录成功时触发
     */
    @EventListener
    public void onLoginSuccess(AuthenticationSuccessEvent event) {
        Object principal = event.getAuthentication().getPrincipal();
        if (!(principal instanceof org.dromara.common.satoken.utils.LoginUserDetails userDetails)) {
            return;
        }
        LoginUser loginUser = userDetails.getLoginUser();
        String tokenValue = loginUser.getToken();
        UserAgent userAgent = UserAgentUtil.parse(ServletUtils.getRequest().getHeader("User-Agent"));
        String ip = ServletUtils.getClientIP();
        UserOnlineDTO dto = new UserOnlineDTO();
        dto.setIpaddr(ip);
        dto.setLoginLocation(AddressUtils.getRealAddressByIP(ip));
        dto.setBrowser(userAgent.getBrowser().getName());
        dto.setOs(userAgent.getOs().getName());
        dto.setLoginTime(System.currentTimeMillis());
        dto.setTokenId(tokenValue);
        dto.setUserName(loginUser.getUsername());
        dto.setClientKey(loginUser.getClientKey());
        dto.setDeviceType(loginUser.getDeviceType());
        dto.setDeptName(loginUser.getDeptName());
        String tenantId = loginUser.getTenantId();
        TenantHelper.dynamic(tenantId, () -> {
            RedisUtils.setCacheObject(CacheConstants.ONLINE_TOKEN_KEY + tokenValue, dto, Duration.ofMinutes(30));
        });
        // 记录登录日志
        LogininforEvent logininforEvent = new LogininforEvent();
        logininforEvent.setTenantId(tenantId);
        logininforEvent.setUsername(loginUser.getUsername());
        logininforEvent.setStatus(Constants.LOGIN_SUCCESS);
        logininforEvent.setMessage(MessageUtils.message("user.login.success"));
        logininforEvent.setRequest(ServletUtils.getRequest());
        SpringUtils.context().publishEvent(logininforEvent);
        // 更新登录信息
        loginService.recordLoginInfo(loginUser.getUserId(), ip);
        log.info("user doLogin, userId:{}, token:***{}", loginUser.getUserId(), StringUtils.right(tokenValue, 8));
    }

    /**
     * 每次注销成功时触发
     */
    @EventListener
    public void onLogoutSuccess(LogoutSuccessEvent event) {
        LoginUser loginUser = LoginHelper.getLoginUser();
        if (loginUser != null) {
            String tokenValue = loginUser.getToken();
            String tenantId = loginUser.getTenantId();
            TenantHelper.dynamic(tenantId, () -> {
                RedisUtils.deleteObject(CacheConstants.ONLINE_TOKEN_KEY + tokenValue);
            });
            log.info("user doLogout, userId:{}, token:***{}", loginUser.getUserId(), StringUtils.right(tokenValue, 8));
        }
    }

}
