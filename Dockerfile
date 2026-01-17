# 使用官方Nitter镜像
FROM zedeus/nitter:latest

# 复制配置文件和启动脚本到/app目录（可写目录）
COPY nitter.conf /app/nitter.conf
COPY start.sh /app/start.sh

# 暴露端口（Railway会自动设置PORT环境变量）
EXPOSE 8080

# 保留镜像的ENTRYPOINT（如果有），只覆盖CMD
# 使用sh执行启动脚本（不需要chmod，更兼容）
ENTRYPOINT []
CMD ["sh", "/app/start.sh"]
