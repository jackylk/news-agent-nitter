# 在Vercel上部署Nitter前端测试工具

本指南说明如何将Nitter前端测试工具部署到Vercel。

## 前置要求

1. ✅ GitHub账号
2. ✅ Vercel账号（https://vercel.com）
3. ✅ 本仓库已推送到GitHub

## 部署步骤

### 方法1：通过Vercel Dashboard部署（推荐）

1. **登录Vercel**
   - 访问 https://vercel.com
   - 使用GitHub账号登录

2. **导入项目**
   - 点击 "Add New..." → "Project"
   - 选择你的GitHub仓库（news-agent-nitter）
   - Vercel会自动检测项目配置

3. **配置项目**
   - **Framework Preset**: Other
   - **Root Directory**: `./`（默认）
   - **Build Command**: 留空（静态文件，无需构建）
   - **Output Directory**: `./`（默认）
   - **Install Command**: 留空（无需安装依赖）

4. **环境变量**（可选）
   - 通常不需要环境变量
   - 如果需要，可以在 "Environment Variables" 中添加

5. **部署**
   - 点击 "Deploy"
   - 等待部署完成（通常需要1-2分钟）

6. **访问应用**
   - 部署完成后，Vercel会提供一个URL
   - 例如：`https://your-project.vercel.app`
   - 点击URL即可访问应用

### 方法2：使用Vercel CLI部署

1. **安装Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **登录Vercel**
   ```bash
   vercel login
   ```

3. **部署项目**
   ```bash
   cd news-agent-nitter
   vercel
   ```

4. **生产环境部署**
   ```bash
   vercel --prod
   ```

## 项目结构

部署到Vercel的项目结构：

```
news-agent-nitter/
├── api/
│   └── rss.js          # Vercel Serverless函数（RSS代理）
├── index.html          # 前端页面
├── vercel.json         # Vercel配置文件
├── package.json        # 项目配置
└── .vercelignore      # Vercel忽略文件
```

## 功能说明

### RSS代理API

- **路径**: `/api/rss`
- **方法**: GET
- **参数**: `url` - 目标RSS URL
- **示例**: `/api/rss?url=https://nitter.example.com/OpenAI/rss`

### 前端功能

- ✅ Nitter实例管理
- ✅ 推文查看
- ✅ 自动使用代理解决CORS问题

## 配置说明

### vercel.json

```json
{
  "version": 2,
  "routes": [
    {
      "src": "/api/rss",
      "dest": "/api/rss.js"
    }
  ],
  "rewrites": [
    {
      "source": "/",
      "destination": "/index.html"
    }
  ]
}
```

### API路由

`api/rss.js` 是一个Vercel Serverless函数，用于：
- 代理RSS请求，解决CORS问题
- 转发响应头和内容
- 处理错误和超时

## 使用说明

### 1. 访问应用

部署完成后，访问Vercel提供的URL，例如：
```
https://your-project.vercel.app
```

### 2. 添加Nitter实例

1. 切换到"实例管理"标签页
2. 输入Nitter实例URL（例如：`https://your-nitter-service.railway.app`）
3. 点击"添加实例"

### 3. 测试实例

1. 点击"测试"按钮验证实例是否可用
2. 查看实例状态（在线/离线）

### 4. 查看推文

1. 切换到"推文查看"标签页
2. 点击"加载 @OpenAI 推文"或"加载 @elonmusk 推文"
3. 或输入自定义用户名并选择实例

## 故障排查

### 问题1：API路由返回404

**症状**：访问 `/api/rss` 返回404错误

**解决方案**：
1. 检查 `api/rss.js` 文件是否存在
2. 确认 `vercel.json` 配置正确
3. 重新部署项目

### 问题2：CORS错误

**症状**：浏览器控制台显示CORS错误

**解决方案**：
1. 确认API路由正常工作
2. 检查 `vercel.json` 中的CORS头配置
3. 前端代码会自动使用代理，无需手动配置

### 问题3：RSS代理失败

**症状**：无法加载推文，显示代理错误

**解决方案**：
1. 检查Nitter实例URL是否正确
2. 确认Nitter实例正常运行
3. 查看Vercel函数日志

### 问题4：部署失败

**症状**：Vercel部署失败

**解决方案**：
1. 检查项目结构是否正确
2. 确认所有必需文件都已提交到GitHub
3. 查看Vercel部署日志

## 更新应用

### 自动更新

- Vercel会自动检测GitHub仓库的推送
- 每次推送都会触发新的部署
- 可以在Vercel Dashboard中查看部署历史

### 手动更新

1. 在本地修改代码
2. 提交并推送到GitHub
3. Vercel会自动重新部署

## 自定义域名

1. 在Vercel Dashboard中，进入项目设置
2. 点击 "Domains"
3. 添加你的自定义域名
4. 按照提示配置DNS记录

## 成本说明

- **Vercel免费版**：
  - 无限部署
  - 100GB带宽/月
  - Serverless函数执行时间有限制
  - 对于本应用完全够用

## 相关文档

- Vercel文档：https://vercel.com/docs
- Vercel Serverless函数：https://vercel.com/docs/serverless-functions
- 前端工具使用指南：`FRONTEND_GUIDE.md`

## 总结

按照以上步骤，你可以轻松将Nitter前端测试工具部署到Vercel：

- ✅ 自动部署（GitHub推送触发）
- ✅ 全球CDN加速
- ✅ 自动HTTPS
- ✅ Serverless函数处理RSS代理
- ✅ 完全免费（免费版足够使用）

部署完成后，就可以在任何地方访问和使用Nitter测试工具了！
