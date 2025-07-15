package com.example.itwordslearning.service.impl;

import com.example.itwordslearning.dto.UserTestSessionDTO;
import com.example.itwordslearning.entity.UserTestSession;
import com.example.itwordslearning.mapper.UserTestSessionMapper;
import com.example.itwordslearning.service.UserTestSessionService;
import org.springframework.beans.BeanUtils; // 用于对象属性拷贝
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserTestSessionServiceImpl implements UserTestSessionService {

    private final UserTestSessionMapper userTestSessionMapper;

    @Autowired
    public UserTestSessionServiceImpl(UserTestSessionMapper userTestSessionMapper) {
        this.userTestSessionMapper = userTestSessionMapper;
    }

    @Override
    public List<UserTestSessionDTO> getTestScoresByUserId(Integer userId) {
        // 1. 调用 Mapper 获取实体列表
        List<UserTestSession> sessions = userTestSessionMapper.findTestSessionsByUserId(userId);

        // 2. 将实体列表转换为 DTO 列表
        return sessions.stream()
                .map(session -> {
                    UserTestSessionDTO dto = new UserTestSessionDTO();
                    // 使用 BeanUtils 拷贝相同名称的属性
                    BeanUtils.copyProperties(session, dto);
                    // 额外设置 testTime 属性，因为它在 Entity 中是 endedAt
                    dto.setTestTime(session.getEndedAt());
                    return dto;
                })
                .collect(Collectors.toList());
    }
}
