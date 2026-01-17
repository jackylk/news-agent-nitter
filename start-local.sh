#!/bin/bash

# 本地开发环境一键启动脚本

set -e

echo "🚀 启动本地开发环境..."
echo ""

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker未运行，请先启动Docker"
    exit 1
fi

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ 未检测到Node.js，请先安装Node.js"
    exit 1
fi

echo "✅ 环境检查通过"
echo ""

# 生成密钥（如果不存在）
if [ ! -f .env ]; then
    echo "📝 生成环境变量..."
    NITTER_HMAC_KEY=$(openssl rand -hex 32)
    NITTER_BASE64SECRET=$(openssl rand -base64 32)
    
    cat > .env << EOF
NITTER_HMAC_KEY=$NITTER_HMAC_KEY
NITTER_BASE64SECRET=$NITTER_BASE64SECRET
NITTER_DOMAIN=localhost:8080
REDIS_HOST=redis
REDIS_PORT=6379
EOF
    echo "✅ 已创建.env文件"
fi

# 加载环境变量
export $(cat .env | grep -v '^#' | xargs)

echo "🐳 启动Docker服务（Redis + Nitter）..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 检查服务状态
echo ""
echo "📊 服务状态："
docker-compose ps

echo ""
echo "🔍 检查Redis连接..."
if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis运行正常"
else
    echo "⚠️  Redis可能还在启动中，请稍候..."
fi

echo ""
echo "🌐 启动前端服务..."
echo "   前端地址: http://localhost:3000"
echo "   Nitter地址: http://localhost:8080"
echo ""
echo "   按 Ctrl+C 停止所有服务"
echo ""

# 启动前端服务（前台运行）
node proxy-server.js
