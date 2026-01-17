#!/bin/bash

# Nitter前端测试工具启动脚本

echo "🚀 启动Nitter前端测试工具..."
echo ""

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "❌ 未检测到Node.js，请先安装Node.js"
    echo ""
    echo "可以使用以下方式启动："
    echo "1. 使用Python: python3 -m http.server 8000"
    echo "2. 使用PHP: php -S localhost:8000"
    echo "3. 直接打开 index.html 文件（可能遇到CORS问题）"
    exit 1
fi

# 启动代理服务器
echo "✅ 检测到Node.js"
echo "📡 启动代理服务器..."
echo ""
echo "访问地址: http://localhost:3000"
echo "按 Ctrl+C 停止服务器"
echo ""

node proxy-server.js
