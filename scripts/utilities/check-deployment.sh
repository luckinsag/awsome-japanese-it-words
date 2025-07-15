#!/bin/bash

# ITWORDS 部署前检查脚本
# 验证所有部署前置条件

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

# 检查结果
PASS=0
FAIL=0

# 检查函数
check_item() {
    if [ $1 -eq 0 ]; then
        log_success "$2"
        PASS=$((PASS + 1))
    else
        log_error "$2"
        FAIL=$((FAIL + 1))
    fi
}

echo "=========================================="
echo "      ITWORDS 部署前检查"
echo "=========================================="
echo

# 1. 检查密钥文件
log_info "1. 检查密钥文件..."
if [ -f "sag-.pem" ]; then
    PERMS=$(stat -c %a sag-.pem 2>/dev/null || stat -f %Lp sag-.pem 2>/dev/null)
    if [ "$PERMS" = "400" ]; then
        check_item 0 "密钥文件存在且权限正确 (400)"
    else
        log_warning "密钥文件权限不正确，正在修复..."
        chmod 400 sag-.pem
        check_item 0 "密钥文件权限已修复"
    fi
else
    check_item 1 "密钥文件 sag-.pem 不存在"
fi

# 2. 检查项目目录
log_info "2. 检查项目目录..."
if [ -d "itwords_api" ] && [ -d "itwords_display" ]; then
    check_item 0 "项目目录完整 (itwords_api, itwords_display)"
else
    check_item 1 "项目目录不完整"
fi

# 3. 检查docker-compose.yml
log_info "3. 检查Docker配置..."
if [ -f "docker-compose.yml" ]; then
    check_item 0 "docker-compose.yml 存在"
else
    check_item 1 "docker-compose.yml 不存在"
fi

# 4. 检查单词数据文件
log_info "4. 检查数据文件..."
if [ -f "complete_wordlist.csv" ]; then
    check_item 0 "complete_wordlist.csv 存在"
else
    log_warning "complete_wordlist.csv 不存在，将跳过数据导入"
fi

# 5. 检查部署脚本
log_info "5. 检查部署脚本..."
if [ -f "scripts/deployment/deploy-to-ec2-optimized.sh" ] && [ -x "scripts/deployment/deploy-to-ec2-optimized.sh" ]; then
    check_item 0 "deploy-to-ec2-optimized.sh 存在且可执行"
else
    check_item 1 "deploy-to-ec2-optimized.sh 不存在或不可执行"
fi

# 6. 检查SSH连接
log_info "6. 测试EC2连接..."
if ssh -i sag-.pem -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@57.180.30.179 "echo '连接成功'" 2>/dev/null; then
    check_item 0 "EC2 SSH连接正常"
else
    check_item 1 "EC2 SSH连接失败"
fi

# 7. 检查AWS CLI
log_info "7. 检查AWS CLI..."
if command -v aws &> /dev/null; then
    if aws sts get-caller-identity &> /dev/null; then
        check_item 0 "AWS CLI已安装且配置正确"
    else
        check_item 1 "AWS CLI配置错误"
    fi
else
    log_warning "AWS CLI未安装，但不影响部署"
fi

# 8. 检查EC2实例状态
log_info "8. 检查EC2实例状态..."
if command -v aws &> /dev/null; then
    INSTANCE_STATUS=$(aws ec2 describe-instances --instance-ids i-04319d3d7e427a629 --query 'Reservations[0].Instances[0].State.Name' --output text 2>/dev/null || echo "unknown")
    if [ "$INSTANCE_STATUS" = "running" ]; then
        check_item 0 "EC2实例正在运行"
    else
        check_item 1 "EC2实例状态异常: $INSTANCE_STATUS"
    fi
else
    log_warning "无法检查EC2实例状态（AWS CLI未安装）"
fi

# 9. 检查本地Docker环境
log_info "9. 检查本地Docker环境..."
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
    if docker info &> /dev/null; then
        check_item 0 "本地Docker环境正常"
    else
        check_item 1 "本地Docker服务未启动"
    fi
else
    log_warning "本地Docker未安装，但不影响远程部署"
fi

# 10. 检查网络连接
log_info "10. 检查网络连接..."
if ping -c 1 57.180.30.179 &> /dev/null; then
    check_item 0 "网络连接到EC2实例正常"
else
    check_item 1 "无法ping通EC2实例"
fi

echo
echo "=========================================="
echo "              检查结果"
echo "=========================================="
echo "✅ 通过: $PASS"
echo "❌ 失败: $FAIL"
echo

if [ $FAIL -eq 0 ]; then
    log_success "所有检查项目通过！可以开始部署。"
    echo
    echo "🚀 执行部署命令："
    echo "   ./quick-deploy.sh"
    echo "   或"
    echo "   ./deploy-to-ec2.sh"
    echo
else
    log_error "有 $FAIL 个检查项目失败，请修复后重新检查。"
    echo
    echo "🔧 常见修复方法："
    echo "   1. 密钥文件问题: chmod 400 sag-.pem"
    echo "   2. 项目目录问题: 确保 itwords_api 和 itwords_display 目录存在"
    echo "   3. 脚本权限问题: chmod +x deploy-to-ec2.sh"
    echo "   4. EC2连接问题: 检查实例状态和安全组配置"
    echo
fi

echo "==========================================" 