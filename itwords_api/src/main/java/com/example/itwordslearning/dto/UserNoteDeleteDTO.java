package com.example.itwordslearning.dto;

public class UserNoteDeleteDTO {
    private Integer userId;  // 用户ID（建议：增加@NotNull校验）
    private Integer wordId;  // 单词ID（建议：增加@Min(1)校验ID有效性）

    // 建议1：可以添加Lombok注解简化代码
    // @Data
    // @NoArgsConstructor
    // @AllArgsConstructor
    
    public Integer getUserId() {
        return userId;
    }

    // 建议2：增加空值校验
    // if(userId == null) throw new IllegalArgumentException("用户ID不能为空");
    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getWordId() {
        return wordId;
    }

    // 建议3：增加业务校验
    // if(wordId <= 0) throw new IllegalArgumentException("单词ID必须大于0");
    public void setWordId(Integer wordId) {
        this.wordId = wordId;
    }

    /* 其他改进建议：
    1. 重写toString()方法方便调试
    2. 添加Builder构建器模式
    3. 实现Serializable接口
    4. 添加参数校验注解：
       - @NotNull
       - @Min(1)
    */
}