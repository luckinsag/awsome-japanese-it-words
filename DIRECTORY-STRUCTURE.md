# ITWORDS 项目目录结构

## 📁 完整目录结构

```
ITWORDS 4/
├── 🚀 根目录脚本 (快速使用)
│   ├── deploy.sh                    # 一键部署脚本
│   ├── update.sh                    # 快速更新脚本
│   └── check.sh                     # 环境检查脚本
│
├── 🔑 配置文件
│   ├── sag-.pem                     # AWS EC2密钥文件
│   ├── docker-compose.yml           # Docker编排配置
│   └── complete_wordlist.csv        # 单词数据文件
│
├── 🔧 应用代码
│   ├── itwords_api/                 # Spring Boot后端
│   └── itwords_display/             # Vue.js前端
│
├── 📜 脚本目录 (scripts/)
│   ├── 🚀 部署脚本 (deployment/)
│   │   ├── deploy-to-ec2-optimized.sh    # 完整优化部署
│   │   ├── quick-deploy-optimized.sh     # 快速优化部署
│   │   └── update-deployment.sh          # 增量更新
│   │
│   ├── 🛠️ 工具脚本 (utilities/)
│   │   ├── check-deployment.sh           # 环境检查
│   │   └── start-project.sh              # 项目启动
│   │
│   ├── ☁️ AWS脚本 (aws/)
│   │   ├── configure-security-group.sh   # 安全组配置
│   │   ├── reset-instance-key.sh         # 重置实例密钥
│   │   └── update-instance-key.sh        # 更新实例密钥
│   │
│   └── 📊 数据处理 (data-processing/)
│       ├── import_words_fast.sh          # 快速导入单词
│       ├── import_words_final.sh         # 最终导入脚本
│       ├── import_words_to_mysql_*.sh    # MySQL导入脚本
│       ├── lesson_renumber_*.sh          # 课程重编号
│       └── merge_*.sh                    # 数据合并脚本
│
├── 📚 文档目录 (docs/)
│   ├── DEPLOYMENT.md                    # 部署指南
│   ├── DEPLOYMENT-COMPARISON.md         # 部署方式对比
│   └── DEPLOYMENT-GUIDE.md              # 使用指南
│
├── 🌐 网络配置
│   └── nginx/                           # Nginx配置
│
└── 📖 项目文档
    ├── README.md                        # 项目说明
    ├── README-DEPLOYMENT.md             # 部署说明
    ├── 基本设计书.md                     # 基本设计文档
    ├── 详细设计书.md                     # 详细设计文档
    ├── aws-connection-info.md           # AWS连接信息
    ├── aws-quick-reference.txt          # AWS快速参考
    └── ssh-config                       # SSH配置
```

## 🎯 使用指南

### 快速使用 (推荐)

```bash
# 1. 环境检查
./check.sh

# 2. 一键部署
./deploy.sh

# 3. 快速更新
./update.sh
```

### 高级使用

```bash
# 完整部署 (生产环境)
./scripts/deployment/deploy-to-ec2-optimized.sh

# 环境检查
./scripts/utilities/check-deployment.sh

# AWS管理
./scripts/aws/configure-security-group.sh
```

## 📋 文件说明

### 根目录脚本
- **deploy.sh**: 一键部署到AWS EC2
- **update.sh**: 快速更新应用
- **check.sh**: 检查部署环境

### 配置文件
- **sag-.pem**: AWS EC2 SSH密钥文件
- **docker-compose.yml**: Docker容器编排配置
- **complete_wordlist.csv**: 单词数据文件

### 脚本分类

#### 部署脚本 (scripts/deployment/)
- **deploy-to-ec2-optimized.sh**: 完整的优化部署脚本
- **quick-deploy-optimized.sh**: 快速优化部署脚本
- **update-deployment.sh**: 增量更新脚本

#### 工具脚本 (scripts/utilities/)
- **check-deployment.sh**: 环境检查脚本
- **start-project.sh**: 本地项目启动脚本

#### AWS脚本 (scripts/aws/)
- **configure-security-group.sh**: 配置AWS安全组
- **reset-instance-key.sh**: 重置EC2实例密钥
- **update-instance-key.sh**: 更新EC2实例密钥

#### 数据处理脚本 (scripts/data-processing/)
- **import_words_*.sh**: 单词数据导入脚本
- **lesson_renumber_*.sh**: 课程重编号脚本
- **merge_*.sh**: 数据合并脚本

### 文档文件

#### 部署文档 (docs/)
- **DEPLOYMENT.md**: 详细的部署指南
- **DEPLOYMENT-COMPARISON.md**: 部署方式对比分析
- **DEPLOYMENT-GUIDE.md**: 完整的使用指南

#### 项目文档
- **README.md**: 项目主要说明文档
- **基本设计书.md**: 项目基本设计
- **详细设计书.md**: 项目详细设计
- **aws-connection-info.md**: AWS连接配置信息

## 🔧 维护说明

### 脚本权限
所有脚本文件都已设置执行权限：
```bash
chmod +x *.sh
chmod +x scripts/*/*.sh
```

### 密钥文件权限
AWS密钥文件权限已正确设置：
```bash
chmod 400 sag-.pem
```

### 目录权限
所有目录权限正常，支持读写操作。

## 📊 优化特点

### 目录组织
- ✅ 按功能分类组织脚本
- ✅ 根目录保留最常用的脚本
- ✅ 文档集中管理
- ✅ 清晰的命名规范

### 使用便利性
- ✅ 根目录一键脚本
- ✅ 详细的使用文档
- ✅ 完整的错误处理
- ✅ 自动权限设置

### 维护性
- ✅ 模块化设计
- ✅ 清晰的目录结构
- ✅ 完整的文档说明
- ✅ 版本控制友好

---

**最后更新**: 2024-12-19  
**版本**: v2.0  
**维护者**: ITWORDS项目组 