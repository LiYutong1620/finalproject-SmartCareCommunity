package com.smartcare.business.elder.controller;

import com.smartcare.business.elder.domain.ElUtilityData;
import com.smartcare.business.elder.service.ElUtilityMonitorService;
import com.smartcare.common.core.domain.AjaxResult;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 独居老人水电数据管理与AI监测控制器
 */
@RestController
@RequestMapping("/property/elder/utility")
@RequiredArgsConstructor
public class ElUtilityDataController {

    private final ElUtilityMonitorService utilityMonitorService;

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

    /** 手动触发水电异常检测 */
    @PostMapping("/check/{residentId}")
    public AjaxResult checkAnomaly(@PathVariable Long residentId) {
        Map<String, Object> result = utilityMonitorService.performUtilityCheck(residentId);
        return AjaxResult.success(result);
    }

    /** 仅检测异常不生成预警（预览模式） */
    @GetMapping("/detect/{residentId}")
    public AjaxResult detectOnly(@PathVariable Long residentId) {
        List<Map<String, Object>> anomalies = utilityMonitorService.detectAnomalies(residentId);
        return AjaxResult.success(anomalies);
    }

    /** 生成正常模拟数据 */
    @PostMapping("/simulate/normal")
    public AjaxResult simulateNormal(@RequestParam Long residentId,
                                     @RequestParam(defaultValue = "7") int days) {
        int count = utilityMonitorService.generateSimulatedData(residentId, days);
        return AjaxResult.success("成功生成" + count + "条模拟数据（" + days + "天，每小时1条）");
    }

    /** 生成异常模拟数据（用于测试告警） */
    @PostMapping("/simulate/anomaly")
    public AjaxResult simulateAnomaly(@RequestParam Long residentId,
                                      @RequestParam(defaultValue = "no_usage") String type) {
        int count = utilityMonitorService.generateAnomalyData(residentId, type);
        return AjaxResult.success("成功生成" + count + "条异常模拟数据（类型：" + type + "）");
    }
}
