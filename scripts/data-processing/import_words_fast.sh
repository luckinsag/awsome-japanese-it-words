#!/bin/bash

# ITWORDS 单词数据快速导入脚本（批量INSERT版本）
# 使用批量INSERT实现快速导入

echo "🚀 开始导入单词数据（批量INSERT方式）..."

# 创建临时SQL文件
cat > /tmp/import_words.sql << 'EOF'
SET NAMES utf8mb4;
SET character_set_client=utf8mb4;
SET character_set_connection=utf8mb4;
SET character_set_results=utf8mb4;

-- 清空现有数据
TRUNCATE TABLE words;

-- 批量插入数据
INSERT INTO words (japanese, chinese, english, category) VALUES
EOF

# 转换CSV为SQL INSERT语句（跳过标题行）
tail -n +2 complete_wordlist.csv | sed 's/"/\\"/g' | sed 's/,/","/g' | sed 's/^/("/' | sed 's/$/"),/' | sed '$s/,$/;/' >> /tmp/import_words.sql

# 执行SQL导入
docker exec -i itwords-mysql mysql -u root -pxcx981211 --default-character-set=utf8mb4 mysql_itwordslearning < /tmp/import_words.sql

# 验证导入结果
docker exec itwords-mysql mysql -u root -pxcx981211 --default-character-set=utf8mb4 mysql_itwordslearning -e "
SELECT CONCAT('✅ 成功导入 ', COUNT(*), ' 条单词数据') as result FROM words;
"

# 清理临时文件
rm -f /tmp/import_words.sql

echo "✅ 单词数据导入完成！" 