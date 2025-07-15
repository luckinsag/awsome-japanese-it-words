#!/bin/bash

# 合并两个CSV文件，形成完整的Lesson 1-31课程
# wordlist.csv: Lesson 1-9
# japanese_vocabulary_database_cleaned.csv: Lesson 10-31

echo "开始合并CSV文件..."

# 1. 创建新的合并文件，从wordlist.csv开始
echo "复制wordlist.csv作为基础文件..."
cp wordlist.csv complete_wordlist.csv

# 2. 清理wordlist.csv的格式（去掉引号和多余空格）
echo "清理格式..."
sed -i '' 's/"//g' complete_wordlist.csv
sed -i '' 's/       ,/,/g' complete_wordlist.csv
sed -i '' 's/      ,/,/g' complete_wordlist.csv
sed -i '' 's/japanese       ,chinese      ,english      ,category/japanese,chinese,english,category/' complete_wordlist.csv

# 3. 将japanese_vocabulary_database_cleaned.csv的内容添加到合并文件（跳过标题行）
echo "添加Lesson 10-31的单词..."
tail -n +2 japanese_vocabulary_database_cleaned.csv >> complete_wordlist.csv

echo "合并完成！"
echo "新文件：complete_wordlist.csv"
echo "包含课程：Lesson 1-31"

# 验证结果
echo ""
echo "验证结果："
echo "总课程数："
grep -o "Lesson [0-9]\+" complete_wordlist.csv | sort -V | uniq | wc -l
echo "课程范围："
grep -o "Lesson [0-9]\+" complete_wordlist.csv | sort -V | uniq | head -3
echo "..."
grep -o "Lesson [0-9]\+" complete_wordlist.csv | sort -V | uniq | tail -3 