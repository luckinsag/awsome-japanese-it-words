#!/bin/bash

# 将complete_wordlist.csv数据导入到MySQL数据库（改进版）
# 数据库：mysql_itwordslearning
# 表：words

DB_NAME="mysql_itwordslearning"
TABLE_NAME="words"
CSV_FILE="../../complete_wordlist.csv"

echo "开始导入单词数据到MySQL数据库..."

# 检查CSV文件是否存在
if [ ! -f "$CSV_FILE" ]; then
    echo "错误：找不到CSV文件 $CSV_FILE"
    echo "当前目录：$(pwd)"
    ls -la ../../*.csv
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

# 使用Python脚本处理CSV文件（更可靠）
python3 -c "
import csv
import sys

try:
    with open('$CSV_FILE', 'r', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        values = []
        for row in reader:
            japanese = row['japanese'].strip().replace(\"'\", \"''\")
            chinese = row['chinese'].strip().replace(\"'\", \"''\")
            english = row['english'].strip().replace(\"'\", \"''\")
            category = row['category'].strip()
            
            values.append(f\"('{japanese}', '{english}', '{chinese}', '{category}', 1)\")
        
        # 输出INSERT语句
        print('INSERT INTO $TABLE_NAME (word, pronunciation, meaning, category, difficulty_level) VALUES')
        for i, value in enumerate(values):
            if i == len(values) - 1:
                print(f'{value};')
            else:
                print(f'{value},')
                
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
" >> $TEMP_SQL

echo ""
echo "生成的SQL文件：$TEMP_SQL"
echo "SQL文件大小：$(wc -l < $TEMP_SQL) 行"

# 询问是否继续执行
echo ""
read -p "是否继续执行MySQL导入？(y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消导入"
    exit 1
fi

echo "执行MySQL导入..."

# 执行SQL文件
mysql -u root -p $DB_NAME < $TEMP_SQL

if [ $? -eq 0 ]; then
    echo "✅ 数据导入成功！"
    echo ""
    echo "验证导入结果..."
    mysql -u root -p $DB_NAME -e "SELECT COUNT(*) as total_words FROM $TABLE_NAME;"
    echo ""
    echo "按课程统计："
    mysql -u root -p $DB_NAME -e "SELECT category, COUNT(*) as word_count FROM $TABLE_NAME GROUP BY category ORDER BY category;"
else
    echo "❌ 数据导入失败"
    exit 1
fi

# 询问是否清理临时文件
echo ""
read -p "是否删除临时SQL文件？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f $TEMP_SQL
    echo "临时文件已删除"
else
    echo "临时文件保留：$TEMP_SQL"
fi

echo "导入完成！" 