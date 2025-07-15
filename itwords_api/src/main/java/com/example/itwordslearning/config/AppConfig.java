package com.example.itwordslearning.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 应用核心配置类
 * 
 * 职责范围：
 * 1. 定义全局基础组件Bean
 * 2. 配置安全相关基础设施
 * 3. 集中管理无状态工具类
 * 
 * 安全合规要求：
 * - 所有密码必须使用BCrypt强哈希存储
 * - 禁止配置任何弱密码编码器（如NoOpPasswordEncoder）
 * - 必须使用安全的随机盐值
 */
@Configuration // 标识为Spring配置类，会被组件扫描自动处理
public class AppConfig {

    /**
     * 密码编码器Bean配置
     * 
     * 技术选型说明：
     * 选择BCrypt的原因：
     * 1. 自适应计算成本（可通过strength参数调整）
     * 2. 内置随机盐处理（相同密码每次哈希结果不同）
     * 3. 抵抗彩虹表攻击
     * 
     * 安全参数：
     * - 默认strength=10（2^10次哈希轮次）
     * - 每个密码处理耗时约100ms（平衡安全性与性能）
     * 
     * 使用规范：
     * 1. 必须用于所有密码存储场景
     * 2. 验证时使用matches()方法而非直接比较
     * 
     * 生产环境建议：
     * 1. 监控密码哈希耗时（突然下降可能表示降级攻击）
     * 2. 定期评估strength参数（随着硬件发展调整）
     * 
     * @return 配置好的BCrypt密码编码器实例（线程安全）
     */
    @Bean // 声明为Spring容器管理的Bean（单例模式）
    public BCryptPasswordEncoder bCryptPasswordEncoder() {
        // 可通过构造函数调整计算强度：new BCryptPasswordEncoder(12)
        return new BCryptPasswordEncoder();
        
        // 替代方案（如需更严格安全）：
        // return new DelegatingPasswordEncoder("bcrypt", 
        //     Collections.singletonMap("bcrypt", new BCryptPasswordEncoder()));
    }

    // 推荐扩展配置：
    // 1. 国际化的MessageSource
    // 2. 线程池TaskExecutor
    // 3. 缓存管理器CacheManager
}