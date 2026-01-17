# 本地开发环境设置指南

本指南说明如何在本地部署和调试整个系统（前端、Nitter后端、Redis）。

## 架构概览

```
本地开发环境
├── Redis服务 (Docker)
│   └── 端口: 6379
├── Nitter服务 (Docker)
│   └── 端口: 8080
└── 前端服务 (Node.js)
    └── 端口: 3000
```

## 前置要求

1. ✅ Docker 和 Docker Compose
2. ✅ Node.js (>= 12.0.0)
3. ✅ 终端访问权限

## 快速启动

### 方法1：一键启动（推荐）

```bash
# 启动所有服务
./start-local.sh
```

### 方法2：分步启动

#### 步骤1：启动Redis和Nitter（Docker Compose）

```bash
# 生成密钥（首次运行）
export NITTER_HMAC_KEY=$(openssl rand -hex 32)
export NITTER_BASE64SECRET=$(openssl rand -base64 32)

# 启动Redis和Nitter
docker-compose up -d

# 查看日志
docker-compose logs -f nitter
```

#### 步骤2：启动前端服务

```bash
# 安装依赖（如果需要）
npm install

# 启动前端代理服务器
npm start
# 或
node proxy-server.js
```

## 详细步骤

### 1. 准备环境变量

创建 `.env` 文件（可选，用于设置密钥）：

```bash
# 生成密钥
NITTER_HMAC_KEY=$(openssl rand -hex 32)
NITTER_BASE64SECRET=$(openssl rand -base64 32)

# 保存到.env文件
cat > .env << EOF
NITTER_HMAC_KEY=$NITTER_HMAC_KEY
NITTER_BASE64SECRET=$NITTER_BASE64SECRET
NITTER_DOMAIN=localhost:8080
REDIS_HOST=redis
REDIS_PORT=6379
EOF
```

### 2. 启动Redis和Nitter

```bash
# 使用docker-compose启动
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看Nitter日志
docker-compose logs -f nitter

# 查看Redis日志
docker-compose logs -f redis
```

### 3. 启动前端服务

```bash
# 在项目根目录
node proxy-server.js
```

前端服务将在 `http://localhost:3000` 启动。

### 4. 测试服务

#### 快速测试（推荐）

```bash
# 运行测试脚本
./test-local.sh
```

这将自动测试所有服务并显示结果。

#### 手动测试

**测试Redis**：
```bash
# 使用redis-cli测试（如果已安装）
redis-cli -h localhost -p 6379 ping
# 应该返回: PONG

# 或使用Docker
docker-compose exec redis redis-cli ping
```

**测试Nitter**：
1. **访问Nitter主页**：
   ```
   http://localhost:8080
   ```

2. **测试RSS端点**：
   ```
   http://localhost:8080/OpenAI/rss
   http://localhost:8080/elonmusk/rss
   ```

**测试前端**：
1. **访问前端页面**：
   ```
   http://localhost:3000
   ```

2. **添加Nitter实例**：
   - URL: `http://localhost:8080`
   - 名称: "本地Nitter实例"

3. **测试实例连接**：
   - 点击"测试"按钮

4. **查看推文**：
   - 点击"加载 @OpenAI 推文"或"加载 @elonmusk 推文"

## 故障排查

### 问题1：Docker服务无法启动

**检查**：
```bash
# 查看Docker状态
docker ps
docker-compose ps

# 查看日志
docker-compose logs
```

**解决方案**：
- 确保Docker正在运行
- 检查端口是否被占用（6379, 8080）
- 尝试重启Docker服务

### 问题2：Nitter无法连接Redis

**检查**：
```bash
# 查看Nitter日志
docker-compose logs nitter

# 测试Redis连接
docker-compose exec redis redis-cli ping
```

**解决方案**：
- 确保Redis服务正常运行
- 检查环境变量配置
- 等待几秒让Redis完全启动

### 问题3：前端无法访问Nitter

**检查**：
- 确认Nitter在 `http://localhost:8080` 运行
- 检查浏览器控制台的CORS错误
- 确认前端代理服务器正在运行

**解决方案**：
- 使用前端代理服务器（`http://localhost:3000`）
- 前端会自动通过代理访问Nitter RSS

### 问题4：端口被占用

**解决方案**：
1. 查找占用端口的进程：
   ```bash
   # macOS/Linux
   lsof -i :8080
   lsof -i :6379
   lsof -i :3000
   ```

2. 修改docker-compose.yml中的端口映射

3. 或停止占用端口的服务

## 开发工作流

### 修改Nitter配置

1. 编辑 `nitter.conf`
2. 重启Nitter服务：
   ```bash
   docker-compose restart nitter
   ```

### 修改前端代码

1. 编辑 `index.html`
2. 刷新浏览器（前端代理服务器支持热重载）

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f nitter
docker-compose logs -f redis

# 查看前端日志（在运行proxy-server.js的终端）
```

## 停止服务

```bash
# 停止所有服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v

# 停止前端服务
# 在运行proxy-server.js的终端按 Ctrl+C
```

## 清理环境

```bash
# 停止并删除所有容器和数据
docker-compose down -v

# 删除Docker镜像（可选）
docker rmi news-agent-nitter_nitter
```

## 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 进入Nitter容器
docker-compose exec nitter sh

# 进入Redis容器
docker-compose exec redis sh

# 测试Redis连接
docker-compose exec redis redis-cli ping
```

## 下一步

本地调试通过后，可以：
1. 部署Nitter到Railway
2. 部署前端到Vercel
3. 在Railway上配置Redis

详细部署说明请参考：
- `RAILWAY_DEPLOY.md` - Railway部署指南
- `VERCEL_DEPLOY.md` - Vercel部署指南
