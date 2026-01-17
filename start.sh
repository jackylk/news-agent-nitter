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
  echo "解析REDIS_URL: $REDIS_URL"
  # 解析Redis URL格式：redis://[password@]host:port[/db]
  # 提取host（在@之后，:之前）
  REDIS_HOST=$(echo "$REDIS_URL" | sed -E 's|redis://([^@]+@)?([^:/]+).*|\2|')
  # 提取port（在最后一个:之后，/之前）
  REDIS_PORT=$(echo "$REDIS_URL" | sed -E 's|redis://[^:]+:([0-9]+).*|\1|')
  if [ "$REDIS_PORT" = "$REDIS_URL" ]; then
    REDIS_PORT="6379"  # 如果没有找到port，使用默认值
  fi
  # 提取password（在://之后，@之前）
  REDIS_PASSWORD=$(echo "$REDIS_URL" | sed -E 's|redis://([^:]+):([^@]+)@.*|\2|' || echo "")
  if [ "$REDIS_PASSWORD" = "$REDIS_URL" ]; then
    REDIS_PASSWORD=""  # 如果没有找到password，清空
  fi
  echo "解析结果 - Host: $REDIS_HOST, Port: $REDIS_PORT, Password: ${REDIS_PASSWORD:+已设置}"
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

# 更新Redis配置（在[Cache]部分内）
if [ -n "$REDIS_HOST" ]; then
  # 更新[Cache]部分的host
  sed "/^\[Cache\]/,/^\[/ s|^host = .*|host = \"$REDIS_HOST\"|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  echo "已更新Redis host: $REDIS_HOST"
fi

if [ -n "$REDIS_PORT" ]; then
  # 更新[Cache]部分的port（在[Cache]和下一个[之间）
  sed "/^\[Cache\]/,/^\[/ s|^port = .*|port = $REDIS_PORT|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  echo "已更新Redis port: $REDIS_PORT"
fi

if [ -n "$REDIS_PASSWORD" ]; then
  # 更新[Cache]部分的password
  sed "/^\[Cache\]/,/^\[/ s|^password = .*|password = \"$REDIS_PASSWORD\"|" "$TEMP_CONFIG" > "$TEMP_SED" && mv "$TEMP_SED" "$TEMP_CONFIG"
  echo "已更新Redis password: [已设置]"
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

# 切换到Nitter可执行文件所在目录（确保sessions.jsonl在正确位置）
NITTER_DIR="$(dirname "$NITTER_BIN")"
cd "$NITTER_DIR" || {
  echo "警告: 无法切换到 $NITTER_DIR，尝试其他目录..."
  cd /src || cd /app || cd /tmp || cd /
}

echo "当前工作目录: $(pwd)"

# 创建sessions.jsonl文件（Nitter需要这个文件，即使是空的）
# 在当前工作目录创建（Nitter查找 ./sessions.jsonl）
SESSIONS_FILE="$(pwd)/sessions.jsonl"
if [ ! -f "$SESSIONS_FILE" ]; then
  if touch "$SESSIONS_FILE" 2>/dev/null; then
    echo "创建sessions.jsonl文件: $SESSIONS_FILE"
  else
    # 如果当前目录不可写，尝试在可写目录创建并创建符号链接
    for WRITABLE_DIR in "/tmp" "/app"; do
      if [ -w "$WRITABLE_DIR" ] 2>/dev/null; then
        TEMP_SESSIONS="$WRITABLE_DIR/sessions.jsonl"
        touch "$TEMP_SESSIONS" 2>/dev/null && ln -sf "$TEMP_SESSIONS" "$SESSIONS_FILE" 2>/dev/null && {
          echo "创建sessions.jsonl文件（通过符号链接）: $SESSIONS_FILE -> $TEMP_SESSIONS"
          break
        }
      fi
    done
  fi
fi

echo "检查sessions.jsonl文件:"
ls -la "$SESSIONS_FILE" 2>/dev/null || ls -la sessions.jsonl 2>/dev/null || echo "警告: sessions.jsonl可能不存在"

# 尝试创建符号链接到/etc（如果/etc可写且Nitter需要）
if [ -w /etc ] 2>/dev/null; then
  ln -sf "$TEMP_CONFIG" /etc/nitter.conf 2>/dev/null && echo "已创建配置文件符号链接"
fi

# 输出最终配置信息用于调试
echo ""
echo "=== 最终配置信息 ==="
echo "Redis配置:"
echo "  REDIS_HOST: ${REDIS_HOST:-未设置}"
echo "  REDIS_PORT: ${REDIS_PORT:-未设置}"
echo "  REDIS_PASSWORD: ${REDIS_PASSWORD:+已设置}"
echo ""
echo "配置文件[Cache]部分:"
grep -A 5 "^\[Cache\]" "$TEMP_CONFIG" || echo "无法读取Cache配置"
echo ""

# 测试Redis连接（如果安装了redis-cli或nc）
echo "测试Redis连接..."
REDIS_CONNECTED=false

# 方法1: 使用redis-cli测试完整连接（包括认证）
if command -v redis-cli >/dev/null 2>&1; then
  echo "使用redis-cli测试Redis连接和认证..."
  if [ -n "$REDIS_PASSWORD" ]; then
    # 尝试使用AUTH命令（只密码）
    REDIS_TEST_CMD="redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning ping 2>&1"
    # 先连接，然后发送AUTH命令
    REDIS_AUTH_TEST="(echo AUTH $REDIS_PASSWORD; echo PING) | redis-cli -h $REDIS_HOST -p $REDIS_PORT --no-auth-warning 2>&1"
  else
    REDIS_TEST_CMD="redis-cli -h $REDIS_HOST -p $REDIS_PORT ping 2>&1"
    REDIS_AUTH_TEST=""
  fi
  
  RETRY_COUNT=0
  MAX_RETRIES=5
  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if [ -n "$REDIS_PASSWORD" ] && [ -n "$REDIS_AUTH_TEST" ]; then
      # 测试带密码的连接
      RESULT=$(eval "$REDIS_AUTH_TEST")
      if echo "$RESULT" | grep -q "PONG"; then
        echo "✅ Redis连接和认证成功！"
        REDIS_CONNECTED=true
        break
      fi
      # 如果AUTH方式失败，尝试使用-a参数
      RESULT=$(redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" -a "$REDIS_PASSWORD" --no-auth-warning ping 2>&1)
    else
      RESULT=$(eval "$REDIS_TEST_CMD")
    fi
    
    if echo "$RESULT" | grep -q "PONG"; then
      echo "✅ Redis连接成功！"
      REDIS_CONNECTED=true
      break
    else
      RETRY_COUNT=$((RETRY_COUNT + 1))
      if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        echo "⏳ Redis连接失败: $RESULT，等待3秒后重试 ($RETRY_COUNT/$MAX_RETRIES)..."
        sleep 3
      else
        echo "⚠️  Redis连接测试失败: $RESULT"
        echo "   但将继续启动Nitter（Nitter可能会重试连接）"
        echo "   提示：如果Nitter仍然无法连接，可能是Redis认证方式不兼容"
      fi
    fi
  done
# 方法2: 使用nc (netcat) 测试端口
elif command -v nc >/dev/null 2>&1; then
  echo "使用nc测试Redis端口连接..."
  if nc -z -w 3 "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; then
    echo "✅ Redis端口可访问（但未测试认证）"
    REDIS_CONNECTED=true
  else
    echo "⚠️  Redis端口不可访问，但将继续启动Nitter"
  fi
else
  echo "⚠️  redis-cli和nc都未安装，跳过Redis连接测试"
  echo "   提示：Nitter会在启动后自动重试连接Redis"
fi

# 输出Redis连接信息用于调试
echo ""
echo "Redis连接信息："
echo "  Host: $REDIS_HOST"
echo "  Port: $REDIS_PORT"
echo "  Password: ${REDIS_PASSWORD:+已设置（长度: ${#REDIS_PASSWORD}）}"
echo "  连接测试: ${REDIS_CONNECTED:+✅ 成功}${REDIS_CONNECTED:-❌ 失败}"
echo ""

echo ""
echo "启动Nitter..."

# 重要提示：即使Redis连接失败，Nitter仍然可以启动
# RSS功能可能仍然可用（不依赖Redis缓存）
if [ "$REDIS_CONNECTED" != "true" ]; then
  echo ""
  echo "⚠️  警告：Redis连接测试未通过"
  echo "   Nitter仍会启动，但功能可能受限："
  echo "   - RSS功能通常仍然可用（不依赖Redis）"
  echo "   - 缓存功能不可用"
  echo "   - 如果Nitter启动后仍显示Redis错误，这是正常的"
  echo "   - 可以尝试访问RSS端点测试功能是否正常"
  echo ""
fi

# 启动Nitter，使用-c参数指定配置文件路径
# 注意：Nitter可能会在启动时尝试连接Redis，如果失败会显示错误
# 但这不影响RSS功能的正常使用
exec "$NITTER_BIN" -c "$TEMP_CONFIG"
