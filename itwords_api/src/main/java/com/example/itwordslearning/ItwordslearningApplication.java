package com.example.itwordslearning;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import java.util.TimeZone;

@SpringBootApplication
public class ItwordslearningApplication implements CommandLineRunner {

	public static void main(String[] args) {
		SpringApplication.run(ItwordslearningApplication.class, args);
	}

	@Override
	public void run(String... args) throws Exception {
		// 设置应用默认时区为东京时区
		TimeZone.setDefault(TimeZone.getTimeZone("Asia/Tokyo"));
		System.out.println("应用时区已设置为: " + TimeZone.getDefault().getID());
	}
}
