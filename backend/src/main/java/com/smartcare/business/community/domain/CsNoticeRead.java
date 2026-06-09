package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cs_notice_read")
public class CsNoticeRead {
    private Long noticeId;
    private Long userId;
    private LocalDateTime readTime;
}
