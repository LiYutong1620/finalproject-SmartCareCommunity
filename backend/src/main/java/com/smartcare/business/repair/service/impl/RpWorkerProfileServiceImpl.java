package com.smartcare.business.repair.service.impl;

import com.smartcare.business.repair.domain.RpWorkerProfile;
import com.smartcare.business.repair.mapper.RpWorkerProfileMapper;
import com.smartcare.business.repair.service.RpWorkerProfileService;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RpWorkerProfileServiceImpl implements RpWorkerProfileService {

    private final RpWorkerProfileMapper profileMapper;
    private final SysUserMapper userMapper;

    @Override
    public RpWorkerProfile getByWorkerId(Long workerId) {
        RpWorkerProfile profile = profileMapper.selectById(workerId);
        if (profile == null) {
            throw new ServiceException("维修工档案不存在");
        }
        return profile;
    }

    @Override
    public Map<String, Object> getWorkerPublicInfo(Long workerId) {
        RpWorkerProfile profile = getByWorkerId(workerId);
        SysUser user = userMapper.selectById(workerId);
        Map<String, Object> info = new HashMap<>();
        info.put("workerId", workerId);
        info.put("workerNo", user != null && StringUtils.hasText(user.getUsername())
            ? user.getUsername() : "W" + workerId);
        info.put("name", user != null && StringUtils.hasText(user.getNickName())
            ? user.getNickName() : "维修工");
        info.put("virtualPhone", RpWorkerProfileService.maskPhone(user != null ? user.getPhone() : null));
        info.put("workStatus", profile.getWorkStatus());
        info.put("avgScore", profile.getAvgScore());
        info.put("evalCount", profile.getEvalCount());
        info.put("certName", profile.getCertName());
        info.put("certExpire", profile.getCertExpire());
        return info;
    }

    @Override
    public void updateWorkStatus(Long workerId, String workStatus) {
        RpWorkerProfile profile = getByWorkerId(workerId);
        profile.setWorkStatus(workStatus);
        profileMapper.updateById(profile);
    }
}
