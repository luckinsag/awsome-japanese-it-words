package com.example.itwordslearning.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

/**
 * Spring Security 核心配置类
 * 
 * 安全架构原则：
 * 1. 显式声明所有端点的访问策略
 * 2. 默认拒绝所有未明确放行的请求
 * 3. 最小权限原则（PoLP）实施
 * 
 * 生产环境必须修改：
 * - 禁用anyRequest().permitAll()
 * - 启用CSRF保护（或明确管理CORS）
 * - 配置JWT/OAuth2认证流程
 */
@Configuration
@EnableWebSecurity // 启用Spring Security的Web安全支持
public class SecurityConfig {

    /**
     * 安全过滤器链配置（Spring Security 5.7+新写法）
     * 
     * 当前配置说明（仅用于开发测试）：
     * 1. 完全禁用CSRF保护（生产环境必须启用）
     * 2. 开放所有API访问（生产环境必须配置具体权限）
     * 3. 禁用表单登录（纯API架构适用）
     * 
     * @param http Spring Security配置构建器
     * @return 构建的安全过滤器链
     * @throws Exception 配置过程中的异常
     * 
     * 生产环境推荐配置：
     * 1. 基于角色的访问控制（RBAC）：
     *    .requestMatchers("/admin/**").hasRole("ADMIN")
     * 2. JWT认证集成：
     *    .oauth2ResourceServer(OAuth2ResourceServerConfigurer::jwt)
     * 3. 会话管理：
     *    .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
     * 
     * 安全审计要点：
     * - 所有放行的端点必须记录理由
     * - 定期检查未认证的API端点
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // CSRF配置（当前禁用仅用于测试）
            .csrf(csrf -> csrf.disable()) 
            // 生产环境替代方案：
            // .csrf(csrf -> csrf
            //     .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
            //     .ignoringRequestMatchers("/api/public/**"))
            
            // 授权请求配置
            .authorizeHttpRequests(auth -> auth
                // 开放认证相关端点
                .requestMatchers(
                    new AntPathRequestMatcher("/api/auth/register", "POST"),
                    new AntPathRequestMatcher("/api/auth/login", "POST")
                ).permitAll()
                
                // 临时开放所有请求（仅用于开发阶段）
                .anyRequest().permitAll() 
                // 生产环境必须替换为：
                // .anyRequest().authenticated()
            )
            
            // 禁用默认表单登录（API服务不需要）
            .formLogin(form -> form.disable())
            
            // 建议添加的配置（生产环境）：
            // .exceptionHandling(e -> e
            //     .authenticationEntryPoint(jwtAuthEntryPoint)
            //     .accessDeniedHandler(accessDeniedHandler))
            // .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
        ;

        return http.build();
    }

    // 其他安全相关配置建议：
    // 1. 密码编码器Bean（已在AppConfig中配置）
    // 2. CORS配置（需单独配置）
    // 3. 安全事件监听器
}