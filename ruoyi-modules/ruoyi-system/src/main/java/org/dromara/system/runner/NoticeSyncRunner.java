package org.dromara.system.runner;

import org.dromara.system.service.ISysNoticeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 通知公告消息缓存初始化:
 * 启动时比对MySQL与Redis, Redis中无用户消息列表时从MySQL全量同步
 *
 * @author dromara
 */
@Slf4j
@RequiredArgsConstructor
@Component
public class NoticeSyncRunner implements ApplicationRunner {

    private final ISysNoticeService noticeService;

    @Override
    public void run(ApplicationArguments args) {
        try {
            noticeService.syncNoticeMsgFromDb();
        } catch (Exception e) {
            log.error("通知公告: 消息同步MySQL->Redis失败", e);
        }
    }

}
