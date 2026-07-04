package com.smartcare.business.repair.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.repair.domain.RpWorkerCertificate;
import com.smartcare.business.repair.domain.RpWorkerProfile;
import com.smartcare.business.repair.domain.RpWorkerSkill;
import com.smartcare.business.repair.mapper.RpWorkerCertificateMapper;
import com.smartcare.business.repair.mapper.RpWorkerProfileMapper;
import com.smartcare.business.repair.mapper.RpWorkerSkillMapper;
import com.smartcare.business.repair.service.RpWorkerProfileService;
import com.smartcare.business.repair.support.WorkerSkillCatalog;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.domain.SysWorkerAccount;
import com.smartcare.system.mapper.SysWorkerAccountMapper;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RpWorkerProfileServiceImpl implements RpWorkerProfileService {

    private final RpWorkerProfileMapper profileMapper;
    private final RpWorkerSkillMapper skillMapper;
    private final RpWorkerCertificateMapper certMapper;
    private final UserAccountService accountService;
    private final SysWorkerAccountMapper workerAccountMapper;

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
        SysUser user = accountService.findById(workerId);
        Map<String, Object> info = new HashMap<>();
        info.put("workerId", workerId);
        info.put("workerNo", user != null && StringUtils.hasText(user.getUsername())
            ? user.getUsername() : "W" + workerId);
        String displayName = StringUtils.hasText(profile.getRealName()) ? profile.getRealName()
            : (user != null && StringUtils.hasText(user.getNickName()) ? user.getNickName() : "维修工");
        info.put("name", displayName);
        String phone = StringUtils.hasText(profile.getPhone()) ? profile.getPhone()
            : (user != null ? user.getPhone() : null);
        info.put("virtualPhone", RpWorkerProfileService.maskPhone(phone));
        info.put("workStatus", profile.getWorkStatus());
        info.put("workerLevel", profile.getWorkerLevel());
        info.put("avgScore", profile.getAvgScore());
        info.put("evalCount", profile.getEvalCount());
        return info;
    }

    @Override
    public Map<String, Object> getQualification(Long workerId) {
        Map<String, Object> data = new HashMap<>(getWorkerPublicInfo(workerId));
        List<RpWorkerSkill> skills = skillMapper.selectList(
            new LambdaQueryWrapper<RpWorkerSkill>()
                .eq(RpWorkerSkill::getWorkerId, workerId)
                .orderByDesc(RpWorkerSkill::getSkillId));
        List<RpWorkerCertificate> certificates = certMapper.selectList(
            new LambdaQueryWrapper<RpWorkerCertificate>()
                .eq(RpWorkerCertificate::getWorkerId, workerId)
                .orderByDesc(RpWorkerCertificate::getCreateTime));
        data.put("skills", skills);
        data.put("certificates", certificates);
        data.put("skillCatalog", WorkerSkillCatalog.ALL_SKILLS);
        return data;
    }

    @Override
    public List<Map<String, Object>> listWorkerSummaries(String keyword) {
        List<SysWorkerAccount> accounts = workerAccountMapper.selectList(
            new LambdaQueryWrapper<SysWorkerAccount>()
                .eq(SysWorkerAccount::getDelFlag, "0")
                .orderByDesc(SysWorkerAccount::getCreateTime));
        List<Map<String, Object>> rows = new ArrayList<>();
        String kw = StringUtils.hasText(keyword) ? keyword.trim() : null;
        for (SysWorkerAccount acc : accounts) {
            Long workerId = acc.getAccountId();
            RpWorkerProfile profile = profileMapper.selectById(workerId);
            String name = profile != null && StringUtils.hasText(profile.getRealName())
                ? profile.getRealName() : acc.getUsername();
            if (kw != null && !name.contains(kw) && !acc.getUsername().contains(kw)) {
                continue;
            }
            long pendingSkills = skillMapper.selectCount(new LambdaQueryWrapper<RpWorkerSkill>()
                .eq(RpWorkerSkill::getWorkerId, workerId)
                .eq(RpWorkerSkill::getAuditStatus, "0"));
            long pendingCerts = certMapper.selectCount(new LambdaQueryWrapper<RpWorkerCertificate>()
                .eq(RpWorkerCertificate::getWorkerId, workerId)
                .eq(RpWorkerCertificate::getAuditStatus, "0"));
            long pending = pendingSkills + pendingCerts;
            Map<String, Object> row = new HashMap<>();
            row.put("workerId", workerId);
            row.put("name", name);
            row.put("username", acc.getUsername());
            row.put("workerLevel", profile != null && StringUtils.hasText(profile.getWorkerLevel())
                ? profile.getWorkerLevel() : "初级");
            row.put("hireTime", acc.getCreateTime());
            row.put("auditStatus", pending > 0 ? "0" : "1");
            row.put("pendingCount", pending);
            rows.add(row);
        }
        return rows;
    }

    @Override
    public void updateWorkStatus(Long workerId, String workStatus) {
        if (!List.of("available", "busy", "rest").contains(workStatus)) {
            throw new ServiceException("无效的工作状态");
        }
        RpWorkerProfile profile = getByWorkerId(workerId);
        profile.setWorkStatus(workStatus);
        profileMapper.updateById(profile);
    }

    @Override
    public void applySkill(Long workerId, String skillName, String applyRemark) {
        if (!StringUtils.hasText(skillName)) {
            throw new ServiceException("请选择技能标签");
        }
        if (!StringUtils.hasText(applyRemark) || applyRemark.trim().length() < 10) {
            throw new ServiceException("请填写至少10字的技能说明或从业证明");
        }
        if (!WorkerSkillCatalog.ALL_SKILLS.contains(skillName.trim())) {
            throw new ServiceException("技能不在系统字典中");
        }
        String name = skillName.trim();
        long exists = skillMapper.selectCount(new LambdaQueryWrapper<RpWorkerSkill>()
            .eq(RpWorkerSkill::getWorkerId, workerId)
            .eq(RpWorkerSkill::getSkillName, name)
            .in(RpWorkerSkill::getAuditStatus, "0", "1"));
        if (exists > 0) {
            throw new ServiceException("该技能已拥有或正在审核中");
        }
        RpWorkerSkill skill = new RpWorkerSkill();
        skill.setWorkerId(workerId);
        skill.setSkillName(name);
        skill.setSkillLevel("初级");
        skill.setAuditStatus("0");
        skill.setApplyRemark(applyRemark.trim());
        skillMapper.insert(skill);
    }

    @Override
    public void applyCert(Long workerId, String certName, LocalDate certExpire,
                          String relatedSkill, String applyRemark) {
        if (!StringUtils.hasText(certName)) {
            throw new ServiceException("请填写证书名称");
        }
        if (certExpire == null) {
            throw new ServiceException("请填写证书有效期");
        }
        if (!StringUtils.hasText(applyRemark) || applyRemark.trim().length() < 10) {
            throw new ServiceException("请填写至少10字的证书说明");
        }
        long dup = certMapper.selectCount(new LambdaQueryWrapper<RpWorkerCertificate>()
            .eq(RpWorkerCertificate::getWorkerId, workerId)
            .eq(RpWorkerCertificate::getCertName, certName.trim())
            .in(RpWorkerCertificate::getAuditStatus, "0", "1"));
        if (dup > 0) {
            throw new ServiceException("同名证书已存在或正在审核中");
        }
        RpWorkerCertificate cert = new RpWorkerCertificate();
        cert.setWorkerId(workerId);
        cert.setCertName(certName.trim());
        cert.setCertExpire(certExpire);
        cert.setRelatedSkill(StringUtils.hasText(relatedSkill) ? relatedSkill.trim() : null);
        cert.setApplyRemark(applyRemark.trim());
        cert.setAuditStatus("0");
        cert.setCreateTime(LocalDateTime.now());
        certMapper.insert(cert);
    }

    @Override
    public void updateWorkerLevel(Long workerId, String workerLevel) {
        if (!List.of("初级", "中级", "高级", "资深").contains(workerLevel)) {
            throw new ServiceException("无效的职级");
        }
        RpWorkerProfile profile = getByWorkerId(workerId);
        profile.setWorkerLevel(workerLevel);
        profileMapper.updateById(profile);
    }

    @Override
    public void auditCertById(Long certId, boolean approved, String rejectReason) {
        RpWorkerCertificate cert = certMapper.selectById(certId);
        if (cert == null) {
            throw new ServiceException("证书记录不存在");
        }
        if (!approved) {
            if (!StringUtils.hasText(rejectReason) || rejectReason.trim().length() < 2) {
                throw new ServiceException("请填写驳回原因");
            }
            cert.setAuditRemark(rejectReason.trim());
        } else {
            cert.setAuditRemark(null);
        }
        cert.setAuditStatus(approved ? "1" : "2");
        certMapper.updateById(cert);
    }

    @Override
    public void addCertByAdmin(Long workerId, RpWorkerCertificate cert) {
        getByWorkerId(workerId);
        if (!StringUtils.hasText(cert.getCertName())) {
            throw new ServiceException("请填写证书名称");
        }
        cert.setWorkerId(workerId);
        cert.setCertName(cert.getCertName().trim());
        if (StringUtils.hasText(cert.getRelatedSkill())) {
            cert.setRelatedSkill(cert.getRelatedSkill().trim());
        }
        cert.setAuditStatus("1");
        cert.setCreateTime(LocalDateTime.now());
        certMapper.insert(cert);
    }

    @Override
    public void updateCertByAdmin(RpWorkerCertificate cert) {
        if (cert.getCertId() == null) {
            throw new ServiceException("证书ID不能为空");
        }
        RpWorkerCertificate existing = certMapper.selectById(cert.getCertId());
        if (existing == null) {
            throw new ServiceException("证书记录不存在");
        }
        if (!StringUtils.hasText(cert.getCertName())) {
            throw new ServiceException("请填写证书名称");
        }
        existing.setCertName(cert.getCertName().trim());
        existing.setCertExpire(cert.getCertExpire());
        existing.setRelatedSkill(StringUtils.hasText(cert.getRelatedSkill()) ? cert.getRelatedSkill().trim() : null);
        existing.setApplyRemark(cert.getApplyRemark());
        certMapper.updateById(existing);
    }

    @Override
    public void deleteCertById(Long certId) {
        if (certMapper.selectById(certId) == null) {
            throw new ServiceException("证书记录不存在");
        }
        certMapper.deleteById(certId);
    }

    @Override
    public List<String> listApprovedSkillNames(Long workerId) {
        return skillMapper.selectList(new LambdaQueryWrapper<RpWorkerSkill>()
                .eq(RpWorkerSkill::getWorkerId, workerId)
                .eq(RpWorkerSkill::getAuditStatus, "1"))
            .stream()
            .map(RpWorkerSkill::getSkillName)
            .toList();
    }

    @Override
    public boolean hasApprovedCert(Long workerId) {
        return certMapper.selectCount(new LambdaQueryWrapper<RpWorkerCertificate>()
            .eq(RpWorkerCertificate::getWorkerId, workerId)
            .eq(RpWorkerCertificate::getAuditStatus, "1")) > 0;
    }
}
