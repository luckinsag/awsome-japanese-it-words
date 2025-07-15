package com.example.itwordslearning.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.example.itwordslearning.entity.Word;
import com.example.itwordslearning.response.Result;
import com.example.itwordslearning.service.WordService;

/**
 * 单词数据管理控制器
 * 
 * 核心能力：
 * 1. 提供单词数据的批量查询接口
 * 2. 支持按分类筛选单词
 * 3. 标准化数据返回格式
 * 
 * 设计规范：
 * - 所有接口返回统一包装结果(Result<T>)
 * - 严格区分查询(POST)与获取(GET)语义
 * - 支持跨域访问（生产环境应限制来源）
 * 
 * 性能考量：
 * - 大数据量返回时应实现分页
 * - 高频访问接口建议增加缓存
 * - 分类查询应建立数据库索引
 */
@CrossOrigin(origins = "*") // 允许所有跨域请求（生产环境建议配置具体域名）
@RestController
@RequestMapping("/api/words") // 版本化API建议使用/api/v1/words
public class WordController {

    @Autowired 
    private WordService wordService; // 领域服务接口隔离

    /**
     * 获取全部单词数据（大数据量警告）
     * 
     * 协议选择说明：
     * 使用POST而非GET的原因：
     * 1. 避免URL长度限制（未来可能增加复杂查询参数）
     * 2. 符合"查询"操作语义（GET应用于幂等获取）
     * 
     * @return 标准化结果包装：
     *         - data: 单词列表（可能包含数千条记录）
     *         - 永远返回200状态码（业务错误放在message中）
     *         
     * 风险提示：
     * 1. 数据量过大可能造成内存溢出（建议实现分页）
     * 2. 未做敏感字段过滤（如内部ID暴露）
     * 
     * 改进建议：
     * 1. 增加maxPageSize限制（如@Max(1000)）
     * 2. 添加@PreAuthorize权限控制
     */
    @PostMapping("/all")
    public Result<List<Word>> getAllWords() {
        List<Word> words = wordService.getAllWords(); // 服务层应考虑缓存策略
        return Result.success("クエリ成功", words); 
        // 生产环境建议增加：.addMeta("totalCount", words.size())
    }
    
// 	废弃接口说明（保留注释作为文档）：
//  @PostMapping("/all")
//  public List<Word> getAllWords() {
//      return wordService.getAllWords();
//  }

    /**
     * 按分类批量查询单词
     * 
     * 参数规范：
     * @param categories 分类名称列表（示例）：
     *        ["technology", "business"]
     *        约束：
     *        - 至少包含1个分类
     *        - 每个分类长度2-20字符
     *        
     * 设计决策：
     * 1. 使用POST而非GET + @RequestParam的原因：
     *    - 参数结构更复杂（支持数组）
     *    - 避免URL编码问题
     * 2. 不使用@GetMapping("/byCategories")的原因：
     *    - 查询条件可能扩展为复杂对象
     *    
     * 性能优化：
     * - 数据库应在category字段建立索引
     * - 可考虑添加@Cacheable注解
     * 
     * 错误案例：
     * - 400: 参数校验失败
     * - 404: 分类不存在（当前实现返回空列表）
     */
    @PostMapping("/byCategories")
    public Result<List<Word>> getWordsByCategories(
            @RequestBody List<String> categories) {
        // 服务层应实现：
        // 1. 分类存在性校验
        // 2. 查询结果缓存
        List<Word> words = wordService.getWordsByCategoryIn(categories);
        return Result.success("クエリ成功", words)
                // 扩展建议：
                // .addMeta("matchedCategories", 实际匹配的分类)
                ;
    }

//  废弃接口说明（保留注释作为文档）：
//  @PostMapping("/byCategories")
//  public List<Word> getWordsByCategories(@RequestBody List<String> categories) {
//  return wordService.getWordsByCategoryIn(categories);
//  }
    
//   @GetMapping("/byCategories")
//   public List<Word> getWordsByCategories(@RequestParam("categories") List<String> categories) {
//   return wordService.getWordsByCategoryIn(categories);
//   }
    
    
    // 推荐扩展接口：
    // 1. @PostMapping("/search") - 复杂条件搜索
    // 2. @GetMapping("/random") - 随机单词获取
    // 3. @PostMapping("/export") - 导出单词本
}