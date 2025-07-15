package com.example.itwordslearning.dto;

public class NoteDTO {
    private Integer wordId; // 单词ID（建议添加@NotNull注解确保非空）
    private String memo;   // 笔记内容（建议添加@Size(max=1000)限制长度）

    // 建议：可以添加Lombok的@Getter/@Setter注解来简化代码
    // @Getter @Setter
    public Integer getWordId() {
        return wordId;
    }

    // 建议：参数校验（如wordId>0）
    public void setWordId(Integer wordId) {
        this.wordId = wordId;
    }

    public String getMemo() {
        return memo;
    }

    // 建议：空值处理（memo = memo != null ? memo.trim() : null）
    public void setMemo(String memo) {
        this.memo = memo;
    }

    /* 其他改进建议：
    1. 添加toString()方法方便调试
    2. 考虑添加构造方法
    3. 可以增加@ApiModelProperty注解用于Swagger文档
    4. 建议实现Serializable接口
    */
}