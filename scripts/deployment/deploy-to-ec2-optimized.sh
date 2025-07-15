#!/bin/bash

# ITWORDS 项目 AWS EC2 优化部署脚本
# 使用镜像上传方式，更稳定快速
# 作者: ITWORDS项目组
# 日期: 2024-12-19

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# EC2 连接配置
EC2_IP="57.180.30.179"
EC2_USER="ec2-user"
KEY_FILE="./sag-.pem"
INSTANCE_ID="i-04319d3d7e427a629"

# 镜像标签
BACKEND_IMAGE="backend:latest"
FRONTEND_IMAGE="frontend:latest"
MYSQL_IMAGE="mysql:8.0"

# 检查必要文件
check_prerequisites() {
    log_info "检查部署前置条件..."
    
    # 检查密钥文件
    if [ ! -f "$KEY_FILE" ]; then
        log_error "密钥文件 $KEY_FILE 不存在！"
        exit 1
    fi
    
    # 检查密钥文件权限
    if [ "$(stat -c %a $KEY_FILE 2>/dev/null || stat -f %Lp $KEY_FILE 2>/dev/null)" != "400" ]; then
        log_warning "设置密钥文件权限为400..."
        chmod 400 "$KEY_FILE"
    fi
    
    # 检查docker-compose.yml
    if [ ! -f "docker-compose.yml" ]; then
        log_error "docker-compose.yml 文件不存在！"
        exit 1
    fi
    
    # 检查项目目录
    if [ ! -d "itwords_api" ] || [ ! -d "itwords_display" ]; then
        log_error "项目目录不完整！请确保 itwords_api 和 itwords_display 目录存在"
        exit 1
    fi
    
    log_success "前置条件检查完成"
}

# 测试EC2连接
test_ec2_connection() {
    log_info "测试EC2实例连接..."
    
    if ssh -i "$KEY_FILE" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo '连接成功'" 2>/dev/null; then
        log_success "EC2连接测试成功"
        return 0
    else
        log_error "无法连接到EC2实例 $EC2_IP"
        log_info "请检查："
        log_info "1. 实例是否正在运行"
        log_info "2. 安全组是否开放22端口"
        log_info "3. 密钥文件是否正确"
        return 1
    fi
}

# 在EC2上安装Docker
install_docker_on_ec2() {
    log_info "在EC2实例上安装Docker..."
    
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
        # 检测操作系统
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$NAME
        else
            OS=$(uname -s)
        fi
        
        echo "检测到操作系统: $OS"
        
        # 检查Docker是否已安装
        if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
            echo "Docker已安装，跳过安装步骤"
            docker --version
            docker-compose --version
            exit 0
        fi
        
        # 安装Docker
        if [[ "$OS" == *"Amazon Linux"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"RHEL"* ]]; then
            echo "使用yum安装Docker..."
            sudo yum update -y
            sudo yum install -y docker
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
        elif [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
            echo "使用apt安装Docker..."
            sudo apt update -y
            sudo apt install -y docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
        else
            echo "不支持的操作系统: $OS"
            exit 1
        fi
        
        # 安装docker-compose
        echo "安装docker-compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        # 验证安装
        docker --version
        docker-compose --version
        
        # 重新加载用户组（避免需要重新登录）
        newgrp docker
EOF
    
    log_success "Docker安装完成"
}

# 本地构建镜像
build_images_locally() {
    log_info "在本地构建Docker镜像..."
    
    # 停止本地容器
    log_info "停止本地容器..."
    docker-compose down 2>/dev/null || true
    
    # 构建镜像 - 指定平台为linux/amd64以兼容EC2
    log_info "构建后端镜像..."
    DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose build --no-cache backend
    
    log_info "构建前端镜像..."
    DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose build --no-cache frontend
    
    # 标记镜像
    log_info "标记镜像..."
    docker tag itwords4-backend:latest $BACKEND_IMAGE
    docker tag itwords4-frontend:latest $FRONTEND_IMAGE
    
    log_success "镜像构建完成"
}

# 保存镜像为tar文件
save_images() {
    log_info "保存镜像为tar文件..."
    
    # 创建临时目录
    mkdir -p deploy-images
    
    # 保存镜像
    log_info "保存后端镜像..."
    docker save $BACKEND_IMAGE -o deploy-images/backend.tar
    
    log_info "保存前端镜像..."
    docker save $FRONTEND_IMAGE -o deploy-images/frontend.tar
    
    # 压缩镜像文件
    log_info "压缩镜像文件..."
    tar -czf deploy-images.tar.gz -C deploy-images .
    
    log_success "镜像保存完成"
}

# 传输镜像到EC2
transfer_images_to_ec2() {
    log_info "传输镜像到EC2实例..."
    
    # 创建远程目录
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" "mkdir -p ~/itwords-images"
    
    # 传输镜像文件
    log_info "传输镜像文件..."
    scp -i "$KEY_FILE" deploy-images.tar.gz "$EC2_USER@$EC2_IP:~/itwords-images/"
    
    log_success "镜像传输完成"
}

# 在EC2上加载镜像
load_images_on_ec2() {
    log_info "在EC2上加载镜像..."
    
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
        cd ~/itwords-images
        
        # 解压镜像文件
        echo "解压镜像文件..."
        tar -xzf deploy-images.tar.gz
        
        # 加载镜像
        echo "加载后端镜像..."
        docker load -i backend.tar
        
        echo "加载前端镜像..."
        docker load -i frontend.tar
        
        # 验证镜像
        echo "验证镜像..."
        docker images | grep itwords
        
        # 清理临时文件
        rm -f *.tar
EOF
    
    log_success "镜像加载完成"
}

# 准备部署配置
prepare_deployment_config() {
    log_info "准备部署配置..."
    
    # 创建优化的docker-compose.yml
    cat > deploy-compose.yml << 'EOF'
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
      - ./scripts/data-processing/init.sql:/docker-entrypoint-initdb.d/init.sql
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
    
    # 创建数据库初始化脚本
    cat > init-db.sh << 'EOF'
#!/bin/bash
# 数据库初始化脚本
echo "等待MySQL启动..."
sleep 30

# 检查数据库是否已初始化
echo "检查数据库状态..."
if docker exec itwords-mysql mysql -u root -pxcx981211 mysql_itwordslearning -e "SELECT COUNT(*) FROM words;" 2>/dev/null | grep -q "[0-9]"; then
    echo "数据库已初始化，跳过数据导入"
else
    echo "数据库未初始化，开始导入数据..."
    
    # 导入单词数据（如果CSV文件存在且格式匹配）
    if [ -f "complete_wordlist.csv" ]; then
        echo "导入单词数据..."
        # 检查CSV文件格式，根据实际格式调整导入语句
        docker exec itwords-mysql mysql -u root -pxcx981211 mysql_itwordslearning -e "
            LOAD DATA INFILE '/var/lib/mysql-files/complete_wordlist.csv' 
            INTO TABLE words 
            FIELDS TERMINATED BY ',' 
            ENCLOSED BY '\"' 
            LINES TERMINATED BY '\n' 
            IGNORE 1 LINES 
            (japanese, chinese, english, category);
        " 2>/dev/null || echo "单词数据导入失败或已存在"
        echo "单词数据导入完成"
    else
        echo "complete_wordlist.csv 不存在，跳过数据导入"
    fi
fi

# 创建测试用户（使用项目实际的用户表结构）
echo "创建测试用户..."
docker exec itwords-mysql mysql -u root -pxcx981211 mysql_itwordslearning -e "
    INSERT INTO users (username, password, japanese, chinese, category) VALUES
    ('testuser', '\$2a\$10\$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', 'テストユーザー', '测试用户', 'student'),
    ('admin', '\$2a\$10\$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', '管理者', '管理员', 'admin'),
    ('student', '\$2a\$10\$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVEFDa', '学生', '学生', 'student')
    ON DUPLICATE KEY UPDATE japanese = VALUES(japanese), chinese = VALUES(chinese), category = VALUES(category);
" 2>/dev/null || echo "测试用户创建失败或已存在"

echo "数据库初始化完成"
EOF
    
    chmod +x init-db.sh
    
    log_success "部署配置准备完成"
}

# 传输部署配置
transfer_deployment_config() {
    log_info "传输部署配置到EC2..."
    
    # 传输配置文件
    scp -i "$KEY_FILE" deploy-compose.yml "$EC2_USER@$EC2_IP:~/itwords-images/"
    scp -i "$KEY_FILE" init-db.sh "$EC2_USER@$EC2_IP:~/itwords-images/"
    scp -i "$KEY_FILE" scripts/data-processing/init.sql "$EC2_USER@$EC2_IP:~/itwords-images/" 2>/dev/null || log_warning "init.sql 不存在，跳过"
    scp -i "$KEY_FILE" complete_wordlist.csv "$EC2_USER@$EC2_IP:~/itwords-images/" 2>/dev/null || log_warning "complete_wordlist.csv 不存在，跳过"
    
    log_success "部署配置传输完成"
}

# 在EC2上启动应用
start_application_on_ec2() {
    log_info "在EC2上启动应用..."
    
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
        cd ~/itwords-images
        
        # 停止并清理现有容器
        echo "清理现有容器..."
        docker-compose -f deploy-compose.yml down -v 2>/dev/null || true
        docker system prune -f
        
        # 启动应用
        echo "启动应用..."
        docker-compose -f deploy-compose.yml up -d
        
        # 等待服务启动
        echo "等待服务启动..."
        sleep 15
        
        # 检查容器状态
        echo "检查容器状态..."
        docker-compose -f deploy-compose.yml ps
        
        # 运行数据库初始化脚本
        echo "初始化数据库..."
        ./init-db.sh
        
        # 测试API
        echo "测试API连接..."
        sleep 5
        curl -f http://localhost:8080/api/health || echo "后端API测试失败"
        curl -f http://localhost || echo "前端测试失败"
EOF
    
    log_success "应用启动完成"
}

# 配置防火墙
configure_firewall() {
    log_info "配置防火墙..."
    
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
        # 配置本地防火墙
        if command -v ufw &> /dev/null; then
            sudo ufw allow 80/tcp
            sudo ufw allow 8080/tcp
            sudo ufw allow 22/tcp
            sudo ufw --force enable
        elif command -v firewall-cmd &> /dev/null; then
            sudo firewall-cmd --permanent --add-port=80/tcp
            sudo firewall-cmd --permanent --add-port=8080/tcp
            sudo firewall-cmd --permanent --add-port=22/tcp
            sudo firewall-cmd --reload
        fi
        
        echo "防火墙配置完成"
EOF
    
    log_success "防火墙配置完成"
}

# 显示部署结果
show_deployment_result() {
    log_info "部署完成！"
    echo
    echo "=========================================="
    echo "           ITWORDS 部署成功！"
    echo "=========================================="
    echo
    echo "🌐 应用访问地址："
    echo "   前端应用: http://$EC2_IP"
    echo "   后端API:  http://$EC2_IP:8080"
    echo "   健康检查: http://$EC2_IP:8080/api/health"
    echo
    echo "🔑 测试账户："
    echo "   用户名: testuser, admin, student"
    echo "   密码: password"
    echo
    echo "📊 容器状态："
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" "cd ~/itwords-images && docker-compose -f deploy-compose.yml ps"
    echo
    echo "📝 日志查看："
    echo "   docker-compose -f deploy-compose.yml logs -f"
    echo
    echo "🛠️  常用命令："
    echo "   SSH连接: ssh -i $KEY_FILE $EC2_USER@$EC2_IP"
    echo "   重启服务: docker-compose -f deploy-compose.yml restart"
    echo "   查看日志: docker-compose -f deploy-compose.yml logs"
    echo "   停止服务: docker-compose -f deploy-compose.yml down"
    echo
    echo "=========================================="
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    rm -rf deploy-images
    rm -f deploy-images.tar.gz
    rm -f deploy-compose.yml
    rm -f init-db.sh
    log_success "清理完成"
}

# 主函数
main() {
    echo "=========================================="
    echo "      ITWORDS AWS EC2 优化部署"
    echo "=========================================="
    echo
    
    # 执行部署步骤
    check_prerequisites
    test_ec2_connection
    install_docker_on_ec2
    build_images_locally
    save_images
    transfer_images_to_ec2
    load_images_on_ec2
    prepare_deployment_config
    transfer_deployment_config
    start_application_on_ec2
    configure_firewall
    show_deployment_result
    cleanup
    
    log_success "优化部署流程完成！"
}

# 错误处理
trap 'log_error "部署过程中发生错误，请检查日志"; cleanup; exit 1' ERR

# 执行主函数
main "$@" 