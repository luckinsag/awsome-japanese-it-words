#!/bin/bash

# ITWORDS 一键部署脚本
# 快速部署到AWS EC2

echo "🚀 ITWORDS 一键部署"
echo "=========================================="

# 检查脚本是否存在
if [ ! -f "scripts/deployment/deploy-to-ec2-optimized.sh" ]; then
    echo "❌ 错误: scripts/deployment/deploy-to-ec2-optimized.sh 脚本不存在"
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

echo "✅ 前置检查完成，开始部署..."
echo "📦 部署方式: 本地构建镜像 → 上传到EC2 → 启动容器"
echo

# 执行优化部署脚本
./scripts/deployment/deploy-to-ec2-optimized.sh

echo
echo "🎉 部署完成！"
echo "访问地址: http://57.180.30.179" 