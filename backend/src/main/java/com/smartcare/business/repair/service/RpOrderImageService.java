package com.smartcare.business.repair.service;

import com.smartcare.business.repair.domain.RpOrderImage;
import java.util.List;

public interface RpOrderImageService {

    void saveImages(Long orderId, List<String> imageUrls);

    List<RpOrderImage> getByOrderId(Long orderId);

    void deleteByOrderId(Long orderId);

    void deleteByIds(List<Long> imageIds);
}