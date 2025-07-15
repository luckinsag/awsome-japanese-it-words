#!/bin/bash

# 合并单词最少的两个课程：Lesson 22 (4个单词) 和 Lesson 21 (6个单词)
# 将 Lesson 22 的单词合并到 Lesson 21，然后将 Lesson 23-32 的编号都减1

echo "开始合并课程..."
echo "将 Lesson 22 的单词合并到 Lesson 21"

# 1. 将 Lesson 22 的所有单词改为 Lesson 21
sed -i '' 's/Lesson 22/Lesson 21/g' japanese_vocabulary_database_cleaned.csv

# 2. 将 Lesson 23-32 的编号都减1 (从高到低处理避免冲突)
for i in {32..23}; do
    new_lesson=$((i - 1))
    sed -i '' "s/Lesson $i/TEMP_$new_lesson/g" japanese_vocabulary_database_cleaned.csv
done

# 3. 将所有TEMP_替换为Lesson
sed -i '' 's/TEMP_/Lesson /g' japanese_vocabulary_database_cleaned.csv

echo "合并完成！"
echo "现在课程编号为：Lesson 10-31"
echo "Lesson 21 现在包含了原来 Lesson 21 和 Lesson 22 的所有单词" 