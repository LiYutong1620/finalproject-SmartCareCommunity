package com.smartcare.business.elder.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.elder.domain.ElCareStaff;
import com.smartcare.business.elder.mapper.ElCareStaffMapper;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ElCareStaffService {

    private final ElCareStaffMapper staffMapper;

    public TableDataInfo list(int pageNum, int pageSize, Long buildingId, String staffType) {
        LambdaQueryWrapper<ElCareStaff> qw = new LambdaQueryWrapper<ElCareStaff>()
            .eq(StringUtils.hasText(staffType), ElCareStaff::getStaffType, staffType)
            .orderByDesc(ElCareStaff::getStaffId);
        if (buildingId != null) {
            qw.apply("FIND_IN_SET({0}, building_ids) > 0", String.valueOf(buildingId));
        }
        Page<ElCareStaff> page = staffMapper.selectPage(new Page<>(pageNum, pageSize), qw);
        return new TableDataInfo(page.getTotal(), page.getRecords());
    }

    public List<ElCareStaff> listAll(String staffType) {
        LambdaQueryWrapper<ElCareStaff> qw = new LambdaQueryWrapper<ElCareStaff>()
            .eq(StringUtils.hasText(staffType), ElCareStaff::getStaffType, staffType)
            .orderByDesc(ElCareStaff::getStaffId);
        return staffMapper.selectList(qw);
    }

    @Transactional
    public void add(ElCareStaff staff) {
        validate(staff);
        staffMapper.insert(staff);
    }

    @Transactional
    public void update(ElCareStaff staff) {
        if (staff.getStaffId() == null) {
            throw new ServiceException("人员ID不能为空");
        }
        validate(staff);
        staffMapper.updateById(staff);
    }

    @Transactional
    public void delete(Long staffId) {
        staffMapper.deleteById(staffId);
    }

    private void validate(ElCareStaff staff) {
        if (!StringUtils.hasText(staff.getName())) {
            throw new ServiceException("姓名不能为空");
        }
        if (!StringUtils.hasText(staff.getPhone())) {
            throw new ServiceException("电话不能为空");
        }
        if (!staff.getPhone().matches("^1\\d{10}$")) {
            throw new ServiceException("手机号格式不正确");
        }
        if (StringUtils.hasText(staff.getBuildingIds())) {
            List<String> ids = Arrays.stream(staff.getBuildingIds().split(","))
                .map(String::trim)
                .filter(StringUtils::hasText)
                .collect(Collectors.toList());
            staff.setBuildingIds(String.join(",", ids));
        }
    }
}
