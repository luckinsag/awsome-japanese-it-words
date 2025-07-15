#!/bin/bash

# DuckDNS 配置脚本
# 使用方法: ./setup_duckdns.sh YOUR_DOMAIN YOUR_TOKEN

DOMAIN="$1"
TOKEN="$2"
IP="57.180.30.179"

if [ -z "$DOMAIN" ] || [ -z "$TOKEN" ]; then
    echo "使用方法: $0 <域名> <token>"
    echo "例如: $0 itwords-learning YOUR_DUCKDNS_TOKEN"
    echo ""
    echo "步骤："
    echo "1. 访问 https://www.duckdns.org/"
    echo "2. 登录并创建一个域名"
    echo "3. 获取您的token"
    echo "4. 运行: $0 您的域名 您的token"
    exit 1
fi

echo "🌐 设置 DuckDNS 域名..."
echo "域名: ${DOMAIN}.duckdns.org"
echo "IP地址: $IP"

# 更新 DuckDNS 记录
RESPONSE=$(curl -s "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=${IP}")

if [ "$RESPONSE" = "OK" ]; then
    echo "✅ DuckDNS 记录更新成功！"
    echo "您的应用现在可以通过以下域名访问："
    echo "🌐 http://${DOMAIN}.duckdns.org"
    echo "🌐 https://${DOMAIN}.duckdns.org (如果配置了SSL)"
    
    # 测试域名解析
    echo ""
    echo "测试域名解析..."
    sleep 5
    
    if nslookup "${DOMAIN}.duckdns.org" >/dev/null 2>&1; then
        echo "✅ 域名解析成功"
        
        # 测试HTTP访问
        echo "测试HTTP访问..."
        if curl -s -I "http://${DOMAIN}.duckdns.org" | head -1 | grep -q "200\|301\|302"; then
            echo "✅ HTTP访问成功"
        else
            echo "⚠️  HTTP访问可能需要几分钟时间生效"
        fi
    else
        echo "⚠️  域名解析可能需要几分钟时间生效"
    fi
    
    # 创建自动更新脚本
    cat > update_duckdns.sh << EOF
#!/bin/bash
# DuckDNS 自动更新脚本
curl -s "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=${IP}" > /dev/null
EOF
    chmod +x update_duckdns.sh
    
    echo ""
    echo "📝 已创建自动更新脚本: update_duckdns.sh"
    echo "您可以将此脚本添加到crontab中定期更新："
    echo "crontab -e"
    echo "添加行: */5 * * * * $(pwd)/update_duckdns.sh"
    
else
    echo "❌ DuckDNS 记录更新失败"
    echo "响应: $RESPONSE"
    echo "请检查域名和token是否正确"
fi 