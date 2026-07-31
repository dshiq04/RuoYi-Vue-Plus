package org.dromara.system.service.impl;

import cn.hutool.core.util.ArrayUtil;
import org.dromara.common.core.domain.model.LoginUser;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.common.sensitive.core.SensitiveService;
import org.dromara.common.tenant.helper.TenantHelper;
import org.springframework.stereotype.Service;

/**
 * 脱敏服务
 * 默认管理员不过滤
 * 需自行根据业务重写实现
 *
 * @author Lion Li
 * @version 3.6.0
 */
@Service
public class SysSensitiveServiceImpl implements SensitiveService {

    /**
     * 是否脱敏
     */
    @Override
    public boolean isSensitive(String[] roleKey, String[] perms) {
        if (!LoginHelper.isLogin()) {
            return true;
        }
        LoginUser loginUser = LoginHelper.getLoginUser();
        boolean roleExist = ArrayUtil.isNotEmpty(roleKey);
        boolean permsExist = ArrayUtil.isNotEmpty(perms);
        if (roleExist && permsExist) {
            if (hasRoleOr(loginUser, roleKey) && hasPermissionOr(loginUser, perms)) {
                return false;
            }
        } else if (roleExist && hasRoleOr(loginUser, roleKey)) {
            return false;
        } else if (permsExist && hasPermissionOr(loginUser, perms)) {
            return false;
        }

        if (TenantHelper.isEnable()) {
            return !LoginHelper.isSuperAdmin() && !LoginHelper.isTenantAdmin();
        }
        return !LoginHelper.isSuperAdmin();
    }

    /**
     * 判断用户是否拥有指定角色（任一匹配即可）
     */
    private boolean hasRoleOr(LoginUser loginUser, String[] roleKeys) {
        if (loginUser.getRolePermission() == null) {
            return false;
        }
        for (String roleKey : roleKeys) {
            if (loginUser.getRolePermission().contains(roleKey)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 判断用户是否拥有指定权限（任一匹配即可）
     */
    private boolean hasPermissionOr(LoginUser loginUser, String[] perms) {
        if (loginUser.getMenuPermission() == null) {
            return false;
        }
        for (String perm : perms) {
            if (loginUser.getMenuPermission().contains(perm)) {
                return true;
            }
        }
        return false;
    }

}
