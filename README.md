<div align="center">

# Airlock

**Run untrusted code without trusting it.**

Pick a runtime. Paste the command. Exit and it's gone.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/airlock.sh | bash
```

Pick a runtime from the menu. Or pass it directly: `bash -s -- node`

</div>

---

## Node.js

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e npm_config_cache=/workspace/.npm-cache \
  node:lts bash
```

## Bun

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e BUN_INSTALL_CACHE_DIR=/workspace/.bun-cache \
  oven/bun:latest bash
```

## Deno

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e DENO_DIR=/workspace/.deno-cache \
  --entrypoint /bin/bash \
  denoland/deno:latest
```

## Python

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e PIP_CACHE_DIR=/workspace/.pip-cache \
  -e HOME=/workspace \
  python:3 bash
```

## Go

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e GOPATH=/workspace/.go -e HOME=/workspace \
  golang:latest bash
```

## Rust

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e CARGO_HOME=/workspace/.cargo -e HOME=/workspace \
  rust:latest bash
```

## Zig

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e ZIG_GLOBAL_CACHE_DIR=/workspace/.zig-cache \
  --entrypoint /bin/sh \
  euantorano/zig:latest
```

## Debian

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e HOME=/workspace \
  debian:stable bash
```

## Alpine

```bash
docker run -it --rm --pids-limit 256 \
  -v "${PWD}:/workspace" -w /workspace \
  -e HOME=/workspace \
  alpine:latest sh
```

---

Replace `docker` with `podman` if needed.

---

## License

MIT
