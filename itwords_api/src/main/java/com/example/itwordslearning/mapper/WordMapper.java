package com.example.itwordslearning.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.itwordslearning.entity.Word;

@Mapper // 标识为MyBatis的Mapper接口
// 建议添加：@Repository注解以明确DAO层组件角色
// 建议添加：类级别的Javadoc说明此Mapper的职责范围
public interface WordMapper {

    /**
     * 获取所有单词
     * @return 单词实体列表（可能为空列表但不应为null）
     * 
     * 性能警告：当数据量大时可能造成内存问题
     * 改进建议1：添加分页参数
     * 改进建议2：返回Stream<Word>进行流式处理
     * 安全建议：考虑数据权限控制
     */
    List<Word> getAllWords();

    /**
     * 根据分类获取单词
     * @param categories 分类列表（至少包含一个分类）
     * @return 符合条件的单词列表（可能为空列表但不应为null）
     * 
     * 参数验证：需要确保categories非空且不为空列表
     * 性能建议：对于大分类列表考虑分批查询
     * SQL注入：确保categories已做安全处理
     * 扩展建议：添加排序参数
     */
    List<Word> getWordsByCategory(@Param("categories") List<String> categories);

    // ===== 缺少的常用方法建议 =====
    
    /**
     * 分页查询建议
     */
    // List<Word> getWordsByPage(@Param("offset") int offset, 
    //                         @Param("limit") int limit);

    /**
     * 按ID获取单词详情
     */
    // Word getWordById(@Param("id") Integer id);

    /**
     * 搜索建议
     */
    // List<Word> searchWords(@Param("keyword") String keyword,
    //                      @Param("matchPrefix") boolean matchPrefix);

    /**
     * 统计数量
     */
    // int countWordsByCategory(@Param("category") String category);
}
