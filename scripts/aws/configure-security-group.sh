#!/bin/bash

# 配置EC2安全组脚本

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取实例的安全组ID
get_security_group() {
    log_info "获取实例的安全组信息..."
    
    # 通过IP地址查找实例
    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=ip-address,Values=18.181.19.159" \
        --query 'Reservations[0].Instances[0].InstanceId' \
        --output text)
    
    if [ "$INSTANCE_ID" = "None" ] || [ -z "$INSTANCE_ID" ]; then
        log_error "无法找到IP为 18.181.19.159 的实例"
        exit 1
    fi
    
    log_success "找到实例: $INSTANCE_ID"
    
    # 获取安全组ID
    SECURITY_GROUP_ID=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
        --output text)
    
    log_success "安全组ID: $SECURITY_GROUP_ID"
}

# 配置安全组规则
configure_security_group() {
    log_info "配置安全组规则..."
    
    # 开放SSH端口 (22) - 可能已存在，忽略错误
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 22 \
        --cidr 0.0.0.0/0 \
        --region ap-northeast-1 2>/dev/null || log_info "SSH端口 (22) 已存在"
    
    log_success "SSH端口 (22) 已配置"
    
    # 开放HTTP端口 (80)
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 80 \
        --cidr 0.0.0.0/0 \
        --region ap-northeast-1 2>/dev/null || log_info "HTTP端口 (80) 已存在"
    
    log_success "HTTP端口 (80) 已配置"
    
    # 开放HTTPS端口 (443)
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 443 \
        --cidr 0.0.0.0/0 \
        --region ap-northeast-1 2>/dev/null || log_info "HTTPS端口 (443) 已存在"
    
    log_success "HTTPS端口 (443) 已配置"
    
    # 开放后端API端口 (8080)
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 8080 \
        --cidr 0.0.0.0/0 \
        --region ap-northeast-1 2>/dev/null || log_info "后端API端口 (8080) 已存在"
    
    log_success "后端API端口 (8080) 已配置"
    
    # 开放数据库端口 (3306) - 仅用于测试，生产环境建议限制IP
    aws ec2 authorize-security-group-ingress \
        --group-id $SECURITY_GROUP_ID \
        --protocol tcp \
        --port 3306 \
        --cidr 0.0.0.0/0 \
        --region ap-northeast-1 2>/dev/null || log_info "数据库端口 (3306) 已存在"
    
    log_success "数据库端口 (3306) 已配置"
}

# 测试SSH连接
test_ssh() {
    log_info "测试SSH连接..."
    
    # 等待几秒钟让安全组规则生效
    sleep 10
    
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
    log_info "开始配置EC2安全组..."
    
    get_security_group
    configure_security_group
    test_ssh
    
    log_success "安全组配置完成！"
    echo
    echo "现在可以运行部署脚本："
    echo "  ./deploy-to-ec2.sh"
}

main "$@" 