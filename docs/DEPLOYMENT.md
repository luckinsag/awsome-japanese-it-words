# ITWORDS 项目 AWS EC2 部署指南

## 📋 部署概述

本项目提供了完整的自动化部署脚本，可以将ITWORDS应用一键部署到AWS EC2实例上。

## 🎯 部署目标

- ✅ 自动连接AWS EC2实例
- ✅ 自动安装Docker和docker-compose
- ✅ 自动构建和部署应用容器
- ✅ 自动配置数据库和测试数据
- ✅ 自动配置防火墙和安全组
- ✅ 提供完整的访问信息

## 🚀 快速部署

### 方法一：一键部署（推荐）

```bash
# 执行快速部署脚本
./quick-deploy.sh
```

### 方法二：详细部署

```bash
# 执行完整部署脚本
./deploy-to-ec2.sh
```

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| `deploy-to-ec2.sh` | 完整的自动化部署脚本 |
| `quick-deploy.sh` | 快速部署脚本（推荐使用） |
| `docker-compose.yml` | Docker容器编排配置 |
| `sag-.pem` | AWS EC2密钥文件 |

## 🔧 前置条件

### 1. 本地环境要求
- macOS/Linux系统
- 已安装SSH客户端
- 项目文件完整（itwords_api, itwords_display目录）

### 2. AWS EC2实例要求
- 实例ID: `i-04319d3d7e427a629`
- 公网IP: `57.180.30.179`
- 操作系统: Amazon Linux 2 或 Ubuntu
- 安全组: 开放22(SSH), 80(HTTP), 8080(应用)端口

### 3. 密钥文件
- 文件名: `sag-.pem`
- 位置: 项目根目录
- 权限: 400 (仅所有者可读)

## 📋 部署步骤详解

### 1. 前置检查
- ✅ 检查密钥文件存在性和权限
- ✅ 检查项目目录完整性
- ✅ 检查docker-compose.yml文件

### 2. EC2连接测试
- ✅ 测试SSH连接到EC2实例
- ✅ 验证网络连通性

### 3. Docker环境安装
- ✅ 自动检测操作系统类型
- ✅ 安装Docker和docker-compose
- ✅ 配置用户权限和系统服务

### 4. 文件传输
- ✅ 创建临时部署目录
- ✅ 复制项目文件到EC2
- ✅ 传输数据库初始化脚本

### 5. 应用部署
- ✅ 清理现有容器
- ✅ 构建Docker镜像
- ✅ 启动所有服务容器
- ✅ 初始化数据库和测试数据

### 6. 防火墙配置
- ✅ 配置本地防火墙规则
- ✅ 开放必要端口

## 🌐 部署结果

### 访问地址
- **前端应用**: http://57.180.30.179
- **后端API**: http://57.180.30.179:8080
- **健康检查**: http://57.180.30.179:8080/api/health

### 测试账户
| 用户名 | 密码 | 角色 |
|--------|------|------|
| testuser | password | 普通用户 |
| admin | password | 管理员 |
| student | password | 学生用户 |

## 🛠️ 管理命令

### SSH连接到EC2
```bash
ssh -i sag-.pem ec2-user@57.180.30.179
```

### 容器管理
```bash
# 进入部署目录
cd ~/itwords-deploy

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 重新构建
docker-compose build --no-cache
```

### 数据库管理
```bash
# 连接MySQL
docker exec -it itwords-mysql mysql -u root -proot itwords_db

# 查看表结构
SHOW TABLES;

# 查看单词数据
SELECT COUNT(*) FROM words;

# 查看用户数据
SELECT username, email, role FROM users;
```

## 🔍 故障排除

### 常见问题

#### 1. SSH连接失败
```bash
# 检查密钥文件权限
chmod 400 sag-.pem

# 检查实例状态
aws ec2 describe-instances --instance-ids i-04319d3d7e427a629

# 检查安全组
aws ec2 describe-security-groups --group-ids [安全组ID]
```

#### 2. Docker安装失败
```bash
# 手动安装Docker
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

#### 3. 容器启动失败
```bash
# 查看详细日志
docker-compose logs

# 检查端口占用
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :8080

# 重新构建镜像
docker-compose build --no-cache
```

#### 4. 数据库连接失败
```bash
# 检查MySQL容器状态
docker ps | grep mysql

# 查看MySQL日志
docker logs itwords-mysql

# 手动初始化数据库
./init-db.sh
```

### 日志查看
```bash
# 查看所有容器日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f itwords-backend
docker-compose logs -f itwords-frontend
docker-compose logs -f itwords-mysql
```

## 📊 监控和维护

### 系统监控
```bash
# 查看系统资源使用
htop
df -h
free -h

# 查看Docker资源使用
docker stats
```

### 备份策略
```bash
# 备份数据库
docker exec itwords-mysql mysqldump -u root -proot itwords_db > backup.sql

# 备份应用数据
tar -czf app-backup.tar.gz ~/itwords-deploy
```

### 更新部署
```bash
# 停止现有服务
docker-compose down

# 拉取最新代码
git pull

# 重新部署
./deploy-to-ec2.sh
```

## 🔒 安全建议

1. **密钥管理**
   - 定期轮换EC2密钥对
   - 不要将密钥文件提交到版本控制
   - 备份密钥文件到安全位置

2. **网络安全**
   - 限制安全组入站规则
   - 使用VPC和私有子网
   - 配置WAF和DDoS防护

3. **应用安全**
   - 定期更新Docker镜像
   - 使用强密码策略
   - 启用HTTPS

4. **监控告警**
   - 配置CloudWatch监控
   - 设置异常告警
   - 定期检查日志

## 📞 技术支持

如遇到部署问题，请检查：

1. **日志文件**: 查看详细的错误日志
2. **网络连接**: 确认EC2实例网络正常
3. **资源限制**: 检查实例类型和资源使用
4. **权限问题**: 确认用户和文件权限正确

---

**最后更新**: 2024-12-19  
**版本**: v1.0  
**维护者**: ITWORDS项目组 