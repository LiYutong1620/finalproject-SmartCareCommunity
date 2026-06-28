package com.smartcare.business.ai.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.smartcare.business.ai.domain.AiChatMessage;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AiChatMessageMapper extends BaseMapper<AiChatMessage> {
}
