package com.smartcare.business.repair.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.repair.domain.RpOrderImage;
import com.smartcare.business.repair.mapper.RpOrderImageMapper;
import com.smartcare.business.repair.service.RpOrderImageService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RpOrderImageServiceImpl implements RpOrderImageService {

    private final RpOrderImageMapper imageMapper;

    @Override
    @Transactional
    public void saveImages(Long orderId, List<String> imageUrls) {
        if (imageUrls == null || imageUrls.isEmpty()) {
            return;
        }
        List<RpOrderImage> images = imageUrls.stream()
                .map(url -> {
                    RpOrderImage img = new RpOrderImage();
                    img.setOrderId(orderId);
                    img.setImageUrl(url);
                    return img;
                })
                .collect(Collectors.toList());
        images.forEach(imageMapper::insert);
    }

    @Override
    public List<RpOrderImage> getByOrderId(Long orderId) {
        return imageMapper.selectList(
                new LambdaQueryWrapper<RpOrderImage>()
                        .eq(RpOrderImage::getOrderId, orderId)
        );
    }

    @Override
    @Transactional
    public void deleteByOrderId(Long orderId) {
        imageMapper.delete(
            new LambdaQueryWrapper<RpOrderImage>()
                .eq(RpOrderImage::getOrderId, orderId)
        );
    }

    @Override
    @Transactional
    public void deleteByIds(List<Long> imageIds) {
        if (imageIds == null || imageIds.isEmpty()) {
            return;
        }
        imageMapper.deleteBatchIds(imageIds);
    }
}