package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/system/user")
@RequiredArgsConstructor
public class SysUserController {

    private final SysUserService userService;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String username,
                           @RequestParam(required = false) String userType) {
        var page = userService.pageList(pageNum, pageSize, username, userType);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @PutMapping("/resetPwd")
    public AjaxResult resetPwd(@RequestBody Map<String, String> body) {
        userService.resetPassword(Long.parseLong(body.get("userId")), body.get("password"));
        return AjaxResult.success();
    }
}
