package com.smartcare.business.repair.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.repair.domain.RpRepairType;
import com.smartcare.business.repair.mapper.RpRepairTypeMapper;
import com.smartcare.business.repair.service.RpRepairTypeService;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class RpRepairTypeServiceImpl implements RpRepairTypeService {

    private final RpRepairTypeMapper typeMapper;

    @Override
    public List<RpRepairType> listAll() {
        return typeMapper.selectList(new LambdaQueryWrapper<RpRepairType>().orderByAsc(RpRepairType::getOrderNum));
    }

    @Override
    public List<RpRepairType> listTree() {
        List<RpRepairType> all = listAll();
        all.sort(Comparator.comparing(RpRepairType::getOrderNum, Comparator.nullsLast(Integer::compareTo)));
        return all;
    }

    @Override
    public RpRepairType getById(Long typeId) {
        RpRepairType type = typeMapper.selectById(typeId);
        if (type == null) {
            throw new ServiceException("报修类型不存在");
        }
        return type;
    }

    @Override
    public void save(RpRepairType type) {
        if (!StringUtils.hasText(type.getTypeName())) {
            throw new ServiceException("类型名称不能为空");
        }
        typeMapper.insert(type);
    }

    @Override
    public void update(RpRepairType type) {
        getById(type.getTypeId());
        typeMapper.updateById(type);
    }

    @Override
    public void delete(Long typeId) {
        typeMapper.deleteById(typeId);
    }

    private List<RpRepairType> buildTree(List<RpRepairType> all, Long parentId) {
        List<RpRepairType> children = new ArrayList<>();
        for (RpRepairType item : all) {
            Long pid = item.getParentId() == null ? 0L : item.getParentId();
            if (pid.equals(parentId)) {
                children.add(item);
            }
        }
        return children;
    }
}
