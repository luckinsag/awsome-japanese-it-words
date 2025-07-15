package com.example.itwordslearning.service;

import com.example.itwordslearning.dto.RegisterDTO;
import com.example.itwordslearning.dto.UserDTO;
import com.example.itwordslearning.entity.User;
import com.example.itwordslearning.entity.UserSettings;
import com.example.itwordslearning.exception.UsernameAlreadyExistsException;
import com.example.itwordslearning.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

@Autowired
private UserMapper userMapper;

@Autowired
private BCryptPasswordEncoder bCryptPasswordEncoder;

public UserDTO login(String username, String password) {
User user = userMapper.findUserByUsername(username);
if (user != null && bCryptPasswordEncoder.matches(password, user.getPassword())) {
UserSettings userSettings = userMapper.findUserSettingsByUserId(user.getUserId());
if (userSettings == null) {
userSettings = new UserSettings();
userSettings.setUserId(user.getUserId());
userSettings.setFontSize("m");
userSettings.setBackgroundColor("w");
userMapper.insertUserSettings(userSettings);
}
return new UserDTO(user.getUserId(), user.getUsername(), userSettings);
}
return null;
}

@Transactional
public int register(RegisterDTO registerDTO) {
if (userMapper.findUserByUsername(registerDTO.getUsername()) != null) {
            throw new UsernameAlreadyExistsException("ユーザー名が既に存在します");
}

User user = new User();
user.setUsername(registerDTO.getUsername());
user.setPassword(bCryptPasswordEncoder.encode(registerDTO.getPassword()));

userMapper.insertUser(user); // 插入用户

UserSettings userSettings = new UserSettings();
userSettings.setUserId(user.getUserId());
userSettings.setFontSize("m");
userSettings.setBackgroundColor("w");

return userMapper.insertUserSettings(userSettings);
}

public UserDTO findUserByUsername(String username) {
User user = userMapper.findUserByUsername(username);
if (user != null) {
UserSettings userSettings = userMapper.findUserSettingsByUserId(user.getUserId());
if (userSettings == null) {
userSettings = new UserSettings();
userSettings.setUserId(user.getUserId());
userSettings.setFontSize("m");
userSettings.setBackgroundColor("w");
userMapper.insertUserSettings(userSettings);
}
return new UserDTO(user.getUserId(), user.getUsername(), userSettings);
}
return null;
}

@Transactional
public int updateUserSettings(UserSettings settings) {
return userMapper.updateUserSettings(settings);
}
}