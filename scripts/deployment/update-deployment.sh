#!/bin/bash

# ITWORDS 快速更新部署脚本
# 用于增量更新，只更新变更的部分

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 检查前置条件
check_prerequisites() {
    log_info "检查更新前置条件..."
    
    if [ ! -f "$KEY_FILE" ]; then
        log_error "密钥文件 $KEY_FILE 不存在！"
        exit 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        log_error "docker-compose.yml 文件不存在！"
        exit 1
    fi
    
    log_success "前置条件检查完成"
}

# 测试连接
test_connection() {
    log_info "测试EC2连接..."
    
    if ssh -i "$KEY_FILE" -o ConnectTimeout=10 "$EC2_USER@$EC2_IP" "echo '连接成功'" 2>/dev/null; then
        log_success "EC2连接正常"
    else
        log_error "EC2连接失败"
        exit 1
    fi
}

# 备份当前部署
backup_current_deployment() {
    log_info "备份当前部署..."
    
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
        cd ~/itwords-images
        
        # 备份数据库
        echo "备份数据库..."
        docker exec itwords-mysql mysqldump -u root -proot itwords_db > backup_$(date +%Y%m%d_%H%M%S).sql
        
        # 备份配置文件
        echo "备份配置文件..."
        cp deploy-compose.yml deploy-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
        
        echo "备份完成"
EOF
    
    log_success "备份完成"
}

# 构建更新镜像
build_update_images() {
    log_info "构建更新镜像..."
    
    # 停止本地容器
    docker-compose down 2>/dev/null || true
    
    # 构建镜像
    log_info "构建后端镜像..."
    docker-compose build --no-cache itwords-backend
    
    log_info "构建前端镜像..."
    docker-compose build --no-cache itwords-frontend
    
    # 标记镜像
    docker tag itwords4_itwords-backend:latest itwords-backend:latest
    docker tag itwords4_itwords-frontend:latest itwords-frontend:latest
    
    log_success "镜像构建完成"
}

# 保存并传输镜像
save_and_transfer_images() {
    log_info "保存并传输镜像..."
    
    # 创建临时目录
    mkdir -p update-images
    
    # 保存镜像
    docker save itwords-backend:latest -o update-images/backend.tar
    docker save itwords-frontend:latest -o update-images/frontend.tar
    
    # 压缩
    tar -czf update-images.tar.gz -C update-images .
    
    # 传输到EC2
    scp -i "$KEY_FILE" update-images.tar.gz "$EC2_USER@$EC2_IP:~/itwords-images/"
    
    log_success "镜像传输完成"
}

# 在EC2上更新镜像
update_images_on_ec2() {
    log_info "在EC2上更新镜像..."
    
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
        cd ~/itwords-images
        
        # 解压镜像
        tar -xzf update-images.tar.gz
        
        # 停止应用
        echo "停止应用..."
        docker-compose -f deploy-compose.yml down
        
        # 加载新镜像
        echo "加载新镜像..."
        docker load -i backend.tar
        docker load -i frontend.tar
        
        # 清理旧镜像
        echo "清理旧镜像..."
        docker image prune -f
        
        # 清理临时文件
        rm -f *.tar update-images.tar.gz
        
        echo "镜像更新完成"
EOF
    
    log_success "镜像更新完成"
}

# 重启应用
restart_application() {
    log_info "重启应用..."
    
    ssh -i "$KEY_FILE" "$EC2_USER@$EC2_IP" << 'EOF'
        cd ~/itwords-images
        
        # 启动应用
        echo "启动应用..."
        docker-compose -f deploy-compose.yml up -d
        
        # 等待启动
        echo "等待服务启动..."
        sleep 10
        
        # 检查状态
        echo "检查服务状态..."
        docker-compose -f deploy-compose.yml ps
        
        # 测试API
        echo "测试API..."
        sleep 5
        curl -f http://localhost:8080/api/health || echo "后端API测试失败"
        curl -f http://localhost || echo "前端测试失败"
EOF
    
    log_success "应用重启完成"
}

# 清理本地文件
cleanup() {
    log_info "清理本地文件..."
    rm -rf update-images
    rm -f update-images.tar.gz
    log_success "清理完成"
}

# 显示更新结果
show_update_result() {
    log_info "更新完成！"
    echo
    echo "=========================================="
    echo "           ITWORDS 更新成功！"
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
    echo "   回滚备份: 查看 ~/itwords-images/backup_*.sql"
    echo
    echo "=========================================="
}

# 主函数
main() {
    echo "=========================================="
    echo "      ITWORDS 快速更新部署"
    echo "=========================================="
    echo
    
    check_prerequisites
    test_connection
    backup_current_deployment
    build_update_images
    save_and_transfer_images
    update_images_on_ec2
    restart_application
    show_update_result
    cleanup
    
    log_success "快速更新完成！"
}

# 错误处理
trap 'log_error "更新过程中发生错误，请检查日志"; cleanup; exit 1' ERR

# 执行主函数
main "$@" 