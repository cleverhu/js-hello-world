FROM node:16-alpine AS builder
WORKDIR /app

# 安装 pkg
RUN npm install -g pkg

COPY . .

# 使用环境变量控制 pkg 的目标平台
ARG TARGETPLATFORM
RUN TARGETARCH=`echo $TARGETPLATFORM | cut -d '/' -f2`; \
    PKG_TARGET="node16-linux-x64"; \
    if [ "$TARGETARCH" = "arm64" ]; then \
        PKG_TARGET="node16-linux-arm64"; \
    fi; \
    pkg main.js -t $PKG_TARGET -o server.out

FROM ghcr.io/phusion/baseimage:jammy-1.0.2
ARG TARGETPLATFORM

WORKDIR /home
COPY --from=builder /app/server.out .

# 根据 TARGETPLATFORM 环境变量选择不同的二进制文件
ENTRYPOINT [ "server.out" ] 
