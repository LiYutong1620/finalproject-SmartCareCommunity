package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElDisposalPlan;
import com.smartcare.business.elder.mapper.ElDisposalPlanMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ElDisposalPlanService {

    private final ElDisposalPlanMapper planMapper;

    public TableDataInfo list(int pageNum, int pageSize, Integer level) {
        LambdaQueryWrapper<ElDisposalPlan> qw = new LambdaQueryWrapper<ElDisposalPlan>()
            .eq(level != null, ElDisposalPlan::getLevel, level)
            .orderByAsc(ElDisposalPlan::getLevel)
            .orderByDesc(ElDisposalPlan::getPlanId);
        Page<ElDisposalPlan> page = planMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    public List<ElDisposalPlan> listAll(Integer level) {
        LambdaQueryWrapper<ElDisposalPlan> qw = new LambdaQueryWrapper<ElDisposalPlan>()
            .eq(level != null, ElDisposalPlan::getLevel, level)
            .orderByAsc(ElDisposalPlan::getLevel)
            .orderByDesc(ElDisposalPlan::getPlanId);
        return planMapper.selectList(qw);
    }

    public ElDisposalPlan suggestPlan(int alertLevel) {
        return planMapper.selectOne(
            new LambdaQueryWrapper<ElDisposalPlan>()
                .eq(ElDisposalPlan::getLevel, alertLevel)
                .orderByDesc(ElDisposalPlan::getPlanId)
                .last("LIMIT 1")
        );
    }

    @Transactional
    public void add(ElDisposalPlan plan) {
        validate(plan);
        planMapper.insert(plan);
    }

    @Transactional
    public void update(ElDisposalPlan plan) {
        if (plan.getPlanId() == null) {
            throw new ServiceException("预案ID不能为空");
        }
        validate(plan);
        planMapper.updateById(plan);
    }

    @Transactional
    public void delete(Long planId) {
        planMapper.deleteById(planId);
    }

    private void validate(ElDisposalPlan plan) {
        if (plan.getLevel() == null) {
            throw new ServiceException("预警等级不能为空");
        }
        if (plan.getLevel() < 1 || plan.getLevel() > 2) {
            throw new ServiceException("预警等级应为1(立即上门)或2(电话确认后上门)");
        }
    }
}
