# metrix

Go health-check service tối giản. Expose một endpoint `/healthz` trả về JSON gồm status, hostname, uptime và thời gian hiện tại.

## Endpoint

`GET /healthz`

```json
{
  "status": "ok",
  "host": "ae280d822a12",
  "uptime": "947.467592ms",
  "time": "2026-06-30T03:58:27Z"
}
```

## Cấu hình

| Env    | Mặc định | Mô tả              |
| ------ | -------- | ------------------ |
| `PORT` | `8080`   | Port HTTP lắng nghe |

## Chạy local

```bash
go run .
# hoặc đổi port
PORT=9000 go run .

curl localhost:8080/healthz
```

## Docker

Image dùng multi-stage build, nén binary bằng UPX (`--best --lzma`) và chạy bằng non-root user trên Alpine. Image cuối ~11MB.

```bash
docker build -t metrix .
docker run --rm -p 8080:8080 metrix
```

Version Go và Alpine được pin cố định trong [`Dockerfile`](./Dockerfile) (không dùng tag `latest`).

## CI/CD

GitHub Actions workflow [`.github/workflows/docker.yml`](./.github/workflows/docker.yml) build multi-arch (`linux/amd64`, `linux/arm64`) và push lên Docker Hub khi:

- push lên branch `main`
- push tag `v*`
- chạy thủ công (`workflow_dispatch`)

### Secrets cần cấu hình

Tại GitHub repo → Settings → Secrets and variables → Actions:

| Secret               | Mô tả                                                                    |
| -------------------- | ------------------------------------------------------------------------ |
| `DOCKERHUB_USERNAME` | Docker Hub username                                                      |
| `DOCKERHUB_TOKEN`    | Docker Hub access token (Account Settings → Personal access tokens)      |

Image name tự suy ra là `<DOCKERHUB_USERNAME>/metrix`. Tag được sinh tự động: tên branch, semver từ git tag, short SHA, và `latest` cho branch mặc định.

## Cấu trúc

```
metrix/
├── main.go                       # HTTP service + /healthz handler
├── go.mod
├── Dockerfile                    # multi-stage, UPX, version pinned, non-root
├── .dockerignore
├── .gitignore
└── .github/workflows/docker.yml  # CI build & push Docker Hub
```
