package com.example.itwordslearning.entity;

public class UserSettings {
private Integer userId;
private String fontSize;
private String backgroundColor;

public Integer getUserId() {
return userId;
}

public void setUserId(Integer userId) {
this.userId = userId;
}

public String getFontSize() {
return fontSize;
}

public void setFontSize(String fontSize) {
this.fontSize = fontSize;
}

public String getBackgroundColor() {
return backgroundColor;
}

public void setBackgroundColor(String backgroundColor) {
this.backgroundColor = backgroundColor;
}
}