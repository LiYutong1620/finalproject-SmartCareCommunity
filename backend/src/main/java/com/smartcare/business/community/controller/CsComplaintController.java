package com.smartcare.business.community.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.CsComplaint;
import com.smartcare.business.community.mapper.CsComplaintMapper;
import com.smartcare.business.community.service.PropertyCommunityService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class CsComplaintController {

    private final CsComplaintMapper complaintMapper;
    private final PropertyCommunityService propertyCommunityService;

    @PostMapping("/owner/complaint")
    public AjaxResult submit(@RequestBody CsComplaint complaint) {
        complaint.setUserId(SecurityUtils.getUserId());
        complaint.setComplaintNo(propertyCommunityService.nextComplaintNo());
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

}
