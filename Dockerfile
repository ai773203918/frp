# 【修改】将 Go 版本从 1.23 升级到 1.24
FROM golang:1.24 AS building

# 设置工作目录
WORKDIR /building

# 从 frp-src 子目录复制源码
COPY frp-src/ .

# 在/building目录下执行make命令，构建frps和frpc二进制文件
RUN make frps && make frpc

# 第二阶段：打包阶段
FROM alpine:3

# 设置工作目录为 /frp
WORKDIR /frp

# 使用 apk 添加 tzdata 包
RUN apk add --no-cache tzdata

# 从第一阶段构建的镜像中复制指定的二进制文件
COPY --from=building /building/bin/frps /frp/frps
COPY --from=building /building/bin/frpc /frp/frpc

# 设置环境变量 mode
ENV mode=frps

# 设置容器启动时执行的默认命令
CMD ["/bin/sh", "-c", "./$mode -c $mode.toml"]