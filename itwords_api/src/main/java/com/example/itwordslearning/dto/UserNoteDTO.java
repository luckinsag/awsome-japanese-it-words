package com.example.itwordslearning.dto;

public class UserNoteDTO {
    private Integer userId;    // 用户ID（建议：@NotNull校验）
    private Integer wordId;   // 单词ID（建议：@Min(1)校验）
    private String memo;      // 用户笔记（建议：@Size(max=500)限制长度）
    
    // 单词信息字段（建议：可考虑拆分为关联对象）
    private String japanese;  // 日文释义（建议：非空校验）
    private String chinese;   // 中文释义
    private String english;   // 英文释义
    private String category;  // 单词分类
    private String addedAt;   // 添加时间（建议：改用LocalDateTime类型）

    // 建议1：使用Lombok简化代码
    // @Data
    // @Builder
    // @NoArgsConstructor
    // @AllArgsConstructor

    public Integer getUserId() {
        return userId;
    }

    // 建议2：空值校验
    // if(userId == null) throw new IllegalArgumentException();
    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getWordId() {
        return wordId;
    }

    public void setWordId(Integer wordId) {
        this.wordId = wordId;
    }

    public String getMemo() {
        return memo;
    }

    // 建议3：自动trim()
    // this.memo = memo != null ? memo.trim() : null;
    public void setMemo(String memo) {
        this.memo = memo;
    }

    /* 其他改进建议：
    1. 重写toString()（注意排除敏感信息）
    2. 添加字段校验注解：
       - @NotBlank (字符串字段)
       - @Pattern (分类字段格式校验)
    3. 时间字段建议：
       - private LocalDateTime addedAt;
       - 添加@JsonFormat格式化
    4. 可考虑拆分：
       - 用户笔记信息（userId+wordId+memo）
       - 单词基本信息（其他字段）
    */
    
    // 保持原有getter/setter不变
    public String getJapanese() {
        return japanese;
    }

    public void setJapanese(String japanese) {
        this.japanese = japanese;
    }

    public String getChinese() {
        return chinese;
    }

    public void setChinese(String chinese) {
        this.chinese = chinese;
    }

    public String getEnglish() {
        return english;
    }

    public void setEnglish(String english) {
        this.english = english;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getAddedAt() {
        return addedAt;
    }

    // 建议4：日期格式校验
    // @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    public void setAddedAt(String addedAt) {
        this.addedAt = addedAt;
    }
}