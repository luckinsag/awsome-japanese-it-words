package com.example.itwordslearning.service;

import com.example.itwordslearning.dto.UserTestSessionDTO;

import java.util.List;

public interface UserTestSessionService {

    /**
     * 根据用户ID获取该用户的所有考试成绩信息
     * @param userId 用户ID
     * @return 考试成绩信息DTO列表
     */
    List<UserTestSessionDTO> getTestScoresByUserId(Integer userId);
}