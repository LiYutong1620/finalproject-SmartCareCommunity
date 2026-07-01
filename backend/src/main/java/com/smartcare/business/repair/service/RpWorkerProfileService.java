package com.smartcare.business.repair.service;

import com.smartcare.business.repair.domain.RpWorkerProfile;
import org.springframework.util.StringUtils;

import java.util.Map;

public interface RpWorkerProfileService {

    RpWorkerProfile getByWorkerId(Long workerId);

    Map<String, Object> getWorkerPublicInfo(Long workerId);

    void updateWorkStatus(Long workerId, String workStatus);

    static String maskPhone(String phone) {
        if (!StringUtils.hasText(phone) || phone.length() < 7) {
            return "暂无";
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }
}
