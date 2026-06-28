package com.smartcare.business.community.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.smartcare.business.community.domain.CsNoticeRead;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Collection;
import java.util.List;

@Mapper
public interface CsNoticeReadMapper extends BaseMapper<CsNoticeRead> {

    @Insert("INSERT INTO cs_notice_read (notice_id, user_id, read_time) VALUES (#{noticeId}, #{userId}, NOW()) " +
        "ON DUPLICATE KEY UPDATE read_time = NOW()")
    int markRead(@Param("noticeId") Long noticeId, @Param("userId") Long userId);

    @Select("SELECT notice_id FROM cs_notice_read WHERE user_id = #{userId}")
    List<Long> selectReadNoticeIds(@Param("userId") Long userId);

    @Select("<script>SELECT notice_id FROM cs_notice_read WHERE user_id = #{userId} AND notice_id IN "
        + "<foreach collection='noticeIds' item='id' open='(' separator=',' close=')'>#{id}</foreach></script>")
    List<Long> selectReadNoticeIdsByNotices(@Param("userId") Long userId,
                                              @Param("noticeIds") Collection<Long> noticeIds);

    @Select("SELECT user_id FROM cs_notice_read WHERE notice_id = #{noticeId}")
    List<Long> selectReadUserIdsByNotice(@Param("noticeId") Long noticeId);
}
