package org.dromara.system.service.impl;

import lombok.RequiredArgsConstructor;
import org.dromara.common.core.constant.TenantConstants;
import org.dromara.common.core.service.PermissionService;
import org.dromara.common.satoken.utils.LoginHelper;
import org.dromara.system.service.ISysMenuService;
import org.dromara.system.service.ISysPermissionService;
import org.dromara.system.service.ISysRoleService;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Set;

/**
 * 用户权限处理
 *
 * @author ruoyi
 */
@RequiredArgsConstructor
@Service
public class SysPermissionServiceImpl implements ISysPermissionService, PermissionService {

    private final ISysRoleService roleService;
    private final ISysMenuService menuService;

    /**
     * 获取角色数据权限
     *
     * @param userId  用户id
     * @return 角色权限信息
     */
    @Override
    public Set<String> getRolePermission(Long userId) {
        Set<String> roles = new HashSet<>();
        // 管理员拥有所有权限
        if (LoginHelper.isSuperAdmin(userId)) {
            roles.add(TenantConstants.SUPER_ADMIN_ROLE_KEY);
        } else {
            roles.addAll(roleService.selectRolePermissionByUserId(userId));
        }
        return roles;
    }

    /**
     * 获取菜单数据权限
     *
     * @param userId  用户id
     * @return 菜单权限信息
     */
    @Override
    public Set<String> getMenuPermission(Long userId) {
        Set<String> perms = new HashSet<>();
        // 管理员拥有所有权限
        if (LoginHelper.isSuperAdmin(userId)) {
            // 保留通配符，供前端 hasPermi('*:*:*') 兼容判断使用
            perms.add("*:*:*");
            // Spring Security 的 hasAuthority 为精确匹配，不支持通配符，
            // 因此需要加载 sys_menu 中全部权限标识，保证 @PreAuthorize 校验通过
            perms.addAll(menuService.selectAllMenuPerms());
        } else {
            perms.addAll(menuService.selectMenuPermsByUserId(userId));
        }
        return perms;
    }
}
