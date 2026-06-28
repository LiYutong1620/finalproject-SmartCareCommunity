package com.smartcare.business.community.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.smartcare.business.community.domain.CsNotice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.Map;

@Mapper
public interface CsNoticeMapper extends BaseMapper<CsNotice> {

    IPage<Map<String, Object>> selectOwnerNoticePage(
        Page<Map<String, Object>> page,
        @Param("userId") Long userId,
        @Param("noticeType") String noticeType,
        @Param("title") String title,
        @Param("publishTimeStart") LocalDateTime publishTimeStart,
        @Param("publishTimeEnd") LocalDateTime publishTimeEnd,
        @Param("readStatus") String readStatus
    );
}
