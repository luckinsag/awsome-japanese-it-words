#!/bin/bash

# 将complete_wordlist.csv数据导入到MySQL数据库
# 数据库：mysql_itwordslearning
# 表：words

DB_NAME="mysql_itwordslearning"
TABLE_NAME="words"
CSV_FILE="complete_wordlist.csv"

echo "开始导入单词数据到MySQL数据库..."

# 检查CSV文件是否存在
if [ ! -f "$CSV_FILE" ]; then
    echo "错误：找不到CSV文件 $CSV_FILE"
    exit 1
fi

# 检查MySQL是否可用
if ! command -v mysql &> /dev/null; then
    echo "错误：未找到MySQL客户端"
    exit 1
fi

# 创建临时SQL文件
TEMP_SQL="temp_import_words.sql"

echo "-- 临时SQL文件，用于导入单词数据" > $TEMP_SQL
echo "USE $DB_NAME;" >> $TEMP_SQL
echo "" >> $TEMP_SQL

# 清空现有数据（可选）
echo "-- 清空现有单词数据" >> $TEMP_SQL
echo "DELETE FROM $TABLE_NAME;" >> $TEMP_SQL
echo "ALTER TABLE $TABLE_NAME AUTO_INCREMENT = 1;" >> $TEMP_SQL
echo "" >> $TEMP_SQL

# 生成INSERT语句
echo "-- 插入单词数据" >> $TEMP_SQL
echo "INSERT INTO $TABLE_NAME (word, pronunciation, meaning, category, difficulty_level) VALUES" >> $TEMP_SQL

# 处理CSV文件（跳过标题行）
tail -n +2 "$CSV_FILE" | while IFS=',' read -r japanese chinese english category; do
    # 清理字段中的引号和特殊字符
    japanese=$(echo "$japanese" | sed "s/'/''/g" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    chinese=$(echo "$chinese" | sed "s/'/''/g" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    english=$(echo "$english" | sed "s/'/''/g" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    category=$(echo "$category" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # 如果是最后一行，不加逗号
    if [ $(tail -n +2 "$CSV_FILE" | wc -l) -eq $(($(wc -l < "$CSV_FILE") - 1)) ]; then
        echo "('$japanese', '$english', '$chinese', '$category', 1);" >> $TEMP_SQL
    else
        echo "('$japanese', '$english', '$chinese', '$category', 1)," >> $TEMP_SQL
    fi
done

echo ""
echo "生成的SQL文件：$TEMP_SQL"
echo "执行MySQL导入..."

# 执行SQL文件
mysql -u root -p $DB_NAME < $TEMP_SQL

if [ $? -eq 0 ]; then
    echo "✅ 数据导入成功！"
    echo "验证导入结果..."
    mysql -u root -p $DB_NAME -e "SELECT COUNT(*) as total_words FROM $TABLE_NAME;"
    mysql -u root -p $DB_NAME -e "SELECT category, COUNT(*) as word_count FROM $TABLE_NAME GROUP BY category ORDER BY category;"
else
    echo "❌ 数据导入失败"
    exit 1
fi

# 清理临时文件
rm -f $TEMP_SQL

echo "导入完成！" 