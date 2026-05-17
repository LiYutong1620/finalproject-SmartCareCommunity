package com.smartcare.business.community.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.CsNotice;
import com.smartcare.business.community.mapper.CsNoticeMapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class CsNoticeController {

    private final CsNoticeMapper noticeMapper;

    @GetMapping({"/owner/notice/list", "/property/notice/list"})
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String noticeType) {
        Page<CsNotice> page = noticeMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<CsNotice>()
                .eq(CsNotice::getStatus, "1")
                .eq(noticeType != null, CsNotice::getNoticeType, noticeType)
                .orderByDesc(CsNotice::getPinned)
                .orderByDesc(CsNotice::getCreateTime));
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PostMapping("/property/notice")
    public AjaxResult add(@RequestBody CsNotice notice) {
        notice.setCreateBy(SecurityUtils.getUserId());
        notice.setStatus("1");
        noticeMapper.insert(notice);
        return AjaxResult.success();
    }

    @PutMapping("/property/notice")
    public AjaxResult edit(@RequestBody CsNotice notice) {
        noticeMapper.updateById(notice);
        return AjaxResult.success();
    }

    @DeleteMapping("/property/notice/{noticeId}")
    public AjaxResult remove(@PathVariable Long noticeId) {
        CsNotice n = new CsNotice();
        n.setNoticeId(noticeId);
        n.setStatus("0");
        noticeMapper.updateById(n);
        return AjaxResult.success();
    }
}
