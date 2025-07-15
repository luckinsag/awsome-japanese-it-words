#!/bin/bash

# 将complete_wordlist.csv数据导入到MySQL数据库（最终版）
# 数据库：mysql_itwordslearning
# 表：words
# 列名完全匹配：japanese, chinese, english, category

DB_NAME="mysql_itwordslearning"
TABLE_NAME="words"
CSV_FILE="../../complete_wordlist.csv"
DB_PASSWORD="xcx981211"

echo "开始导入单词数据到MySQL数据库..."
echo "数据库：$DB_NAME"
echo "表名：$TABLE_NAME"
echo "CSV文件：$CSV_FILE"

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

# 测试MySQL连接
echo "测试MySQL连接..."
mysql -u root -p$DB_PASSWORD -e "SELECT 1;" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "错误：无法连接到MySQL数据库，请检查密码是否正确"
    exit 1
fi
echo "✅ MySQL连接成功"

# 检查数据库是否存在
mysql -u root -p$DB_PASSWORD -e "USE $DB_NAME;" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "错误：数据库 $DB_NAME 不存在"
    exit 1
fi
echo "✅ 数据库 $DB_NAME 存在"

# 显示CSV文件信息
echo ""
echo "CSV文件信息："
echo "总行数：$(wc -l < $CSV_FILE)"
echo "列名：$(head -1 $CSV_FILE)"
echo ""

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

# 使用Python脚本处理CSV文件
echo "正在处理CSV文件..."

# 创建临时Python脚本
cat > temp_process_csv.py << 'EOF'
import csv
import sys

try:
    with open('../../complete_wordlist.csv', 'r', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        values = []
        count = 0
        
        for row in reader:
            japanese = row['japanese'].strip().replace("'", "''")
            chinese = row['chinese'].strip().replace("'", "''")
            english = row['english'].strip().replace("'", "''")
            category = row['category'].strip()
            
            # 跳过空行
            if not japanese and not chinese and not english:
                continue
                
            values.append(f"('{japanese}', '{chinese}', '{english}', '{category}')")
            count += 1
        
        # 输出到stderr，不影响SQL生成
        print(f'处理了 {count} 条记录', file=sys.stderr)
        
        # 输出INSERT语句到stdout
        print(f'INSERT INTO words (japanese, chinese, english, category) VALUES')
        for i, value in enumerate(values):
            if i == len(values) - 1:
                print(f'{value};')
            else:
                print(f'{value},')
                
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
EOF

# 运行Python脚本并将输出追加到SQL文件
python3 temp_process_csv.py >> $TEMP_SQL

if [ $? -ne 0 ]; then
    echo "❌ CSV处理失败"
    rm -f temp_process_csv.py
    exit 1
fi

# 清理临时Python脚本
rm -f temp_process_csv.py

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
mysql -u root -p$DB_PASSWORD $DB_NAME < $TEMP_SQL

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 数据导入成功！"
    echo ""
    echo "验证导入结果..."
    mysql -u root -p$DB_PASSWORD $DB_NAME -e "SELECT COUNT(*) as total_words FROM $TABLE_NAME;"
    echo ""
    echo "按课程统计："
    mysql -u root -p$DB_PASSWORD $DB_NAME -e "SELECT category, COUNT(*) as word_count FROM $TABLE_NAME GROUP BY category ORDER BY category;"
    echo ""
    echo "前5条记录："
    mysql -u root -p$DB_PASSWORD $DB_NAME -e "SELECT word_id, japanese, chinese, english, category FROM $TABLE_NAME LIMIT 5;"
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

echo ""
echo "🎉 导入完成！"
echo "数据库：$DB_NAME"
echo "表：$TABLE_NAME"
echo "现在可以在应用程序中使用这些数据了。" 