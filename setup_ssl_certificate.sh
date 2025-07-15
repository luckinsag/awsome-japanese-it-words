#!/bin/bash

# SSL证书设置脚本
# 使用Let's Encrypt为域名设置免费SSL证书

DOMAIN="$1"
EC2_IP="57.180.30.179"
EC2_USER="ec2-user"
KEY_FILE="./sag-.pem"

if [ -z "$DOMAIN" ]; then
    echo "使用方法: $0 <完整域名>"
    echo "例如: $0 itwords-learning.duckdns.org"
    exit 1
fi

echo "🔒 为域名 $DOMAIN 设置SSL证书..."

# 检查密钥文件是否存在
if [ ! -f "$KEY_FILE" ]; then
    echo "❌ 错误: $KEY_FILE 密钥文件不存在"
    exit 1
fi

chmod 400 "$KEY_FILE"

echo "1. 连接到EC2实例..."
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$EC2_USER@$EC2_IP" "echo 'EC2连接成功'" || {
    echo "❌ 无法连接到EC2实例"
    exit 1
}

echo "2. 在EC2上安装Certbot并获取SSL证书..."
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" << EOF
# 安装Certbot
sudo yum update -y
sudo yum install -y certbot python3-certbot-nginx

# 创建临时的nginx配置来验证域名
sudo tee /etc/nginx/conf.d/temp-ssl.conf > /dev/null << 'NGINX_CONFIG'
server {
    listen 80;
    server_name $DOMAIN;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}
NGINX_CONFIG

# 创建web根目录
sudo mkdir -p /var/www/html
sudo chown nginx:nginx /var/www/html

# 重载nginx
sudo systemctl reload nginx

# 获取SSL证书
sudo certbot certonly --webroot -w /var/www/html -d $DOMAIN --email your-email@example.com --agree-tos --no-eff-email

if [ \$? -eq 0 ]; then
    echo "✅ SSL证书获取成功"
    
    # 更新nginx配置以使用SSL
    sudo tee /etc/nginx/conf.d/ssl.conf > /dev/null << 'SSL_CONFIG'
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    
    # SSL配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # 安全头
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    
    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /api/ {
        proxy_pass http://backend:8080/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
SSL_CONFIG
    
    # 删除临时配置
    sudo rm -f /etc/nginx/conf.d/temp-ssl.conf
    
    # 重载nginx
    sudo systemctl reload nginx
    
    # 设置自动续期
    echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
    
    echo "✅ SSL证书配置完成"
    echo "您的应用现在可以通过HTTPS访问: https://$DOMAIN"
    
else
    echo "❌ SSL证书获取失败"
    echo "请确保："
    echo "1. 域名已正确解析到服务器IP"
    echo "2. 端口80和443已开放"
    echo "3. 域名格式正确"
fi
EOF

echo "3. 验证SSL证书..."
sleep 10

if curl -s -I "https://$DOMAIN" | head -1 | grep -q "200\|301\|302"; then
    echo "✅ HTTPS访问成功"
    echo "🎉 您的应用现在可以通过以下地址访问："
    echo "🌐 https://$DOMAIN"
else
    echo "⚠️  HTTPS可能需要几分钟时间生效"
fi 