package com.smartcare.system.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.framework.storage.FileStorageService;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.ProfilePhoneVerifyService;
import com.smartcare.system.service.SysUserService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/system/user/profile")
@RequiredArgsConstructor
public class ProfileController {

    private static final Set<String> ALLOWED_EXT = Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp");

    private final SysUserService userService;
    private final CmResidentMapper residentMapper;
    private final ProfilePhoneVerifyService profilePhoneVerifyService;
    private final FileStorageService fileStorageService;

    @GetMapping
    public AjaxResult profile() {
        SysUser user = requireLoginUser();
        return AjaxResult.success(toProfileVo(user));
    }

    @PutMapping
    public AjaxResult updateProfile(@RequestBody ProfileBody body) {
        SysUser user = requireLoginUser();
        Long userId = user.getUserId();
        String newPhone = StringUtils.hasText(body.getPhone()) ? body.getPhone().trim() : null;
        String oldPhone = user.getPhone();
        boolean phoneChanged = StringUtils.hasText(newPhone)
            && (oldPhone == null || !newPhone.equals(oldPhone));
        if (phoneChanged) {
            profilePhoneVerifyService.verifyAndConsume(userId, newPhone, body.getPhoneCode());
        }

        SysUser update = new SysUser();
        update.setUserId(userId);
        update.setNickName(body.getNickName());
        update.setPhone(newPhone);
        update.setAvatar(body.getAvatar());
        update.setGender(body.getGender());
        update.setAge(body.getAge());
        validateGenderAge(body.getGender(), body.getAge());
        userService.updateProfileSelf(update);

        if ("0".equals(user.getUserType())) {
            syncOwnerResident(userId, body);
        }

        SysUser latest = userService.selectById(userId);
        return AjaxResult.success(toProfileVo(latest));
    }

    @PostMapping("/phone/send-code")
    public AjaxResult sendPhoneCode(@RequestBody PhoneSendBody body) {
        if (!StringUtils.hasText(body.getPhone())) {
            throw new ServiceException("请输入手机号");
        }
        Long userId = requireLoginUser().getUserId();
        String code = profilePhoneVerifyService.sendCode(userId, body.getPhone());
        Map<String, String> data = new HashMap<>();
        data.put("message", "验证码已发送");
        data.put("demoCode", code);
        return AjaxResult.success(data);
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
        String filename = fileStorageService.saveFlat(file, "avatar");
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

    private void syncOwnerResident(Long userId, ProfileBody body) {
        CmResident resident = findResidentByUserId(userId);
        if (resident == null) {
            return;
        }
        if (StringUtils.hasText(body.getPhone())) {
            long dup = residentMapper.selectCount(new LambdaQueryWrapper<CmResident>()
                .eq(CmResident::getDelFlag, "0")
                .eq(CmResident::getPhone, body.getPhone())
                .ne(CmResident::getResidentId, resident.getResidentId()));
            if (dup > 0) {
                throw new ServiceException("该手机号已被其他住户档案使用");
            }
        }
        CmResident upd = new CmResident();
        upd.setResidentId(resident.getResidentId());
        if (StringUtils.hasText(body.getPhone())) {
            upd.setPhone(body.getPhone());
        }
        if (body.getGender() != null) {
            upd.setGender(body.getGender());
        }
        if (body.getAge() != null) {
            upd.setAge(body.getAge());
        }
        residentMapper.updateById(upd);
    }

    private void validateGenderAge(String gender, Integer age) {
        if (StringUtils.hasText(gender) && !"0".equals(gender) && !"1".equals(gender)) {
            throw new ServiceException("性别格式不正确");
        }
        if (age != null && (age < 1 || age > 120)) {
            throw new ServiceException("年龄应在1-120之间");
        }
    }

    private CmResident findResidentByUserId(Long userId) {
        return residentMapper.selectOne(new LambdaQueryWrapper<CmResident>()
            .eq(CmResident::getUserId, userId)
            .eq(CmResident::getDelFlag, "0")
            .last("LIMIT 1"));
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
        vo.put("gender", user.getGender());
        vo.put("age", user.getAge());
        if ("0".equals(user.getUserType())) {
            CmResident resident = findResidentByUserId(user.getUserId());
            if (resident != null) {
                if (StringUtils.hasText(resident.getGender())) {
                    vo.put("gender", resident.getGender());
                }
                if (resident.getAge() != null) {
                    vo.put("age", resident.getAge());
                }
            }
        }
        return vo;
    }

    @Data
    static class ProfileBody {
        private String nickName;
        private String phone;
        private String phoneCode;
        private String avatar;
        private String gender;
        private Integer age;
    }

    @Data
    static class PhoneSendBody {
        private String phone;
    }

    @Data
    static class UpdatePwdBody {
        private String oldPassword;
        private String newPassword;
    }
}
