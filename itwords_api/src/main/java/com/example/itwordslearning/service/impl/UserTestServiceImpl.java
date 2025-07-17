package com.example.itwordslearning.service.impl;

import com.example.itwordslearning.dto.UserTestRecordDTO;
import com.example.itwordslearning.entity.UserTest;
import com.example.itwordslearning.mapper.UserTestMapper;
import com.example.itwordslearning.service.UserTestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date; // 确保导入 java.util.Date 或 java.time.LocalDateTime

@Service
public class UserTestServiceImpl implements UserTestService {

    @Autowired
    private UserTestMapper userTestMapper;

    @Override
    public Integer insertUserTestAndReturnSessionId(UserTestRecordDTO dto) {
        UserTest test = new UserTest();
        test.setUserId(dto.getUserId());

        // 使用前端传来的时间，如果为空则使用当前时间
        Date testTime = dto.getEndedAt() != null ? dto.getEndedAt() : new Date();
        test.setEndedAt(testTime);
        System.out.println("保存考试记录，用户ID: " + dto.getUserId() + ", 考试时间: " + testTime + ", 分数: " + dto.getScore());
        
        test.setScore(dto.getScore());

        userTestMapper.insertUserTest(test);
        return userTestMapper.getLastSessionId();
    }
}