#!/bin/bash

# 重置EC2实例密钥对脚本

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

# 检查当前密钥对
check_current_key() {
    log_info "检查当前密钥对..."
    
    CURRENT_KEY=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].KeyName' \
        --output text)
    
    log_info "当前密钥对: $CURRENT_KEY"
}

# 尝试直接修改密钥对（通常不会成功，但可以尝试）
try_modify_key() {
    log_info "尝试修改实例密钥对..."
    
    if aws ec2 modify-instance-attribute \
        --instance-id $INSTANCE_ID \
        --key-name ITWORDS-key \
        --region ap-northeast-1 2>/dev/null; then
        log_success "密钥对修改成功！"
        return 0
    else
        log_warning "无法直接修改密钥对，需要重启实例"
        return 1
    fi
}

# 重启实例
restart_instance() {
    log_info "重启实例..."
    
    aws ec2 reboot-instances --instance-ids $INSTANCE_ID --region ap-northeast-1
    
    log_info "等待实例重启完成..."
    sleep 60
    
    log_success "实例重启完成"
}

# 测试SSH连接
test_ssh() {
    log_info "测试SSH连接..."
    
    for i in {1..5}; do
        log_info "尝试第 $i 次连接..."
        
        if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -i ITWORDS-key.pem ec2-user@18.181.19.159 "echo 'SSH连接成功'" &> /dev/null; then
            log_success "SSH连接测试成功！"
            return 0
        else
            log_warning "第 $i 次连接失败，等待10秒后重试..."
            sleep 10
        fi
    done
    
    log_error "SSH连接失败，请手动检查"
    return 1
}

# 显示手动操作指南
show_manual_guide() {
    log_warning "自动修改密钥对失败，请手动操作："
    echo
    echo "1. 登录AWS控制台："
    echo "   https://console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#Instances:instanceId=$INSTANCE_ID"
    echo
    echo "2. 选择实例 $INSTANCE_ID"
    echo
    echo "3. 操作步骤："
    echo "   - 选择实例 → 操作 → 安全 → 修改密钥对"
    echo "   - 选择密钥对：ITWORDS-key"
    echo "   - 点击'修改密钥对'"
    echo "   - 重启实例：操作 → 实例状态 → 重启实例"
    echo
    echo "4. 重启完成后，运行："
    echo "   ./deploy-to-ec2.sh"
    echo
}

# 主函数
main() {
    log_info "开始重置EC2实例密钥对..."
    
    get_instance_id
    check_current_key
    
    if try_modify_key; then
        restart_instance
        test_ssh
    else
        show_manual_guide
    fi
}

main "$@" 