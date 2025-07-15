# ITWORDS 部署脚本使用指南

## 📋 脚本概览

本项目提供了多种部署脚本，满足不同场景的需求：

| 脚本 | 用途 | 适用场景 | 推荐度 |
|------|------|----------|--------|
| `check-deployment.sh` | 部署前检查 | 验证环境 | ⭐⭐⭐⭐⭐ |
| `quick-deploy-optimized.sh` | 优化快速部署 | 首次部署 | ⭐⭐⭐⭐⭐ |
| `deploy-to-ec2-optimized.sh` | 完整优化部署 | 生产部署 | ⭐⭐⭐⭐⭐ |
| `update-deployment.sh` | 快速更新 | 增量更新 | ⭐⭐⭐⭐⭐ |
| `quick-deploy.sh` | 原始快速部署 | 开发测试 | ⭐⭐⭐ |
| `deploy-to-ec2.sh` | 原始完整部署 | 开发测试 | ⭐⭐⭐ |

## 🚀 推荐部署流程

### 1. 首次部署（推荐）

```bash
# 1. 检查环境
./check-deployment.sh

# 2. 执行优化部署
./quick-deploy-optimized.sh
```

### 2. 生产环境部署

```bash
# 1. 检查环境
./check-deployment.sh

# 2. 执行完整优化部署
./deploy-to-ec2-optimized.sh
```

### 3. 快速更新

```bash
# 执行快速更新
./update-deployment.sh
```

## 📝 详细使用说明

### 环境检查脚本

**用途**: 验证所有部署前置条件

```bash
./check-deployment.sh
```

**检查项目**:
- ✅ 密钥文件存在性和权限
- ✅ 项目目录完整性
- ✅ Docker配置文件
- ✅ 数据文件
- ✅ 部署脚本
- ✅ EC2连接
- ✅ AWS CLI配置
- ✅ EC2实例状态
- ✅ 本地Docker环境
- ✅ 网络连接

### 优化快速部署脚本

**用途**: 一键完成优化部署

```bash
./quick-deploy-optimized.sh
```

**特点**:
- 🚀 本地构建镜像
- 📦 镜像文件传输
- ⚡ 快速部署
- 🛡️ 高稳定性

### 完整优化部署脚本

**用途**: 完整的生产环境部署

```bash
./deploy-to-ec2-optimized.sh
```

**特点**:
- 🔧 完整的Docker环境安装
- 📦 镜像构建和传输
- 🗄️ 数据库初始化
- 🔒 防火墙配置
- 📊 详细的状态检查

### 快速更新脚本

**用途**: 增量更新应用

```bash
./update-deployment.sh
```

**特点**:
- 💾 自动备份当前部署
- 🔄 只更新变更的镜像
- ⚡ 快速重启
- 🔍 状态验证

## 🎯 使用场景

### 开发环境
```bash
# 快速部署用于开发测试
./quick-deploy.sh
```

### 生产环境
```bash
# 完整的生产环境部署
./deploy-to-ec2-optimized.sh
```

### 日常更新
```bash
# 快速更新应用
./update-deployment.sh
```

### 故障排查
```bash
# 检查环境状态
./check-deployment.sh
```

## 🔧 高级用法

### 自定义部署

1. **修改配置**
   ```bash
   # 编辑脚本中的配置
   vim deploy-to-ec2-optimized.sh
   
   # 修改EC2 IP地址
   EC2_IP="your-ec2-ip"
   ```

2. **自定义镜像标签**
   ```bash
   # 修改镜像标签
   BACKEND_IMAGE="your-backend:latest"
   FRONTEND_IMAGE="your-frontend:latest"
   ```

3. **添加环境变量**
   ```bash
   # 在脚本中添加环境变量
   export CUSTOM_VAR="value"
   ```

### 批量部署

```bash
# 创建批量部署脚本
cat > batch-deploy.sh << 'EOF'
#!/bin/bash
# 批量部署到多个EC2实例

INSTANCES=(
    "57.180.30.179"
    "your-other-ec2-ip"
)

for IP in "${INSTANCES[@]}"; do
    echo "部署到 $IP"
    EC2_IP=$IP ./deploy-to-ec2-optimized.sh
done
EOF

chmod +x batch-deploy.sh
```

### 自动化部署

```bash
# 创建CI/CD脚本
cat > ci-deploy.sh << 'EOF'
#!/bin/bash
# CI/CD自动化部署

# 检查代码变更
if git diff --quiet HEAD~1 HEAD; then
    echo "没有代码变更，跳过部署"
    exit 0
fi

# 执行部署
./update-deployment.sh

# 发送通知
curl -X POST "your-webhook-url" \
     -H "Content-Type: application/json" \
     -d '{"text":"部署完成"}'
EOF
```

## 🛠️ 故障排除

### 常见问题

1. **密钥文件权限错误**
   ```bash
   chmod 400 sag-.pem
   ```

2. **EC2连接失败**
   ```bash
   # 检查实例状态
   aws ec2 describe-instances --instance-ids i-04319d3d7e427a629
   
   # 检查安全组
   aws ec2 describe-security-groups --group-ids [安全组ID]
   ```

3. **Docker构建失败**
   ```bash
   # 清理Docker缓存
   docker system prune -a
   
   # 重新构建
   docker-compose build --no-cache
   ```

4. **镜像传输超时**
   ```bash
   # 检查网络连接
   ping 57.180.30.179
   
   # 使用rsync替代scp
   rsync -avz -e "ssh -i sag-.pem" deploy-images.tar.gz ec2-user@57.180.30.179:~/itwords-images/
   ```

### 日志查看

```bash
# 查看部署日志
./deploy-to-ec2-optimized.sh 2>&1 | tee deploy.log

# 查看EC2上的容器日志
ssh -i sag-.pem ec2-user@57.180.30.179 "cd ~/itwords-images && docker-compose -f deploy-compose.yml logs -f"
```

### 回滚操作

```bash
# SSH到EC2
ssh -i sag-.pem ec2-user@57.180.30.179

# 查看备份
cd ~/itwords-images
ls -la backup_*.sql

# 回滚数据库
docker exec -i itwords-mysql mysql -u root -proot itwords_db < backup_20241219_143022.sql

# 重启服务
docker-compose -f deploy-compose.yml restart
```

## 📊 性能监控

### 部署性能指标

```bash
# 记录部署时间
time ./deploy-to-ec2-optimized.sh

# 监控资源使用
ssh -i sag-.pem ec2-user@57.180.30.179 "docker stats --no-stream"
```

### 应用性能监控

```bash
# 检查API响应时间
curl -w "@curl-format.txt" -o /dev/null -s http://57.180.30.179:8080/api/health

# 监控容器状态
ssh -i sag-.pem ec2-user@57.180.30.179 "watch -n 1 'docker-compose -f deploy-compose.yml ps'"
```

## 🔒 安全建议

1. **密钥管理**
   - 定期轮换EC2密钥对
   - 使用SSH密钥而不是密码
   - 限制密钥文件权限

2. **网络安全**
   - 配置安全组规则
   - 使用VPC和私有子网
   - 启用WAF和DDoS防护

3. **应用安全**
   - 定期更新Docker镜像
   - 使用强密码策略
   - 启用HTTPS

4. **监控告警**
   - 配置CloudWatch监控
   - 设置异常告警
   - 定期检查日志

## 📞 技术支持

如遇到部署问题，请按以下步骤排查：

1. **查看日志**: 检查详细的错误日志
2. **验证环境**: 运行环境检查脚本
3. **测试连接**: 确认网络和SSH连接
4. **检查资源**: 验证EC2实例资源使用
5. **权限问题**: 确认文件和用户权限

---

**最后更新**: 2024-12-19  
**版本**: v2.0  
**维护者**: ITWORDS项目组 