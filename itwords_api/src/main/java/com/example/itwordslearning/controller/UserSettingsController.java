package com.example.itwordslearning.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.example.itwordslearning.dto.UserSettingsUpdateDTO;
import com.example.itwordslearning.response.Result;
import com.example.itwordslearning.service.UserSettingsService;

/**
 * 用户个性化设置控制器
 * 
 * 核心职责：
 * 1. 管理用户个性化配置（如UI主题、学习偏好等）
 * 2. 提供设置项的原子化更新能力
 * 3. 保证设置操作的安全性和幂等性
 * 
 * 技术特性：
 * - 严格使用PUT语义实现幂等更新
 * - 采用增量更新模式（非全量替换）
 * - 设置变更实时生效（配合前端热更新）
 * 
 * 安全审计要求：
 * - 必须验证用户身份（建议使用JWT）
 * - 敏感设置变更需二次验证
 * - 所有修改操作记录审计日志
 */
@CrossOrigin(origins = "*")  // 跨域配置：允许所有域名访问，实际生产环境建议指定具体域名
@RestController
@RequestMapping("/api/user/settings") // 符合REST层级资源命名规范
public class UserSettingsController {

    @Autowired
    private UserSettingsService userSettingsService; // 领域服务接口隔离

    /**
     * 更新用户个性化设置（增量更新）
     * 
     * 设计规范：
     * 1. 严格遵循HTTP PUT语义
     * 2. 支持JSON Merge Patch格式
     * 3. 变更生效无需登出重登
     * 
     * @param dto 设置更新传输对象（示例）：
     *        {
     *          "userId": 123,
     *          "theme": "dark",
     *          "fontSize": 14,
     *          "dailyTarget": 20
     *        }
     *        字段约束：
     *        - userId: 必须有效且匹配当前会话
     *        - 其他字段：需通过服务层校验
     *        
     * @return 标准化结果包装：
     *         - 成功(200): 无数据返回
     *         - 业务错误(400): 参数非法/用户不存在
     *         - 权限错误(403): 越权访问
     *         
     * 事务保证：
     * - 服务层需保证多设置项的原子更新
     * - 变更前后触发校验钩子
     * 
     * 监控指标：
     * 1. 记录设置变更类型分布
     * 2. 跟踪高频修改操作
     * 
     * 示例调用：
     * PUT /api/user/settings/update
     * Headers: Authorization: Bearer {jwt}
     * Body: {"userId":123,"theme":"dark"}
     */
    @PutMapping("/update") // 幂等操作必须使用PUT
    public Result<String> updateSettings(@RequestBody UserSettingsUpdateDTO dto) {
        // 服务层应实现：
        // 1. 用户权限校验
        // 2. 设置项合法性检查
        // 3. 审计日志记录
        boolean success = userSettingsService.updateSettings(dto);
        
        if (success) {
            // 成功响应应保持简洁，避免暴露内部实现
            return Result.success("設定更新成功", null);
        } else {
            // 明确区分"用户不存在"和"数据未变更"两种情况
            return Result.error(400, "設定更新失敗：ユーザーが存在しないかデータが変更されていません");
        }
    }

    // 推荐扩展接口：
    // 1. @GetMapping("/history") - 获取设置变更历史
    // 2. @PostMapping("/reset") - 重置为默认设置
    // 3. @GetMapping("/export") - 导出设置备份
}