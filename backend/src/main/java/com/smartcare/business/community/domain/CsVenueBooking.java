package com.smartcare.business.community.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;

@Data
@TableName("cs_venue_booking")
public class CsVenueBooking {
    @TableId(type = IdType.AUTO)
    private Long bookingId;
    private Long venueId;
    private Long userId;
    private LocalDate bookDate;
    private String timeSlot;
    private String status;
}
