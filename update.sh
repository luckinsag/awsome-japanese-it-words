#!/bin/bash

# ITWORDS 快速更新脚本
# 增量更新应用

echo "🔄 ITWORDS 快速更新"
echo "=========================================="

# 检查脚本是否存在
if [ ! -f "scripts/deployment/update-deployment.sh" ]; then
    echo "❌ 错误: 更新脚本不存在"
    exit 1
fi

# 检查密钥文件
if [ ! -f "./sag-.pem" ]; then
    echo "❌ 错误: 密钥文件 sag-.pem 不存在"
    echo "请确保密钥文件在当前目录下"
    exit 1
fi

# 设置密钥文件权限
chmod 400 ./sag-.pem

echo "✅ 前置检查完成，开始更新..."
echo "📦 更新方式: 本地构建镜像 → 上传到EC2 → 重启容器"
echo

# 执行更新脚本
./scripts/deployment/update-deployment.sh

echo
echo "🎉 更新完成！"
echo "访问地址: http://57.180.30.179" 