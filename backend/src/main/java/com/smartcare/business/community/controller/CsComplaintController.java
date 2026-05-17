package com.smartcare.business.community.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.CsComplaint;
import com.smartcare.business.community.mapper.CsComplaintMapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.ThreadLocalRandom;

@RestController
@RequiredArgsConstructor
public class CsComplaintController {

    private final CsComplaintMapper complaintMapper;

    @PostMapping("/owner/complaint")
    public AjaxResult submit(@RequestBody CsComplaint complaint) {
        complaint.setUserId(SecurityUtils.getUserId());
        complaint.setComplaintNo("CP" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
            + ThreadLocalRandom.current().nextInt(100, 999));
        complaint.setStatus("pending");
        complaintMapper.insert(complaint);
        return AjaxResult.success();
    }

    @GetMapping("/owner/complaint/list")
    public AjaxResult ownerList(@RequestParam(defaultValue = "1") int pageNum,
                                @RequestParam(defaultValue = "10") int pageSize) {
        Page<CsComplaint> page = complaintMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<CsComplaint>()
                .eq(CsComplaint::getUserId, SecurityUtils.getUserId())
                .orderByDesc(CsComplaint::getCreateTime));
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/property/complaint/list")
    public AjaxResult propertyList(@RequestParam(defaultValue = "1") int pageNum,
                                   @RequestParam(defaultValue = "10") int pageSize,
                                   @RequestParam(required = false) String status) {
        Page<CsComplaint> page = complaintMapper.selectPage(new Page<>(pageNum, pageSize),
            new LambdaQueryWrapper<CsComplaint>()
                .eq(status != null, CsComplaint::getStatus, status)
                .orderByDesc(CsComplaint::getCreateTime));
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PutMapping("/property/complaint/handle")
    public AjaxResult handle(@RequestBody CsComplaint complaint) {
        complaint.setHandlerId(SecurityUtils.getUserId());
        complaint.setStatus("processing");
        complaintMapper.updateById(complaint);
        return AjaxResult.success();
    }

    @PutMapping("/property/complaint/reply")
    public AjaxResult reply(@RequestBody CsComplaint complaint) {
        complaint.setReplyTime(LocalDateTime.now());
        complaint.setStatus("replied");
        complaint.setHandlerId(SecurityUtils.getUserId());
        complaintMapper.updateById(complaint);
        return AjaxResult.success();
    }
}
