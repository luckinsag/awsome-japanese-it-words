package com.example.itwordslearning.response;

/**
 * 通用响应包装类，用于统一封装接口返回结果。
 *
 * @param <T> 返回数据的类型
 */
public class Result<T> {
	private int code;       // 状态码，例如 200 表示成功，其他表示错误
	private String message; // 提示信息，例如“成功”或错误原因
	private T data;         // 返回的实际数据内容（可以为任意类型）

	// 获取状态码
	public int getCode() {
		return code;
	}

	// 设置状态码
	public void setCode(int code) {
		this.code = code;
	}

	// 获取提示信息
	public String getMessage() {
		return message;
	}

	// 设置提示信息
	public void setMessage(String message) {
		this.message = message;
	}

	// 获取响应数据
	public T getData() {
		return data;
	}

	// 设置响应数据
	public void setData(T data) {
		this.data = data;
	}

	// 全参构造函数
	public Result(int code, String message, T data) {
		this.code = code;
		this.message = message;
		this.data = data;
	}

	/**
	 * 返回成功响应，默认消息为“成功”
	 * @param data 返回数据
	 * @param <T> 数据类型
	 * @return Result 对象
	 */
	public static <T> Result<T> success(T data) {
		return new Result<>(200, "成功", data);
	}

	/**
	 * 返回成功响应，自定义消息
	 * @param message 自定义提示消息
	 * @param data 返回数据
	 * @param <T> 数据类型
	 * @return Result 对象
	 */
	public static <T> Result<T> success(String message, T data) {
		return new Result<>(200, message, data);
	}

	/**
	 * 返回错误响应，包含错误码和错误消息
	 * @param code 错误状态码
	 * @param message 错误提示信息
	 * @param <T> 数据类型
	 * @return Result 对象
	 */
	public static <T> Result<T> error(int code, String message) {
		return new Result<>(code, message, null);
	}

	/**
	 * 返回 401 未授权 错误
	 * @param <T> 数据类型
	 * @return Result 对象
	 */
	public static <T> Result<T> unauthorized() {
		        return new Result<>(401, "未認証", null);
	}

	/**
	 * 返回 403 禁止访问 错误
	 * @param <T> 数据类型
	 * @return Result 对象
	 */
	public static <T> Result<T> forbidden() {
		        return new Result<>(403, "アクセス禁止", null);
	}

	/**
	 * 返回 404 资源未找到 错误
	 * @param <T> 数据类型
	 * @return Result 对象
	 */
	public static <T> Result<T> notFound() {
		        return new Result<>(404, "リソースが見つかりません", null);
	}
}

//✅ 建议一：添加无参构造函数，便于 Spring 序列化（例如用于 JSON 反序列化）
//public Result() {}


//✅ 建议二：可以考虑定义枚举类 ResultCode 来集中管理状态码和信息
//示例：
//public enum ResultCode {
//  SUCCESS(200, "成功"),
//  UNAUTHORIZED(401, "未授权"),
//  FORBIDDEN(403, "禁止访问"),
//  NOT_FOUND(404, "资源未找到");
//
//  private final int code;
//  private final String message;
//  // 构造方法、getter略
//}
//
//使用：
//return new Result<>(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMessage(), data);


//✅ 建议三：添加 toString() 方法方便调试日志输出
//@Override
//public String toString() {
//  return "Result{" +
//          "code=" + code +
//          ", message='" + message + '\'' +
//          ", data=" + data +
//          '}';
//}
