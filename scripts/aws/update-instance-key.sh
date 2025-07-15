#!/bin/bash

# 更新EC2实例密钥对脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 获取实例ID
get_instance_id() {
    log_info "获取实例ID..."
    
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=ip-address,Values=18.181.19.159" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text)
    
    if [ "$INSTANCE_ID" = "None" ] || [ -z "$INSTANCE_ID" ]; then
        log_error "无法找到IP为 18.181.19.159 的实例"
        exit 1
    fi
    
    log_success "实例ID: $INSTANCE_ID"
}

# 停止实例
stop_instance() {
    log_info "停止实例以更新密钥对..."
    
    aws ec2 stop-instances --instance-ids $INSTANCE_ID --region ap-northeast-1
    
    log_info "等待实例停止..."
    aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID --region ap-northeast-1
    
    log_success "实例已停止"
}

# 更新实例密钥对
update_instance_key() {
    log_info "更新实例密钥对..."
    
    aws ec2 modify-instance-attribute \
        --instance-id $INSTANCE_ID \
        --key-name ITWORDS-key \
        --region ap-northeast-1
    
    log_success "密钥对已更新"
}

# 启动实例
start_instance() {
    log_info "启动实例..."
    
    aws ec2 start-instances --instance-ids $INSTANCE_ID --region ap-northeast-1
    
    log_info "等待实例启动..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region ap-northeast-1
    
    log_success "实例已启动"
}

# 测试SSH连接
test_ssh() {
    log_info "测试SSH连接..."
    
    # 等待实例完全启动
    sleep 30
    
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ITWORDS-key.pem ec2-user@18.181.19.159 "echo 'SSH连接成功'" &> /dev/null; then
        log_success "SSH连接测试成功！"
        return 0
    else
        log_error "SSH连接仍然失败"
        return 1
    fi
}

# 主函数
main() {
    log_info "开始更新EC2实例密钥对..."
    
    get_instance_id
    stop_instance
    update_instance_key
    start_instance
    test_ssh
    
    log_success "密钥对更新完成！"
    echo
    echo "现在可以运行部署脚本："
    echo "  ./deploy-to-ec2.sh"
}

main "$@" 