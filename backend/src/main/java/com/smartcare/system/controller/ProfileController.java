package com.smartcare.system.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.SysUserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/system/user/profile")
@RequiredArgsConstructor
public class ProfileController {

    private static final Set<String> ALLOWED_EXT = Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp");

    private final SysUserService userService;

    @Value("${smartcare.file.upload-path:./upload}")
    private String uploadPath;

    @GetMapping
    public AjaxResult profile() {
        SysUser user = requireLoginUser();
        return AjaxResult.success(toProfileVo(user));
    }

    @PutMapping
    public AjaxResult updateProfile(@RequestBody SysUser body) {
        Long userId = requireLoginUser().getUserId();
        SysUser update = new SysUser();
        update.setUserId(userId);
        update.setNickName(body.getNickName());
        update.setPhone(body.getPhone());
        update.setAvatar(body.getAvatar());
        userService.updateProfileSelf(update);
        SysUser latest = userService.selectById(userId);
        return AjaxResult.success(toProfileVo(latest));
    }

    @PutMapping("/updatePwd")
    public AjaxResult updatePwd(@RequestBody UpdatePwdBody body) {
        Long userId = requireLoginUser().getUserId();
        userService.updatePassword(userId, body.getOldPassword(), body.getNewPassword());
        return AjaxResult.success();
    }

    @PostMapping("/avatar")
    public AjaxResult uploadAvatar(@RequestParam("avatarfile") MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new ServiceException("请选择图片");
        }
        String original = file.getOriginalFilename();
        String ext = original != null && original.contains(".")
            ? original.substring(original.lastIndexOf('.')).toLowerCase() : "";
        if (!ALLOWED_EXT.contains(ext)) {
            throw new ServiceException("仅支持 jpg/png/gif/webp 格式");
        }
        Path dir = Paths.get(uploadPath, "avatar");
        Files.createDirectories(dir);
        String filename = UUID.randomUUID().toString().replace("-", "") + ext;
        Path target = dir.resolve(filename);
        file.transferTo(target.toFile());

        String avatarUrl = "/upload/avatar/" + filename;
        Long userId = requireLoginUser().getUserId();
        SysUser update = new SysUser();
        update.setUserId(userId);
        update.setAvatar(avatarUrl);
        userService.updateProfileSelf(update);

        Map<String, String> data = new HashMap<>();
        data.put("imgUrl", avatarUrl);
        return AjaxResult.success(data);
    }

    private SysUser requireLoginUser() {
        SysUser login = SecurityUtils.getUser();
        if (login == null) {
            throw new ServiceException("未登录");
        }
        SysUser user = userService.selectById(login.getUserId());
        if (user == null) {
            throw new ServiceException("用户不存在");
        }
        return user;
    }

    private Map<String, Object> toProfileVo(SysUser user) {
        Map<String, Object> vo = new HashMap<>();
        vo.put("userId", user.getUserId());
        vo.put("username", user.getUsername());
        vo.put("nickName", user.getNickName());
        vo.put("phone", user.getPhone());
        vo.put("avatar", user.getAvatar());
        vo.put("userType", user.getUserType());
        vo.put("createTime", user.getCreateTime());
        return vo;
    }

    @Data
    static class UpdatePwdBody {
        private String oldPassword;
        private String newPassword;
    }
}
