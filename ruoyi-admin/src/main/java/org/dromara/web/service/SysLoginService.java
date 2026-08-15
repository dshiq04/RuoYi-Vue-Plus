package org.dromara.web.service;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.lang.Opt;
import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.http.useragent.UserAgent;
import cn.hutool.http.useragent.UserAgentUtil;
import com.baomidou.lock.annotation.Lock4j;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.core.constant.CacheConstants;
import org.dromara.common.core.constant.Constants;
import org.dromara.common.core.constant.SystemConstants;
import org.dromara.common.core.constant.TenantConstants;
import org.dromara.common.core.domain.dto.PostDTO;
import org.dromara.common.core.domain.dto.RoleDTO;
import org.dromara.common.core.domain.dto.UserOnlineDTO;
import org.dromara.common.core.domain.model.LoginUser;
import org.dromara.common.core.enums.LoginType;
import org.dromara.common.core.exception.ServiceException;
import org.dromara.common.core.exception.user.UserException;
import org.dromara.common.core.utils.*;
import org.dromara.common.core.utils.ip.AddressUtils;
import org.dromara.common.log.event.LogininforEvent;
import org.dromara.common.mybatis.helper.DataPermissionHelper;
import org.dromara.common.redis.utils.RedisUtils;
import org.dromara.common.satoken.utils.JwtUtils;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.common.tenant.exception.TenantException;
import org.dromara.common.tenant.helper.TenantHelper;
import org.dromara.system.domain.SysUser;
import org.dromara.system.domain.bo.SysSocialBo;
import org.dromara.system.domain.vo.*;
import org.dromara.system.mapper.SysUserMapper;
import org.dromara.system.service.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.function.Supplier;

/**
 * 登录校验方法
 *
 * @author Lion Li
 */
@RequiredArgsConstructor
@Slf4j
@Service
public class SysLoginService {

    @Value("${user.password.maxRetryCount}")
    private Integer maxRetryCount;

    @Value("${user.password.lockTime}")
    private Integer lockTime;

    private final ISysTenantService tenantService;
    private final ISysPermissionService permissionService;
    private final ISysSocialService sysSocialService;
    private final ISysRoleService roleService;
    private final ISysDeptService deptService;
    private final ISysPostService postService;
    private final SysUserMapper userMapper;
    private final JwtUtils jwtUtils;

    /**
     * 绑定第三方用户
     *
     * @param userInfo OAuth2用户信息
     */
    @Lock4j
    public void socialRegister(org.dromara.common.social.utils.OAuth2UserInfo userInfo) {
        String authId = userInfo.getSource() + userInfo.getUuid();
        SysSocialBo bo = new SysSocialBo();
        bo.setUserId(LoginHelper.getUserId());
        bo.setAuthId(authId);
        bo.setOpenId(userInfo.getUuid());
        bo.setUserName(userInfo.getUsername());
        bo.setNickName(userInfo.getNickname());
        bo.setSource(userInfo.getSource());
        List<SysSocialVo> checkList = sysSocialService.selectByAuthId(authId);
        if (CollUtil.isNotEmpty(checkList)) {
            throw new ServiceException("此三方账号已经被绑定!");
        }
        // 查询是否已经绑定用户
        SysSocialBo params = new SysSocialBo();
        params.setUserId(LoginHelper.getUserId());
        params.setSource(bo.getSource());
        List<SysSocialVo> list = sysSocialService.queryList(params);
        if (CollUtil.isEmpty(list)) {
            // 没有绑定用户, 新增用户信息
            sysSocialService.insertByBo(bo);
        } else {
            // 更新用户信息
            bo.setId(list.get(0).getId());
            sysSocialService.updateByBo(bo);
        }
    }

    /**
     * 退出登录
     */
    public void logout() {
        try {
            LoginUser loginUser = LoginHelper.getLoginUser();
            String token = resolveToken(ServletUtils.getRequest());
            if (ObjectUtil.isNull(loginUser) && StrUtil.isNotBlank(token)) {
                // 认证上下文为空时 尝试从redis取用户信息
                loginUser = RedisUtils.getCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token);
            }
            if (ObjectUtil.isNull(loginUser)) {
                return;
            }
            if (TenantHelper.isEnable() && LoginHelper.isSuperAdmin()) {
                // 超级管理员 登出清除动态租户
                TenantHelper.clearDynamic();
            }
            String tenantId = loginUser.getTenantId();
            // 使用令牌组件销毁令牌 删除redis中的登录用户信息与在线用户信息 强制登出
            jwtUtils.invalidateToken(token);
            recordLogininfor(tenantId, loginUser.getUsername(), Constants.LOGOUT, MessageUtils.message("user.logout.success"));
        } catch (Exception ignored) {
        } finally {
            SecurityContextHolder.clearContext();
        }
    }

    /**
     * 从请求头或请求参数中解析JWT令牌
     */
    private String resolveToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (StrUtil.isNotBlank(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        bearerToken = request.getParameter("Authorization");
        if (StrUtil.isNotBlank(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }

    /**
     * 登录成功后处理：存储令牌与用户/角色权限到redis、记录在线用户、写入登录日志、更新最近登录信息
     * <p>
     * ONLINE_TOKEN 创建原则(注意平台)：同一用户在同一平台(客户端+设备类型)已存在在线令牌时，
     * 不重复创建，直接复用已有令牌；不存在时才创建新的在线令牌。
     *
     * @param loginUser 登录用户
     * @param newToken  本次登录生成的新JWT令牌
     * @return 实际生效的令牌(复用已有令牌时返回已有令牌)
     */
    public String onLoginSuccess(LoginUser loginUser, String newToken) {
        HttpServletRequest request = ServletUtils.getRequest();
        UserAgent userAgent = UserAgentUtil.parse(request.getHeader("User-Agent"));
        String ip = ServletUtils.getClientIP();
        // 查找当前用户在当前平台是否已存在在线令牌
        String existToken = getOnlineTokenByUserAndPlatform(loginUser);
        String token;
        if (StrUtil.isNotBlank(existToken)) {
            // 已有在线令牌 复用 不重复创建 清理本次新生成的令牌缓存
            RedisUtils.deleteObject(CacheConstants.LOGIN_TOKEN_KEY + newToken);
            token = existToken;
        } else {
            token = newToken;
        }
        // 1. 令牌与用户/角色权限存入redis 有效期7天
        // 2. 在线用户信息存入redis 有效期7天 (不存在才创建)
        loginUser.setToken(token);
        TenantHelper.dynamic(loginUser.getTenantId(), () -> {
            RedisUtils.setCacheObject(CacheConstants.LOGIN_TOKEN_KEY + token, loginUser, Duration.ofDays(7));
            if (StrUtil.isBlank(existToken)) {
                // 不存在在线令牌 创建新的在线用户信息
                UserOnlineDTO dto = new UserOnlineDTO();
                dto.setIpaddr(ip);
                dto.setLoginLocation(AddressUtils.getRealAddressByIP(ip));
                dto.setBrowser(userAgent.getBrowser().getName());
                dto.setOs(userAgent.getOs().getName());
                dto.setLoginTime(System.currentTimeMillis());
                dto.setTokenId(token);
                dto.setUserName(loginUser.getUsername());
                dto.setClientKey(loginUser.getClientKey());
                dto.setDeviceType(loginUser.getDeviceType());
                dto.setDeptName(loginUser.getDeptName());
                RedisUtils.setCacheObject(CacheConstants.ONLINE_TOKEN_KEY + token, dto, Duration.ofDays(7));
            } else {
                // 已存在在线令牌 仅刷新登录信息与有效期
                UserOnlineDTO dto = RedisUtils.getCacheObject(CacheConstants.ONLINE_TOKEN_KEY + token);
                if (ObjectUtil.isNotNull(dto)) {
                    dto.setIpaddr(ip);
                    dto.setLoginLocation(AddressUtils.getRealAddressByIP(ip));
                    dto.setBrowser(userAgent.getBrowser().getName());
                    dto.setOs(userAgent.getOs().getName());
                    dto.setLoginTime(System.currentTimeMillis());
                    RedisUtils.setCacheObject(CacheConstants.ONLINE_TOKEN_KEY + token, dto, Duration.ofDays(7));
                }
            }
        });
        // 3. 记录登录日志
        recordLogininfor(loginUser.getTenantId(), loginUser.getUsername(), Constants.LOGIN_SUCCESS, MessageUtils.message("user.login.success"));
        // 4. 更新最近登录信息
        recordLoginInfo(loginUser.getUserId(), ip);
        log.info("user doLogin, userId:{}, token:***{}", loginUser.getUserId(), StringUtils.right(token, 8));
        return token;
    }

    /**
     * 查询当前用户在当前平台(客户端+设备类型)是否已有在线令牌
     *
     * @param loginUser 登录用户
     * @return 已存在的在线令牌 无则返回null
     */
    private String getOnlineTokenByUserAndPlatform(LoginUser loginUser) {
        Collection<String> keys = RedisUtils.keys(CacheConstants.ONLINE_TOKEN_KEY + "*");
        for (String key : keys) {
            UserOnlineDTO dto = RedisUtils.getCacheObject(key);
            if (dto == null) {
                continue;
            }
            // 注意平台：同一用户、同一客户端、同一设备类型才算已有在线令牌
            if (StrUtil.equals(dto.getUserName(), loginUser.getUsername())
                && StrUtil.equals(dto.getClientKey(), loginUser.getClientKey())
                && StrUtil.equals(dto.getDeviceType(), loginUser.getDeviceType())) {
                return dto.getTokenId();
            }
        }
        return null;
    }

    /**
     * 记录登录信息
     *
     * @param tenantId 租户ID
     * @param username 用户名
     * @param status   状态
     * @param message  消息内容
     */
    public void recordLogininfor(String tenantId, String username, String status, String message) {
        LogininforEvent logininforEvent = new LogininforEvent();
        logininforEvent.setTenantId(tenantId);
        logininforEvent.setUsername(username);
        logininforEvent.setStatus(status);
        logininforEvent.setMessage(message);
        logininforEvent.setRequest(ServletUtils.getRequest());
        SpringUtils.context().publishEvent(logininforEvent);
    }

    /**
     * 构建登录用户
     */
    public LoginUser buildLoginUser(SysUserVo user) {
        LoginUser loginUser = new LoginUser();
        Long userId = user.getUserId();
        loginUser.setTenantId(user.getTenantId());
        loginUser.setUserId(userId);
        loginUser.setDeptId(user.getDeptId());
        loginUser.setUsername(user.getUserName());
        loginUser.setNickname(user.getNickName());
        loginUser.setUserType(user.getUserType());
        loginUser.setMenuPermission(permissionService.getMenuPermission(userId));
        loginUser.setRolePermission(permissionService.getRolePermission(userId));
        if (ObjectUtil.isNotNull(user.getDeptId())) {
            Opt<SysDeptVo> deptOpt = Opt.of(user.getDeptId()).map(deptService::selectDeptById);
            loginUser.setDeptName(deptOpt.map(SysDeptVo::getDeptName).orElse(StringUtils.EMPTY));
            loginUser.setDeptCategory(deptOpt.map(SysDeptVo::getDeptCategory).orElse(StringUtils.EMPTY));
        }
        List<SysRoleVo> roles = roleService.selectRolesByUserId(userId);
        List<SysPostVo> posts = postService.selectPostsByUserId(userId);
        loginUser.setRoles(BeanUtil.copyToList(roles, RoleDTO.class));
        loginUser.setPosts(BeanUtil.copyToList(posts, PostDTO.class));
        return loginUser;
    }

    /**
     * 记录登录信息
     *
     * @param userId 用户ID
     */
    public void recordLoginInfo(Long userId, String ip) {
        SysUser sysUser = new SysUser();
        sysUser.setUserId(userId);
        sysUser.setLoginIp(ip);
        sysUser.setLoginDate(DateUtils.getNowDate());
        sysUser.setUpdateBy(userId);
        DataPermissionHelper.ignore(() -> userMapper.updateById(sysUser));
    }

    /**
     * 登录校验
     */
    public void checkLogin(LoginType loginType, String tenantId, String username, Supplier<Boolean> supplier) {
        String errorKey = CacheConstants.PWD_ERR_CNT_KEY + username;
        String loginFail = Constants.LOGIN_FAIL;

        // 获取用户登录错误次数，默认为0 (可自定义限制策略 例如: key + username + ip)
        int errorNumber = ObjectUtil.defaultIfNull(RedisUtils.getCacheObject(errorKey), 0);
        // 锁定时间内登录 则踢出
        if (errorNumber >= maxRetryCount) {
            recordLogininfor(tenantId, username, loginFail, MessageUtils.message(loginType.getRetryLimitExceed(), maxRetryCount, lockTime));
            throw new UserException(loginType.getRetryLimitExceed(), maxRetryCount, lockTime);
        }

        if (supplier.get()) {
            // 错误次数递增
            errorNumber++;
            RedisUtils.setCacheObject(errorKey, errorNumber, Duration.ofMinutes(lockTime));
            // 达到规定错误次数 则锁定登录
            if (errorNumber >= maxRetryCount) {
                recordLogininfor(tenantId, username, loginFail, MessageUtils.message(loginType.getRetryLimitExceed(), maxRetryCount, lockTime));
                throw new UserException(loginType.getRetryLimitExceed(), maxRetryCount, lockTime);
            } else {
                // 未达到规定错误次数
                recordLogininfor(tenantId, username, loginFail, MessageUtils.message(loginType.getRetryLimitCount(), errorNumber));
                throw new UserException(loginType.getRetryLimitCount(), errorNumber);
            }
        }

        // 登录成功 清空错误次数
        RedisUtils.deleteObject(errorKey);
    }

    /**
     * 校验租户
     *
     * @param tenantId 租户ID
     */
    public void checkTenant(String tenantId) {
        if (!TenantHelper.isEnable()) {
            return;
        }
        if (StringUtils.isBlank(tenantId)) {
            throw new TenantException("tenant.number.not.blank");
        }
        if (TenantConstants.DEFAULT_TENANT_ID.equals(tenantId)) {
            return;
        }
        SysTenantVo tenant = tenantService.queryByTenantId(tenantId);
        if (ObjectUtil.isNull(tenant)) {
            log.info("登录租户：{} 不存在.", tenantId);
            throw new TenantException("tenant.not.exists");
        } else if (SystemConstants.DISABLE.equals(tenant.getStatus())) {
            log.info("登录租户：{} 已被停用.", tenantId);
            throw new TenantException("tenant.blocked");
        } else if (ObjectUtil.isNotNull(tenant.getExpireTime())
            && new Date().after(tenant.getExpireTime())) {
            log.info("登录租户：{} 已超过有效期.", tenantId);
            throw new TenantException("tenant.expired");
        }
    }

}
