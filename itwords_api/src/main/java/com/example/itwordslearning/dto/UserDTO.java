package com.example.itwordslearning.dto;

import com.example.itwordslearning.entity.UserSettings;

public class UserDTO {
	private Integer userId;
	private String username;
	private UserSettings userSettings; // 引入用户设置

	public UserDTO(Integer userId, String username, UserSettings userSettings) {
		this.userId = userId;
		this.username = username;
		this.userSettings = userSettings;
	}

	public Integer getUserId() {
		return userId;
	}

	public String getUsername() {
		return username;
	}

	public UserSettings getUserSettings() {
		return userSettings;
	}
}