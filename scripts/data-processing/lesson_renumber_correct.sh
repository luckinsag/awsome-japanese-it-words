#!/bin/bash

# 重新编号课程，让它们从Lesson 10开始连续编号
# 当前有：1-20, 29-31 (共23个课程)
# 目标：10-32 (连续的23个课程)

# 先处理高数字的课程，避免冲突
sed -i '' 's/Lesson 31/TEMP_32/g' japanese_vocabulary_database_cleaned.csv
sed -i '' 's/Lesson 30/TEMP_31/g' japanese_vocabulary_database_cleaned.csv  
sed -i '' 's/Lesson 29/TEMP_30/g' japanese_vocabulary_database_cleaned.csv

# 处理1-20的课程，从20开始往下
for i in {20..1}; do
    new_lesson=$((i + 9))
    sed -i '' "s/Lesson $i/TEMP_$new_lesson/g" japanese_vocabulary_database_cleaned.csv
done

# 最后将所有TEMP_替换为Lesson 
sed -i '' 's/TEMP_/Lesson /g' japanese_vocabulary_database_cleaned.csv

echo "课程重新编号完成！"
echo "新的课程编号：Lesson 10-32 (连续编号)" 