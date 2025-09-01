# ImagentX后端生产环境Dockerfile
FROM docker.io/library/eclipse-temurin:17-jdk-alpine as builder

# 设置工作目录
WORKDIR /app

# 复制Maven配置文件
COPY ImagentX/pom.xml .
COPY ImagentX/mvnw .
COPY ImagentX/.mvn .mvn

# 修复mvnw执行权限（Windows兼容）
RUN chmod +x ./mvnw

# 下载依赖（利用Docker缓存）
RUN ./mvnw dependency:go-offline -B

# 复制源代码
COPY ImagentX/src src

# 构建应用
RUN ./mvnw clean package -DskipTests -B

# 运行时镜像
FROM docker.io/library/eclipse-temurin:17-jre-alpine

# 安装必要的系统工具
RUN apk add --no-cache curl

# 创建应用用户
RUN addgroup -g 1000 imagentx && adduser -D -s /bin/sh -u 1000 -G imagentx imagentx

# 设置工作目录
WORKDIR /app

# 从构建阶段复制JAR文件
COPY --from=builder /app/target/*.jar app.jar

# 创建日志和存储目录
RUN mkdir -p logs storage && \
    chown -R imagentx:imagentx /app

# 切换到非root用户
USER imagentx

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1

# 暴露端口
EXPOSE 8080

# JVM优化参数
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200"

# 启动命令
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]