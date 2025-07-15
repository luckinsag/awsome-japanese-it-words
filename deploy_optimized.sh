#!/bin/bash

echo "🚀 开始部署优化后的ITWORDS应用..."

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否已构建前端
if [ ! -d "itwords_display/dist" ]; then
    echo -e "${RED}❌ 前端未构建，请先运行: cd itwords_display && npm run build${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 前端构建文件已存在${NC}"

# 构建后端
echo -e "${YELLOW}📦 构建后端应用...${NC}"
cd itwords_api
./mvnw clean package -DskipTests
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 后端构建失败${NC}"
    exit 1
fi
cd ..

echo -e "${GREEN}✅ 后端构建完成${NC}"

# 部署到服务器
echo -e "${YELLOW}🚀 部署到服务器...${NC}"

# 创建部署目录结构
ssh -i sag-.pem ec2-user@57.180.30.179 "mkdir -p /home/ec2-user/itwords-deploy-new"

# 复制文件到服务器
echo -e "${YELLOW}📁 复制文件到服务器...${NC}"
scp -i sag-.pem docker-compose.yml ec2-user@57.180.30.179:/home/ec2-user/itwords-deploy-new/
scp -i sag-.pem -r itwords_api ec2-user@57.180.30.179:/home/ec2-user/itwords-deploy-new/
scp -i sag-.pem -r itwords_display ec2-user@57.180.30.179:/home/ec2-user/itwords-deploy-new/

# 在服务器上执行部署
ssh -i sag-.pem ec2-user@57.180.30.179 << 'EOF'
cd /home/ec2-user

echo "🔄 停止旧服务..."
cd itwords-deploy
docker-compose down

echo "🔄 备份旧版本..."
if [ -d "itwords-deploy-backup" ]; then
    rm -rf itwords-deploy-backup
fi
mv itwords-deploy itwords-deploy-backup

echo "🔄 切换到新版本..."
mv itwords-deploy-new itwords-deploy

echo "🚀 启动新服务..."
cd itwords-deploy
docker-compose up -d --build

echo "⏳ 等待服务启动..."
sleep 60

echo "🔍 检查服务状态..."
docker ps

echo "🔍 检查后端健康状态..."
curl -m 10 http://localhost:8080/actuator/health || echo "后端服务检查失败"

echo "🔍 检查前端状态..."
curl -m 10 http://localhost:80/ | head -5 || echo "前端服务检查失败"

echo "✅ 部署完成！"
EOF

echo -e "${GREEN}✅ 部署完成！${NC}"
echo -e "${YELLOW}🌐 网站地址: http://itwords-learning.duckdns.org${NC}"
echo -e "${YELLOW}📊 请等待1-2分钟让服务完全启动${NC}" 