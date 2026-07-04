package com.smartcare.business.repair.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderFieldImage;
import com.smartcare.business.repair.domain.RpOrderFieldRecord;
import com.smartcare.business.repair.mapper.RpOrderFieldImageMapper;
import com.smartcare.business.repair.mapper.RpOrderFieldRecordMapper;
import com.smartcare.business.repair.mapper.RpOrderMapper;
import com.smartcare.common.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RpOrderFieldService {

    private final RpOrderFieldRecordMapper recordMapper;
    private final RpOrderFieldImageMapper fieldImageMapper;
    private final RpOrderMapper orderMapper;

    public RpOrderFieldRecord findOpenRecord(Long orderId) {
        return recordMapper.selectOne(new LambdaQueryWrapper<RpOrderFieldRecord>()
            .eq(RpOrderFieldRecord::getOrderId, orderId)
            .eq(RpOrderFieldRecord::getStatus, RpOrderFieldRecord.STATUS_OPEN)
            .orderByDesc(RpOrderFieldRecord::getRecordId)
            .last("LIMIT 1"));
    }

    public List<RpOrderFieldRecord> listByOrderId(Long orderId) {
        List<RpOrderFieldRecord> records = recordMapper.selectList(
            new LambdaQueryWrapper<RpOrderFieldRecord>()
                .eq(RpOrderFieldRecord::getOrderId, orderId)
                .in(RpOrderFieldRecord::getStatus,
                    RpOrderFieldRecord.STATUS_SAVED, RpOrderFieldRecord.STATUS_SUBMITTED)
                .orderByDesc(RpOrderFieldRecord::getCreateTime));
        records.forEach(this::attachImages);
        return records;
    }

    public void attachImages(RpOrderFieldRecord record) {
        if (record == null) {
            return;
        }
        List<RpOrderFieldImage> images = fieldImageMapper.selectList(
            new LambdaQueryWrapper<RpOrderFieldImage>()
                .eq(RpOrderFieldImage::getRecordId, record.getRecordId()));
        record.setImages(images);
    }

    public Map<String, Object> buildWorkerFieldContext(Long orderId, String orderStatus) {
        Map<String, Object> ctx = new HashMap<>();
        RpOrderFieldRecord open = findOpenRecord(orderId);
        if (open != null) {
            attachImages(open);
        }
        ctx.put("activeVisit", open);
        ctx.put("canOnSite", "processing".equals(orderStatus) && open == null);
        ctx.put("fieldRecords", listByOrderId(orderId));
        return ctx;
    }

    @Transactional
    public RpOrderFieldRecord startOnSite(Long orderId, Long workerId) {
        RpOrder order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new ServiceException("工单不存在");
        }
        if (!"processing".equals(order.getStatus())) {
            throw new ServiceException("当前工单不可标记到场");
        }
        if (!workerId.equals(order.getWorkerId())) {
            throw new ServiceException("无权操作该工单");
        }
        if (findOpenRecord(orderId) != null) {
            throw new ServiceException("已有进行中的现场记录");
        }
        RpOrderFieldRecord record = new RpOrderFieldRecord();
        record.setOrderId(orderId);
        record.setWorkerId(workerId);
        record.setContent("");
        record.setStatus(RpOrderFieldRecord.STATUS_OPEN);
        record.setCreateTime(LocalDateTime.now());
        recordMapper.insert(record);
        attachImages(record);
        return record;
    }

    @Transactional
    public RpOrderFieldRecord saveRecord(Long orderId, Long workerId, Long recordId,
                                           String content, List<String> imageUrls, boolean closeVisit) {
        RpOrderFieldRecord record = loadEditableRecord(orderId, workerId, recordId);
        if (content != null) {
            record.setContent(content.trim());
        }
        if (imageUrls != null && !imageUrls.isEmpty()) {
            for (String url : imageUrls) {
                RpOrderFieldImage img = new RpOrderFieldImage();
                img.setRecordId(record.getRecordId());
                img.setImageUrl(url);
                fieldImageMapper.insert(img);
            }
        }
        if (closeVisit && RpOrderFieldRecord.STATUS_OPEN.equals(record.getStatus())) {
            record.setStatus(RpOrderFieldRecord.STATUS_SAVED);
        }
        recordMapper.updateById(record);
        attachImages(record);
        return record;
    }

    @Transactional
    public RpOrderFieldRecord prepareForComplete(Long orderId, Long workerId) {
        RpOrderFieldRecord record = findOpenRecord(orderId);
        if (record == null) {
            throw new ServiceException("请先点击「已到场」并填写现场记录");
        }
        if (!workerId.equals(record.getWorkerId())) {
            throw new ServiceException("无权操作该现场记录");
        }
        if (!StringUtils.hasText(record.getContent())) {
            throw new ServiceException("请填写现场记录说明");
        }
        attachImages(record);
        if (record.getImages() == null || record.getImages().isEmpty()) {
            throw new ServiceException("请上传至少一张现场照片");
        }
        record.setStatus(RpOrderFieldRecord.STATUS_SUBMITTED);
        record.setSubmitTime(LocalDateTime.now());
        recordMapper.updateById(record);
        return record;
    }

    private RpOrderFieldRecord loadEditableRecord(Long orderId, Long workerId, Long recordId) {
        RpOrderFieldRecord record;
        if (recordId != null) {
            record = recordMapper.selectById(recordId);
        } else {
            record = findOpenRecord(orderId);
        }
        if (record == null || !orderId.equals(record.getOrderId())) {
            throw new ServiceException("现场记录不存在");
        }
        if (!workerId.equals(record.getWorkerId())) {
            throw new ServiceException("无权操作该现场记录");
        }
        if (!RpOrderFieldRecord.STATUS_OPEN.equals(record.getStatus())) {
            throw new ServiceException("当前现场记录不可编辑");
        }
        return record;
    }
}
