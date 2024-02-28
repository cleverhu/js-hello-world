FROM node:16-alpine AS builder
WORKDIR /app

# 安装 pkg
RUN npm install -g pkg

COPY . .

# 使用环境变量控制 pkg 的目标平台
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        pkg main.js -t node16-linux-x64 --out-path .; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        pkg main.js -t node16-linux-arm64 --out-path .; \
    fi

FROM ghcr.io/phusion/baseimage:jammy-1.0.2
ARG TARGETPLATFORM
COPY --from=builder /app/main* /home/

# 根据 TARGETPLATFORM 环境变量选择不同的二进制文件
CMD if [ "$TARGETPLATFORM" = "linux/amd64" ]; then /home/main-x64; else /home/main-arm64; fi
