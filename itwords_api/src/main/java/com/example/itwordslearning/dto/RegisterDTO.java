package com.example.itwordslearning.dto;

public class RegisterDTO {
    private String username;    // 用户名（建议：增加@NotBlank和@Size(min=4,max=20)校验）
    private String password;    // 密码（建议：增加@Pattern校验复杂度）
    private String fontSize;    // 字体大小（建议：改为数值类型如Integer）
    private String backgroundColor; // 背景色（建议：增加格式校验如16进制颜色码）

    // 建议1：使用Lombok简化代码
    // @Data
    // @NoArgsConstructor
    // @AllArgsConstructor
    
    public String getUsername() {
        return username;
    }

    // 建议2：增加空值处理
    // this.username = username != null ? username.trim() : null;
    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    // 建议3：密码字段特殊处理（如禁止日志输出）
    public void setPassword(String password) {
        this.password = password;
    }

    public String getFontSize() {
        return fontSize;
    }

    // 建议4：改为数值类型并校验范围
    // @Min(12) @Max(24)
    // private Integer fontSize;
    public void setFontSize(String fontSize) {
        this.fontSize = fontSize;
    }

    public String getBackgroundColor() {
        return backgroundColor;
    }

    // 建议5：增加颜色格式校验
    // @Pattern(regexp = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$")
    public void setBackgroundColor(String backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    /* 其他改进建议：
    1. 增加toString()方法（注意排除敏感字段）
    2. 实现Builder模式方便对象创建
    3. 添加字段默认值（如fontSize="14px"）
    4. 考虑继承基础DTO类包含公共字段
    */
}