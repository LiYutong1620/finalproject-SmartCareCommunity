package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.SysRoleService;
import com.smartcare.system.service.SysUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/system/user")
@RequiredArgsConstructor
public class SysUserController {

    private final SysUserService userService;
    private final SysRoleService roleService;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String username,
                           @RequestParam(required = false) String userType) {
        var page = userService.pageList(pageNum, pageSize, username, userType);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    /** 新增用户（物业后台添加业主/维修工/物业） */
    @PostMapping
    public AjaxResult add(@RequestBody SysUser user) {
        if (!StringUtils.hasText(user.getUsername()) || user.getUsername().length() < 4) {
            throw new ServiceException("账号长度至少4位");
        }
        if (!StringUtils.hasText(user.getPassword()) || user.getPassword().length() < 6) {
            throw new ServiceException("密码长度至少6位");
        }
        if (userService.selectByUsername(user.getUsername()) != null) {
            throw new ServiceException("账号已存在");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setStatus("0");
        user.setDelFlag("0");
        if (!StringUtils.hasText(user.getUserType())) {
            user.setUserType("0");
        }
        userService.createUser(user);
        return AjaxResult.success();
    }

    /** 修改用户信息 */
    @PutMapping
    public AjaxResult edit(@RequestBody SysUser user) {
        if (user.getUserId() == null) {
            throw new ServiceException("用户ID不能为空");
        }
        // 不允许通过这个接口修改密码
        user.setPassword(null);
        userService.updateProfile(user);
        return AjaxResult.success();
    }

    /** 停用/启用用户 */
    @PutMapping("/changeStatus")
    public AjaxResult changeStatus(@RequestBody Map<String, String> body) {
        Long userId = Long.parseLong(body.get("userId"));
        String status = body.get("status");
        SysUser u = new SysUser();
        u.setUserId(userId);
        u.setStatus(status);
        userService.updateProfile(u);
        return AjaxResult.success();
    }

    @PutMapping("/resetPwd")
    public AjaxResult resetPwd(@RequestBody Map<String, String> body) {
        userService.resetPassword(Long.parseLong(body.get("userId")), body.get("password"));
        return AjaxResult.success();
    }

    /** 删除用户（逻辑删除） */
    @DeleteMapping("/{userId}")
    public AjaxResult remove(@PathVariable Long userId) {
        userService.deleteUser(userId);
        return AjaxResult.success();
    }
}
