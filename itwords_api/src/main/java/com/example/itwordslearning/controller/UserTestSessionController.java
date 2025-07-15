package com.example.itwordslearning.controller;

import com.example.itwordslearning.dto.UserTestSessionDTO;
import com.example.itwordslearning.service.UserTestSessionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Collections; // 导入 Collections 类，用于返回空列表

@RestController
@RequestMapping("/api/testSessions") // 统一的路径前缀
// @CrossOrigin(origins = "http://localhost:5173") // 如果需要，可以为这个Controller单独配置CORS
public class UserTestSessionController {

    @Autowired // 使用 @Autowired 进行服务注入
    private UserTestSessionService userTestSessionService;

    /**
     * 根据用户ID获取考试成绩列表
     * GET /api/testSessions/user/{userId}
     *
     * @param userId 用户ID
     * @return 考试成绩DTO列表。如果用户无成绩，返回空列表。
     */
    @GetMapping("/user/{userId}")
    public List<UserTestSessionDTO> getTestScoresByUserId(@PathVariable Integer userId) {
        List<UserTestSessionDTO> scores = userTestSessionService.getTestScoresByUserId(userId);
        // 如果 service 返回 null（虽然在 service 层已经处理为不会返回 null），
        // 确保这里也返回一个空列表而不是 null，以避免前端错误。
        return scores != null ? scores : Collections.emptyList();
    }
}