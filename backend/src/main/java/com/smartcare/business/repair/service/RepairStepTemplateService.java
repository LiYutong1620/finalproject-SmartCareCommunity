package com.smartcare.business.repair.service;

import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.mapper.RpRepairTypeMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RepairStepTemplateService {

    private static final Map<String, List<String>> STEP_TEMPLATES = new LinkedHashMap<>();

    static {
        STEP_TEMPLATES.put("水管漏水", List.of(
            "关闭对应区域进水阀门，避免积水扩大",
            "检查接口、阀门、软管等漏水点位",
            "更换密封圈、接头或损坏管件",
            "恢复通水并观察30分钟确认无渗漏"
        ));
        STEP_TEMPLATES.put("跳闸", List.of(
            "断开可疑回路负载，确保操作安全",
            "打开配电箱检查空开与线路状态",
            "排查短路、过载或漏电原因",
            "修复后逐路合闸测试运行是否正常"
        ));
        STEP_TEMPLATES.put("马桶堵塞", List.of(
            "关闭进水阀，清理马桶周边",
            "使用皮搋子或疏通器进行初步疏通",
            "检查下水管道是否仍有堵塞",
            "通水测试并确认排水正常"
        ));
        STEP_TEMPLATES.put("门窗损坏", List.of(
            "检查门窗框体、合页、锁具损坏情况",
            "确认是否需要更换配件或整体调整",
            "进行紧固、校正或更换损坏部件",
            "反复开关测试，确保使用安全"
        ));
        STEP_TEMPLATES.put("水电", List.of(
            "现场确认故障现象并切断相关水源/电源",
            "排查常见故障点并准备所需工具",
            "按标准流程维修处理",
            "恢复使用后进行功能与安全复检"
        ));
        STEP_TEMPLATES.put("电路", List.of(
            "断电并设置警示，确保作业安全",
            "使用工具检测故障线路或设备",
            "更换损坏元件或重新接线",
            "送电测试并记录处理结果"
        ));
    }

    private final RpRepairTypeMapper typeMapper;

    public Map<String, Object> matchSteps(Long typeId, String description) {
        String typeName = resolveTypeName(typeId, description);
        List<String> steps = matchByKeyword(typeName);
        if (steps.isEmpty() && StringUtils.hasText(description)) {
            steps = matchByKeyword(description);
        }
        if (steps.isEmpty()) {
            steps = List.of(
                "佩戴防护并确认现场安全",
                "核对故障描述与现场情况",
                "按社区标准流程实施维修",
                "完成后请业主验收并记录结果"
            );
        }
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("typeName", typeName);
        result.put("steps", steps);
        return result;
    }

    private String resolveTypeName(Long typeId, String description) {
        if (typeId != null) {
            RpRepairType type = typeMapper.selectById(typeId);
            if (type != null) {
                return type.getTypeName();
            }
        }
        return StringUtils.hasText(description) ? description : "通用维修";
    }

    private List<String> matchByKeyword(String text) {
        if (!StringUtils.hasText(text)) {
            return List.of();
        }
        for (Map.Entry<String, List<String>> entry : STEP_TEMPLATES.entrySet()) {
            if (text.contains(entry.getKey())) {
                return entry.getValue();
            }
        }
        return new ArrayList<>();
    }
}
