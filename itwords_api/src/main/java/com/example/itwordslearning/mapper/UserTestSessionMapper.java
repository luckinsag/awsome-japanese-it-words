package com.example.itwordslearning.mapper;

import com.example.itwordslearning.entity.UserTestSession;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserTestSessionMapper {

    /**
     * 根据用户ID查询其所有考试会话记录
     * @param userId 用户ID
     * @return 考试会话记录列表
     */
    List<UserTestSession> findTestSessionsByUserId(@Param("userId") Integer userId);
}