package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.service.RepairAiStepService;
import com.smartcare.business.repair.service.RepairUploadService;
import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.business.repair.service.RpWorkerProfileService;
import com.smartcare.business.repair.service.WorkerDashboardService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/worker/repair")
@RequiredArgsConstructor
public class WorkerRepairController {

    private final RpOrderService orderService;
    private final RpWorkerProfileService workerProfileService;
    private final RepairAiStepService aiStepService;
    private final WorkerDashboardService dashboardService;
    private final RepairUploadService uploadService;

    @GetMapping("/dashboard")
    public AjaxResult dashboard(@RequestParam(defaultValue = "7") int trendDays) {
        int days = trendDays == 30 ? 30 : 7;
        return AjaxResult.success(dashboardService.getDashboard(SecurityUtils.getUserId(), days));
    }

    @GetMapping("/evaluations")
    public AjaxResult evaluations() {
        return AjaxResult.success(dashboardService.getEvaluations(SecurityUtils.getUserId()));
    }

    @GetMapping("/todo")
    public AjaxResult todo(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status,
                           @RequestParam(required = false) String urgency) {
        var page = orderService.pageTodoByWorker(SecurityUtils.getUserId(), pageNum, pageSize, status, urgency);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/history")
    public AjaxResult history(@RequestParam(defaultValue = "1") int pageNum,
                              @RequestParam(defaultValue = "10") int pageSize,
                              @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
                              @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
                              @RequestParam(required = false) String urgency) {
        var page = orderService.pageHistoryByWorker(SecurityUtils.getUserId(), pageNum, pageSize, startTime, endTime, urgency);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
                           @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        var page = orderService.pageByWorker(SecurityUtils.getUserId(), pageNum, pageSize, status, startTime, endTime);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/pool")
    public AjaxResult pool(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize) {
        var page = orderService.pagePendingPool(pageNum, pageSize);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        Map<String, Object> detail = orderService.buildDetail(orderId, SecurityUtils.getUserId(), "worker");
        return AjaxResult.success(detail);
    }

    @GetMapping("/{orderId}/ai-steps")
    public AjaxResult aiSteps(@PathVariable Long orderId) {
        Map<String, Object> detail = orderService.buildDetail(orderId, SecurityUtils.getUserId(), "worker");
        RpOrder order = (RpOrder) detail.get("order");
        if (!"processing".equals(order.getStatus())) {
            return AjaxResult.error("仅处理中工单可获取AI推荐步骤");
        }
        return AjaxResult.success(aiStepService.generateStepsForOrder(order));
    }

    @PutMapping("/accept/{orderId}")
    public AjaxResult accept(@PathVariable Long orderId) {
        orderService.accept(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/reject/{orderId}")
    public AjaxResult reject(@PathVariable Long orderId, @RequestBody Map<String, String> body) {
        orderService.reject(orderId, SecurityUtils.getUserId(), body.get("reason"), body.get("remark"));
        return AjaxResult.success();
    }

    @PutMapping("/status")
    public AjaxResult updateStatus(@RequestBody Map<String, String> body) {
        orderService.updateStatus(Long.parseLong(body.get("orderId")),
            body.get("status"), SecurityUtils.getUserId().toString(), body.get("remark"));
        return AjaxResult.success();
    }

    @PutMapping("/on-site/{orderId}")
    public AjaxResult onSite(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.workerOnSite(orderId, SecurityUtils.getUserId()));
    }

    @PostMapping("/{orderId}/field-record")
    public AjaxResult saveFieldRecord(@PathVariable Long orderId,
                                      @RequestParam(required = false) Long recordId,
                                      @RequestParam(required = false) String content,
                                      @RequestParam(defaultValue = "false") boolean closeVisit,
                                      @RequestParam(required = false) MultipartFile[] files) throws Exception {
        var imageUrls = uploadService.saveRepairImages(files, true);
        var record = orderService.saveFieldRecord(orderId, SecurityUtils.getUserId(),
            recordId, content, imageUrls, closeVisit);
        return AjaxResult.success(record);
    }

    @PutMapping("/complete/{orderId}")
    public AjaxResult complete(@PathVariable Long orderId) {
        orderService.complete(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PostMapping("/{orderId}/images")
    public AjaxResult uploadImages(@PathVariable Long orderId,
                                   @RequestParam MultipartFile[] files) throws Exception {
        var urls = uploadService.saveRepairImages(files, true);
        orderService.saveOrderImages(orderId, urls);
        orderService.addProgress(orderId, "现场拍照", SecurityUtils.getUserId().toString(), "上传" + urls.size() + "张现场照片");
        return AjaxResult.success(urls);
    }

    @GetMapping("/profile")
    public AjaxResult profile() {
        return AjaxResult.success(workerProfileService.getQualification(SecurityUtils.getUserId()));
    }

    @GetMapping("/skills/catalog")
    public AjaxResult skillCatalog() {
        return AjaxResult.success(com.smartcare.business.repair.support.WorkerSkillCatalog.ALL_SKILLS);
    }

    @PostMapping("/skills/apply")
    public AjaxResult applySkill(@RequestBody Map<String, String> body) {
        workerProfileService.applySkill(
            SecurityUtils.getUserId(), body.get("skillName"), body.get("applyRemark"));
        return AjaxResult.success();
    }

    @PutMapping("/profile/cert")
    public AjaxResult applyCert(@RequestBody Map<String, String> body) {
        LocalDate expire = body.get("certExpire") != null && !body.get("certExpire").isBlank()
            ? LocalDate.parse(body.get("certExpire")) : null;
        workerProfileService.applyCert(
            SecurityUtils.getUserId(),
            body.get("certName"),
            expire,
            body.get("relatedSkill"),
            body.get("applyRemark"));
        return AjaxResult.success();
    }

    @PutMapping("/profile/status")
    public AjaxResult updateStatusProfile(@RequestBody Map<String, String> body) {
        workerProfileService.updateWorkStatus(SecurityUtils.getUserId(), body.get("workStatus"));
        return AjaxResult.success();
    }
}
