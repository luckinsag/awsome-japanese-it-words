package com.example.itwordslearning.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.example.itwordslearning.dto.NoteDTO;
import com.example.itwordslearning.dto.UserNoteDTO;
import com.example.itwordslearning.entity.UserNote;
import com.example.itwordslearning.mapper.UserNoteMapper;

@Service
public class UserNoteService {

    @Autowired
    private UserNoteMapper userNoteMapper;

    // 标记重点单词（无笔记内容时memo可为null）
    public int addUserNote(UserNoteDTO userNoteDTO) {
        // 添加参数验证
        if (userNoteDTO.getWordId() == null) {
            throw new IllegalArgumentException("単語IDは必須です");
        }
        if (userNoteDTO.getUserId() == null) {
            throw new IllegalArgumentException("ユーザーIDは必須です");
        }
        
        // 避免重复插入
        int exists = userNoteMapper.checkNoteExists(userNoteDTO.getWordId(), userNoteDTO.getUserId());
        if (exists > 0) {
            return 1; // 已存在视为成功
        }
        
        UserNote userNote = new UserNote();
        userNote.setUserId(userNoteDTO.getUserId());
        userNote.setWordId(userNoteDTO.getWordId());
        userNote.setMemo(userNoteDTO.getMemo());
        return userNoteMapper.insertUserNote(userNote);
    }

    public List<UserNoteDTO> getUserNotes(Integer userId) {
        return userNoteMapper.getNotesByUserId(userId);
    }

    public int deleteUserNote(Integer userId, Integer wordId) {
        return userNoteMapper.deleteUserNote(userId, wordId);
    }

    // 获取某个单词的笔记内容（必须带userId）
    public String getNoteByWordId(Integer wordId, Integer userId) {
        UserNote note = userNoteMapper.getNoteByWordId(wordId, userId);
        return note != null ? note.getMemo() : null;
    }

    // 保存或更新笔记（有则更新，无则插入）
    @Transactional
    public boolean saveOrUpdateNote(NoteDTO noteDTO, Integer userId) {
        int exists = userNoteMapper.checkNoteExists(noteDTO.getWordId(), userId);
        if (exists > 0) {
            int updatedRows = userNoteMapper.updateNoteByWordId(noteDTO.getWordId(), userId, noteDTO.getMemo());
            return updatedRows > 0;
        } else {
            int insertedRows = userNoteMapper.insertNote(noteDTO.getWordId(), userId, noteDTO.getMemo());
            return insertedRows > 0;
        }
    }
}
//import java.util.List;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Service;
//import org.springframework.transaction.annotation.Transactional;
//import com.example.itwordslearning.dto.NoteDTO;
//import com.example.itwordslearning.dto.UserNoteDTO;
//import com.example.itwordslearning.entity.UserNote;
//import com.example.itwordslearning.mapper.UserNoteMapper;
//
///**
// * 用户笔记服务层
// * 处理用户笔记相关的业务逻辑
// */
//@Service
//public class UserNoteService {
//
//    @Autowired
//    private UserNoteMapper userNoteMapper; // 用户笔记数据访问接口
//    
//    /**
//     * 添加用户笔记关联
//     * @param userNoteDTO 用户笔记传输对象
//     * @return 影响的行数
//     * 建议：添加参数校验
//     */
//    public int addUserNote(UserNoteDTO userNoteDTO) {
//        UserNote userNote = new UserNote();
//        userNote.setUserId(userNoteDTO.getUserId());
//        userNote.setWordId(userNoteDTO.getWordId());
//        userNote.setMemo(userNoteDTO.getMemo());
//        return userNoteMapper.insertUserNote(userNote);
//    }
//    
//    /**
//     * 获取用户所有笔记
//     * @param userId 用户ID
//     * @return 笔记列表
//     * 建议：添加分页查询支持
//     */
//    public List<UserNoteDTO> getUserNotes(Integer userId) {
//        return userNoteMapper.getNotesByUserId(userId);
//    }
//    
//    /**
//     * 删除用户笔记
//     * @param userId 用户ID
//     * @param wordId 单词ID
//     * @return 影响的行数
//     * 建议：添加删除前的权限校验
//     */
//    public int deleteUserNote(Integer userId, Integer wordId) {
//        return userNoteMapper.deleteUserNote(userId, wordId);
//    }
//    
//    /**
//     * 根据单词ID获取笔记内容
//     * @param wordId 单词ID
//     * @return 笔记内容
//     * 建议：添加缓存支持
//     */
//    public String getNoteByWordId(Integer wordId) {
//        UserNote note = userNoteMapper.getNoteByWordId(wordId);
//        return note != null ? note.getMemo() : null;
//    }
//
//    /**
//     * 保存或更新笔记（事务处理）
//     * @param noteDTO 笔记数据
//     * @param userId 用户ID
//     * @return 操作是否成功
//     * 注意：@Transactional确保操作原子性
//     */
//    @Transactional
//    public boolean saveOrUpdateNote(NoteDTO noteDTO, Integer userId) {
//        // 检查是否已存在笔记
//        int exists = userNoteMapper.checkNoteExists(noteDTO.getWordId(), userId);
//        if (exists > 0) {
//            // 更新现有笔记
//            int updatedRows = userNoteMapper.updateNoteByWordId(noteDTO.getWordId(), noteDTO.getMemo());
//            return updatedRows > 0;
//        } else {
//            // 新增笔记
//            int insertedRows = userNoteMapper.insertNote(noteDTO.getWordId(), userId, noteDTO.getMemo());
//            return insertedRows > 0;
//        }
//    }
//    
//    /* 其他改进建议：
//    1. 添加日志记录
//    2. 实现笔记版本控制
//    3. 添加批量操作接口
//    4. 增加笔记变更通知功能
//    */
//}