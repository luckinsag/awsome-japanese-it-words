package com.example.itwordslearning.dto;

/**
 * 用户登录数据传输对象(Data Transfer Object)
 * 用于接收前端传递的用户名和密码
 */
public class LoginDTO {
    private String username; // 用户名字段
    private String password; // 密码字段

    /**
     * 获取用户名
     * @return 当前用户名
     */
    public String getUsername() {
        return username;
    }

    /**
     * 设置用户名
     * @param username 要设置的用户名
     */
    public void setUsername(String username) {
        this.username = username;
    }

    /**
     * 获取密码（注意：不应在日志中记录此值）
     * @return 当前密码
     */
    public String getPassword() {
        return password;
    }

    /**
     * 设置密码
     * @param password 要设置的密码
     */
    public void setPassword(String password) {
        this.password = password;
    }
}