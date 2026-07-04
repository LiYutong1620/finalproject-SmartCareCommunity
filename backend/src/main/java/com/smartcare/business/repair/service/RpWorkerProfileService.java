package com.smartcare.business.repair.service;

import com.smartcare.business.repair.domain.RpWorkerCertificate;
import com.smartcare.business.repair.domain.RpWorkerProfile;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface RpWorkerProfileService {

    RpWorkerProfile getByWorkerId(Long workerId);

    Map<String, Object> getWorkerPublicInfo(Long workerId);

    Map<String, Object> getQualification(Long workerId);

    void updateWorkStatus(Long workerId, String workStatus);

    void applySkill(Long workerId, String skillName, String applyRemark);

    void applyCert(Long workerId, String certName, LocalDate certExpire, String relatedSkill, String applyRemark);

    void updateWorkerLevel(Long workerId, String workerLevel);

    List<Map<String, Object>> listWorkerSummaries(String keyword);

    void auditCertById(Long certId, boolean approved, String rejectReason);

    void addCertByAdmin(Long workerId, RpWorkerCertificate cert);

    void updateCertByAdmin(RpWorkerCertificate cert);

    void deleteCertById(Long certId);

    List<String> listApprovedSkillNames(Long workerId);

    boolean hasApprovedCert(Long workerId);

    static String maskPhone(String phone) {
        if (phone == null || phone.isBlank() || phone.length() < 7) {
            return "暂无";
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }
}
