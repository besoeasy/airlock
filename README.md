<div align="center">

# Airlock

**Run untrusted code without trusting it.**

Pick a runtime. Paste the command. Exit and it's gone.

</div>

---

## Node.js

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e npm_config_cache=/workspace/.npm-cache \
  node:lts bash
```

## Bun

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e BUN_INSTALL_CACHE_DIR=/workspace/.bun-cache \
  oven/bun:latest bash
```

## Deno

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e DENO_DIR=/workspace/.deno-cache \
  --entrypoint /bin/bash \
  denoland/deno:latest
```

## Python

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e PIP_CACHE_DIR=/workspace/.pip-cache \
  -e HOME=/workspace \
  python:3 bash
```

## Go

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e GOPATH=/workspace/.go \
  -e HOME=/workspace \
  golang:latest bash
```

## Rust

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e CARGO_HOME=/workspace/.cargo \
  -e HOME=/workspace \
  rust:latest bash
```

## Zig

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e ZIG_GLOBAL_CACHE_DIR=/workspace/.zig-cache \
  --entrypoint /bin/sh \
  euantorano/zig:latest
```

## Debian

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e HOME=/workspace \
  debian:stable bash
```

## Alpine

```bash
docker run -it --rm \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e HOME=/workspace \
  alpine:latest sh
```

---

## Podman

Replace `docker` with `podman`. Everything else stays the same.

---

## Flags

| Flag | What it does |
|------|-------------|
| `--cap-drop ALL` | Drops all Linux capabilities |
| `--security-opt no-new-privileges` | No setuid escalation |
| `--pids-limit 256` | Fork bomb protection |
| `-v "${PWD}:/workspace"` | Mounts current directory |
| `--rm` | Container deleted on exit |

---

## Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
airlock-node() {
  docker run -it --rm --cap-drop ALL --security-opt no-new-privileges --pids-limit 256 \
    -v "${PWD}:/workspace" -w /workspace -e npm_config_cache=/workspace/.npm-cache \
    node:lts bash
}

airlock-python() {
  docker run -it --rm --cap-drop ALL --security-opt no-new-privileges --pids-limit 256 \
    -v "${PWD}:/workspace" -w /workspace -e PIP_CACHE_DIR=/workspace/.pip-cache -e HOME=/workspace \
    python:3 bash
}

airlock-go() {
  docker run -it --rm --cap-drop ALL --security-opt no-new-privileges --pids-limit 256 \
    -v "${PWD}:/workspace" -w /workspace -e GOPATH=/workspace/.go -e HOME=/workspace \
    golang:latest bash
}
```

---

## License

MIT
