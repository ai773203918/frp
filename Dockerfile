# 第一阶段：构建阶段，使用golang:1.23作为基础镜像
FROM golang:1.23 AS building
# 将当前目录(包含Dockerfile的目录)下的文件复制到容器中的/building目录
COPY . /building
# 设置工作目录为/building
WORKDIR /building
# 在/building目录下执行make命令，构建frps和frpc二进制文件
RUN make frps && make frpc

# 第二阶段：构建基础镜像，使用alpine:3
FROM alpine:3
# 设置工作目录为/frp
WORKDIR /frp
# 使用apk(Alpine Linux的包管理器)添加tzdata包，用于提供时区数据，但不缓存
RUN apk add --no-cache tzdata
# 从第一阶段构建的镜像中复制frps二进制文件到当前镜像的/frp目录
COPY --from=building /building/bin/frps /frp/frps
# 从第一阶段构建的镜像中复制frpc二进制文件到当前镜像的/frp目录
COPY --from=building /building/bin/frpc /frp/frpc
# 设置环境变量mode，用于选择启动frps(服务端)还是frpc(客户端)
ENV mode=frps
# ENTRYPOINT ["/frp/$mode -c /frp/$mode.toml"]  # ENTRYPOINT 无法使用变量，不能作为启动命令，故使用 CMD
# 设置容器启动时执行的默认命令，根据mode变量来决定启动文件+配置文件
CMD ["/bin/sh", "-c", "./$mode -c $mode.toml"]
# 注意，必须挂载配置文件才能启动