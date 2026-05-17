package com.smartcare.framework.captcha;

import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class CaptchaController {

    private final CaptchaService captchaService;

    @GetMapping("/captchaImage")
    public AjaxResult captchaImage() {
        CaptchaService.CaptchaResult result = captchaService.create();
        Map<String, Object> data = new HashMap<>();
        data.put("uuid", result.uuid());
        data.put("img", result.img());
        data.put("captchaEnabled", result.captchaEnabled());
        return AjaxResult.success(data);
    }
}
