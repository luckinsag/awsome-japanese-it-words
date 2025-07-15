package com.example.itwordslearning.service.impl;

import com.example.itwordslearning.dto.UserWrongDTO;
import com.example.itwordslearning.dto.UserWrongDeleteDTO;
import com.example.itwordslearning.dto.UserWrongSelectDTO;
import com.example.itwordslearning.entity.UserWrong;
import com.example.itwordslearning.entity.UserWrongWord;
import com.example.itwordslearning.mapper.UserWrongMapper;
import com.example.itwordslearning.service.UserWrongService;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserWrongServiceImpl implements UserWrongService {

    @Autowired
    private UserWrongMapper userWrongMapper;

    @Override
    public int insertUserWrong(UserWrongDTO dto) {
        UserWrong wrong = new UserWrong();
        wrong.setSessionId(dto.getSessionId());
        wrong.setUserId(dto.getUserId());
        wrong.setWordId(dto.getWordId());
        return userWrongMapper.insertUserWrong(wrong);
    }
    
    @Override
    public int deleteUserWrong(UserWrongDeleteDTO dto) {
        return userWrongMapper.deleteUserWrong(dto.getUserId(), dto.getWordId());
    }

    @Override
    public List<UserWrongWord> getWrongWordsByUserId(UserWrongSelectDTO dto) {
        return userWrongMapper.getWrongWordsByUserId(dto.getUserId());
    }
}
