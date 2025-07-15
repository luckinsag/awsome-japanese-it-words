package com.example.itwordslearning.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper // 标识为MyBatis的Mapper接口
// 建议：添加@Repository注解以明确其DAO层组件的角色
// 建议：考虑添加javadoc类注释说明这个Mapper的职责
public interface UserSettingsMapper {

    /**
     * 更新用户设置
     * @param userId 用户ID（必需）
     * @param fontSize 字体大小（可空）
     * @param backgroundColor 背景颜色（可空）
     * @return 受影响的行数（1表示成功更新，0表示用户不存在）
     * 
     * 问题：当前设计会覆盖所有设置字段，即使只更新其中一项
     * 建议方案1：拆分为独立更新方法（updateFontSize, updateBackgroundColor）
     * 建议方案2：使用@DynamicSQL实现选择性更新
     * 
     * 安全建议：应验证userId存在性和参数有效性
     * 扩展建议：考虑添加updateTime字段记录最后修改时间
     */
    int updateUserSettings(
            @Param("userId") Integer userId, 
            @Param("fontSize") String fontSize,
            @Param("backgroundColor") String backgroundColor);
    
    // 缺少的常用方法建议：
    // 1. 获取用户设置（对应更新操作）
    // UserSettings getUserSettings(@Param("userId") Integer userId);
    
    // 2. 初始化用户设置（首次使用时）
    // int initUserSettings(@Param("userId") Integer userId);
}
