package com.example.itwordslearning.service;

import com.example.itwordslearning.dto.UserTestRecordDTO;

public interface UserTestService {
    Integer insertUserTestAndReturnSessionId(UserTestRecordDTO userTestDTO);
}
