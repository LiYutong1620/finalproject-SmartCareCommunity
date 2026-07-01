package com.smartcare.business.repair.service;

import com.smartcare.business.repair.domain.RpRepairType;

import java.util.List;

public interface RpRepairTypeService {

    List<RpRepairType> listAll();

    List<RpRepairType> listTree();

    RpRepairType getById(Long typeId);

    void save(RpRepairType type);

    void update(RpRepairType type);

    void delete(Long typeId);
}
