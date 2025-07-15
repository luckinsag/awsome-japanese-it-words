# AWS 连接信息与网络配置

## 🔐 AWS CLI 配置

### 基本信息
- **AWS CLI 版本**: 2.27.49
- **区域**: ap-northeast-1 (亚太东北部-东京)
- **账户ID**: 628532653086
- **用户ARN**: arn:aws:iam::628532653086:root

### 配置文件位置
- **配置文件**: ~/.aws/config
- **凭证文件**: ~/.aws/credentials

### 当前配置
```bash
# ~/.aws/config
[default]
region = ap-northeast-1
output = json
```

## 🖥️ EC2 实例信息

### 当前运行实例
| 项目 | 值 |
|------|-----|
| **实例ID** | i-04319d3d7e427a629 |
| **实例名称** | itwords-new |
| **实例类型** | t2.micro |
| **状态** | running |
| **公网IP** | 57.180.30.179 |
| **私网IP** | 172.31.9.197 |
| **可用区** | ap-northeast-1a |
| **密钥对** | sag- |

### 连接信息
```bash
# SSH连接命令
ssh -i sag-.pem ec2-user@57.180.30.179

# 密钥文件权限
chmod 400 sag-.pem
```

## 🌐 网络配置

### VPC 信息
- **VPC ID**: vpc-0353485927017f0ac
- **VPC CIDR**: 默认VPC
- **子网ID**: subnet-05479790b2dba8576
- **可用区**: ap-northeast-1a

### 安全组配置
- **安全组名称**: launch-wizard-1
- **安全组ID**: sg-0da63733e1b03dd37
- **入站规则**:
  - 端口 80 (HTTP): 0.0.0.0/0
  - 端口 22 (SSH): 0.0.0.0/0
  - 端口 443 (HTTPS): 0.0.0.0/0
  - 端口 8080 (应用): 0.0.0.0/0 ✅ 已添加

### 网络接口
- **网络接口ID**: 自动分配
- **公网IP分配**: 自动分配
- **私网IP**: 172.31.9.197

## 💰 成本优化策略

### 避免收费方案
1. **不使用弹性IP** - 新实例自动分配公网IP，无需额外付费
2. **按需使用** - 不需要时及时终止实例
3. **使用t2.micro** - 免费套餐实例类型

### 费用说明
- **t2.micro实例**: 免费套餐内免费
- **公网IP**: 使用中免费
- **弹性IP**: 未使用时收费，避免使用

## 🔧 常用命令

### AWS CLI 命令
```bash
# 查看当前用户身份
aws sts get-caller-identity

# 列出EC2实例
aws ec2 describe-instances

# 查看实例状态
aws ec2 describe-instances --instance-ids i-04319d3d7e427a629

# 终止实例
aws ec2 terminate-instances --instance-ids i-04319d3d7e427a629

# 创建新实例（自动分配公网IP）
aws ec2 run-instances \
  --image-id ami-0f95ad36d6d54ceba \
  --count 1 \
  --instance-type t2.micro \
  --key-name sag- \
  --security-group-ids [安全组ID] \
  --subnet-id subnet-05479790b2dba8576 \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=itwords-new}]'
```

### SSH 连接命令
```bash
# 设置密钥权限
chmod 400 sag-.pem

# 连接到实例
ssh -i sag-.pem ec2-user@57.180.30.179

# 使用SSH配置文件（可选）
# 在 ~/.ssh/config 中添加：
Host itwords-ec2
    HostName 57.180.30.179
    User ec2-user
    IdentityFile ~/path/to/sag-.pem
    Port 22
```

## 📁 密钥文件管理

### 密钥文件位置
- **密钥文件**: ./sag-.pem
- **权限设置**: 400 (仅所有者可读)
- **密钥对名称**: sag-

### 安全注意事项
- 密钥文件权限必须设置为400
- 不要将密钥文件提交到版本控制
- 定期轮换密钥对
- 备份密钥文件到安全位置

## 🚀 部署信息

### 应用访问地址
- **前端应用**: http://57.180.30.179
- **后端API**: http://57.180.30.179:8080
- **数据库**: 57.180.30.179:3306

### 部署脚本
项目包含以下部署脚本：
- `deploy-on-ec2.sh` - EC2实例部署脚本
- `docker-compose.yml` - Docker容器编排
- `scripts/deployment/` - 部署相关脚本

## 📝 注意事项

### 环境变量问题
当前shell环境中的PAGER变量设置可能导致输出重定向：
```bash
# 临时解决
unset PAGER

# 永久解决：编辑 ~/.zshrc 移除PAGER设置
```

### 实例管理
- 定期检查实例状态
- 不需要时及时终止实例
- 监控费用使用情况
- 备份重要数据

## 🔄 更新记录

| 日期 | 更新内容 |
|------|----------|
| 2024-12-19 | 创建新EC2实例，分配公网IP |
| 2024-12-19 | 成功连接EC2实例 |
| 2024-12-19 | 配置AWS CLI连接 |
| 2024-12-19 | 添加8080端口到安全组，修复后端API外部访问 |

---

**最后更新**: 2024-12-19  
**维护者**: ITWORDS项目组 