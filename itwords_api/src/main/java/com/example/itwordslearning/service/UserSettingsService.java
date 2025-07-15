package com.example.itwordslearning.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.itwordslearning.dto.UserSettingsUpdateDTO;
import com.example.itwordslearning.mapper.UserSettingsMapper;

/**
 * 用户设置服务类
 * 处理用户个性化配置相关的业务逻辑
 */
@Service
public class UserSettingsService {

    @Autowired
    private UserSettingsMapper userSettingsMapper; // 用户设置数据访问接口

    /**
     * 更新用户设置
     * @param dto 设置更新数据传输对象
     *        - userId: 用户ID（必须存在）
     *        - fontSize: 字体大小（可选）
     *        - backgroundColor: 背景颜色（可选）
     * @return 是否更新成功
     * 
     * 建议：
     * 1. 添加@Transactional注解保证原子性
     * 2. 增加参数校验逻辑
     * 3. 添加设置变更审计日志
     */
    public boolean updateSettings(UserSettingsUpdateDTO dto) {
        // 参数校验建议：
        // if(dto.getUserId() == null) throw new IllegalArgumentException();
        
        int updatedRows = userSettingsMapper.updateUserSettings(
            dto.getUserId(), 
            dto.getFontSize(),
            dto.getBackgroundColor()
        );
        return updatedRows > 0;
    }

    /* 其他增强建议（以注释形式保留）：
    
    // 1. 获取用户设置
    public UserSettings getSettings(Long userId) {
        // 实现逻辑
    }
    
    // 2. 重置为默认设置
    @Transactional
    public boolean resetToDefault(Long userId) {
        // 实现逻辑
    }
    
    // 3. 批量更新设置
    @Transactional
    public int batchUpdateSettings(List<UserSettingsUpdateDTO> dtos) {
        // 实现逻辑
    }
    */
}