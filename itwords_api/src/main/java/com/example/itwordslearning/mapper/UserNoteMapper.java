package com.example.itwordslearning.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.example.itwordslearning.dto.UserNoteDTO;
import com.example.itwordslearning.entity.UserNote;

@Mapper
public interface UserNoteMapper {
    int insertUserNote(UserNote userNote);

    List<UserNoteDTO> getNotesByUserId(@Param("userId") Integer userId);

    int deleteUserNote(@Param("userId") Integer userId, @Param("wordId") Integer wordId);

    // 必须带 userId
    UserNote getNoteByWordId(@Param("wordId") Integer wordId, @Param("userId") Integer userId);

    // 必须带 userId
    int updateNoteByWordId(@Param("wordId") Integer wordId, @Param("userId") Integer userId, @Param("memo") String memo);

    int insertNote(@Param("wordId") Integer wordId, @Param("userId") Integer userId, @Param("memo") String memo);

    int checkNoteExists(@Param("wordId") Integer wordId, @Param("userId") Integer userId);
}
//
//import java.util.List;
//
//import org.apache.ibatis.annotations.Mapper;
//import org.apache.ibatis.annotations.Param;
//
//import com.example.itwordslearning.dto.UserNoteDTO;
//import com.example.itwordslearning.entity.UserNote;
//
//@Mapper // MyBatis标记接口为Mapper，建议添加@Repository注解同时使用，以明确DAO层组件
//public interface UserNoteMapper {
//    /**
//     * 插入用户笔记（使用实体对象作为参数）
//     * @param userNote 用户笔记实体对象
//     * @return 受影响的行数，建议明确成功返回值（通常1表示成功）
//     * 建议：参数校验应该在Service层完成
//     */
//    int insertUserNote(UserNote userNote);
//
//    /**
//     * 根据用户ID获取所有笔记（返回DTO列表）
//     * @param userId 用户ID
//     * @return 用户笔记DTO列表，建议返回空列表而不是null
//     * 建议：考虑添加分页参数（pageNum, pageSize）防止数据量过大
//     */
//    List<UserNoteDTO> getNotesByUserId(@Param("userId") Integer userId);
//
//    /**
//     * 删除指定用户的单词笔记
//     * @param userId 用户ID
//     * @param wordId 单词ID
//     * @return 受影响的行数，建议明确成功返回值
//     * 建议：考虑添加@Transactional注解在Service层保证事务性
//     */
//    int deleteUserNote(@Param("userId") Integer userId, @Param("wordId") Integer wordId);
//
//    /**
//     * 根据单词ID获取笔记详情
//     * @param wordId 单词ID
//     * @return 用户笔记实体，可能为null（当不存在时）
//     * 建议：考虑添加userId参数确保数据隔离
//     */
//    UserNote getNoteByWordId(@Param("wordId") Integer wordId);  //根据单词ID获取笔记
//
//    /**
//     * 根据单词ID更新笔记内容
//     * @param wordId 单词ID
//     * @param memo 笔记内容
//     * @return 受影响的行数
//     * 问题：缺少userId参数可能导致数据安全问题
//     * 建议：添加userId参数和更新时间字段
//     */
//    int updateNoteByWordId(@Param("wordId") Integer wordId, @Param("memo") String memo); //根据单词ID更新笔记
//
//    /**
//     * 插入新笔记（参数形式）
//     * @param wordId 单词ID
//     * @param userId 用户ID
//     * @param memo 笔记内容
//     * @return 受影响的行数
//     * 建议：与insertUserNote功能重复，考虑合并或删除其中一个
//     */
//    int insertNote(@Param("wordId") Integer wordId, @Param("userId") Integer userId, @Param("memo") String memo);  //插入新的笔记
//
//    /**
//     * 检查指定用户的单词笔记是否存在
//     * @param wordId 单词ID
//     * @param userId 用户ID
//     * @return 存在返回1，不存在返回0
//     * 建议：方法名改为existsByWordIdAndUserId更符合Spring习惯
//     * 建议：返回boolean类型更直观
//     */
//    int checkNoteExists(@Param("wordId") Integer wordId, @Param("userId") Integer userId); 
//}
