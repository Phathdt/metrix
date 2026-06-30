# CLAUDE.md

Hướng dẫn cho Claude Code khi làm việc trong repo này.

## Tổng quan

`metrix` là Go health-check service tối giản. Một file `main.go` chạy HTTP server expose `GET /healthz` trả về JSON (status, hostname, uptime, time). Không có dependency ngoài stdlib.

## Lệnh thường dùng

```bash
# Chạy local (mặc định port 8080, đổi qua env PORT)
go run .
PORT=9000 go run .

# Kiểm tra & build
go vet ./...
go build -o metrix .

# Docker (multi-stage + UPX, image ~11MB)
docker build -t metrix .
docker run --rm -p 8080:8080 metrix

# Test endpoint
curl localhost:8080/healthz
```

## Kiến trúc

- `main.go` — toàn bộ logic: handler `/healthz`, đọc env `PORT`, log lỗi `ListenAndServe`. Biến `start` track uptime từ lúc khởi động.
- `Dockerfile` — 2 stage. Build stage dùng `golang:<ver>-alpine`, nén binary bằng UPX. Runtime stage dùng `alpine:<ver>` pinned, chạy non-root user `app`.
- `.github/workflows/docker.yml` — build multi-arch và push Docker Hub khi push `main`/tag `v*`.

## Quy ước

- **Pin version**: Go và Alpine trong `Dockerfile` luôn pin số cụ thể, KHÔNG dùng tag `latest`. Khi nâng version, cập nhật cả `Dockerfile` và dòng `go` trong `go.mod` cho khớp.
- **Build static**: giữ `CGO_ENABLED=0` và `-ldflags="-s -w" -trimpath` để binary nhỏ, chạy được trên Alpine.
- **Secrets CI**: workflow cần `DOCKERHUB_USERNAME` và `DOCKERHUB_TOKEN` cấu hình trong GitHub repo secrets.
- Giữ service tối giản theo YAGNI/KISS — không thêm framework hay dependency trừ khi thực sự cần.

## Verify sau khi đổi code

1. `go vet ./... && go build -o /tmp/metrix .`
2. Chạy thử và curl `/healthz` để confirm JSON đúng.
3. Nếu đổi `Dockerfile`: `docker build` lại và chạy container test endpoint.
