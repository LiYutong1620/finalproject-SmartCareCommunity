package com.smartcare.business.repair.service;

import com.smartcare.business.repair.domain.RpOrderEval;

public interface RpOrderEvalService {

    void saveEval(Long orderId, Integer score, String tags, String content);
}