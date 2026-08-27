package org.dromara.system.controller.system;

import org.springframework.security.access.prepost.PreAuthorize;
import lombok.RequiredArgsConstructor;
import org.dromara.common.core.domain.R;
import org.dromara.common.idempotent.annotation.RepeatSubmit;
import org.dromara.common.log.annotation.Log;
import org.dromara.common.log.enums.BusinessType;
import org.dromara.common.mybatis.core.page.PageQuery;
import org.dromara.common.mybatis.core.page.TableDataInfo;
import org.dromara.common.web.core.BaseController;
import org.dromara.system.domain.bo.SysNoticeBo;
import org.dromara.system.domain.vo.SysNoticeVo;
import org.dromara.system.service.ISysNoticeService;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 公告 信息操作处理
 *
 * @author Lion Li
 */
@Validated
@RequiredArgsConstructor
@RestController
@RequestMapping("/system/notice")
public class SysNoticeController extends BaseController {

    private final ISysNoticeService noticeService;

    /**
     * 获取通知公告列表
     */
    @PreAuthorize("hasAuthority('system:notice:list')")
    @GetMapping("/list")
    public TableDataInfo<SysNoticeVo> list(SysNoticeBo notice, PageQuery pageQuery) {
        return noticeService.selectPageNoticeList(notice, pageQuery);
    }

    /**
     * 获取当前登录用户的通知消息列表(从Redis读取, 供顶部铃铛展示)
     */
    @GetMapping("/push/list")
    public R<List<SysNoticeVo>> pushList() {
        return R.ok(noticeService.selectPushNoticeList());
    }

    /**
     * 标记通知消息已读(写入Redis已读集合)
     *
     * @param noticeIds 公告ID集合
     */
    @PutMapping("/push/read")
    public R<Void> pushRead(@RequestBody List<String> noticeIds) {
        return toAjax(noticeService.markNoticeRead(noticeIds));
    }

    /**
     * 根据通知公告编号获取详细信息
     *
     * @param noticeId 公告ID
     */
    @PreAuthorize("hasAuthority('system:notice:query')")
    @GetMapping(value = "/{noticeId}")
    public R<SysNoticeVo> getInfo(@PathVariable String noticeId) {
        return R.ok(noticeService.selectNoticeById(noticeId));
    }

    /**
     * 新增通知公告(同步按发送对象投递到Redis用户消息列表)
     */
    @PreAuthorize("hasAuthority('system:notice:add')")
    @Log(title = "通知公告", businessType = BusinessType.INSERT)
    @RepeatSubmit()
    @PostMapping
    public R<Void> add(@Validated @RequestBody SysNoticeBo notice) {
        return toAjax(noticeService.insertNotice(notice));
    }

    /**
     * 修改通知公告
     */
    @PreAuthorize("hasAuthority('system:notice:edit')")
    @Log(title = "通知公告", businessType = BusinessType.UPDATE)
    @RepeatSubmit()
    @PutMapping
    public R<Void> edit(@Validated @RequestBody SysNoticeBo notice) {
        return toAjax(noticeService.updateNotice(notice));
    }

    /**
     * 删除通知公告
     *
     * @param noticeIds 公告ID串
     */
    @PreAuthorize("hasAuthority('system:notice:remove')")
    @Log(title = "通知公告", businessType = BusinessType.DELETE)
    @DeleteMapping("/{noticeIds}")
    public R<Void> remove(@PathVariable String[] noticeIds) {
        return toAjax(noticeService.deleteNoticeByIds(noticeIds));
    }
}
