#!/bin/bash

# 重新编号课程，让它们从Lesson 10开始
# 需要从高数字开始替换，避免重复替换

# 先处理高数字的课程
sed -i '' 's/Lesson 31/Lesson 40/g' japanese_vocabulary_database_cleaned.csv
sed -i '' 's/Lesson 30/Lesson 39/g' japanese_vocabulary_database_cleaned.csv
sed -i '' 's/Lesson 29/Lesson 38/g' japanese_vocabulary_database_cleaned.csv

# 然后处理1-20的课程，需要从20开始往下
for i in {20..1}; do
    new_lesson=$((i + 9))
    sed -i '' "s/Lesson $i/Lesson $new_lesson/g" japanese_vocabulary_database_cleaned.csv
done

echo "课程重新编号完成！"
echo "新的课程编号范围：Lesson 10 - Lesson 40" 