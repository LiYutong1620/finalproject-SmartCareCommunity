package com.smartcare.business.property.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.smartcare.common.core.domain.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("cm_resident")
public class CmResident extends BaseEntity {

    @TableId(type = IdType.AUTO)
    private Long residentId;
    private Long userId;
    private Long houseId;
    private String name;
    private String gender;
    private Integer age;
    private String idCard;
    private String phone;
    /** @deprecated 保留列，新逻辑用 isOwner */
    private String residentType;
    private LocalDate moveInDate;
    /** @deprecated 保留列，新逻辑用 emergencyName/Phone/Relation */
    private String emergencyContact;
    private String remark;
    private String delFlag;
    /** 居住状态：1在住 2空置 3出租 */
    private String livingStatus;
    /** 是否产权人：1是 0否 */
    private Integer isOwner;
    private String ownerName;
    private String ownerPhone;
    /** 与产权人关系：本人/配偶/子女/父母/兄弟姐妹/亲属/租客/其他 */
    private String ownerRelation;
    private String emergencyName;
    private String emergencyPhone;
    /** 与住户关系：配偶/子女/父母/兄弟姐妹/亲属/邻居/朋友/其他 */
    private String emergencyRelation;

    @TableField(exist = false)
    private List<Long> tagIds;
    @TableField(exist = false)
    private List<String> systemTags;
    /** 动态计算，非数据库列 */
    @TableField(exist = false)
    private Integer isAloneLiving;
}
