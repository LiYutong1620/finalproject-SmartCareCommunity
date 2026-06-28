package com.smartcare.business.community.service;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.smartcare.business.ai.service.KbLearnService;
import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.mapper.CsNoticeMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class NoticePublishScheduler {

    private final CsNoticeMapper noticeMapper;
    private final KbLearnService kbLearnService;

    public void processScheduledTasks() {
        int activated = activateDueNotices();
        offlineDueNotices();
        if (activated > 0) {
            kbLearnService.syncNewlyPublishedNotices();
        }
    }

    /** 将已到发布时间的待发布公告自动上架 */
    public int activateDueNotices() {
        return noticeMapper.update(null, new LambdaUpdateWrapper<CsNotice>()
            .set(CsNotice::getStatus, "1")
            .eq(CsNotice::getStatus, "2")
            .le(CsNotice::getCreateTime, LocalDateTime.now()));
    }

    /** 将已到下架时间的公告自动下架并取消置顶 */
    public int offlineDueNotices() {
        return noticeMapper.update(null, new LambdaUpdateWrapper<CsNotice>()
            .set(CsNotice::getStatus, "0")
            .set(CsNotice::getPinned, 0)
            .in(CsNotice::getStatus, "1", "2")
            .isNotNull(CsNotice::getOfflineTime)
            .le(CsNotice::getOfflineTime, LocalDateTime.now()));
    }
}
