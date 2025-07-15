package com.example.itwordslearning.mapper;

import com.example.itwordslearning.entity.UserWrong;
import com.example.itwordslearning.entity.UserWrongWord;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserWrongMapper {
    int insertUserWrong(UserWrong userWrong);
    
    int deleteUserWrong(@Param("userId") Integer userId, @Param("wordId") Integer wordId);

    List<UserWrongWord> getWrongWordsByUserId(@Param("userId") Integer userId);
}
