#!/bin/bash

# 本地环境测试脚本

echo "🧪 测试本地开发环境..."
echo ""

# 测试Redis
echo "1️⃣ 测试Redis连接..."
if docker-compose exec -T redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
    echo "   ✅ Redis运行正常"
else
    echo "   ❌ Redis连接失败"
fi

# 测试Nitter
echo ""
echo "2️⃣ 测试Nitter服务..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|301\|302"; then
    echo "   ✅ Nitter运行正常 (http://localhost:8080)"
else
    echo "   ⚠️  Nitter可能还在启动中或未运行"
fi

# 测试Nitter RSS
echo ""
echo "3️⃣ 测试Nitter RSS端点..."
RSS_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/OpenAI/rss 2>/dev/null)
if [ "$RSS_TEST" = "200" ]; then
    echo "   ✅ RSS端点正常 (http://localhost:8080/OpenAI/rss)"
    echo "   📄 尝试获取RSS内容..."
    curl -s http://localhost:8080/OpenAI/rss | head -20
    echo ""
else
    echo "   ⚠️  RSS端点返回: HTTP $RSS_TEST"
    echo "   （可能Nitter还在启动中，或需要Twitter session token）"
fi

# 测试前端服务
echo ""
echo "4️⃣ 测试前端服务..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null | grep -q "200"; then
    echo "   ✅ 前端服务运行正常 (http://localhost:3000)"
else
    echo "   ⚠️  前端服务未运行，请运行: node proxy-server.js"
fi

# 测试前端API
echo ""
echo "5️⃣ 测试前端API代理..."
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/api/rss?url=http://localhost:8080/OpenAI/rss" 2>/dev/null | grep -q "200"; then
    echo "   ✅ 前端API代理正常"
else
    echo "   ⚠️  前端API代理未运行或Nitter未就绪"
fi

echo ""
echo "📋 服务地址："
echo "   - Redis: localhost:6379"
echo "   - Nitter: http://localhost:8080"
echo "   - 前端: http://localhost:3000"
echo ""
echo "💡 提示："
echo "   - 如果RSS返回空内容，可能需要Twitter session token"
echo "   - 如果服务未运行，请使用 ./start-local.sh 启动"
echo ""
