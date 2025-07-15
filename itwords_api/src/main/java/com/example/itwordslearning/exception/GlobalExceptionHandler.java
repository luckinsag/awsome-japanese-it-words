package com.example.itwordslearning.exception;

import com.example.itwordslearning.response.Result;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * 全局异常处理器
 * 使用@ControllerAdvice注解标记为全局控制器增强类
 * 可集中处理应用程序中抛出的各种异常
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 处理用户名已存在异常
     * @param ex 捕获到的UsernameAlreadyExistsException异常对象
     * @return 包含错误信息的响应实体
     * 
     * 注解说明:
     * @ExceptionHandler 指定要处理的异常类型
     * @ResponseBody 表示返回对象应直接写入HTTP响应体
     * 
     * 处理逻辑:
     * 1. 构建错误结果对象(状态码400 + 异常消息)
     * 2. 包装成ResponseEntity返回
     */
    @ExceptionHandler(UsernameAlreadyExistsException.class)
    @ResponseBody
    public ResponseEntity<Result<String>> handleUsernameAlreadyExistsException(UsernameAlreadyExistsException ex) {
        // 构建错误响应结果
        Result<String> result = Result.error(
            HttpStatus.BAD_REQUEST.value(), // HTTP状态码(400)
            ex.getMessage()                 // 异常中的错误消息
        );
        
        // 返回响应实体(包含结果对象和HTTP状态)
        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
    }
    
    // 示例：可以添加其他的异常处理方法
    /*
    @ExceptionHandler(OtherException.class)
    @ResponseBody
    public ResponseEntity<Result<String>> handleOtherException(OtherException ex) {
        Result<String> result = Result.error(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "システム内部エラー: " + ex.getMessage()
        );
        return new ResponseEntity<>(result, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    */
}
