package com.example.itwordslearning.dto;

/**
 * UserSettingsUpdateDTO 是用于接收用户设置更新请求的数据传输对象。
 * 主要包含用户ID、字体大小和背景颜色设置等属性。
 */
public class UserSettingsUpdateDTO {

	// 用户唯一标识符
	private Integer userId;

	// 用户设置的字体大小，可选值：S（小）、M（中）、L（大）
	private String fontSize;

	// 用户设置的背景颜色，可选值：W（白）、B（黑）、G（绿）等
	private String backgroundColor;

	/**
	 * 获取用户ID
	 * @return Integer 用户的唯一ID
	 */
	public Integer getUserId() {
		return userId;
	}

	/**
	 * 设置用户ID
	 * @param userId 要设置的用户ID
	 */
	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	/**
	 * 获取用户设置的字体大小
	 * @return String 字体大小（S、M、L）
	 */
	public String getFontSize() {
		return fontSize;
	}

	/**
	 * 设置字体大小
	 * @param fontSize 字体大小（只能为S、M、L之一）
	 */
	public void setFontSize(String fontSize) {
		this.fontSize = fontSize;
	}

	/**
	 * 获取背景颜色设置
	 * @return String 背景颜色代码（如W、B、G）
	 */
	public String getBackgroundColor() {
		return backgroundColor;
	}

	/**
	 * 设置背景颜色
	 * @param backgroundColor 背景颜色代码（如W、B、G）
	 */
	public void setBackgroundColor(String backgroundColor) {
		this.backgroundColor = backgroundColor;
	}
}

/**
 * 建议一：添加输入校验（可以使用 Java Bean Validation，如 @Size、@Pattern 等） 示例：
 * 
 * @Pattern(regexp = "S|M|L", message = "字体大小只能为 S、M、L") private String
 *                 fontSize;
 * 
 * @Pattern(regexp = "W|B|G", message = "背景颜色只能为 W、B、G") private String
 *                 backgroundColor;
 * 
 *                 这样可以在 Controller 层自动进行参数校验，避免非法输入。
 */

/**
 * 建议二：使用枚举类型替代字符串常量，增加类型安全和可维护性 示例：定义 FontSize 和 BackgroundColor 枚举类型
 * 
 * public enum FontSize { S, M, L } public enum BackgroundColor { W, B, G }
 * 
 * 然后改为： private FontSize fontSize; private BackgroundColor backgroundColor;
 * 
 * 好处：避免传错字符串、增强代码可读性和自动补全支持。
 */

/**
 * 建议三：添加 toString() 方法用于调试
 * 
 * @Override public String toString() { return "UserSettingsUpdateDTO{" +
 *           "userId=" + userId + ", fontSize='" + fontSize + '\'' + ",
 *           backgroundColor='" + backgroundColor + '\'' + '}'; }
 */
