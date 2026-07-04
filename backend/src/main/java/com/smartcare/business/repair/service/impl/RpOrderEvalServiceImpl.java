package com.smartcare.business.repair.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.repair.domain.RpOrderEval;
import com.smartcare.business.repair.mapper.RpOrderEvalMapper;
import com.smartcare.business.repair.service.RpOrderEvalService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RpOrderEvalServiceImpl implements RpOrderEvalService {

    private final RpOrderEvalMapper evalMapper;

    @Override
    @Transactional
    public void saveEval(Long orderId, Integer score, String tags, String content) {
        RpOrderEval eval = new RpOrderEval();
        eval.setOrderId(orderId);
        eval.setScore(score);
        eval.setTags(tags);
        eval.setContent(content);
        eval.setAppealStatus("0");
        evalMapper.insert(eval);
    }

    @Override
    public RpOrderEval findByOrderId(Long orderId) {
        return evalMapper.selectOne(new LambdaQueryWrapper<RpOrderEval>()
            .eq(RpOrderEval::getOrderId, orderId)
            .orderByDesc(RpOrderEval::getEvalId)
            .last("LIMIT 1"));
    }
}