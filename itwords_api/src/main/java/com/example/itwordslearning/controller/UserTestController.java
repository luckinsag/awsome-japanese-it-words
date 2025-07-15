package com.example.itwordslearning.controller;

import com.example.itwordslearning.dto.UserTestRecordDTO;
import com.example.itwordslearning.service.UserTestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/userTest")
public class UserTestController {

    @Autowired
    private UserTestService userTestService;

    @PostMapping("/add")
    public Integer insertScoreAndGetSessionId(@RequestBody UserTestRecordDTO dto) {
        return userTestService.insertUserTestAndReturnSessionId(dto);
    }
}
