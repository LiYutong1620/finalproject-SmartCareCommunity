package com.smartcare.business.repair.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("rp_order_image")
public class RpOrderImage {

    @TableId(type = IdType.AUTO)
    private Long imageId;

    private Long orderId;

    private String imageUrl;
}