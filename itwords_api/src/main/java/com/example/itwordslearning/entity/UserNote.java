package com.example.itwordslearning.entity;

import java.util.Date;

/**
 * UserNote 实体类，表示用户对某个单词添加的笔记信息。
 * 一般用于记录用户的学习笔记、备注等内容。
 */
public class UserNote {

	// 笔记唯一标识符（主键）
	private Integer notesId;

	// 所属用户的ID（外键关联用户表）
	private Integer userId;

	// 所关联的单词ID（外键关联词汇表）
	private Integer wordId;

	// 添加笔记的时间
	private Date addedAt;

	// 用户自定义的备注信息（可选）
	private String memo;

	// 获取笔记ID
	public Integer getNotesId() {
		return notesId;
	}

	// 设置笔记ID
	public void setNotesId(Integer notesId) {
		this.notesId = notesId;
	}

	// 获取所属用户ID
	public Integer getUserId() {
		return userId;
	}

	// 设置所属用户ID
	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	// 获取对应的单词ID
	public Integer getWordId() {
		return wordId;
	}

	// 设置对应的单词ID
	public void setWordId(Integer wordId) {
		this.wordId = wordId;
	}

	// 获取笔记添加时间
	public Date getAddedAt() {
		return addedAt;
	}

	// 设置笔记添加时间
	public void setAddedAt(Date addedAt) {
		this.addedAt = addedAt;
	}

	// 获取备注内容
	public String getMemo() {
		return memo;
	}

	// 设置备注内容
	public void setMemo(String memo) {
		this.memo = memo;
	}
}
//✅ 建议一：将 java.util.Date 替换为更现代的 java.time.LocalDateTime（Java 8+ 推荐）
//import java.time.LocalDateTime;
//private LocalDateTime addedAt;
//更精确，线程安全，和数据库映射也更兼容（尤其是使用 MyBatis 或 JPA 时）

//✅ 建议二：添加无参构造函数和全参构造函数
//public UserNote() {}
//public UserNote(Integer notesId, Integer userId, Integer wordId, LocalDateTime addedAt, String memo) { ... }

//✅ 建议三：重写 toString 方法便于调试和日志输出
//@Override
//public String toString() {
//  return "UserNote{" +
//      "notesId=" + notesId +
//      ", userId=" + userId +
//      ", wordId=" + wordId +
//      ", addedAt=" + addedAt +
//      ", memo='" + memo + '\'' +
//      '}';
//}

//✅ 建议四：如果你计划将这个类序列化为 JSON，使用注解（如 @JsonFormat）控制日期格式：
//@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
//private LocalDateTime addedAt;

//✅ 建议五：根据业务场景，考虑是否要限制 memo 字符长度（如 255 字符以内）
