package com.example.itwordslearning.service;

import java.util.List;

import com.example.itwordslearning.dto.UserWrongDTO;
import com.example.itwordslearning.dto.UserWrongDeleteDTO;
import com.example.itwordslearning.dto.UserWrongSelectDTO;
import com.example.itwordslearning.entity.UserWrongWord;

public interface UserWrongService {
    int insertUserWrong(UserWrongDTO dto);
    
    int deleteUserWrong(UserWrongDeleteDTO dto);

    List<UserWrongWord> getWrongWordsByUserId(UserWrongSelectDTO dto);
}

