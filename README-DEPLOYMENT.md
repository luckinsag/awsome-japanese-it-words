# ITWORDS 容器化部署方案

## 🚀 快速开始

### 一键部署（推荐）

```bash
# 克隆项目后，直接运行快速启动脚本
./scripts/deployment/quick-start.sh
```

### 手动部署

```bash
# 本地Docker部署
./scripts/deployment/docker-deploy.sh

# AWS EC2云部署
./scripts/deployment/aws-deploy.sh
```

## 📋 部署架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx (80)    │    │  Spring Boot    │    │   MySQL 8.0     │
│   (前端代理)     │◄──►│   (后端API)     │◄──►│   (数据库)      │
│   Port: 80      │    │   Port: 8080    │    │   Port: 3306    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🐳 Docker容器

| 服务 | 镜像 | 端口 | 说明 |
|------|------|------|------|
| frontend | nginx:alpine | 80 | Vue.js前端 + Nginx代理 |
| backend | openjdk:17-jre-slim | 8080 | Spring Boot后端API |
| mysql | mysql:8.0 | 3306 | MySQL数据库 |

## 💾 数据持久化

- **MySQL数据**: `mysql_data` 卷
- **后端日志**: `backend_logs` 卷
- **自动备份**: 支持数据库备份脚本

## ☁️ AWS免费套餐

- **EC2实例**: t2.micro (1vCPU, 1GB RAM)
- **存储**: EBS 30GB
- **流量**: 每月15GB出站
- **时长**: 每月750小时

## 🔧 常用命令

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 重新构建
docker-compose up --build -d
```

## 📖 详细文档

完整部署指南请查看：[DEPLOYMENT.md](./DEPLOYMENT.md)

## 🆘 故障排除

1. **端口冲突**: 检查80, 8080, 3306端口占用
2. **数据库连接**: 确认MySQL容器正常运行
3. **前端访问**: 检查Nginx配置和代理设置
4. **AWS部署**: 确认AWS CLI配置和权限

## 📞 支持

如遇问题，请：
1. 查看详细部署文档
2. 检查Docker和AWS官方文档
3. 查看项目Issues
4. 联系项目维护团队

---

**注意**: 本方案已针对免费套餐优化，适合个人项目和小型应用部署。 