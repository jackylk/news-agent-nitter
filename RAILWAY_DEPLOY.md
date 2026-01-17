# 在Railway上部署Nitter实例

本指南详细说明如何在Railway上部署Nitter实例，与网站后台服务在同一Railway项目中。

## 架构概览

```
Railway Project
├── 网站后台服务 (Node.js)
│   └── 端口: 3000
├── Nitter服务 (Docker)
│   └── 端口: 8080 (Railway自动分配)
└── Redis服务 (Railway插件)
    └── 内部服务名: redis-service.railway.internal
```

## 前置要求

1. ✅ 已有Railway账号和项目
2. ✅ 网站后台服务已在Railway上运行
3. ✅ 本仓库已推送到GitHub

## 部署步骤

### 步骤1：创建GitHub仓库

1. 在GitHub上创建新仓库（例如：`nitter-instance`）
2. 将本目录（`nitter-instance/`）中的所有文件推送到仓库：
   ```bash
   cd nitter-instance
   git init
   git add .
   git commit -m "Initial commit: Nitter instance for Railway"
   git remote add origin https://github.com/your-username/nitter-instance.git
   git push -u origin main
   ```

### 步骤2：在Railway项目中添加Redis服务

1. 登录Railway，进入你的项目（与网站后台同一个项目）
2. 点击 **"New"** → **"Database"** → **"Add Redis"**
3. Railway会自动创建Redis实例
4. 等待Redis服务启动完成（通常需要1-2分钟）

### 步骤3：获取Redis连接信息

1. 点击Redis服务，进入服务详情页
2. 点击 **"Variables"** 标签页
3. 查找以下环境变量：
   - `REDIS_URL` - 完整的Redis连接URL（推荐使用）
   - 或者 `REDIS_HOST`、`REDIS_PORT`、`REDIS_PASSWORD` 等

**重要**：记下这些值，稍后需要配置到Nitter服务中。

### 步骤4：在Railway项目中添加Nitter服务

1. 在同一个Railway项目中，点击 **"New"** → **"GitHub Repo"**
2. 选择刚才创建的Nitter仓库
3. Railway会自动检测Dockerfile并开始构建
4. 等待构建完成（通常需要3-5分钟）

### 步骤5：配置Nitter环境变量

在Nitter服务的设置中，添加以下环境变量：

#### 必需的环境变量

1. **Redis连接**（选择以下方式之一）：

   **方式1：使用REDIS_URL（推荐）**
   ```bash
   REDIS_URL=redis://default:password@redis-service.railway.internal:6379
   ```
   从Redis服务的Variables中复制`REDIS_URL`的值

   **方式2：分别设置**
   ```bash
   REDIS_HOST=redis-service.railway.internal
   REDIS_PORT=6379
   REDIS_PASSWORD=your-redis-password
   REDIS_DB=0
   ```

2. **Nitter域名**：

   ```bash
   NITTER_DOMAIN=your-nitter-service.railway.app
   ```
   
   **如何获取**：
   - 部署完成后，在Nitter服务的设置中查看 **"Public URL"**
   - 复制这个URL（不包含`https://`前缀）

3. **安全密钥**：

   ```bash
   # 生成HMAC Key
   openssl rand -hex 32
   
   # 生成Base64 Secret
   openssl rand -base64 32
   ```
   
   将生成的值填入：
   ```bash
   NITTER_HMAC_KEY=生成的hmac-key
   NITTER_BASE64SECRET=生成的base64-secret
   ```

#### 可选的环境变量

```bash
NITTER_TITLE=Nitter
NITTER_THEME=auto
PORT=8080  # Railway会自动设置，通常无需手动配置
```

### 步骤6：验证部署

1. **检查服务状态**：
   - 在Railway中查看Nitter服务状态，应该显示"Running"
   - 查看日志，确认没有错误

2. **测试Nitter实例**：
   - 访问Nitter服务的Public URL
   - 应该能看到Nitter主页

3. **测试RSS端点**：
   - 访问：`https://your-nitter-service.railway.app/OpenAI/rss`
   - 应该能看到RSS XML内容

### 步骤7：在网站后台添加Nitter实例

1. 登录网站管理后台（`/admin.html`）
2. 进入 **"Nitter管理"** 页签
3. 点击 **"添加Nitter实例"**
3. 输入：
   - **URL**：`https://your-nitter-service.railway.app`
   - **名称**：例如 "Railway Nitter实例"
   - **优先级**：例如 `10`（数字越大越优先）
4. 点击 **"测试"** 按钮验证实例是否可用
5. 如果测试成功，实例就可以使用了

### 步骤8：测试推文抓取

#### 测试@OpenAI和@elonmusk的推文

1. **直接访问RSS端点测试**：
   - OpenAI RSS：`https://your-nitter-service.railway.app/OpenAI/rss`
   - Elon Musk RSS：`https://your-nitter-service.railway.app/elonmusk/rss`
   - 如果能看到XML格式的RSS内容，说明Nitter工作正常

2. **在网站后台添加订阅源**：
   - 在订阅管理中添加Twitter/X订阅源：
     - **OpenAI**：
       - 源URL：`https://twitter.com/OpenAI` 或 `@OpenAI`
       - 源类型：`twitter`
     - **Elon Musk**：
       - 源URL：`https://twitter.com/elonmusk` 或 `@elonmusk`
       - 源类型：`twitter`
   - 等待系统自动抓取（或手动触发收集）
   - 在"最新推文"页面查看抓取到的推文

3. **验证推文抓取**：
   - 检查RSS端点是否返回最新推文
   - 确认推文内容完整（标题、链接、发布时间等）
   - 如果RSS为空，可能是Nitter需要Twitter session token（见下方说明）

## 环境变量参考

### 完整环境变量列表

```bash
# Redis配置（必需）
REDIS_URL=redis://default:password@redis-service.railway.internal:6379
# 或者
REDIS_HOST=redis-service.railway.internal
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password
REDIS_DB=0

# Nitter配置（必需）
NITTER_DOMAIN=your-nitter-service.railway.app
NITTER_HMAC_KEY=your-hmac-key-here
NITTER_BASE64SECRET=your-base64-secret-here

# 可选配置
NITTER_TITLE=Nitter
NITTER_THEME=auto
PORT=8080  # Railway自动设置
```

## 故障排查

### 问题1：Nitter无法连接Redis

**症状**：Nitter服务启动失败，日志显示Redis连接错误

**解决方案**：
1. 检查Redis服务是否正常运行
2. 确认`REDIS_URL`或`REDIS_HOST`环境变量正确
3. 如果使用内部服务名，确保格式正确：`redis-service.railway.internal`
4. 检查Redis密码是否正确

### 问题2：RSS端点返回404或错误

**症状**：访问`/username/rss`返回404或错误页面

**解决方案**：
1. 检查`NITTER_DOMAIN`环境变量是否设置为正确的域名
2. 确认域名格式正确（不包含`https://`前缀）
3. 查看Nitter服务日志，查找具体错误信息

### 问题3：推文抓取失败

**症状**：RSS端点可以访问，但返回空内容或错误

**解决方案**：
1. Nitter可能因为Twitter/X的变更而失效
2. 检查Nitter服务日志
3. 尝试访问Nitter网页界面，确认功能正常
4. 考虑更新Nitter镜像版本

### 问题4：服务无法启动

**症状**：Railway显示服务启动失败

**解决方案**：
1. 查看服务日志，查找错误信息
2. 检查环境变量是否全部配置
3. 确认Dockerfile和配置文件格式正确
4. 检查端口配置（Railway会自动设置PORT）

## 更新和维护

### 更新Nitter镜像

Railway会在重新部署时自动拉取最新镜像。要手动更新：

1. 在Railway中，进入Nitter服务
2. 点击 **"Redeploy"** 或 **"Deploy"**
3. Railway会重新构建并部署

### 查看日志

1. 在Railway中，进入Nitter服务
2. 点击 **"Logs"** 标签页
3. 可以实时查看服务日志

### 监控服务状态

1. 在Railway项目页面，可以查看所有服务状态
2. 使用Railway的监控功能查看资源使用情况
3. 在网站后台的Nitter管理中，定期测试实例可用性

## 成本说明

- **Railway免费版**：每月$5免费额度
- **Redis服务**：占用部分资源
- **Nitter服务**：占用部分资源
- **建议**：监控使用量，避免超出免费额度

## 相关文档

- 主项目部署：`RAILWAY_DEPLOY.md`
- Nitter详细说明：`NITTER_DEPLOY.md`
- Nitter GitHub：https://github.com/zedeus/nitter

## 重要提示

### 关于Session Token

由于Twitter/X的变更，Nitter现在可能需要Twitter账号的session token才能稳定工作。如果遇到以下问题：

- RSS端点返回空内容
- 推文抓取失败
- 访问用户页面显示错误

可能需要配置session token。详细说明请参考Nitter官方文档。

**注意**：即使没有session token，RSS功能可能仍然可以工作，这取决于Twitter/X的当前限制。

## 总结

按照以上步骤，你可以在Railway上成功部署Nitter实例，并与网站后台服务在同一个项目中运行。这样可以：

- ✅ 统一管理所有服务
- ✅ 资源隔离，互不影响
- ✅ 独立扩展和更新
- ✅ 自动SSL和域名

部署完成后，就可以在网站后台添加Nitter实例，并开始抓取Twitter/X推文了！

如果遇到问题，请查看故障排查部分或Nitter官方文档。
