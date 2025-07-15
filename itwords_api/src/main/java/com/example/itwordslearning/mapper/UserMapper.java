package com.example.itwordslearning.mapper;

import com.example.itwordslearning.entity.User;
import com.example.itwordslearning.entity.UserSettings;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper {
User findUserByUsername(String username);
UserSettings findUserSettingsByUserId(Integer userId);
int insertUser(User user);
int insertUserSettings(UserSettings settings);
int updateUserSettings(UserSettings settings);
}