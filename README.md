# metrix

Minimal Go health-check service. Exposes a single `/healthz` endpoint returning JSON with status, hostname, uptime, and current time.

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

## Configuration

| Env    | Default | Description        |
| ------ | ------- | ------------------ |
| `PORT` | `8080`  | HTTP listen port   |

## Run locally

```bash
go run .
# or change the port
PORT=9000 go run .

curl localhost:8080/healthz
```

## Docker

The image uses a multi-stage build, compresses the binary with UPX (`--best --lzma`), and runs as a non-root user on Alpine. Final image is ~11MB.

Pull and run the published image:

```bash
docker run --rm -p 8080:8080 phathdt379/metrix:1.0
```

Or build locally:

```bash
docker build -t metrix .
docker run --rm -p 8080:8080 metrix
```

Go and Alpine versions are pinned in the [`Dockerfile`](./Dockerfile) (no `latest` tag).

## CI/CD

The GitHub Actions workflow [`.github/workflows/docker.yml`](./.github/workflows/docker.yml) builds multi-arch images (`linux/amd64`, `linux/arm64`) and pushes to Docker Hub on:

- push to the `main` branch
- push of a `v*` tag
- manual trigger (`workflow_dispatch`)

### Required secrets

In the GitHub repo → Settings → Secrets and variables → Actions:

| Secret               | Description                                                          |
| -------------------- | ------------------------------------------------------------------- |
| `DOCKERHUB_USERNAME` | Docker Hub username                                                 |
| `DOCKERHUB_TOKEN`    | Docker Hub access token (Account Settings → Personal access tokens) |

The image name is `phathdt379/metrix`. Tags are generated automatically: branch name, semver from git tags, short SHA, and `latest` for the default branch.

## Structure

```
metrix/
├── main.go                       # HTTP service + /healthz handler
├── go.mod
├── Dockerfile                    # multi-stage, UPX, pinned versions, non-root
├── .dockerignore
├── .gitignore
└── .github/workflows/docker.yml  # CI build & push to Docker Hub
```
