#!/bin/bash

# ITWORDS 部署修复脚本
# 解决架构不匹配和配置问题

echo "🔧 ITWORDS 部署修复脚本"
echo "=========================================="

# 配置
EC2_IP="57.180.30.179"
EC2_USER="ec2-user"
KEY_FILE="./sag-.pem"

# 日志函数
log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[SUCCESS] $1"
}

log_error() {
    echo "[ERROR] $1"
}

log_warning() {
    echo "[WARNING] $1"
}

# 检查密钥文件
if [ ! -f "$KEY_FILE" ]; then
    log_error "密钥文件 $KEY_FILE 不存在"
    exit 1
fi

chmod 400 "$KEY_FILE"

log_info "开始修复部署问题..."

# 1. 停止当前容器
log_info "停止当前容器..."
ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
    cd ~/itwords-images
    docker-compose -f deploy-compose.yml down -v
    docker system prune -f
EOF

# 2. 删除错误的镜像
log_info "删除错误的镜像..."
ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
    docker rmi backend:latest frontend:latest 2>/dev/null || true
    docker rmi itwords4-backend:latest itwords4-frontend:latest 2>/dev/null || true
EOF

# 3. 在本地重新构建正确架构的镜像
log_info "在本地重新构建镜像（linux/amd64架构）..."
docker-compose down 2>/dev/null || true

# 构建后端镜像
log_info "构建后端镜像..."
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose build --no-cache backend
docker tag itwords4-backend:latest backend:latest

# 构建前端镜像
log_info "构建前端镜像..."
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose build --no-cache frontend
docker tag itwords4-frontend:latest frontend:latest

# 4. 保存并传输镜像
log_info "保存镜像..."
mkdir -p fix-images
docker save backend:latest -o fix-images/backend.tar
docker save frontend:latest -o fix-images/frontend.tar
tar -czf fix-images.tar.gz -C fix-images .

log_info "传输镜像到EC2..."
scp -i "$KEY_FILE" fix-images.tar.gz "$EC2_USER@$EC2_IP:~/itwords-images/"

# 5. 在EC2上加载镜像
log_info "在EC2上加载镜像..."
ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
    cd ~/itwords-images
    
    # 解压镜像
    tar -xzf fix-images.tar.gz
    
    # 加载镜像
    docker load -i backend.tar
    docker load -i frontend.tar
    
    # 验证镜像
    docker images | grep -E "(backend|frontend)"
    
    # 清理临时文件
    rm -f *.tar fix-images.tar.gz
EOF

# 6. 创建正确的部署配置
log_info "创建正确的部署配置..."
cat > fix-deploy-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: itwords-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: xcx981211
      MYSQL_DATABASE: mysql_itwordslearning
      MYSQL_USER: itwords_user
      MYSQL_PASSWORD: itwords_password
    ports:
      - "3307:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - itwords-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  backend:
    image: backend:latest
    container_name: itwords-backend
    restart: unless-stopped
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/mysql_itwordslearning?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=Asia/Tokyo&useUnicode=true&characterEncoding=utf8
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: xcx981211
      SERVER_PORT: 8080
    ports:
      - "8080:8080"
    volumes:
      - backend_logs:/app/logs
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - itwords-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend:
    image: frontend:latest
    container_name: itwords-frontend
    restart: unless-stopped
    ports:
      - "80:80"
    depends_on:
      backend:
        condition: service_healthy
    networks:
      - itwords-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

volumes:
  mysql_data:
    driver: local
  backend_logs:
    driver: local

networks:
  itwords-network:
    driver: bridge
EOF

# 传输修复配置
scp -i "$KEY_FILE" fix-deploy-compose.yml "$EC2_USER@$EC2_IP:~/itwords-images/deploy-compose.yml"
scp -i "$KEY_FILE" scripts/data-processing/init.sql "$EC2_USER@$EC2_IP:~/itwords-images/init.sql"

# 7. 启动应用
log_info "启动应用..."
ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
    cd ~/itwords-images
    
    # 启动应用
    docker-compose -f deploy-compose.yml up -d
    
    # 等待服务启动
    echo "等待服务启动..."
    sleep 30
    
    # 检查容器状态
    echo "检查容器状态..."
    docker-compose -f deploy-compose.yml ps
    
    # 检查容器日志
    echo "检查后端日志..."
    docker-compose -f deploy-compose.yml logs backend | tail -20
    
    echo "检查前端日志..."
    docker-compose -f deploy-compose.yml logs frontend | tail -20
    
    # 测试连接
    echo "测试API连接..."
    sleep 10
    curl -f http://localhost:8080/actuator/health || echo "后端API测试失败"
    curl -f http://localhost || echo "前端测试失败"
EOF

# 8. 清理本地文件
log_info "清理本地文件..."
rm -rf fix-images
rm -f fix-images.tar.gz
rm -f fix-deploy-compose.yml

log_success "修复完成！"
echo
echo "=========================================="
echo "           ITWORDS 修复完成！"
echo "=========================================="
echo
echo "🌐 应用访问地址："
echo "   前端应用: http://$EC2_IP"
echo "   后端API:  http://$EC2_IP:8080"
echo
echo "📊 容器状态："
ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" "cd ~/itwords-images && docker-compose -f deploy-compose.yml ps"
echo
echo "🛠️  常用命令："
echo "   查看日志: docker-compose -f deploy-compose.yml logs -f"
echo "   重启服务: docker-compose -f deploy-compose.yml restart"
echo "   SSH连接: ssh -i $KEY_FILE $EC2_USER@$EC2_IP"
echo
echo "==========================================" 