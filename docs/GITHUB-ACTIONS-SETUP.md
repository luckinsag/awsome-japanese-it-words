# GitHub Actions 自动部署设置

## 📋 概述

本项目使用 GitHub Actions 实现自动化的测试、构建和部署流程。当代码推送到主分支或创建 Pull Request 时，会自动触发部署流程。

## 🔧 设置步骤

### 1. 配置 GitHub Secrets

在 GitHub 仓库中配置以下 Secrets：

1. 进入仓库设置：`Settings` → `Secrets and variables` → `Actions`
2. 点击 `New repository secret` 添加以下密钥：

#### 必需的 Secrets

| Secret 名称 | 描述 | 示例值 |
|------------|------|--------|
| `EC2_IP` | AWS EC2 实例的公网IP地址 | `57.180.30.179` |
| `EC2_USER` | EC2 实例的用户名 | `ec2-user` |
| `EC2_PRIVATE_KEY` | EC2 实例的私钥文件内容 | `-----BEGIN RSA PRIVATE KEY-----...` |

> **区域建议**：ap-northeast-1（东京）
> 
> **密钥文件名**：本项目默认密钥文件名为 `sag-.pem`，请根据实际情况调整。

### 2. 安全组与端口开放

请确保EC2实例的安全组已开放以下端口：
- 22（SSH远程管理）
- 80（前端Web服务）
- 8080（后端API服务）

### 3. 获取 EC2 私钥内容

```bash
# 在本地执行以下命令获取私钥内容
cat ./sag-.pem
```

将输出的完整内容（包括 `-----BEGIN RSA PRIVATE KEY-----` 和 `-----END RSA PRIVATE KEY-----`）复制到 `EC2_PRIVATE_KEY` secret 中。

### 4. 验证设置

1. 推送代码到主分支或创建 Pull Request
2. 在 GitHub 仓库的 `Actions` 标签页查看工作流执行情况
3. 检查部署是否成功

## 🚀 工作流程

### 触发条件

- **自动触发**：推送到 `main` 或 `master` 分支
- **手动触发**：在 Actions 页面手动运行工作流
- **PR 测试**：创建 Pull Request 时运行测试

### 执行步骤

1. **测试阶段**：
   - 设置 Java 17 环境
   - 运行后端单元测试
   - 设置 Node.js 18 环境
   - 构建前端项目

2. **构建阶段**：
   - 构建 Docker 镜像（linux/amd64 架构）
   - 保存镜像为 tar 文件
   - 传输到 EC2 实例

3. **部署阶段**：
   - 停止现有容器
   - 加载新镜像
   - 启动应用
   - 验证部署状态

## 📊 监控和日志

### 查看部署状态

1. **GitHub Actions 日志**：
   - 进入仓库的 `Actions` 标签页
   - 点击具体的工作流运行记录
   - 查看详细的执行日志

2. **EC2 实例状态**：
   ```bash
   # SSH 连接到 EC2
   ssh -i ./sag-.pem ec2-user@57.180.30.179
   
   # 查看容器状态
   cd ~/itwords-images
   docker-compose -f deploy-compose.yml ps
   
   # 查看日志
   docker-compose -f deploy-compose.yml logs -f
   ```

### 应用访问地址与端口

- 前端: http://57.180.30.179 （80端口）
- 后端: http://57.180.30.179:8080 （8080端口）
- 数据库: 57.180.30.179:3306 （如需远程连接MySQL）

### 故障排除

#### 常见问题

1. **连接失败**：
   - 检查 EC2 实例是否运行
   - 验证安全组设置（22/80/8080端口）
   - 确认私钥内容正确

2. **构建失败**：
   - 检查代码语法错误
   - 验证依赖配置
   - 查看构建日志

3. **部署失败**：
   - 检查 EC2 磁盘空间
   - 验证 Docker 服务状态
   - 查看容器日志

#### 调试命令

```bash
# 检查 EC2 连接
ssh -i ./sag-.pem ec2-user@57.180.30.179 "echo '连接成功'"

# 检查 Docker 状态
ssh -i ./sag-.pem ec2-user@57.180.30.179 "docker --version && docker-compose --version"

# 检查应用状态
ssh -i ./sag-.pem ec2-user@57.180.30.179 "cd ~/itwords-images && docker-compose -f deploy-compose.yml ps"

# 查看详细日志
ssh -i ./sag-.pem ec2-user@57.180.30.179 "cd ~/itwords-images && docker-compose -f deploy-compose.yml logs"
```

## 🔄 手动部署

如果需要手动触发部署：

1. 进入 GitHub 仓库的 `Actions` 标签页
2. 选择 `Deploy to AWS EC2` 工作流
3. 点击 `Run workflow`
4. 选择部署环境（production/staging）
5. 点击 `Run workflow` 开始部署

## 📝 注意事项

### 安全考虑

1. **私钥安全**：
   - 不要在代码中硬编码私钥
   - 定期轮换 EC2 密钥对
   - 使用最小权限原则

2. **网络安全**：
   - 限制 EC2 安全组访问
   - 使用 HTTPS 访问应用
   - 定期更新系统和依赖

### 性能优化

1. **构建缓存**：
   - 利用 GitHub Actions 缓存机制
   - 优化 Docker 镜像层
   - 使用多阶段构建

2. **部署优化**：
   - 使用增量更新
   - 实现蓝绿部署
   - 监控资源使用

## 🛠️ 自定义配置

### 修改部署环境

编辑 `.github/workflows/deploy.yml` 文件：

```yaml
env:
  EC2_IP: ${{ secrets.EC2_IP }}
  EC2_USER: ${{ secrets.EC2_USER }}
  # 添加其他环境变量
```

### 添加部署步骤

```yaml
- name: Custom Step
  run: |
    echo "执行自定义步骤"
    # 添加自定义逻辑
```

### 配置通知

```yaml
- name: Notify on Success
  if: success()
  run: |
    echo "部署成功通知"
    # 发送通知到 Slack、钉钉等
```

## 📚 相关文档

- [GitHub Actions 官方文档](https://docs.github.com/en/actions)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [AWS EC2 文档](https://docs.aws.amazon.com/ec2/)
- [项目部署文档](./DEPLOYMENT.md) 