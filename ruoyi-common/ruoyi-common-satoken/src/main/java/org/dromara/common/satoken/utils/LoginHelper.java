package org.dromara.common.satoken.utils;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.convert.Convert;
import cn.hutool.core.util.ObjectUtil;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import org.dromara.common.core.constant.SystemConstants;
import org.dromara.common.core.constant.TenantConstants;
import org.dromara.common.core.domain.model.LoginUser;
import org.dromara.common.core.enums.UserType;
import org.dromara.common.core.utils.SpringUtils;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Set;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class LoginHelper {

    public static final String LOGIN_USER_KEY = "loginUser";
    public static final String TENANT_KEY = "tenantId";
    public static final String USER_KEY = "userId";
    public static final String USER_NAME_KEY = "userName";
    public static final String DEPT_KEY = "deptId";
    public static final String DEPT_NAME_KEY = "deptName";
    public static final String DEPT_CATEGORY_KEY = "deptCategory";
    public static final String CLIENT_KEY = "clientid";

    /**
     * 登录系统
     */
    public static void login(LoginUser loginUser) {
        LoginUserDetails userDetails = new LoginUserDetails(loginUser);
        Authentication authentication = new LoginAuthenticationToken(userDetails, userDetails.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    /**
     * 获取用户
     */
    @SuppressWarnings("unchecked")
    public static <T extends LoginUser> T getLoginUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (ObjectUtil.isNull(authentication) || !authentication.isAuthenticated()) {
            return null;
        }
        Object principal = authentication.getPrincipal();
        if (principal instanceof LoginUserDetails userDetails) {
            return (T) userDetails.getLoginUser();
        }
        return null;
    }

    /**
     * 获取用户id
     */
    public static Long getUserId() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getUserId() : null;
    }

    /**
     * 获取用户id字符串
     */
    public static String getUserIdStr() {
        return Convert.toStr(getUserId());
    }

    /**
     * 获取用户账户
     */
    public static String getUsername() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getUsername() : null;
    }

    /**
     * 获取租户ID
     */
    public static String getTenantId() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getTenantId() : null;
    }

    /**
     * 获取部门ID
     */
    public static Long getDeptId() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getDeptId() : null;
    }

    /**
     * 获取部门名
     */
    public static String getDeptName() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getDeptName() : null;
    }

    /**
     * 获取部门类别编码
     */
    public static String getDeptCategory() {
        LoginUser loginUser = getLoginUser();
        return loginUser != null ? loginUser.getDeptCategory() : null;
    }

    /**
     * 获取用户类型
     */
    public static UserType getUserType() {
        LoginUser loginUser = getLoginUser();
        if (loginUser == null) {
            return null;
        }
        return UserType.getUserType(loginUser.getUserType());
    }

    /**
     * 是否为超级管理员
     */
    public static boolean isSuperAdmin(Long userId) {
        return SystemConstants.SUPER_ADMIN_ID.equals(userId);
    }

    /**
     * 是否为超级管理员
     */
    public static boolean isSuperAdmin() {
        return isSuperAdmin(getUserId());
    }

    /**
     * 是否为租户管理员
     */
    public static boolean isTenantAdmin(Set<String> rolePermission) {
        if (CollUtil.isEmpty(rolePermission)) {
            return false;
        }
        return rolePermission.contains(TenantConstants.TENANT_ADMIN_ROLE_KEY);
    }

    /**
     * 是否为租户管理员
     */
    public static boolean isTenantAdmin() {
        LoginUser loginUser = getLoginUser();
        if (loginUser == null) {
            return false;
        }
        return isTenantAdmin(loginUser.getRolePermission());
    }

    /**
     * 根据token获取登录用户信息
     */
    @SuppressWarnings("unchecked")
    public static <T extends LoginUser> T getLoginUserByToken(String token) {
        if (ObjectUtil.isEmpty(token)) {
            return null;
        }
        try {
            JwtUtils jwtUtils = SpringUtils.getBean(JwtUtils.class);
            return (T) jwtUtils.getLoginUserFromToken(token);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 检查当前用户是否已登录
     */
    public static boolean isLogin() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            return authentication != null && authentication.isAuthenticated()
                && authentication.getPrincipal() instanceof LoginUserDetails;
        } catch (Exception e) {
            return false;
        }
    }

}
