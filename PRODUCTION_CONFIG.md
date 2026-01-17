# 生产环境配置指南

本指南说明如何配置生产环境（Vercel前端 + Railway后端）。

## 架构概览

```
生产环境
├── 前端 (Vercel)
│   └── URL: https://your-project.vercel.app
├── Nitter后端 (Railway)
│   └── URL: https://news-agent-nitter-production.up.railway.app
└── Redis (Railway)
    └── 内部服务
```

## 部署配置

### 1. Railway后端部署

#### 环境变量配置

在Railway的Nitter服务中，配置以下环境变量：

```bash
# Redis连接（从Redis服务的Variables中复制）
REDIS_URL=redis://default:password@redis.railway.internal:6379

# Nitter域名（重要：使用完整的Railway URL）
NITTER_DOMAIN=news-agent-nitter-production.up.railway.app

# 安全密钥（生成随机值）
NITTER_HMAC_KEY=your-hmac-key-here
NITTER_BASE64SECRET=your-base64-secret-here
```

**生成密钥**：
```bash
openssl rand -hex 32      # 用于NITTER_HMAC_KEY
openssl rand -base64 32   # 用于NITTER_BASE64SECRET
```

#### 验证部署

部署完成后，测试以下端点：

1. **Nitter主页**：
   ```
   https://news-agent-nitter-production.up.railway.app
   ```

2. **RSS端点**：
   ```
   https://news-agent-nitter-production.up.railway.app/OpenAI/rss
   https://news-agent-nitter-production.up.railway.app/elonmusk/rss
   ```

### 2. Vercel前端部署

#### 环境变量配置（可选）

在Vercel项目的环境变量中，可以配置：

```bash
# 生产环境Nitter URL（可选，前端代码已有默认值）
NITTER_PRODUCTION_URL=https://news-agent-nitter-production.up.railway.app
```

**注意**：如果不设置此环境变量，前端会使用默认值。

#### 部署步骤

1. 登录Vercel
2. 导入GitHub仓库
3. 配置项目（使用默认配置即可）
4. 部署

详细步骤请参考：`VERCEL_DEPLOY.md`

### 3. 前端自动配置

前端代码会自动：
- ✅ 检测生产环境
- ✅ 自动添加Railway Nitter实例
- ✅ 使用Vercel的API代理解决CORS问题

## 使用说明

### 访问前端

部署完成后，访问Vercel提供的URL，例如：
```
https://your-project.vercel.app
```

### 默认实例

前端会自动添加生产环境Nitter实例：
- **URL**: `https://news-agent-nitter-production.up.railway.app`
- **名称**: "生产环境Nitter实例 (Railway)"

### 测试功能

1. **测试实例连接**：
   - 在"实例管理"标签页
   - 点击生产环境实例的"测试"按钮
   - 确认状态为"在线"

2. **查看推文**：
   - 切换到"推文查看"标签页
   - 点击"加载 @OpenAI 推文"或"加载 @elonmusk 推文"
   - 或输入自定义用户名

## 环境变量参考

### Railway环境变量

```bash
# 必需
REDIS_URL=redis://default:password@redis.railway.internal:6379
NITTER_DOMAIN=news-agent-nitter-production.up.railway.app
NITTER_HMAC_KEY=your-hmac-key-here
NITTER_BASE64SECRET=your-base64-secret-here

# 可选
NITTER_TITLE=Nitter
NITTER_THEME=auto
PORT=8080
```

### Vercel环境变量（可选）

```bash
# 如果Nitter URL有变化，可以在这里配置
NITTER_PRODUCTION_URL=https://news-agent-nitter-production.up.railway.app
```

## 故障排查

### 问题1：前端无法连接Nitter

**检查**：
1. 确认Railway上的Nitter服务正常运行
2. 检查Nitter服务的Public URL是否正确
3. 在浏览器中直接访问Nitter URL测试

**解决方案**：
- 更新前端代码中的`PRODUCTION_NITTER_URL`常量
- 或在Vercel环境变量中设置`NITTER_PRODUCTION_URL`

### 问题2：CORS错误

**解决方案**：
- 前端会自动使用Vercel的API代理（`/api/rss`）
- 如果仍有问题，检查Vercel函数日志

### 问题3：RSS返回空内容

**可能原因**：
- Nitter可能需要Twitter session token
- Twitter/X的API限制

**解决方案**：
- 参考`RAILWAY_DEPLOY.md`中的"关于Session Token"部分
- 检查Nitter服务日志

## 更新配置

### 更新Nitter URL

如果Railway上的Nitter URL发生变化：

1. **方法1：更新前端代码**
   - 编辑`index.html`中的`PRODUCTION_NITTER_URL`常量
   - 重新部署到Vercel

2. **方法2：使用环境变量**
   - 在Vercel项目设置中添加`NITTER_PRODUCTION_URL`环境变量
   - 重新部署

### 更新Railway配置

1. 在Railway中修改环境变量
2. 服务会自动重新部署
3. 无需修改前端代码

## 监控和维护

### 监控服务状态

1. **Railway**：
   - 在Railway Dashboard查看服务状态
   - 查看服务日志
   - 监控资源使用情况

2. **Vercel**：
   - 在Vercel Dashboard查看部署状态
   - 查看函数日志（API路由）
   - 监控带宽使用

### 定期检查

- ✅ Nitter服务是否正常运行
- ✅ RSS端点是否返回内容
- ✅ 前端是否能正常连接Nitter
- ✅ Redis连接是否正常（虽然RSS不依赖Redis）

## 相关文档

- `RAILWAY_DEPLOY.md` - Railway部署详细指南
- `VERCEL_DEPLOY.md` - Vercel部署详细指南
- `LOCAL_DEV.md` - 本地开发环境设置
- `TEST_CHECKLIST.md` - 测试清单

## 总结

生产环境配置完成后：

- ✅ 前端部署在Vercel，自动使用Railway的Nitter实例
- ✅ 前端自动添加生产环境实例，无需手动配置
- ✅ 通过Vercel API代理解决CORS问题
- ✅ 可以测试@OpenAI和@elonmusk的推文

部署完成后，访问Vercel URL即可开始使用！
