<div align="center">

# 🔒 Airlock

**Run untrusted code without trusting it.**

A single bash script that spins up a disposable, isolated container for any project — so `npm install` can't touch your SSH keys, dotfiles, or anything else that matters.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](#license)
[![Version](https://img.shields.io/badge/version-0.0.8-green.svg)](version.txt)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)](#)
[![Shell](https://img.shields.io/badge/shell-bash-89e051.svg)](#)

</div>

---

## The problem

Every time you clone a repo and run `npm install`, `pip install`, or `go run`, you're giving that code full access to your machine. Post-install scripts, typosquatted packages, and supply-chain attacks don't need a phishing link — they just need you to trust a repo you skimmed for five minutes.

Your SSH keys, browser sessions, `.env` files, and home directory are all one `curl | bash` away from being compromised.

## The fix

```
  Your Machine            Airlock              Container
 ┌────────────────┐      ┌─────────┐      ┌──────────────────────┐
 │  ~/.ssh        │  ✗   │         │      │  /workspace          │
 │  ~/.config     │  ✗   │ airlock │ ───▶ │  your project files  │
 │  ~/Documents   │  ✗   │         │      │  isolated runtime    │
 │  ./project  ───│──────│─────────│─────▶│  no host access      │
 └────────────────┘      └─────────┘      └──────────────────────┘
```

Airlock mounts only your **current directory** into a throwaway container. When you're done, the container is gone. Nothing leaks. Nothing persists.

---

## Install

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | bash
```

That's it. The script:
- Downloads the `airlock` binary to `/usr/local/bin`
- If Docker or Podman isn't found, **automatically installs Podman** for you
  - **Linux**: supports Debian, Ubuntu, Fedora, Arch, openSUSE, Alpine, RHEL, and more
  - **macOS**: installs via Homebrew and initializes a Podman machine, or guides you to Docker Desktop

### macOS prerequisite

Airlock works on macOS with **Docker Desktop** or **Podman Desktop** — both are free:

| Option | Link |
|--------|------|
| Docker Desktop | https://www.docker.com/products/docker-desktop/ |
| Podman Desktop | https://podman-desktop.io/ |
| Homebrew + Podman | `brew install podman && podman machine init && podman machine start` |

No Node.js. No Python. No package manager. Just bash and a container runtime.

---

## Usage

### Interactive menu

```bash
airlock
```

Launches a numbered menu — pick your runtime, get a shell.

### Direct launch

```bash
airlock node      # Node.js LTS shell
airlock bun       # Bun shell
airlock python    # Python 3 shell
airlock go        # Go shell
airlock rust      # Rust shell
airlock debian    # Debian stable shell
airlock alpine    # Alpine Linux shell
```

Your current directory is mounted at `/workspace` inside the container. Work as normal. Exit the shell — the container is destroyed. Nothing left behind.

### Available runtimes

| Command | Image |
|---------|-------|
| `airlock debian` | `debian:stable` |
| `airlock alpine` | `alpine:latest` |
| `airlock node` | `node:lts` |
| `airlock bun` | `oven/bun:latest` |
| `airlock python` | `python:3` |
| `airlock go` | `golang:latest` |
| `airlock rust` | `rust:latest` |

Each image is pre-configured with sensible cache paths inside `/workspace` so tools like `npm`, `pip`, `cargo`, and `go` work correctly without writing to your host.

---

## Project config

Drop a `.airlock` file in any repo to pin the runtime:

```ini
image=node
```

Now `airlock` (with no arguments) in that directory will automatically launch the right environment — no flags, no thinking.

Great for open-source projects: commit `.airlock` so contributors get the correct runtime automatically.

---

## Why it's just one bash script

No daemon. No config system. No agent running in the background. Airlock is ~350 lines of bash that wraps Docker/Podman with the right flags. You can read the whole thing in 5 minutes, audit it, and trust it.

It also **self-updates silently** — on each run it checks for a newer version and replaces itself if one exists.

## Platform support

| Platform | Status | Notes |
|----------|--------|-------|
| Linux | ✅ Full support | Auto-installs Podman if needed |
| macOS | ✅ Full support | Requires Docker Desktop or Podman Desktop |

---

## Uninstall

```bash
sudo rm -f /usr/local/bin/airlock
```

---

## License

MIT