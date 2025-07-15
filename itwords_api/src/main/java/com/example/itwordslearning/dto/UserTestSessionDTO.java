package com.example.itwordslearning.dto;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.util.Date;

public class UserTestSessionDTO {

    private Integer sessionId;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss") // 格式化日期时间
    private Date testTime; // 对应 ended_at
    private Integer score;

    // Getters and Setters
    public Integer getSessionId() {
        return sessionId;
    }

    public void setSessionId(Integer sessionId) {
        this.sessionId = sessionId;
    }

    public Date getTestTime() {
        return testTime;
    }

    public void setTestTime(Date date) {
        this.testTime = date;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    @Override
    public String toString() {
        return "UserTestSessionDTO{" +
               "sessionId=" + sessionId +
               ", testTime=" + testTime +
               ", score=" + score +
               '}';
    }
}
