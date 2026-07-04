package com.smartcare.business.elder.controller;

import com.smartcare.business.elder.domain.ElUtilityData;
import com.smartcare.business.elder.service.ElAiMonitorService;
import com.smartcare.business.elder.service.ElUtilityMonitorService;
import com.smartcare.business.property.domain.CmResident;
import com.smartcare.business.property.mapper.CmResidentMapper;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 独居老人水电数据管理与AI监测控制器
 */
@RestController
@RequestMapping("/property/elder/utility")
@RequiredArgsConstructor
public class ElUtilityDataController {

    private static final Map<String, String> ANOMALY_TYPE_LABEL = Map.of(
        "no_living_sign", "生活迹象异常",
        "no_usage", "24小时全零用量",
        "surge", "用量突增",
        "night_high", "夜间高用量"
    );

    private final ElUtilityMonitorService utilityMonitorService;
    private final ElAiMonitorService aiMonitorService;
    private final CmResidentMapper residentMapper;

    /** 查询水电数据（分页） */
    @GetMapping("/list")
    public AjaxResult list(@RequestParam(required = false) Long residentId,
                           @RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "20") int pageSize) {
        return AjaxResult.success(utilityMonitorService.listUtilityData(residentId, pageNum, pageSize));
    }

    /** 获取某老人最近N小时数据（默认48h，图表用） */
    @GetMapping("/recent/{residentId}")
    public AjaxResult recentData(@PathVariable Long residentId,
                                 @RequestParam(defaultValue = "48") int hours) {
        List<ElUtilityData> data = utilityMonitorService.getRecentData(residentId, hours);
        return AjaxResult.success(data);
    }

    /** 手动触发 AI 安全监测（与 AI 安全监测页一致，含水电规则） */
    @PostMapping("/check/{residentId}")
    public AjaxResult checkAnomaly(@PathVariable Long residentId) {
        return AjaxResult.success(aiMonitorService.performFullCheck(residentId));
    }

    /** 仅检测异常不生成预警（预览模式） */
    @GetMapping("/detect/{residentId}")
    public AjaxResult detectOnly(@PathVariable Long residentId) {
        List<Map<String, Object>> anomalies = utilityMonitorService.detectAnomalies(residentId);
        return AjaxResult.success(anomalies);
    }

    /** 生成正常模拟数据（仅针对指定老人） */
    @PostMapping("/simulate/normal")
    public AjaxResult simulateNormal(@RequestParam Long residentId,
                                     @RequestParam(defaultValue = "7") int days) {
        int count = utilityMonitorService.generateSimulatedData(residentId, days);
        String name = residentName(residentId);
        return AjaxResult.success("已为【" + name + "】生成近 " + days + " 天正常水电数据（共 " + count + " 条）");
    }

    /** 生成异常模拟数据并自动触发 AI 安全监测（仅针对指定老人） */
    @PostMapping("/simulate/anomaly")
    public AjaxResult simulateAnomaly(@RequestParam Long residentId,
                                      @RequestParam(defaultValue = "no_usage") String type) {
        int count = utilityMonitorService.generateAnomalyData(residentId, type);
        Map<String, Object> checkResult = aiMonitorService.performFullCheck(residentId);
        String name = residentName(residentId);
        String typeLabel = ANOMALY_TYPE_LABEL.getOrDefault(type, type);
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("message", "已为【" + name + "】生成近24小时异常数据（" + typeLabel + "），并完成安全监测");
        payload.put("residentName", name);
        payload.put("dataCount", count);
        payload.put("anomalyType", type);
        payload.put("checkResult", checkResult);
        return AjaxResult.success(payload);
    }

    private String residentName(Long residentId) {
        CmResident resident = residentMapper.selectById(residentId);
        return resident != null && resident.getName() != null ? resident.getName() : "选中老人";
    }
}
