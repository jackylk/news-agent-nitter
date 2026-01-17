# Nitter实例快速部署指南

## 5分钟快速部署到Railway

### 步骤1：准备GitHub仓库（2分钟）

1. 在GitHub上创建新仓库（例如：`nitter-instance`）
2. 将本目录推送到仓库：
   ```bash
   cd nitter-instance
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/your-username/nitter-instance.git
   git push -u origin main
   ```

### 步骤2：在Railway中添加服务（3分钟）

1. **添加Redis服务**
   - 登录Railway，进入你的项目
   - 点击 "New" → "Database" → "Add Redis"
   - 等待Redis启动完成

2. **添加Nitter服务**
   - 在同一个项目中，点击 "New" → "GitHub Repo"
   - 选择刚才创建的Nitter仓库
   - Railway会自动开始构建

3. **配置环境变量**
   
   在Nitter服务的"Variables"中添加：
   
   ```bash
   # 从Redis服务的Variables中复制
   REDIS_URL=redis://default:password@redis-service.railway.internal:6379
   
   # 部署后，从Nitter服务的Public URL获取（不包含https://）
   NITTER_DOMAIN=your-nitter-service.railway.app
   
   # 生成密钥（在终端运行）
   # openssl rand -hex 32
   NITTER_HMAC_KEY=生成的密钥
   
   # openssl rand -base64 32
   NITTER_BASE64SECRET=生成的密钥
   ```

4. **获取Nitter URL**
   - 部署完成后，在Nitter服务设置中查看"Public URL"
   - 复制这个URL

### 步骤3：在网站后台添加实例（1分钟）

1. 登录管理后台（`/admin.html`）
2. 进入"Nitter管理"页签
3. 点击"添加Nitter实例"
4. 输入Nitter URL
5. 点击"测试"验证

### 完成！

现在可以开始抓取Twitter/X推文了！

## 测试推文抓取

### 测试@OpenAI和@elonmusk的推文

1. **直接测试RSS端点**：
   ```bash
   # 在浏览器或使用curl测试
   curl https://your-nitter-service.railway.app/OpenAI/rss
   curl https://your-nitter-service.railway.app/elonmusk/rss
   ```
   如果返回XML格式的RSS内容，说明Nitter工作正常。

2. **在网站后台添加订阅源**：
   - **OpenAI**：
     - 源URL：`https://twitter.com/OpenAI` 或 `@OpenAI`
     - 源类型：`twitter`
   - **Elon Musk**：
     - 源URL：`https://twitter.com/elonmusk` 或 `@elonmusk`
     - 源类型：`twitter`
   - 等待系统抓取（或手动触发）
   - 在"最新推文"页面查看

3. **如果RSS返回空内容**：
   - 可能是Nitter需要Twitter session token
   - 参考`RAILWAY_DEPLOY.md`中的"关于Session Token"部分

## 详细文档

- Railway部署详细指南：`RAILWAY_DEPLOY.md`
- 完整部署说明：`README.md`
- 主项目Nitter说明：`../NITTER_DEPLOY.md`
