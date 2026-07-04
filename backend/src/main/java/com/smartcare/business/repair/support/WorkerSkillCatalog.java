package com.smartcare.business.repair.support;

import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Locale;
import java.util.Map;

/** 维修工技能字典及与报修类型的匹配规则（AI 派单依据） */
public final class WorkerSkillCatalog {

    private WorkerSkillCatalog() {}

    public static final List<String> ALL_SKILLS = List.of(
        "水管维修", "管道疏通", "水暖安装", "热水器维修",
        "电路维修", "电工基础", "配电系统", "照明维修",
        "家电维修", "空调维修", "锁具维修", "门窗维修",
        "电梯维保", "弱电维修", "公共设施维护",
        "综合维修", "网络维修", "土建维修", "燃气维修"
    );

    /** 报修类型关键词 → 所需技能 */
    private static final Map<String, List<String>> TYPE_SKILL_MAP = Map.ofEntries(
        Map.entry("水", List.of("水管维修", "管道疏通", "水暖安装", "热水器维修")),
        Map.entry("漏", List.of("水管维修", "水暖安装", "热水器维修")),
        Map.entry("管", List.of("水管维修", "管道疏通", "水暖安装")),
        Map.entry("暖", List.of("热水器维修", "水暖安装")),
        Map.entry("电", List.of("电路维修", "电工基础", "配电系统", "照明维修")),
        Map.entry("跳闸", List.of("电路维修", "配电系统", "电工基础")),
        Map.entry("插座", List.of("电路维修", "电工基础", "照明维修")),
        Map.entry("灯", List.of("照明维修", "电路维修", "电工基础")),
        Map.entry("空调", List.of("空调维修", "家电维修")),
        Map.entry("家电", List.of("家电维修", "综合维修")),
        Map.entry("锁", List.of("锁具维修", "门窗维修")),
        Map.entry("门", List.of("门窗维修", "锁具维修", "综合维修")),
        Map.entry("窗", List.of("门窗维修", "综合维修")),
        Map.entry("电梯", List.of("电梯维保", "公共设施维护")),
        Map.entry("监控", List.of("弱电维修", "公共设施维护")),
        Map.entry("网络", List.of("网络维修", "弱电维修")),
        Map.entry("燃气", List.of("燃气维修", "综合维修"))
    );

    /** 职级权重（AI 派单加分） */
    public static int levelScore(String workerLevel) {
        if (!StringUtils.hasText(workerLevel)) {
            return 5;
        }
        return switch (workerLevel) {
            case "资深" -> 30;
            case "高级" -> 20;
            case "中级" -> 10;
            default -> 0;
        };
    }

    /** 技能与故障类型匹配得分 */
    public static int matchTypeLabel(List<String> approvedSkills, String typeLabel) {
        if (approvedSkills == null || approvedSkills.isEmpty() || !StringUtils.hasText(typeLabel)) {
            return 0;
        }
        String label = typeLabel.toLowerCase(Locale.ROOT);
        int best = 0;
        for (Map.Entry<String, List<String>> entry : TYPE_SKILL_MAP.entrySet()) {
            if (!label.contains(entry.getKey())) {
                continue;
            }
            for (String skill : entry.getValue()) {
                if (approvedSkills.contains(skill)) {
                    best = Math.max(best, 25);
                }
            }
        }
        if (best == 0 && approvedSkills.contains("综合维修")) {
            best = 8;
        }
        return best;
    }
}
