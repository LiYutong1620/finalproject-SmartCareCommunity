package com.smartcare.business.property.mapper;

import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface CmResidentTagRelMapper {

    @Select("SELECT tag_id FROM cm_resident_tag_rel WHERE resident_id = #{residentId}")
    List<Long> selectTagIdsByResident(@Param("residentId") Long residentId);

    @Delete("DELETE FROM cm_resident_tag_rel WHERE resident_id = #{residentId}")
    void deleteByResident(@Param("residentId") Long residentId);

    @Insert("INSERT INTO cm_resident_tag_rel (resident_id, tag_id) VALUES (#{residentId}, #{tagId})")
    void insertRel(@Param("residentId") Long residentId, @Param("tagId") Long tagId);

    @Select("SELECT DISTINCT resident_id FROM cm_resident_tag_rel WHERE tag_id = #{tagId}")
    List<Long> selectResidentIdsByTag(@Param("tagId") Long tagId);
}
