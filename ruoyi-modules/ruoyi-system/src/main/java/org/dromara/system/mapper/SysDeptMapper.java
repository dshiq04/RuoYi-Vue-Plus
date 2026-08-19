package org.dromara.system.mapper;

import cn.hutool.core.convert.Convert;
import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.dromara.common.core.utils.StreamUtils;
import org.dromara.common.mybatis.annotation.DataColumn;
import org.dromara.common.mybatis.annotation.DataPermission;
import org.dromara.common.mybatis.core.mapper.BaseMapperPlus;
import org.dromara.common.mybatis.helper.DataBaseHelper;
import cn.hutool.core.util.ObjectUtil;
import org.dromara.system.domain.SysDept;
import org.dromara.system.domain.vo.SysDeptVo;

import java.util.ArrayList;
import java.util.List;

/**
 * 部门管理 数据层
 *
 * @author Lion Li
 */
public interface SysDeptMapper extends BaseMapperPlus<SysDept, SysDeptVo> {

    /**
     * 构建角色对应的部门 SQL 查询语句
     *
     * <p>该 SQL 用于查询某个角色关联的所有部门 ID，常用于数据权限控制</p>
     *
     * @param roleId 角色ID
     * @return 查询部门ID的 SQL 语句字符串
     */
    default String buildDeptByRoleSql(String roleId) {
        return """
                select srd.dept_id from sys_role_dept srd
                    left join sys_role sr on sr.role_id = srd.role_id
                    where srd.role_id = '%s' and sr.status = '0'
            """.formatted(roleId);
    }

    /**
     * 构建 SQL 查询，用于获取当前角色拥有的部门中所有的父部门ID
     *
     * <p>
     * 该 SQL 用于 deptCheckStrictly 场景下，排除非叶子节点（父节点）用。
     * </p>
     *
     * @param roleId 角色ID
     * @return SQL 语句字符串，查询角色下部门的所有父部门ID
     */
    default String buildParentDeptByRoleSql(String roleId) {
        return """
                select parent_id from sys_dept where dept_id in (
                    select srd.dept_id from sys_role_dept srd
                        left join sys_role sr on sr.role_id = srd.role_id
                        where srd.role_id = '%s' and sr.status = '0'
                )
            """.formatted(roleId);
    }

    /**
     * 查询部门管理数据
     *
     * @param queryWrapper 查询条件
     * @return 部门信息集合
     */
    @DataPermission({
        @DataColumn(key = "deptName", value = "dept_id")
    })
    default List<SysDeptVo> selectDeptList(Wrapper<SysDept> queryWrapper) {
        return this.selectVoList(queryWrapper);
    }

    /**
     * 分页查询部门管理数据
     *
     * @param page         分页信息
     * @param queryWrapper 查询条件
     * @return 部门信息集合
     */
    @DataPermission({
        @DataColumn(key = "deptName", value = "dept_id"),
    })
    default Page<SysDeptVo> selectPageDeptList(Page<SysDept> page, Wrapper<SysDept> queryWrapper) {
        return this.selectVoPage(page, queryWrapper);
    }

    /**
     * 统计指定部门ID的部门数量
     *
     * @param deptId 部门ID
     * @return 该部门ID的部门数量
     */
    @DataPermission({
        @DataColumn(key = "deptName", value = "dept_id")
    })
    default long countDeptById(String deptId) {
        return this.selectCount(new LambdaQueryWrapper<SysDept>().eq(SysDept::getDeptId, deptId));
    }

    /**
     * 根据父部门ID查询其所有子部门的列表
     *
     * @param parentId 父部门ID
     * @return 包含子部门的列表
     */
    default List<SysDept> selectListByParentId(String parentId) {
        return this.selectList(new LambdaQueryWrapper<SysDept>()
            .select(SysDept::getDeptId)
            .apply(DataBaseHelper.findInSet(parentId, "ancestors")));
    }

    /**
     * 查询某个部门及其所有子部门ID（含自身）
     *
     * @param parentId 父部门ID
     * @return 部门ID集合
     */
    default List<String> selectDeptAndChildById(String parentId) {
        if (ObjectUtil.isEmpty(parentId)) {
            return new ArrayList<>();
        }
        // 递归收集 parentId 自身及其所有后代部门ID
        List<String> deptIds = new ArrayList<>();
        collectChildDeptIds(parentId, deptIds);
        return deptIds;
    }

    /**
     * 递归收集部门及其所有子部门的ID
     *
     * @param parentId 父部门ID
     * @param deptIds  用于累积结果的部门ID集合
     */
    default void collectChildDeptIds(String parentId, List<String> deptIds) {
        if (ObjectUtil.isEmpty(parentId) || deptIds.contains(parentId)) {
            return;
        }
        deptIds.add(parentId);
        List<SysDept> children = this.selectListByParentId(parentId);
        for (SysDept child : children) {
            collectChildDeptIds(child.getDeptId(), deptIds);
        }
    }

    /**
     * 根据角色ID查询部门树信息
     *
     * @param roleId            角色ID
     * @param deptCheckStrictly 部门树选择项是否关联显示
     * @return 选中部门列表
     */
    default List<String> selectDeptListByRoleId(String roleId, boolean deptCheckStrictly) {
        LambdaQueryWrapper<SysDept> wrapper = new LambdaQueryWrapper<>();
        wrapper.select(SysDept::getDeptId)
            .inSql(SysDept::getDeptId, this.buildDeptByRoleSql(roleId))
            .orderByAsc(SysDept::getParentId)
            .orderByAsc(SysDept::getOrderNum);
        if (deptCheckStrictly) {
            wrapper.notInSql(SysDept::getDeptId, this.buildParentDeptByRoleSql(roleId));
        }
        return this.selectObjs(wrapper, x -> {
            return Convert.toStr(x);
        });
    }

}
