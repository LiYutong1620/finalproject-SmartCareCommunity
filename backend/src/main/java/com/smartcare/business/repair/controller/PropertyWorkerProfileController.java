package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.domain.RpWorkerCertificate;
import com.smartcare.business.repair.service.RpWorkerProfileService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/property/worker-profile")
@RequiredArgsConstructor
public class PropertyWorkerProfileController {

    private final RpWorkerProfileService workerProfileService;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(required = false) String keyword) {
        return AjaxResult.success(workerProfileService.listWorkerSummaries(keyword));
    }

    @GetMapping("/{workerId}")
    public AjaxResult detail(@PathVariable Long workerId) {
        return AjaxResult.success(workerProfileService.getQualification(workerId));
    }

    @PutMapping("/{workerId}/level")
    public AjaxResult updateLevel(@PathVariable Long workerId, @RequestBody Map<String, String> body) {
        workerProfileService.updateWorkerLevel(workerId, body.get("workerLevel"));
        return AjaxResult.success();
    }

    @PutMapping("/cert-audit/{certId}")
    public AjaxResult auditCert(@PathVariable Long certId, @RequestBody Map<String, Object> body) {
        boolean approved = Boolean.TRUE.equals(body.get("approved"));
        String rejectReason = body.get("rejectReason") != null ? String.valueOf(body.get("rejectReason")) : null;
        workerProfileService.auditCertById(certId, approved, rejectReason);
        return AjaxResult.success();
    }

    @PostMapping("/{workerId}/cert")
    public AjaxResult addCert(@PathVariable Long workerId, @RequestBody RpWorkerCertificate cert) {
        workerProfileService.addCertByAdmin(workerId, cert);
        return AjaxResult.success();
    }

    @PutMapping("/cert/{certId}")
    public AjaxResult updateCert(@PathVariable Long certId, @RequestBody RpWorkerCertificate cert) {
        cert.setCertId(certId);
        workerProfileService.updateCertByAdmin(cert);
        return AjaxResult.success();
    }

    @DeleteMapping("/cert/{certId}")
    public AjaxResult deleteCert(@PathVariable Long certId) {
        workerProfileService.deleteCertById(certId);
        return AjaxResult.success();
    }
}
