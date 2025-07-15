package com.example.itwordslearning.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.itwordslearning.dto.LoginDTO;
import com.example.itwordslearning.dto.RegisterDTO;
import com.example.itwordslearning.dto.UserDTO;
import com.example.itwordslearning.exception.UsernameAlreadyExistsException;
import com.example.itwordslearning.response.Result;
import com.example.itwordslearning.service.UserService;

/**
* 认证授权控制器
*
* 核心职责：
* 1. 处理用户身份认证（登录/登出）
* 2. 管理用户注册流程
* 3. 返回标准化认证结果
*
* 安全规范：
* - 所有接口必须通过HTTPS访问
* - 密码传输需加密（建议前端使用BCrypt哈希）
* - 登录成功应返回HTTP-only的JWT令牌（当前实现需补充）
*
* 路径规范：
* - 所有接口以 /api/auth 为根路径
* - 符合RESTful最佳实践
*/

@CrossOrigin(origins = "*")
@RestController // 声明为REST控制器，自动处理JSON序列化
@RequestMapping("/api/auth") // 控制器级别的统一路径前缀
public class AuthController {

@Autowired // 自动注入用户服务（Spring的依赖注入）
private UserService userService; // 设计原则：面向接口编程，便于测试和替换实现

/**
* 用户登录接口
*
* 业务流程：
* 1. 验证用户名密码
* 2. 生成访问令牌（待实现）
* 3. 记录登录日志（待实现）
*
* @param loginDTO 登录凭证数据传输对象，包含：
* - username : 字符串，必填，长度4-20字符
* - password : 字符串，必填，BCrypt加密后的密文
*
* @return 统一响应实体Result<User>：
* - 成功(200): 返回用户基本信息（不应包含密码等敏感字段）
* - 失败(401): 凭证无效错误
*
* 安全注意事项：
* 1. 必须限制登录尝试频率（防暴力破解）
* 2. 密码比较需用恒定时间算法（防时序攻击）
* 3. 建议补充CAPTCHA验证（高风险操作时）
*
* 示例请求：
* POST /api/auth/login
* {"username":"testuser", "password":"$2a$10$N9qo8uLOickgx2ZMRZoMy..."}
*/
@PostMapping("/login")
public Result<UserDTO> login(@RequestBody LoginDTO loginDTO) {
	UserDTO userDTO = userService.login(loginDTO.getUsername(), loginDTO.getPassword());
	if (userDTO != null) {
		            return Result.success("ログイン成功", userDTO); // 返回 UserDTO
        } else {
            return Result.error(401, "ユーザー名またはパスワードが間違っています");
	}
}

/**
* 用户注册接口
*
* 业务流程：
* 1. 校验用户名唯一性
* 2. 密码强度验证
* 3. 持久化用户信息
* 4. 发送激活邮件（可选）
*
* @param registerDTO 注册信息传输对象，包含：
* - username : 字符串，必填，需符合正则^[a-zA-Z0-9_-]{4,20}$
* - password : 字符串，必填，最小长度8位
* - email : 字符串，可选，需符合邮箱格式
*
* @return 统一响应实体Result<Integer>：
* - 成功(200): 返回新用户ID
* - 失败(500): 服务器错误
* - 失败(400): 参数校验失败（需配合@Validated使用）
*
* 设计约束：
* 1. 密码必须加密存储（推荐BCrypt）
* 2. 敏感字段（如密码）不应出现在日志中
* 3. 需防止批量注册攻击
*
* 扩展建议：
* 1. 添加短信验证码验证
* 2. 实现邮箱激活流程
*/
@PostMapping("/register")
public ResponseEntity<Result<Integer>> register(@RequestBody RegisterDTO registerDTO) {
try {
// 服务层应实现：密码加密、唯一性检查、数据清洗
int userId = userService.register(registerDTO);

if (userId > 0) {
// 实际项目应触发异步事件（如发送欢迎邮件）
return ResponseEntity.ok(Result.success("登録成功", userId));
} else {
// 500表示服务器未能完成请求（非用户侧问题）
return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Result.error(500, "登録失敗"));
}
} catch (UsernameAlreadyExistsException ex) {
// 捕获用户名已存在异常，并返回带有400状态码的响应
return ResponseEntity.badRequest().body(Result.error(400, ex.getMessage()));
}
}

// 待实现接口建议：
// 1. @PostMapping("/logout") - JWT令牌失效
// 2. @PostMapping("/password/reset") - 密码重置
// 3. @GetMapping("/activate/{token}") - 账户激活
}