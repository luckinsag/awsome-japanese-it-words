package com.example.itwordslearning.exception;

/**
 * 用户名已存在异常类
 * 
 * 继承自RuntimeException，表示这是一个非受检异常
 * 当尝试注册或创建已存在的用户名时抛出此异常
 * 
 * 使用@SuppressWarnings("serial")抑制缺少serialVersionUID的警告
 */
@SuppressWarnings("serial")
public class UsernameAlreadyExistsException extends RuntimeException {

    /**
     * 构造方法 - 使用指定的错误消息创建异常实例
     * 
     * @param message 异常详情信息，通常包含重复的用户名
     *                示例："用户名'admin'已存在"
     * 
     * 实现说明:
     * 调用父类RuntimeException的构造方法传递错误消息
     */
    public UsernameAlreadyExistsException(String message) {
        super(message);  // 将错误消息传递给父类构造方法
    }
    
    /**
     * 推荐的扩展构造方法（可选实现）：
     * 
     * 可添加带原因(cause)的构造方法，便于异常链追踪
     * 
     * @param message 异常信息
     * @param cause 原始异常对象
     */
    /*
    public UsernameAlreadyExistsException(String message, Throwable cause) {
        super(message, cause);
    }
    */
}
