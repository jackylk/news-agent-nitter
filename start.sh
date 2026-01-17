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

# 使用/tmp目录创建临时配置文件（通常可写）
TEMP_CONFIG="/tmp/nitter.conf"
BASE_CONFIG="/app/nitter.conf"

# 如果基础配置文件存在，复制到临时位置；否则创建新文件
if [ -f "$BASE_CONFIG" ]; then
  cp "$BASE_CONFIG" "$TEMP_CONFIG"
else
  # 创建默认配置文件
  cat > "$TEMP_CONFIG" << 'EOF'
# Nitter配置文件
[Server]
address = "0.0.0.0"
port = 8080
https = false
title = "Nitter"
hostname = "localhost"

[Cache]
host = "redis"
port = 6379
password = ""
db = 0

[Config]
hmacKey = "change-me"
base64Secret = "change-me"
enableRSS = true
enableDebug = false
proxy = ""

[Theme]
theme = "auto"

[Replace]
twitter = "twitter.com"
x = "x.com"
EOF
fi

# 使用临时文件进行sed操作（避免权限问题）
TEMP_SED="/tmp/nitter.conf.tmp"

# 更新配置值
if [ -n "$NITTER_DOMAIN" ]; then
  sed "s|hostname = .*|hostname = \"$NITTER_DOMAIN\"|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
fi

if [ -n "$PORT" ]; then
  sed "s|port = .*|port = $PORT|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
fi

if [ -n "$REDIS_HOST" ]; then
  if grep -q "^host = " "$TEMP_CONFIG"; then
    sed "s|^host = .*|host = \"$REDIS_HOST\"|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  else
    # 在[Cache]部分后添加
    sed "/^\[Cache\]/a host = \"$REDIS_HOST\"" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  fi
fi

if [ -n "$REDIS_PORT" ]; then
  # 更新Cache部分的port（在[Cache]和下一个[之间）
  if grep -A 10 "^\[Cache\]" "$TEMP_CONFIG" | grep -q "^port = "; then
    sed "/^\[Cache\]/,/^\[/ s|^port = .*|port = $REDIS_PORT|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  else
    # 如果Cache部分没有port，在host后面添加
    sed "/^\[Cache\]/a port = $REDIS_PORT" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  fi
fi

if [ -n "$REDIS_PASSWORD" ]; then
  if grep -q "^password = " "$TEMP_CONFIG"; then
    sed "s|^password = .*|password = \"$REDIS_PASSWORD\"|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  else
    sed "/^\[Cache\]/a password = \"$REDIS_PASSWORD\"" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  fi
fi

if [ -n "$NITTER_HMAC_KEY" ]; then
  sed "s|hmacKey = .*|hmacKey = \"$NITTER_HMAC_KEY\"|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
fi

if [ -n "$NITTER_BASE64SECRET" ]; then
  sed "s|base64Secret = .*|base64Secret = \"$NITTER_BASE64SECRET\"|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
fi

# 查找Nitter可执行文件
NITTER_BIN=""

# 先尝试常见的路径
for path in "/usr/bin/nitter" "/usr/local/bin/nitter" "/app/nitter" "/opt/nitter/nitter" "/nitter"; do
  if [ -f "$path" ] && [ -x "$path" ]; then
    NITTER_BIN="$path"
    echo "在标准路径找到Nitter: $NITTER_BIN"
    break
  fi
done

# 如果还没找到，尝试在PATH中查找
if [ -z "$NITTER_BIN" ]; then
  if command -v nitter >/dev/null 2>&1; then
    NITTER_BIN="nitter"
    echo "在PATH中找到Nitter: $NITTER_BIN"
  fi
fi

# 如果还是找不到，尝试更广泛的查找
if [ -z "$NITTER_BIN" ]; then
  echo "尝试广泛查找Nitter可执行文件..."
  # 查找所有可能的nitter文件
  FOUND=$(find / -name "nitter" -type f -executable 2>/dev/null | head -1)
  if [ -n "$FOUND" ]; then
    NITTER_BIN="$FOUND"
    echo "找到Nitter: $NITTER_BIN"
  else
    echo "警告: 找不到Nitter可执行文件，尝试其他方法..."
    echo "当前PATH: $PATH"
    echo "查找所有nitter相关文件:"
    find /usr /app /opt /bin /sbin /root /home -name "*nitter*" -type f 2>/dev/null | head -20
    echo ""
    echo "查找所有可执行文件:"
    find /usr/bin /usr/local/bin /app /opt -type f -executable 2>/dev/null | head -20
    echo ""
    echo "检查镜像的默认ENTRYPOINT/CMD..."
    # 尝试直接运行nitter（可能镜像有ENTRYPOINT）
    # 设置配置文件环境变量
    export NITTER_CONFIG="$TEMP_CONFIG"
    # 尝试直接执行
    echo "尝试直接执行: nitter -c $TEMP_CONFIG"
    if command -v nitter >/dev/null 2>&1 || which nitter >/dev/null 2>&1; then
      exec nitter -c "$TEMP_CONFIG"
    else
      echo "错误: 无法找到或执行Nitter"
      echo "请检查Nitter镜像是否正确，或联系镜像维护者"
      exit 1
    fi
  fi
fi

echo "使用Nitter: $NITTER_BIN"
echo "使用配置文件: $TEMP_CONFIG"

# 尝试创建符号链接到/etc（如果/etc可写且Nitter需要）
if [ -w /etc ] 2>/dev/null; then
  ln -sf "$TEMP_CONFIG" /etc/nitter.conf 2>/dev/null && echo "已创建配置文件符号链接"
fi

# 启动Nitter，使用-c参数指定配置文件路径
exec "$NITTER_BIN" -c "$TEMP_CONFIG"
