FROM amazoncorretto:17-alpine

# 设置工作目录
WORKDIR /app

# 安装必要的工具
RUN apk add --no-cache curl

# 复制Maven包装器
COPY mvnw .
COPY .mvn .mvn

# 复制pom.xml
COPY pom.xml .

# 复制源代码
COPY src src

# 设置执行权限
RUN chmod +x mvnw

# 构建应用
RUN ./mvnw clean package -DskipTests

# 创建非root用户
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# 创建必要的目录
RUN mkdir -p /app/storage /app/logs && \
    chown -R appuser:appgroup /app

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8088

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8088/api/health || exit 1

# 启动应用
CMD ["java", "-jar", "target/imagent-x-0.0.1-SNAPSHOT.jar"]
