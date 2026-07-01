package com.smartcare.business.repair.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.repair.domain.RpWorkerSkill;
import com.smartcare.business.repair.mapper.RpWorkerSkillMapper;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/system/worker-skill")
@RequiredArgsConstructor
public class RpWorkerSkillController {

    private final RpWorkerSkillMapper skillMapper;

    /** 查询全部技能标签（可按维修工筛选） */
    @GetMapping("/list")
    public AjaxResult list(@RequestParam(required = false) Long workerId) {
        LambdaQueryWrapper<RpWorkerSkill> qw = new LambdaQueryWrapper<>();
        if (workerId != null) {
            qw.eq(RpWorkerSkill::getWorkerId, workerId);
        }
        return AjaxResult.success(skillMapper.selectList(qw));
    }

    /** 新增技能标签 */
    @PostMapping
    public AjaxResult add(@RequestBody RpWorkerSkill skill) {
        if (skill.getWorkerId() == null) {
            throw new ServiceException("维修工ID不能为空");
        }
        if (!StringUtils.hasText(skill.getSkillName())) {
            throw new ServiceException("技能名称不能为空");
        }
        skillMapper.insert(skill);
        return AjaxResult.success();
    }

    /** 修改技能标签 */
    @PutMapping
    public AjaxResult edit(@RequestBody RpWorkerSkill skill) {
        if (skill.getSkillId() == null) {
            throw new ServiceException("技能ID不能为空");
        }
        skillMapper.updateById(skill);
        return AjaxResult.success();
    }

    /** 删除技能标签 */
    @DeleteMapping("/{skillId}")
    public AjaxResult remove(@PathVariable Long skillId) {
        skillMapper.deleteById(skillId);
        return AjaxResult.success();
    }

    /** 获取所有不重复的技能名称（用于AI派单的技能字典） */
    @GetMapping("/dict")
    public AjaxResult dict() {
        List<RpWorkerSkill> all = skillMapper.selectList(null);
        List<String> names = all.stream()
            .map(RpWorkerSkill::getSkillName)
            .distinct()
            .sorted()
            .toList();
        return AjaxResult.success(names);
    }
}
