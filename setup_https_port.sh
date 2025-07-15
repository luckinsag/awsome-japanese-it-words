#!/bin/bash

# 开放HTTPS端口(443)的脚本

echo "🔧 开放HTTPS端口(443)..."

# 方法1: 使用AWS CLI (如果已配置)
echo "尝试使用AWS CLI开放端口443..."
aws ec2 authorize-security-group-ingress \
    --group-id sg-0da63733e1b03dd37 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ 通过AWS CLI成功开放端口443"
else
    echo "⚠️  AWS CLI方法失败，请手动开放端口443"
    echo ""
    echo "📋 手动开放端口443的步骤："
    echo "1. 访问AWS控制台: https://console.aws.amazon.com/ec2/"
    echo "2. 进入 Security Groups"
    echo "3. 找到安全组: sg-0da63733e1b03dd37"
    echo "4. 点击 'Edit inbound rules'"
    echo "5. 添加新规则："
    echo "   - Type: HTTPS"
    echo "   - Protocol: TCP"
    echo "   - Port Range: 443"
    echo "   - Source: 0.0.0.0/0"
    echo "6. 点击 'Save rules'"
    echo ""
    echo "或者添加自定义TCP规则："
    echo "   - Type: Custom TCP"
    echo "   - Protocol: TCP"
    echo "   - Port Range: 443"
    echo "   - Source: 0.0.0.0/0"
fi

echo ""
echo "🔍 验证端口开放状态..."
sleep 5

# 测试端口连通性
if timeout 5 bash -c "</dev/tcp/57.180.30.179/443" 2>/dev/null; then
    echo "✅ 端口443已开放"
else
    echo "❌ 端口443未开放或无法连接"
    echo "请确保在AWS控制台中正确配置了安全组规则"
fi

echo ""
echo "📝 当前开放的端口："
ssh -i ./sag-.pem -o StrictHostKeyChecking=no ec2-user@57.180.30.179 "sudo netstat -tlnp | grep ':443\|:80\|:8080' | sort" 