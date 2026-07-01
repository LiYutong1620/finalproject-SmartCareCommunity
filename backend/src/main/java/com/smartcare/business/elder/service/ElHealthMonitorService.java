package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElAlert;
import com.smartcare.business.elder.domain.ElHealthRecord;
import com.smartcare.business.elder.domain.ElHealthThreshold;
import com.smartcare.business.elder.mapper.ElAlertMapper;
import com.smartcare.business.elder.mapper.ElHealthRecordMapper;
import com.smartcare.business.elder.mapper.ElHealthThresholdMapper;
import com.smartcare.common.core.page.TableDataInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ElHealthMonitorService {

    private final ElHealthRecordMapper healthRecordMapper;
    private final ElHealthThresholdMapper thresholdMapper;
    private final ElAlertMapper alertMapper;

    @Transactional
    public void recordHealthData(Long residentId, ElHealthRecord record) {
        record.setResidentId(residentId);
        if (record.getRecordTime() == null) {
            record.setRecordTime(LocalDateTime.now());
        }
        healthRecordMapper.insert(record);
        checkThresholds(residentId);
    }

    @Transactional
    public void checkThresholds(Long residentId) {
        List<ElHealthThreshold> thresholds = thresholdMapper.selectList(null);
        ElHealthRecord latest = healthRecordMapper.selectOne(
            new LambdaQueryWrapper<ElHealthRecord>()
                .eq(ElHealthRecord::getResidentId, residentId)
                .orderByDesc(ElHealthRecord::getRecordTime)
                .last("LIMIT 1")
        );
        if (latest == null) return;

        List<String> alerts = new ArrayList<>();
        int maxLevel = 3;
        for (ElHealthThreshold threshold : thresholds) {
            BigDecimal value = extractMetricValue(latest, threshold.getMetric());
            if (value == null) continue;
            boolean exceed = false;
            if (threshold.getMinValue() != null && value.compareTo(threshold.getMinValue()) < 0) {
                exceed = true;
            }
            if (threshold.getMaxValue() != null && value.compareTo(threshold.getMaxValue()) > 0) {
                exceed = true;
            }
            if (exceed) {
                alerts.add(threshold.getMetric() + " " + value + " 超出阈值范围");
                maxLevel = Math.min(maxLevel, 2);
                if (value.compareTo(new BigDecimal("100")) > 0 || value.compareTo(new BigDecimal("50")) < 0) {
                    maxLevel = 1;
                }
            }
        }
        if (!alerts.isEmpty()) {
            ElAlert alert = new ElAlert();
            alert.setResidentId(residentId);
            alert.setAlertType("health");
            alert.setAlertLevel(maxLevel);
            alert.setContent(String.join("；", alerts));
            alert.setStatus("pending");
            alert.setCreateTime(LocalDateTime.now());
            alertMapper.insert(alert);
        }
    }

    public TableDataInfo listHealthRecords(Long residentId, int pageNum, int pageSize) {
        LambdaQueryWrapper<ElHealthRecord> qw = new LambdaQueryWrapper<ElHealthRecord>()
            .eq(ElHealthRecord::getResidentId, residentId)
            .orderByDesc(ElHealthRecord::getRecordTime);
        Page<ElHealthRecord> page = healthRecordMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    private BigDecimal extractMetricValue(ElHealthRecord record, String metric) {
        if (!StringUtils.hasText(metric)) return null;
        return switch (metric.toLowerCase()) {
            case "heart_rate", "heartrate", "心率" -> record.getHeartRate() != null
                ? BigDecimal.valueOf(record.getHeartRate()) : null;
            case "steps", "步数" -> record.getSteps() != null
                ? BigDecimal.valueOf(record.getSteps()) : null;
            case "blood_pressure", "bloodpressure", "血压" -> parseSystolic(record.getBloodPressure());
            default -> null;
        };
    }

    private BigDecimal parseSystolic(String bloodPressure) {
        if (!StringUtils.hasText(bloodPressure)) return null;
        String[] parts = bloodPressure.split("/");
        if (parts.length == 0) return null;
        try {
            return new BigDecimal(parts[0].trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
