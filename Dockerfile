# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM golang:1.26.4-alpine3.24 AS builder

# UPX để nén binary
RUN apk add --no-cache upx ca-certificates

WORKDIR /src

# Cache dependencies (chỉ chạy lại khi go.mod/go.sum đổi)
COPY go.mod ./
RUN go mod download

COPY . .

# Build static binary, strip symbols (-s -w) để giảm size
RUN CGO_ENABLED=0 GOOS=linux go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /out/metrix . \
    && upx --best --lzma /out/metrix

# ---- Runtime stage ----
FROM alpine:3.24.1

RUN apk add --no-cache ca-certificates \
    && addgroup -S app && adduser -S app -G app

COPY --from=builder /out/metrix /usr/local/bin/metrix

USER app

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/metrix"]
