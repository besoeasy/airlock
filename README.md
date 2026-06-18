<div align="center">

# Airlock

**Stop running untrusted code on your host.**

Disposable dev environments in Docker or Podman — one command, zero host runtimes.

<br>

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](#license)
[![Version](https://img.shields.io/badge/version-0.0.3-green.svg)](version.txt)

<br>

[Install](#install) · [Usage](#usage) · [Config](#project-config) · [Security](#security)

</div>

---

## Why

Cloning a repo should not mean trusting it.

AI makes it faster than ever to generate code and pull in dependencies — and easier to run `npm install` on a project you skimmed for five minutes. Supply-chain attacks, typosquatted packages, and post-install scripts can reach your home directory, SSH keys, and browser sessions without a phishing link.

If you use Linux, you care about freedom and security. Airlock lets you work normally inside a disposable container instead of giving every repo a seat on your host.

```
  Host machine          Airlock              Container
 ┌─────────────┐      ┌─────────┐      ┌──────────────────┐
 │  your files │ ───▶ │ airlock │ ───▶ │ /workspace       │
 │  ~/.ssh  ✗  │      │  node   │      │ isolated runtime │
 └─────────────┘      └─────────┘      └──────────────────┘
```

**Get pwned less.**

## Features

- **One command** — `airlock node`, `airlock python`, done
- **13 built-in images** — distros and language runtimes, each with tailored container settings
- **Project config** — drop a `.airlock` file in any repo
- **Docker & Podman** — auto-detected; install script can set up Podman for you
- **Self-updating** — checks `version.txt` on startup and updates silently
- **No host runtimes** — nothing to install on your machine except a container engine

## Install

Requires Docker or Podman.

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | bash
```

The install script places `airlock` in `/usr/local/bin`. If no container runtime is found, it installs Podman from your distro's official repos (Debian, Ubuntu, Fedora, Arch, openSUSE, and others).

## Usage

Interactive menu:

```bash
airlock
```

Or launch directly:

```bash
airlock node          # Node.js LTS
airlock python        # Python 3
airlock debian        # Debian stable
```

Your current directory is mounted at `/workspace`. Work inside the container, exit when done — the environment is discarded.

### Images

| Alias | Image |
|-------|-------|
| `debian` | `debian:stable` |
| `alpine` | `alpine:latest` |
| `ubuntu` | `ubuntu:24.04` |
| `arch` | `archlinux:latest` |
| `fedora` | `fedora:latest` |
| `node` | `node:lts` |
| `python` | `python:3` |
| `go` | `golang:latest` |
| `bun` | `oven/bun:latest` |
| `rust` | `rust:latest` |
| `java` | `eclipse-temurin:21` |
| `deno` | `denoland/deno:latest` |
| `zig` | `ziglang/zig:latest` |

## Project config

Add a `.airlock` file to pin defaults for a repo:

```ini
image=node
command=npm test
```

| Key | Description |
|-----|-------------|
| `image` | Alias from the table above, or a full reference (`node:22`, `ghcr.io/org/image`) |
| `command` | Optional command to run instead of an interactive shell |

Running `airlock` with no arguments picks up `.airlock` automatically.

## Security

Airlock reduces risk by keeping development inside containers instead of on your host. It is **not** a guaranteed security boundary — always review unfamiliar code before running it.

## Uninstall

```bash
sudo rm -f /usr/local/bin/airlock /usr/local/bin/version.txt
```

## License

MIT