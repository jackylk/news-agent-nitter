# Nitter前端测试工具使用指南

## 简介

`index.html` 是一个单页Web应用，用于测试和管理Nitter实例，查看推文内容。

## 功能特性

### 1. 实例管理
- ✅ 添加Nitter实例（URL和名称）
- ✅ 测试实例连接状态
- ✅ 删除实例
- ✅ 批量测试所有实例
- ✅ 实例状态显示（在线/离线/测试中）

### 2. 推文查看
- ✅ 快速测试 @OpenAI 和 @elonmusk 的推文
- ✅ 自定义用户名和实例加载推文
- ✅ 显示推文内容、发布时间、原文链接
- ✅ 美观的推文卡片展示

## 使用方法

### 方法1：直接在浏览器中打开

1. 下载 `index.html` 文件
2. 双击文件在浏览器中打开
3. 开始使用

**注意**：由于浏览器的CORS（跨域资源共享）限制，直接从本地文件访问Nitter实例可能会遇到跨域错误。

### 方法2：使用本地Web服务器（推荐）

#### 使用Python（推荐）

```bash
# Python 3
python3 -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

然后在浏览器中访问：`http://localhost:8000`

#### 使用Node.js

```bash
# 安装http-server
npm install -g http-server

# 启动服务器
http-server -p 8000
```

#### 使用PHP

```bash
php -S localhost:8000
```

### 方法3：部署到Web服务器

将 `index.html` 上传到任何Web服务器（如GitHub Pages、Netlify、Vercel等）即可使用。

## 使用步骤

### 步骤1：添加Nitter实例

1. 切换到"实例管理"标签页
2. 输入Nitter实例URL（例如：`https://your-nitter-service.railway.app`）
3. 输入实例名称（可选）
4. 点击"添加实例"

### 步骤2：测试实例

1. 在实例列表中，点击"测试"按钮
2. 等待测试完成
3. 查看实例状态（在线/离线）

### 步骤3：查看推文

#### 快速测试
1. 切换到"推文查看"标签页
2. 点击"加载 @OpenAI 推文"或"加载 @elonmusk 推文"
3. 系统会自动使用第一个可用实例加载推文

#### 自定义加载
1. 输入Twitter用户名（例如：`OpenAI`、`elonmusk`）
2. 从下拉列表中选择Nitter实例
3. 点击"加载推文"

## 数据存储

- 实例列表存储在浏览器的 `localStorage` 中
- 数据保存在本地，不会上传到服务器
- 清除浏览器数据会删除所有保存的实例

## 解决CORS问题

如果遇到CORS（跨域）错误，有以下解决方案：

### 方案1：使用CORS代理

修改代码中的fetch请求，使用CORS代理服务：

```javascript
// 在fetchTweets函数中
const proxyUrl = 'https://cors-anywhere.herokuapp.com/';
const rssUrl = `${proxyUrl}${instanceUrl}/${username}/rss`;
```

### 方案2：配置Nitter允许CORS

如果Nitter实例是你自己部署的，可以在Nitter配置中添加CORS头。

### 方案3：使用浏览器扩展

安装CORS浏览器扩展（如"Allow CORS"），临时禁用CORS检查。

### 方案4：使用后端代理（最佳方案）

创建一个简单的后端API代理，绕过CORS限制。可以参考下面的示例。

## 后端代理示例（可选）

如果需要解决CORS问题，可以创建一个简单的Node.js代理服务器：

```javascript
// proxy-server.js
const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');
const app = express();

app.use(cors());
app.use(express.static('.')); // 提供静态文件

app.get('/api/rss', async (req, res) => {
  const { url } = req.query;
  try {
    const response = await fetch(url);
    const text = await response.text();
    res.set('Content-Type', 'application/xml');
    res.send(text);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(3000, () => {
  console.log('代理服务器运行在 http://localhost:3000');
});
```

然后修改前端代码，使用代理API：

```javascript
const rssUrl = `/api/rss?url=${encodeURIComponent(`${instanceUrl}/${username}/rss`)}`;
```

## 故障排查

### 问题1：无法加载推文，显示CORS错误

**解决方案**：
- 使用本地Web服务器而不是直接打开文件
- 使用CORS代理或后端代理
- 检查Nitter实例是否正常运行

### 问题2：RSS返回空内容

**可能原因**：
- Nitter可能需要Twitter session token
- Twitter/X的API限制
- Nitter实例配置问题

**解决方案**：
- 检查Nitter服务日志
- 参考 `RAILWAY_DEPLOY.md` 中的"关于Session Token"部分
- 尝试访问Nitter网页界面，确认功能正常

### 问题3：实例测试失败

**可能原因**：
- Nitter实例URL不正确
- 实例未正常运行
- 网络连接问题

**解决方案**：
- 检查URL格式是否正确
- 在浏览器中直接访问Nitter实例URL
- 检查Railway服务状态

## 浏览器兼容性

- ✅ Chrome/Edge（推荐）
- ✅ Firefox
- ✅ Safari
- ✅ 移动浏览器

需要支持：
- ES6+ JavaScript
- Fetch API
- localStorage
- DOMParser

## 技术栈

- 纯HTML/CSS/JavaScript
- 无依赖，无需构建工具
- 使用localStorage存储数据
- 使用Fetch API获取RSS
- 使用DOMParser解析XML

## 更新日志

### v1.0.0
- 初始版本
- 实例管理功能
- 推文查看功能
- 快速测试功能

## 贡献

欢迎提交问题和改进建议！
