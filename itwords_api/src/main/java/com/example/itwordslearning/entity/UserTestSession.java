package com.example.itwordslearning.entity;

import java.util.Date;

public class UserTestSession {
	private Integer sessionId;
    private Integer userId;
    private Date endedAt;
    private Integer score;
	public Integer getSessionId() {
		return sessionId;
	}
	public void setSessionId(Integer sessionId) {
		this.sessionId = sessionId;
	}
	public Integer getUserId() {
		return userId;
	}
	public void setUserId(Integer userId) {
		this.userId = userId;
	}
	public Date getEndedAt() {
		return endedAt;
	}
	public void setEndedAt(Date endedAt) {
		this.endedAt = endedAt;
	}
	public Integer getScore() {
		return score;
	}
	public void setScore(Integer score) {
		this.score = score;
	}
    
	@Override
    public String toString() {
        return "UserTestSession{" +
               "sessionId=" + sessionId +
               ", userId=" + userId +
               ", endedAt=" + endedAt +
               ", score=" + score +
               '}';
    }
}
