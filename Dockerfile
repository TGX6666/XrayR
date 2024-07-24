# Build go
FROM golang:1.22.5-alpine AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go mod download \
    && go build -v -o XrayR -trimpath -ldflags "-s -w -buildid="

# Release
FROM alpine:latest
# 安装必要的工具包
RUN apk --update --no-cache add curl tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir /sri/ \
    && curl -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat" -o /sri/geoip.dat \
    && curl -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat" -o /sri/geosite.dat

COPY --from=builder /app/XrayR /usr/local/bin

ENTRYPOINT [ "XrayR", "--config", "/sri/config.yml"]
