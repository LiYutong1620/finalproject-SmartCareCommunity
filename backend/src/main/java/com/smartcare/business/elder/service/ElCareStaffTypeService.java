package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.elder.domain.ElCareStaff;
import com.smartcare.business.elder.domain.ElCareStaffType;
import com.smartcare.business.elder.mapper.ElCareStaffMapper;
import com.smartcare.business.elder.mapper.ElCareStaffTypeMapper;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ElCareStaffTypeService {

    private final ElCareStaffTypeMapper typeMapper;
    private final ElCareStaffMapper staffMapper;

    public List<ElCareStaffType> listAll() {
        return typeMapper.selectList(new LambdaQueryWrapper<ElCareStaffType>()
            .orderByAsc(ElCareStaffType::getSortOrder)
            .orderByAsc(ElCareStaffType::getTypeId));
    }

    @Transactional
    public void add(String typeName) {
        if (!StringUtils.hasText(typeName)) {
            throw new ServiceException("类型名称不能为空");
        }
        String name = typeName.trim();
        if (name.length() > 20) {
            throw new ServiceException("类型名称不能超过20字");
        }
        long dup = typeMapper.selectCount(new LambdaQueryWrapper<ElCareStaffType>()
            .eq(ElCareStaffType::getTypeName, name));
        if (dup > 0) {
            throw new ServiceException("该人员类型已存在");
        }
        ElCareStaffType type = new ElCareStaffType();
        type.setTypeName(name);
        Integer maxSort = typeMapper.selectList(new LambdaQueryWrapper<ElCareStaffType>()
                .orderByDesc(ElCareStaffType::getSortOrder)
                .last("LIMIT 1"))
            .stream()
            .map(ElCareStaffType::getSortOrder)
            .findFirst()
            .orElse(0);
        type.setSortOrder(maxSort + 1);
        typeMapper.insert(type);
    }

    @Transactional
    public void delete(Long typeId) {
        ElCareStaffType type = typeMapper.selectById(typeId);
        if (type == null) {
            throw new ServiceException("人员类型不存在");
        }
        long used = staffMapper.selectCount(new LambdaQueryWrapper<ElCareStaff>()
            .eq(ElCareStaff::getStaffType, type.getTypeName()));
        if (used > 0) {
            throw new ServiceException("该类型下仍有关怀人员，无法删除");
        }
        typeMapper.deleteById(typeId);
    }

    public void assertTypeExists(String staffType) {
        if (!StringUtils.hasText(staffType)) {
            throw new ServiceException("请选择人员类型");
        }
        long cnt = typeMapper.selectCount(new LambdaQueryWrapper<ElCareStaffType>()
            .eq(ElCareStaffType::getTypeName, staffType.trim()));
        if (cnt == 0) {
            throw new ServiceException("人员类型不存在，请先在类型管理中添加");
        }
    }
}
