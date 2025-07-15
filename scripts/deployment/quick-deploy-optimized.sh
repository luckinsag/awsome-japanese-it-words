#!/bin/bash

# ITWORDS 优化快速部署脚本
# 使用镜像上传方式，一键部署到AWS EC2

echo "🚀 开始ITWORDS优化部署到AWS EC2..."
echo "=========================================="

# 检查脚本是否存在
if [ ! -f "deploy-to-ec2-optimized.sh" ]; then
    echo "❌ 错误: deploy-to-ec2-optimized.sh 脚本不存在"
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

echo "✅ 前置检查完成，开始优化部署..."
echo "📦 部署方式: 本地构建镜像 → 上传到EC2 → 启动容器"
echo

# 执行优化部署脚本
./deploy-to-ec2-optimized.sh

echo
echo "🎉 优化部署完成！"
echo "访问地址: http://57.180.30.179"
echo "优势: 更稳定、更快速、更可靠" 