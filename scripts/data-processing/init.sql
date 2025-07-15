-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS mysql_itwordslearning CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE mysql_itwordslearning;

CREATE TABLE `words` (
  `word_id` int NOT NULL AUTO_INCREMENT,
  `japanese` varchar(100) NOT NULL,
  `chinese` varchar(100) NOT NULL,
  `english` varchar(100) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`word_id`)
) ENGINE=InnoDB AUTO_INCREMENT=676 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `japanese` varchar(50) DEFAULT NULL,
  `chinese` varchar(50) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_settings` (
  `user_id` int NOT NULL,
  `font_size` varchar(20) DEFAULT NULL,
  `background_color` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `user_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `user_notes` (
  `notes_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `word_id` int NOT NULL,
  `added_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `memo` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`notes_id`),
  KEY `user_id` (`user_id`),
  KEY `word_id` (`word_id`),
  CONSTRAINT `user_notes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `user_notes_ibfk_2` FOREIGN KEY (`word_id`) REFERENCES `words` (`word_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `test_sessions` (
  `session_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `ended_at` datetime NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`session_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `test_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `test_wrong_answers` (
  `wrong_id` int NOT NULL AUTO_INCREMENT,
  `session_id` int NOT NULL,
  `word_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`wrong_id`),
  KEY `session_id` (`session_id`),
  KEY `word_id` (`word_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `test_wrong_answers_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `test_sessions` (`session_id`),
  CONSTRAINT `test_wrong_answers_ibfk_2` FOREIGN KEY (`word_id`) REFERENCES `words` (`word_id`),
  CONSTRAINT `test_wrong_answers_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; 