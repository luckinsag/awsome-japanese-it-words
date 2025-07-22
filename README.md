# ITWORDS 项目

基于Spring Boot + Vue.js的IT词汇学习应用

##  快速开始

### 一键部署到AWS EC2

```bash
# 1. 检查环境
./check.sh

# 2. 一键部署
./deploy.sh

# 3. 快速更新（后续使用）
./update.sh
```

##  项目结构

```
ITWORDS 4/
├── deploy.sh                    #  一键部署脚本
├── update.sh                    #  快速更新脚本
├── check.sh                     #  环境检查脚本
├── sag-.pem                     #  AWS EC2密钥文件
├── docker-compose.yml           #  Docker编排配置
├── complete_wordlist.csv        #  单词数据文件
├── itwords_api/                 #  Spring Boot后端
├── itwords_display/             #  Vue.js前端
├── scripts/                     #  脚本目录
│   ├── deployment/              #  部署相关脚本
│   │   ├── deploy-to-ec2-optimized.sh    # 完整优化部署
│   │   ├── quick-deploy-optimized.sh     # 快速优化部署
│   │   └── update-deployment.sh          # 增量更新
│   ├── utilities/               #  工具脚本
│   │   └── check-deployment.sh  #  环境检查
│   └── aws/                     #  AWS相关脚本
│       ├── configure-security-group.sh   # 安全组配置
│       ├── reset-instance-key.sh         # 重置实例密钥
│       └── update-instance-key.sh        # 更新实例密钥
├── docs/                        # 文档目录
│   ├── DEPLOYMENT.md            # 部署指南
│   ├── DEPLOYMENT-COMPARISON.md # 部署方式对比
│   └── DEPLOYMENT-GUIDE.md      # 使用指南
└── nginx/                       # Nginx配置
```

##  使用指南

### 首次部署

1. **环境检查**
   ```bash
   ./check.sh
   ```

2. **一键部署**
   ```bash
   ./deploy.sh
   ```

3. **访问应用**
   - http://itwords-learning.duckdns.org
     

### 日常更新

```bash
# 快速更新应用
./update.sh
```
### 完整部署（生产环境）

```bash
./scripts/deployment/deploy-to-ec2-optimized.sh
```

### 环境检查

```bash
./scripts/utilities/check-deployment.sh
```

### AWS管理

```bash
# 配置安全组
./scripts/aws/configure-security-group.sh

# 重置实例密钥
./scripts/aws/reset-instance-key.sh

# 更新实例密钥
./scripts/aws/update-instance-key.sh
```


##  技术栈

- **前端**: Vue.js 3 + Vuetify + Vite
- **后端**: Spring Boot 3 + MyBatis + Spring Security
- **数据库**: MySQL 8.0
- **容器化**: Docker + Docker Compose
- **云平台**: AWS EC2

##  文档

- [部署指南](docs/DEPLOYMENT.md) - 详细的部署说明
- [使用指南](docs/DEPLOYMENT-GUIDE.md) - 完整的使用文档

##  安全说明

- 密钥文件 `sag-.pem` 权限必须设置为400
- 不要将密钥文件提交到版本控制
- 定期轮换AWS密钥对
- 生产环境建议启用HTTPS

##  技术支持

如遇到问题，请按以下步骤排查：

1. 运行环境检查: `./check.sh`
2. 查看部署日志
3. 检查EC2实例状态
4. 验证网络连接

---

**最后更新**: 2025-7-22
**版本**: v2.0  
**维护者**: ITWORDS # awsome-japanese-it-words
