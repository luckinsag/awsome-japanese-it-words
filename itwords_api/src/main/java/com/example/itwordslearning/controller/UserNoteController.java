package com.example.itwordslearning.controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.example.itwordslearning.dto.NoteDTO;
import com.example.itwordslearning.dto.UserNoteDTO;
import com.example.itwordslearning.dto.UserNoteDeleteDTO;
import com.example.itwordslearning.response.Result;
import com.example.itwordslearning.service.UserNoteService;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/userNotes")
public class UserNoteController {

    @Autowired
    private UserNoteService userNoteService;

    @PostMapping("/addto-important-wordlist")
    public Result<Integer> addUserNote(@RequestBody UserNoteDTO userNoteDTO) {
        try {
            // 添加参数验证
            if (userNoteDTO.getWordId() == null) {
                return Result.error(400, "単語IDは必須です");
            }
            if (userNoteDTO.getUserId() == null) {
                return Result.error(400, "ユーザーIDは必須です");
            }
            
            int result = userNoteService.addUserNote(userNoteDTO);
            if (result > 0) {
                return Result.success("追加成功", result);
            } else {
                return Result.error(500, "追加失敗");
            }
        } catch (IllegalArgumentException e) {
            return Result.error(400, e.getMessage());
        } catch (Exception e) {
            return Result.error(500, "追加失敗：" + e.getMessage());
        }
    }

    @PostMapping("/delete-important-words")
    public Result<Integer> deleteUserNote(@RequestBody UserNoteDeleteDTO deleteDTO) {
        int result = userNoteService.deleteUserNote(deleteDTO.getUserId(), deleteDTO.getWordId());
        if (result > 0) {
            return Result.success("削除成功", result);
        } else {
            return Result.error(500, "削除失敗");
        }
    }

    @PostMapping("/show-important-wordlist")
    public Result<List<UserNoteDTO>> getUserNotes(@RequestBody UserNoteDTO dto) {
        try {
            if (dto.getUserId() == null) {
                return Result.error(400, "ユーザーIDは必須です");
            }
            List<UserNoteDTO> userNotes = userNoteService.getUserNotes(dto.getUserId());
            return Result.success("クエリ成功", userNotes);
        } catch (Exception e) {
            return Result.error(500, "クエリ失敗：" + e.getMessage());
        }
    }

    // 必须带userId
    @PostMapping("/get-comments")
    public Result<String> getNote(@RequestBody NoteDTO noteDTO, @RequestHeader("userId") Integer userId) {
        String memo = userNoteService.getNoteByWordId(noteDTO.getWordId(), userId);
        if (memo != null) {
            return Result.success("取得成功", memo);
        } else {
            return Result.error(404, "ノートが見つかりません");
        }
    }

    @PutMapping("/save-comments")
    public Result<String> saveNote(@RequestBody NoteDTO noteDTO, @RequestHeader("userId") Integer userId) {
        boolean success = userNoteService.saveOrUpdateNote(noteDTO, userId);
        if (success) {
            return Result.success("保存成功", null);
        } else {
            return Result.error(500, "保存失敗");
        }
    }
}
//import java.util.List;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.web.bind.annotation.CrossOrigin;
//import org.springframework.web.bind.annotation.PostMapping;
//import org.springframework.web.bind.annotation.PutMapping;
//import org.springframework.web.bind.annotation.RequestBody;
//import org.springframework.web.bind.annotation.RequestHeader;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RestController;
//import com.example.itwordslearning.dto.NoteDTO;
//import com.example.itwordslearning.dto.UserNoteDTO;
//import com.example.itwordslearning.dto.UserNoteDeleteDTO;
//import com.example.itwordslearning.response.Result;
//import com.example.itwordslearning.service.UserNoteService;
//
///**
// * 用户笔记管理控制器
// * 
// * 功能概述：
// * 1. 提供用户笔记的增删改查(CRUD)操作接口
// * 2. 处理前端发起的RESTful API请求
// * 3. 调用Service层完成业务逻辑处理
// * 4. 统一返回格式和错误处理
// * 
// * 技术实现：
// * - 使用Spring MVC框架处理HTTP请求
// * - 采用RESTful风格API设计
// * - 使用DTO(Data Transfer Object)进行数据传输
// * - 跨域支持允许所有来源访问(*)
// * 
// * 访问路径：所有接口以/api/userNotes为根路径
// */
//@CrossOrigin(origins = "*")  // 跨域配置：允许所有域名访问，实际生产环境建议指定具体域名
//@RestController  // 声明为REST控制器，自动将返回对象序列化为JSON
//@RequestMapping("/api/userNotes")  // 控制器级别的基础映射路径
//public class UserNoteController {
//    
//    // 自动注入用户笔记服务层组件
//    // 设计说明：通过接口依赖而非具体实现，符合松耦合原则
//    @Autowired  
//    private UserNoteService userNoteService;
//
//    /**
//     * 添加用户笔记接口
//     * 
//     * 业务逻辑：将用户与单词的关联关系保存到数据库
//     * 
//     * @param userNoteDTO 请求体参数，JSON自动反序列化为对象
//     *        - 包含userId(用户ID)和wordId(单词ID)两个必要字段
//     *        
//     * @return 统一响应结果封装对象Result<Integer>
//     *         - 成功时(code=200): 返回操作影响的行数(通常为1)
//     *         - 失败时(code=500): 返回错误信息和空数据
//     *         
//     * 实现细节：
//     * 1. 调用Service层执行数据库插入操作
//     * 2. 根据返回的受影响行数判断操作是否成功
//     * 3. Service层应处理重复添加的情况
//     * 
//     * 使用示例：
//     * POST /api/userNotes/add
//     * Request Body: {"userId":123, "wordId":456}
//     */
//    @PostMapping("/addto-important-wordlist")
//    public Result<Integer> addUserNote(@RequestBody UserNoteDTO userNoteDTO) {
//        // 调用服务层方法，返回受影响的行数
//        int result = userNoteService.addUserNote(userNoteDTO);
//        
//        // 根据操作结果返回不同的响应
//        if (result > 0) {
//            // 成功响应：状态码200，自定义成功消息和返回数据
//            return Result.success("添加成功", result);
//        } else {
//            // 失败响应：状态码500，错误信息
//            // 可能失败原因：数据库异常、参数校验失败等
//            return Result.error(500, "添加失败");
//        }
//    }
//
//    /**
//     * 获取用户所有笔记列表接口
//     * 
//     * 业务逻辑：查询指定用户的所有单词笔记
//     * 
//     * @param dto 请求体参数，至少需要包含userId字段
//     *        - userId: 要查询的用户唯一标识
//     *        
//     * @return 统一响应结果封装对象Result<List<UserNoteDTO>>
//     *         - 成功时: 返回该用户的所有笔记列表
//     *         - 失败时: 由全局异常处理器处理
//     *         
//     * 注意事项：
//     * 1. 如果用户没有笔记，返回空数组而非错误
//     * 2. 列表中的每个元素包含单词ID和关联信息
//     */
//    @PostMapping("/show-important-wordlist")
//    public Result<List<UserNoteDTO>> getUserNotes(@RequestBody UserNoteDTO dto) {
//        // 调用服务层获取指定用户的笔记列表
//        List<UserNoteDTO> userNotes = userNoteService.getUserNotes(dto.getUserId());
//        
//        // 总是返回成功，空列表表示没有笔记
//        return Result.success("查询成功", userNotes);
//    }
//    
//    /**
//     * 删除用户笔记接口
//     * 
//     * 业务逻辑：删除用户与特定单词的关联记录
//     * 
//     * @param deleteDTO 请求体参数，必须包含：
//     *        - userId: 用户ID
//     *        - wordId: 要取消关联的单词ID
//     *        
//     * @return 统一响应结果封装对象Result<Integer>
//     *         - 成功时: 返回删除的行数(通常为1)
//     *         - 失败时: 返回错误信息
//     *         
//     * 设计考虑：
//     * 1. 如果记录不存在，仍返回成功(影响行数为0)
//     * 2. 需要验证用户权限(当前实现未显示检查)
//     */
//    @PostMapping("/delete-important-words")
//    public Result<Integer> deleteUserNote(@RequestBody UserNoteDeleteDTO deleteDTO) {
//        // 调用服务层执行删除操作
//        int result = userNoteService.deleteUserNote(
//            deleteDTO.getUserId(), 
//            deleteDTO.getWordId()
//        );
//        
//        if (result > 0) {
//            return Result.success("删除成功", result);
//        } else {
//            // 可能原因：记录不存在或数据库错误
//            return Result.error(500, "删除失败");
//        }
//    }
//    
//    /**
//     * 获取特定单词的笔记内容详情
//     * 
//     * 业务逻辑：查询用户对某个单词的具体笔记内容
//     * 
//     * @param noteDTO 请求体参数，必须包含wordId字段
//     *        - wordId: 要查询的单词ID
//     *        
//     * @return 统一响应结果封装对象Result<String>
//     *         - 成功时: 返回笔记文本内容
//     *         - 未找到时: 返回404状态码
//     *         
//     * 补充说明：
//     * 1. 笔记内容为纯文本，不含格式
//     * 2. 后续可扩展支持Markdown格式
//     */
//    @PostMapping("/get-comments")
//    public Result<String> getNote(@RequestBody NoteDTO noteDTO) {
//        // 通过单词ID查询笔记内容
//        String memo = userNoteService.getNoteByWordId(noteDTO.getWordId());
//        
//        if (memo != null) {
//            return Result.success("获取成功", memo);
//        } else {
//            // 404表示资源不存在
//            return Result.error(404, "未找到笔记");
//        }
//    }
//    
//    /**
//     * 保存或更新笔记内容接口
//     * 
//     * 业务逻辑：
//     * - 如果该单词笔记不存在，创建新记录
//     * - 如果已存在，更新现有笔记内容
//     * 
//     * @param noteDTO 请求体参数，必须包含：
//     *        - wordId: 单词ID
//     *        - memo: 笔记内容文本
//     * @param userId 从请求头获取的用户ID
//     *        - 设计考虑：放在header更安全，避免与body数据混淆
//     *        
//     * @return 统一响应结果封装对象Result<String>
//     *         - 成功时: 返回操作成功消息
//     *         - 失败时: 返回500错误
//     *         
//     * 安全考虑：
//     * 1. 需要验证userId是否有权限修改该笔记
//     * 2. 当前实现未做严格权限校验(待完善)
//     */
//    @PutMapping("/save-comments")
//    public Result<String> saveNote(
//            @RequestBody NoteDTO noteDTO, 
//            @RequestHeader("userId") Integer userId) {
//        // 调用服务层保存或更新笔记
//        boolean success = userNoteService.saveOrUpdateNote(noteDTO, userId);
//        
//        if (success) {
//            return Result.success("保存成功", null);
//        } else {
//            // 可能失败原因：数据库错误、权限不足等
//            return Result.error(500, "保存失败");
//        }
//    }
//}