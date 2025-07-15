package com.example.itwordslearning.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.example.itwordslearning.entity.Word;
import com.example.itwordslearning.mapper.WordMapper;

/**
 * 单词数据服务层
 * 负责单词数据的查询和业务逻辑处理
 */
@Service
public class WordService {

    @Autowired
    private WordMapper wordMapper; // 单词数据访问接口

    /**
     * 获取所有单词数据
     * @return 单词列表（可能包含大量数据）
     * 
     * 性能建议：
     * 1. 大数据量场景应实现分页查询
     * 2. 考虑添加缓存机制
     * 3. 高频访问接口建议使用@Cacheable
     */
    public List<Word> getAllWords() {
        return wordMapper.getAllWords();
    }
    
    /**
     * 按分类查询单词
     * @param categories 分类列表（非空）
     * @return 符合条件的单词列表
     * 
     * 优化建议：
     * 1. 添加参数校验：@NotEmpty
     * 2. 数据库category字段应建立索引
     * 3. 可考虑并行查询优化
     */
    public List<Word> getWordsByCategoryIn(List<String> categories) {
        return wordMapper.getWordsByCategory(categories);
    }

    /* 其他扩展建议（以注释形式保留）：
    
    // 1. 分页查询接口
    public Page<Word> getWordsByPage(int pageNum, int pageSize) {
        // 实现分页逻辑
    }
    
    // 2. 单词搜索接口
    public List<Word> searchWords(String keyword) {
        // 实现搜索逻辑
    }
    
    // 3. 批量导入接口
    @Transactional
    public int importWords(List<Word> words) {
        // 实现批量导入
    }
    */
}