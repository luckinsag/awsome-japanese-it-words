package com.example.itwordslearning.mapper;

import com.example.itwordslearning.entity.UserTest;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserTestMapper {

    int insertUserTest(UserTest userTest);

    @Select("SELECT LAST_INSERT_ID()")
    Integer getLastSessionId();
}
