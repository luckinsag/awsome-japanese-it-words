#!/bin/bash

# 简化的SSL证书设置脚本
DOMAIN="itwords-learning.duckdns.org"
EC2_IP="57.180.30.179"
EC2_USER="ec2-user"
KEY_FILE="./sag-.pem"
EMAIL="xuechenxin@gmail.com"

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

echo "2. 停止前端容器并获取SSL证书..."
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "
# 停止前端容器以释放80端口
docker stop itwords-frontend

# 安装Certbot
sudo yum update -y
sudo yum install -y certbot

# 使用非交互式模式获取SSL证书
sudo certbot certonly --standalone \
    -d $DOMAIN \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --non-interactive

if [ \$? -eq 0 ]; then
    echo '✅ SSL证书获取成功'
    
    # 创建SSL证书目录并复制证书
    sudo mkdir -p /home/ec2-user/ssl
    sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /home/ec2-user/ssl/
    sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /home/ec2-user/ssl/
    sudo chown -R ec2-user:ec2-user /home/ec2-user/ssl
    
    echo '✅ SSL证书已复制到 /home/ec2-user/ssl/'
    
    # 设置自动续期
    echo '0 12 * * * /usr/bin/certbot renew --quiet && docker restart itwords-frontend' | sudo crontab -
    
    echo '✅ SSL证书配置完成'
else
    echo '❌ SSL证书获取失败'
    # 重新启动前端容器
    docker start itwords-frontend
    exit 1
fi
"

if [ $? -eq 0 ]; then
    echo "3. 创建支持SSL的nginx配置..."
    
    # 创建nginx SSL配置文件
    cat > nginx_ssl.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # 日志格式
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    # 基本设置
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # Gzip压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;

    # HTTP重定向到HTTPS
    server {
        listen 80;
        server_name itwords-learning.duckdns.org;
        return 301 https://$server_name$request_uri;
    }

    # HTTPS服务器
    server {
        listen 443 ssl http2;
        server_name itwords-learning.duckdns.org;
        
        # SSL证书配置
        ssl_certificate /etc/ssl/certs/fullchain.pem;
        ssl_certificate_key /etc/ssl/private/privkey.pem;
        
        # SSL配置
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        
        # 安全头
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

        root /usr/share/nginx/html;
        index index.html;

        # 静态资源缓存
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # API代理
        location /api/ {
            proxy_pass http://backend:8080/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }

        # Vue Router history模式支持
        location / {
            try_files $uri $uri/ /index.html;
        }

        # 健康检查
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

    echo "4. 更新Docker Compose配置..."
    
    # 备份原配置
    cp docker-compose.yml docker-compose.yml.backup
    
    # 创建新的docker-compose配置
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  frontend:
    build: ./itwords_display
    container_name: itwords-frontend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx_ssl.conf:/etc/nginx/nginx.conf:ro
      - /home/ec2-user/ssl/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro
      - /home/ec2-user/ssl/privkey.pem:/etc/ssl/private/privkey.pem:ro
    depends_on:
      - backend
    networks:
      - itwords-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend:
    build: ./itwords_api
    container_name: itwords-backend
    ports:
      - "8080:8080"
    depends_on:
      - mysql
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/itwords_db?useSSL=false&serverTimezone=UTC&characterEncoding=utf8
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=Sag200312
    networks:
      - itwords-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  mysql:
    image: mysql:8.0
    container_name: itwords-mysql
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=Sag200312
      - MYSQL_DATABASE=itwords_db
      - MYSQL_CHARACTER_SET_SERVER=utf8mb4
      - MYSQL_COLLATION_SERVER=utf8mb4_unicode_ci
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - itwords-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  mysql_data:

networks:
  itwords-network:
    driver: bridge
EOF

    echo "5. 部署SSL配置..."
    scp -i "$KEY_FILE" -o StrictHostKeyChecking=no nginx_ssl.conf docker-compose.yml "$EC2_USER@$EC2_IP:~/"
    
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "
# 停止当前容器
docker-compose down

# 重新启动容器
docker-compose up -d

# 等待容器启动
sleep 30

# 检查容器状态
docker ps
"

    echo "6. 验证SSL证书..."
    sleep 10
    
    if curl -s -I "https://$DOMAIN" | head -1 | grep -q "200\|301\|302"; then
        echo "✅ HTTPS访问成功"
        echo "🎉 您的应用现在可以通过以下地址访问："
        echo "🌐 https://$DOMAIN"
        echo "🔒 SSL证书已正确配置"
    else
        echo "⚠️  HTTPS可能需要几分钟时间生效"
        echo "请稍后再试访问 https://$DOMAIN"
    fi
    
    # 清理临时文件
    rm -f nginx_ssl.conf
    
else
    echo "❌ SSL证书设置失败"
    exit 1
fi 