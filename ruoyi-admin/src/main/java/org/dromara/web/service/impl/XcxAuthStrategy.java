package org.dromara.web.service.impl;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.http.HttpUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.constant.SystemConstants;
import org.dromara.common.core.domain.model.XcxLoginBody;
import org.dromara.common.core.domain.model.XcxLoginUser;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.utils.ValidatorUtils;
import org.dromara.common.json.utils.JsonUtils;
import org.dromara.common.satoken.utils.JwtUtils;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.system.domain.vo.SysClientVo;
import org.dromara.system.domain.vo.SysUserVo;
import org.dromara.web.domain.vo.LoginVo;
import org.dromara.web.service.IAuthStrategy;
import org.dromara.web.service.SysLoginService;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * 小程序认证策略
 *
 * @author Michelle.Chung
 */
@Slf4j
@Service("xcx" + IAuthStrategy.BASE_NAME)
@RequiredArgsConstructor
public class XcxAuthStrategy implements IAuthStrategy {

    private final SysLoginService loginService;
    private final JwtUtils jwtUtils;

    @Override
    public LoginVo login(String body, SysClientVo client) {
        XcxLoginBody loginBody = JsonUtils.parseObject(body, XcxLoginBody.class);
        ValidatorUtils.validate(loginBody);
        String xcxCode = loginBody.getXcxCode();
        String appid = loginBody.getAppid();

        // 通过微信API获取openid（需配置appid和secret）
        // 调用微信登录凭证校验接口 获取 session_key 与 openid
        String openid = getXcxOpenid(appid, xcxCode);

        SysUserVo user = loadUserByOpenid(openid);
        XcxLoginUser loginUser = new XcxLoginUser();
        loginUser.setTenantId(user.getTenantId());
        loginUser.setUserId(user.getUserId());
        loginUser.setUsername(user.getUserName());
        loginUser.setNickname(user.getNickName());
        loginUser.setUserType(user.getUserType());
        loginUser.setClientKey(client.getClientKey());
        loginUser.setDeviceType(client.getDeviceType());
        loginUser.setOpenid(openid);

        LoginHelper.login(loginUser);
        String token = jwtUtils.createToken(loginUser);
        // 登录成功后写入redis令牌与权限
        loginService.onLoginSuccess(loginUser, token);

        LoginVo loginVo = new LoginVo();
        loginVo.setAccessToken(token);
        loginVo.setExpireIn((long) jwtUtils.getExpiration() * 60);
        loginVo.setClientId(client.getClientId());
        loginVo.setOpenid(openid);
        return loginVo;
    }

    /**
     * 调用微信小程序登录接口获取openid
     */
    private String getXcxOpenid(String appid, String code) {
        // TODO 需要配置appSecret，建议从数据库或配置文件读取
        String appSecret = "";
        String url = String.format(
            "https://api.weixin.qq.com/sns/jscode2session?appid=%s&secret=%s&js_code=%s&grant_type=authorization_code",
            appid, appSecret, code);
        try {
            String response = HttpUtil.get(url);
            Map<String, Object> result = JsonUtils.parseMap(response);
            if (result.containsKey("openid")) {
                return (String) result.get("openid");
            } else {
                throw new ServiceException("微信小程序登录失败: " + result.get("errmsg"));
            }
        } catch (ServiceException e) {
            throw e;
        } catch (Exception e) {
            throw new ServiceException("微信小程序登录接口调用失败");
        }
    }

    private SysUserVo loadUserByOpenid(String openid) {
        // todo 自行实现 userService.selectUserByOpenid(openid);
        SysUserVo user = new SysUserVo();
        if (ObjectUtil.isNull(user)) {
            log.info("登录用户：{} 不存在.", openid);
        } else if (SystemConstants.DISABLE.equals(user.getStatus())) {
            log.info("登录用户：{} 已被停用.", openid);
        }
        return user;
    }

}
