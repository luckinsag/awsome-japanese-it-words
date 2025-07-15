package com.example.itwordslearning.controller;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
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

    /**
     * 批量获取笔记内容
     * 
     * @param request 包含单词ID列表的请求对象
     * @param userId 用户ID（从请求头获取）
     * @return Map<Integer, String> 单词ID到笔记内容的映射
     */
    @PostMapping("/batch-comments")
    public Result<Map<Integer, String>> getBatchNotes(@RequestBody BatchNotesRequest request, @RequestHeader("userId") Integer userId) {
        try {
            if (request.getWordIds() == null || request.getWordIds().isEmpty()) {
                return Result.error(400, "単語IDリストは必須です");
            }
            if (userId == null) {
                return Result.error(400, "ユーザーIDは必須です");
            }
            
            Map<Integer, String> notesMap = new HashMap<>();
            for (Integer wordId : request.getWordIds()) {
                String memo = userNoteService.getNoteByWordId(wordId, userId);
                if (memo != null && !memo.trim().isEmpty()) {
                    notesMap.put(wordId, memo);
                }
            }
            
            return Result.success("バッチ取得成功", notesMap);
        } catch (Exception e) {
            return Result.error(500, "バッチ取得失敗：" + e.getMessage());
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

    // 批量笔记请求的内部类
    public static class BatchNotesRequest {
        private List<Integer> wordIds;
        
        public List<Integer> getWordIds() {
            return wordIds;
        }
        
        public void setWordIds(List<Integer> wordIds) {
            this.wordIds = wordIds;
        }
    }
}