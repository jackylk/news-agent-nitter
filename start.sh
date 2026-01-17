#!/bin/sh

# Nitter启动脚本
# 处理Railway环境变量并启动Nitter

# 从环境变量读取配置
NITTER_DOMAIN=${NITTER_DOMAIN:-}
REDIS_URL=${REDIS_URL:-}
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_PASSWORD=${REDIS_PASSWORD:-}
REDIS_DB=${REDIS_DB:-0}
PORT=${PORT:-8080}
NITTER_HMAC_KEY=${NITTER_HMAC_KEY:-}
NITTER_BASE64SECRET=${NITTER_BASE64SECRET:-}

# 如果提供了REDIS_URL，解析它
if [ -n "$REDIS_URL" ]; then
  # 解析Redis URL格式：redis://[password@]host:port[/db]
  REDIS_HOST=$(echo "$REDIS_URL" | sed -E 's|redis://([^:]+:)?([^@]+@)?([^:/]+).*|\3|')
  REDIS_PORT=$(echo "$REDIS_URL" | sed -E 's|redis://[^:]+:([0-9]+).*|\1|' || echo "6379")
  REDIS_PASSWORD=$(echo "$REDIS_URL" | sed -E 's|redis://([^:]+):([^@]+)@.*|\2|' || echo "")
fi

# 配置文件路径（使用/app目录，可写）
CONFIG_FILE="/app/nitter.conf"

# 更新nitter.conf配置文件
if [ -f "$CONFIG_FILE" ]; then
  # 使用sed更新配置文件中的值（在可写目录中操作）
  if [ -n "$NITTER_DOMAIN" ]; then
    sed -i "s|hostname = .*|hostname = \"$NITTER_DOMAIN\"|" "$CONFIG_FILE"
  fi
  
  if [ -n "$PORT" ]; then
    sed -i "s|port = .*|port = $PORT|" "$CONFIG_FILE"
  fi
  
  if [ -n "$REDIS_HOST" ]; then
    sed -i "s|host = .*|host = \"$REDIS_HOST\"|" "$CONFIG_FILE" || echo "host = \"$REDIS_HOST\"" >> "$CONFIG_FILE"
  fi
  
  if [ -n "$REDIS_PORT" ]; then
    sed -i "s|port = .*|port = $REDIS_PORT|" "$CONFIG_FILE" || echo "port = $REDIS_PORT" >> "$CONFIG_FILE"
  fi
  
  if [ -n "$REDIS_PASSWORD" ]; then
    sed -i "s|password = .*|password = \"$REDIS_PASSWORD\"|" "$CONFIG_FILE" || echo "password = \"$REDIS_PASSWORD\"" >> "$CONFIG_FILE"
  fi
  
  if [ -n "$NITTER_HMAC_KEY" ]; then
    sed -i "s|hmacKey = .*|hmacKey = \"$NITTER_HMAC_KEY\"|" "$CONFIG_FILE"
  fi
  
  if [ -n "$NITTER_BASE64SECRET" ]; then
    sed -i "s|base64Secret = .*|base64Secret = \"$NITTER_BASE64SECRET\"|" "$CONFIG_FILE"
  fi
fi

# 查找Nitter可执行文件
NITTER_BIN=""
if [ -f "/usr/bin/nitter" ]; then
  NITTER_BIN="/usr/bin/nitter"
elif [ -f "/app/nitter" ]; then
  NITTER_BIN="/app/nitter"
elif command -v nitter >/dev/null 2>&1; then
  NITTER_BIN="nitter"
else
  echo "错误: 找不到Nitter可执行文件"
  # 列出可能的路径用于调试
  echo "尝试查找Nitter..."
  find /usr /app /opt -name "nitter" -type f 2>/dev/null | head -5
  exit 1
fi

# 尝试创建符号链接到/etc（如果/etc可写）
if [ -w /etc ] 2>/dev/null; then
  ln -sf "$CONFIG_FILE" /etc/nitter.conf 2>/dev/null && echo "已创建配置文件符号链接"
fi

# 启动Nitter，尝试使用-c参数指定配置文件路径
# 如果-c参数不支持，Nitter会使用默认路径（/etc/nitter.conf）
exec "$NITTER_BIN" -c "$CONFIG_FILE"
