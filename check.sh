#!/bin/bash

# ITWORDS 环境检查脚本
# 验证部署前置条件

echo "🔍 ITWORDS 环境检查"
echo "=========================================="

# 检查脚本是否存在
if [ ! -f "scripts/utilities/check-deployment.sh" ]; then
    echo "❌ 错误: 检查脚本不存在"
    exit 1
fi

# 执行检查脚本
./scripts/utilities/check-deployment.sh

echo
echo "📋 检查完成！" 