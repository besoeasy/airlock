<div align="center">

# Airlock

**Run untrusted code without trusting it.**

Copy a command. Get a hardened shell. Nothing touches your machine.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](#license)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](#)

</div>

---

## The problem

Every time you run `npm install`, `pip install`, or `go run` in a cloned repo, that code gets full access to your SSH keys, dotfiles, `.env` files, and everything else on your machine.

## The fix

Airlock gives you copy-pasteable commands that spin up a disposable, hardened container. Your current directory is mounted at `/workspace`. Exit the shell — the container is destroyed.

```
  Your Machine              Airlock              Container
 ┌────────────────┐        ┌─────────┐        ┌──────────────────────┐
 │  ~/.ssh        │    x   │         │        │  /workspace          │
 │  ~/.config     │    x   │ airlock │ ─────▶ │  your project files  │
 │  ~/Documents   │    x   │         │        │  isolated runtime    │
 │  ./project  ───│────────│─────────│───────▶│  no host access      │
 └────────────────┘        └─────────┘        └──────────────────────┘
```

---

## Quick start

Pick your runtime. Paste the command. You're in.

### Node.js

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e npm_config_cache=/workspace/.npm-cache \
  -e NODE_ENV=development \
  node:lts bash
```

### Bun

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e BUN_INSTALL_CACHE_DIR=/workspace/.bun-cache \
  oven/bun:latest bash
```

### Deno

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e DENO_DIR=/workspace/.deno-cache \
  --entrypoint /bin/bash \
  denoland/deno:latest
```

### Python

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e PIP_CACHE_DIR=/workspace/.pip-cache \
  -e HOME=/workspace \
  python:3 bash
```

### Go

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e GOPATH=/workspace/.go \
  -e HOME=/workspace \
  golang:latest bash
```

### Rust

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e CARGO_HOME=/workspace/.cargo \
  -e HOME=/workspace \
  rust:latest bash
```

### Zig

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e ZIG_GLOBAL_CACHE_DIR=/workspace/.zig-cache \
  --entrypoint /bin/sh \
  euantorano/zig:latest
```

### Debian

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e HOME=/workspace \
  debian:stable bash
```

### Alpine

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
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

Every command above works with Podman. Replace `docker` with `podman`:

```bash
podman run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e npm_config_cache=/workspace/.npm-cache \
  node:lts bash
```

---

## What the flags do

| Flag | Purpose |
|------|---------|
| `--read-only` | Container filesystem is read-only. Only `/workspace` and `/tmp` are writable. |
| `--tmpfs /tmp:exec` | Writable `/tmp` for package managers and build tools. |
| `--cap-drop ALL` | Drops all Linux capabilities. Container can't do privileged operations. |
| `--security-opt no-new-privileges` | Prevents processes from gaining privileges via setuid/setgid binaries. |
| `--pids-limit 256` | Fork bomb protection. Caps process count at 256. |
| `-v "${PWD}:/workspace"` | Mounts your current directory into the container. |
| `-w /workspace` | Sets the working directory inside the container. |
| `--rm` | Container is deleted when you exit. Nothing persists. |

---

## Resource limits

Add memory and CPU limits if you want extra protection:

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  --memory 4g \
  --cpus 2 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  node:lts bash
```

---

## Network access

By default, containers have network access (needed for `npm install`, `pip install`, etc.). To block network access entirely:

```bash
docker run -it --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  --network none \
  -v "${PWD}:/workspace" \
  -w /workspace \
  node:lts bash
```

---

## Run a command without a shell

Execute a single command and exit:

```bash
docker run --rm \
  --read-only --tmpfs /tmp:exec \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 256 \
  -v "${PWD}:/workspace" \
  -w /workspace \
  -e npm_config_cache=/workspace/.npm-cache \
  node:lts npm test
```

---

## Save as an alias

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
airlock-node() {
  docker run -it --rm \
    --read-only --tmpfs /tmp:exec \
    --cap-drop ALL \
    --security-opt no-new-privileges \
    --pids-limit 256 \
    -v "${PWD}:/workspace" \
    -w /workspace \
    -e npm_config_cache=/workspace/.npm-cache \
    node:lts bash
}

airlock-python() {
  docker run -it --rm \
    --read-only --tmpfs /tmp:exec \
    --cap-drop ALL \
    --security-opt no-new-privileges \
    --pids-limit 256 \
    -v "${PWD}:/workspace" \
    -w /workspace \
    -e PIP_CACHE_DIR=/workspace/.pip-cache \
    -e HOME=/workspace \
    python:3 bash
}

airlock-go() {
  docker run -it --rm \
    --read-only --tmpfs /tmp:exec \
    --cap-drop ALL \
    --security-opt no-new-privileges \
    --pids-limit 256 \
    -v "${PWD}:/workspace" \
    -w /workspace \
    -e GOPATH=/workspace/.go \
    -e HOME=/workspace \
    golang:latest bash
}
```

Then run `airlock-node`, `airlock-python`, or `airlock-go` from any directory.

---

## License

MIT
