package com.example.itwordslearning.controller;

import com.example.itwordslearning.dto.UserWrongDTO;
import com.example.itwordslearning.dto.UserWrongDeleteDTO;
import com.example.itwordslearning.dto.UserWrongSelectDTO;
import com.example.itwordslearning.entity.UserWrongWord;
import com.example.itwordslearning.service.UserWrongService;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/userWrong")
public class UserWrongController {

	@Autowired
	private UserWrongService userWrongService;

	@PostMapping("/add")
	public int insertWrong(@RequestBody UserWrongDTO dto) {
		return userWrongService.insertUserWrong(dto);
	}

	@PostMapping("/delete")
	public int deleteWrong(@RequestBody UserWrongDeleteDTO dto) {
		return userWrongService.deleteUserWrong(dto);
	}

	@PostMapping("/list")
	public List<UserWrongWord> listWrong(@RequestBody UserWrongSelectDTO dto) {
		return userWrongService.getWrongWordsByUserId(dto);
	}
}
