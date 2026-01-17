# macOS Docker 安装指南

本指南说明如何在 macOS 上安装 Docker 和 Docker Compose。

## 方法1：使用 Docker Desktop（推荐）

Docker Desktop 包含了 Docker 和 Docker Compose，是最简单的安装方式。

### 步骤1：下载 Docker Desktop

1. 访问 Docker Desktop 官网：
   ```
   https://www.docker.com/products/docker-desktop/
   ```

2. 点击 "Download for Mac"

3. 选择适合你 Mac 的版本：
   - **Apple Silicon (M1/M2/M3)**：选择 "Mac with Apple chip"
   - **Intel Mac**：选择 "Mac with Intel chip"

### 步骤2：安装 Docker Desktop

1. 打开下载的 `.dmg` 文件

2. 将 Docker 图标拖拽到 Applications 文件夹

3. 打开 Applications 文件夹，双击 Docker 图标启动

4. 首次启动时，可能需要：
   - 输入管理员密码
   - 允许系统权限

5. 等待 Docker Desktop 启动完成（状态栏会显示 Docker 图标）

### 步骤3：验证安装

打开终端，运行以下命令：

```bash
# 检查Docker版本
docker --version

# 检查Docker Compose版本
docker-compose --version
# 或（新版本）
docker compose version

# 测试Docker是否运行
docker ps
```

如果命令正常执行，说明安装成功！

## 方法2：使用 Homebrew（命令行安装）

如果你已经安装了 Homebrew，可以使用命令行安装：

### 安装 Docker Desktop

```bash
# 安装Docker Desktop
brew install --cask docker

# 启动Docker Desktop
open /Applications/Docker.app
```

### 或者只安装 Docker Engine（不推荐，较复杂）

```bash
# 安装Docker
brew install docker

# 安装Docker Compose
brew install docker-compose
```

## 安装后配置

### 1. 启动 Docker Desktop

- 从 Applications 启动 Docker Desktop
- 等待状态栏显示 Docker 图标（鲸鱼图标）
- 图标变为绿色表示 Docker 正在运行

### 2. 验证安装

运行以下命令验证：

```bash
# 检查Docker版本
docker --version
# 应该显示类似: Docker version 24.0.0, build ...

# 检查Docker Compose版本
docker-compose --version
# 或
docker compose version
# 应该显示类似: Docker Compose version v2.20.0

# 测试Docker是否运行
docker ps
# 应该显示容器列表（可能为空）
```

### 3. 测试 Docker

运行一个测试容器：

```bash
# 运行Hello World容器
docker run hello-world
```

如果看到 "Hello from Docker!" 消息，说明安装成功！

## 常见问题

### 问题1：Docker Desktop 无法启动

**解决方案**：
1. 检查系统要求：
   - macOS 10.15 或更高版本
   - 至少 4GB RAM
   - 虚拟化支持已启用

2. 重启 Mac

3. 检查系统权限设置

### 问题2：权限错误

**症状**：运行 `docker` 命令时提示权限错误

**解决方案**：
1. 确保 Docker Desktop 正在运行
2. 将用户添加到 docker 组（通常 Docker Desktop 会自动处理）
3. 重启终端

### 问题3：Docker Desktop 启动慢

**解决方案**：
- 首次启动需要一些时间初始化
- 确保有足够的磁盘空间
- 关闭其他占用资源的应用

## 下一步

安装完成后，你可以：

1. **启动本地开发环境**：
   ```bash
   ./start-local.sh
   ```

2. **测试服务**：
   ```bash
   ./test-local.sh
   ```

3. **查看详细指南**：
   - `LOCAL_DEV.md` - 本地开发环境设置

## 卸载 Docker Desktop

如果需要卸载：

1. 退出 Docker Desktop（右键点击状态栏图标 → Quit）

2. 删除应用程序：
   ```bash
   rm -rf /Applications/Docker.app
   ```

3. 清理配置文件（可选）：
   ```bash
   rm -rf ~/.docker
   ```

## 相关资源

- Docker Desktop 官网：https://www.docker.com/products/docker-desktop/
- Docker 文档：https://docs.docker.com/
- Docker Compose 文档：https://docs.docker.com/compose/
