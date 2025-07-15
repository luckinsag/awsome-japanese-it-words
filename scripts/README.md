# Scripts 文件夹说明

本文件夹包含了项目中所有的Shell脚本文件，按功能分类整理。

## 文件夹结构

### 📁 data-processing/
数据处理相关脚本
- `lesson_renumber.sh` - 课程重新编号脚本（初版）
- `lesson_renumber_correct.sh` - 课程重新编号脚本（正确版本）
- `merge_lessons.sh` - 合并课程脚本
- `merge_wordlists.sh` - 合并单词列表脚本
- `import_words_to_mysql_final.sh` - 将CSV数据导入MySQL数据库脚本

### 📁 deployment/
部署相关脚本
- `quick-deploy.sh` - 快速部署脚本
- `deploy-frontend.sh` - 前端部署脚本
- `deploy-backend.sh` - 后端部署脚本

### 📁 utilities/
工具类脚本
- `start-project.sh` - 项目启动脚本

## 使用说明

1. 所有脚本都已设置可执行权限
2. 执行脚本前请确保在项目根目录
3. 数据处理脚本会创建备份文件，请注意保存重要数据

## 注意事项

- JavaScript文件仍保持在原来的位置
- 原始的 `deployment-scripts/` 文件夹仍然存在，包含完整的部署配置
- 建议在执行数据处理脚本前备份重要文件 