<img width="910" height="592" alt="airlock" src="https://github.com/user-attachments/assets/8dce039c-01e6-459a-b03a-d8630774a38d" />


<div align="center">

# Airlock

**Instant, disposable development environments and sandboxes.**
*Run, build, and test code without cluttering or risking your host machine.*

[![Release](https://img.shields.io/github/v/release/besoeasy/airlock)](https://github.com/besoeasy/airlock/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](#license)
[![Stars](https://img.shields.io/github/stars/besoeasy/airlock)](https://github.com/besoeasy/airlock/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/besoeasy/airlock)](https://github.com/besoeasy/airlock/commits/main)

</div>

## Table of Contents

- [Quickstart](#quickstart)
- [Features](#features)
- [Install & Update](#install--update)
- [Usage](#usage)
- [Supported Runtimes](#supported-runtimes)
- [Development Boxes](#development-boxes)
- [Configuration (`.airlock`)](#configuration-airlock)
- [Supported Host Operating Systems](#supported-host-operating-systems)
- [Environment Variables](#environment-variables)
- [Airlock vs Toolbox](#airlock-vs-toolbox)
- [Use cases](#use-cases)
- [Contributing](#contributing)
- [License](#license)

## Quickstart

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/install.sh | bash

cd my-project
airlock python      # disposable Python sandbox, your project mounted at /workspace
airlock enter mybox # persistent box (asks which OS on first use)
airlock list        # list all persistent boxes
```

Exit a disposable runtime and it's gone — no SDKs, compilers, or toolchains left on your host.

## Features

- **Disposable containers** — exit and everything inside the container is gone
- **Persistent devboxes** — `airlock enter / list / delete` keeps long-lived environments across sessions
- **Live workspace mounting** — mounts your current directory at `/workspace` with instant file sync
- **Zero-prompt launch** — drop a `.airlock` file in any project to bypass menus and prompts
- **Rootless by design** — Podman runs containers as your user, so files in `/workspace` stay yours (no `root:root` ownership issues, no UID mapping hacks)
- **Fork bomb protection** — enforced process limit (`--pids-limit 256`)
- **Podman required** — the installer sets it up automatically when missing; no Docker, no daemon
- **SELinux out of the box** — automatic `:z` volume relabeling for Fedora, RHEL, and CentOS
- **19 runtimes organized into 3 categories** — see [Supported Runtimes](#supported-runtimes) for the full image table

> [!TIP]
> Airlock requires [**Podman**](https://podman.io/). Podman is rootless and daemonless, so containers run with your user permissions — an extra layer of safety when running untrusted or cloned-repo code. The installer installs it for you when missing; manual commands per distro:
> ```bash
> # Debian/Ubuntu
> sudo apt install podman
> # Fedora/RHEL
> sudo dnf install podman
> # Arch
> sudo pacman -S podman
> # macOS
> brew install podman && podman machine init && podman machine start
> ```

## Install & Update

### One-line installer (Recommended)

Handles rootless and system-wide installations automatically, configures `$PATH` across shells (Bash, Zsh, Fish), installs Podman when missing, and updates Airlock when run again. It installs from the latest GitHub release (falling back to `main` when offline):

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/install.sh | bash
```

### System-wide with sudo (Alternative)

Installs directly to `/usr/local/bin` for all users and shells (running the installer as root also records the release version, so `airlock --version` stays accurate):

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/install.sh | sudo bash
```

## Usage

```bash
airlock            # launches .airlock if present, or opens interactive menu
airlock [runtime]  # directly launch a specific runtime (e.g. airlock python)
airlock init       # create a starter .airlock (auto-detects runtime)
airlock enter mybox         # enter a persistent box (asks OS if new)
airlock list                # list all persistent boxes
airlock delete mybox        # delete a persistent box and its state
airlock --version  # show version + latest release (update notice)
airlock --help     # show help and available runtimes
```

### Shell completions

```bash
airlock completion bash >> ~/.bashrc   # or ~/.bash_profile
airlock completion zsh > ~/.zfunc/_airlock
airlock completion fish > ~/.config/fish/completions/airlock.fish
```

## Supported Runtimes

19 disposable runtimes in 3 categories. Run with `airlock <runtime>` (e.g. `airlock python`). Your current directory is mounted at `/workspace`.

| Category | Runtime | Container Image | Aliases / Notes |
|---|---|---|---|
| Programming Languages | `bun` | `docker.io/oven/bun:latest` | `bash` |
| Programming Languages | `c` | `docker.io/library/gcc:latest` | `cpp`, `gcc` — `bash` |
| Programming Languages | `deno` | `docker.io/denoland/deno:latest` | `bash` via `--entrypoint /bin/bash` |
| Programming Languages | `go` | `docker.io/library/golang:latest` | `bash` |
| Programming Languages | `node` | `docker.io/library/node:lts` | `bash` |
| Programming Languages | `php` | `docker.io/library/php:cli` | `bash` |
| Programming Languages | `python` | `docker.io/library/python:3` | `bash` |
| Programming Languages | `ruby` | `docker.io/library/ruby:latest` | `bash` |
| Programming Languages | `rust` | `docker.io/library/rust:latest` | `bash` |
| Programming Languages | `zig` | `docker.io/euantorano/zig:latest` | `sh` via `--entrypoint /bin/sh` |
| Linux Distributions | `alpine` | `docker.io/library/alpine:latest` | `sh` |
| Linux Distributions | `archlinux` | `docker.io/library/archlinux:latest` | `arch` — `bash` |
| Linux Distributions | `debian` | `docker.io/library/debian:stable` | `bash` — default box OS |
| Linux Distributions | `fedora` | `docker.io/library/fedora:latest` | `bash` |
| Linux Distributions | `nix` | `docker.io/nixos/nix:latest` | `sh` |
| Linux Distributions | `ubuntu` | `docker.io/library/ubuntu:latest` | `bash` |
| Tools & Utilities | `kali` | `docker.io/kalilinux/kali-rolling:latest` | `kalilinux` — `bash` |
| Tools & Utilities | `opencode` | `ghcr.io/anomalyco/opencode` | — |
| Tools & Utilities | `trivy` | `docker.io/aquasec/trivy:latest` | `semgrep` — runs `fs /workspace` |

## Development Boxes

Persistent containers that outlive your shell, running with host networking. Unlike the disposable runtimes above, a devbox keeps its state — install packages, run services, and return to the same environment later. Boxes are named `airlock-<name>`. Entering a new name asks which OS to use (Debian default; Alpine, Arch Linux, Fedora, Ubuntu available).

```bash
airlock enter mybox         # enter a box; asks OS (debian, alpine, fedora, ubuntu, archlinux) if new
airlock list                # list all boxes
airlock delete mybox        # delete a box and its state
```

Boxes are independent: they do **not** mount your current directory and do not map your host user, so you can freely run `apt install` as root inside them.

## Configuration (`.airlock`)

Generate a starter file with `airlock init` (auto-detects from `package.json`, `go.mod`, `Cargo.toml`, `requirements.txt`, etc.):

```bash
airlock init node       # explicit runtime
airlock init            # auto-detect or prompt
airlock init --force    # overwrite existing .airlock
```

Drop a `.airlock` file in your repository to pre-configure your runtime environment. When `.airlock` is present, running `airlock` automatically launches the container with your settings and **skips all interactive questions**:

```ini
# .airlock
runtime=node
ports=3000 8080
env=PORT=3000
env=NODE_ENV=development
```

Airlock also supports single-token `.airlock` files (similar to `.nvmrc` or `.python-version`):

```text
python
```

### Supported Keys

| Key | Description | Example |
|---|---|---|
| `runtime` | Target runtime (or single-token name) | `runtime=node` |
| `ports` | Space-separated ports to forward | `ports=3000 8080` |
| `network` | Container network mode | `network=host` or `network=bridge` |
| `user` | Container user override | `user=1000:1000` or `user=root` |
| `env` | Environment variable (repeatable) | `env=DEBUG=express:*` |
| `selinux` | SELinux `:z` flag override | `selinux=1` or `selinux=0` |

## Supported Host Operating Systems

Airlock runs anywhere Podman runs. **Podman is required** — the installer installs it automatically when missing (or install it yourself with the command below):

| Host OS | Install Podman | Security System | Support Status |
|---|---|---|:---:|
| **Fedora** | `sudo dnf install podman` | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **Red Hat Enterprise Linux (RHEL)** | `sudo dnf install podman` | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **CentOS Stream / Rocky / AlmaLinux** | `sudo dnf install podman` | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **Ubuntu** | `sudo apt install podman` | AppArmor | Verified |
| **Debian** | `sudo apt install podman` | AppArmor | Verified |
| **Arch Linux / Manjaro** | `sudo pacman -S podman` | Standard | Verified |
| **openSUSE** (Leap / Tumbleweed) | `sudo zypper install podman` | AppArmor / SELinux | Verified |
| **Alpine Linux** | `sudo apk add podman` | Standard | Verified |
| **macOS** | `brew install podman` (+ `podman machine init && podman machine start`) | Hypervisor VM Isolation | Verified |
| **Windows (via WSL2)** | Install Podman in your WSL2 distro (see Linux rows) | WSL2 Linux Subsystem | Verified |

> [!NOTE]
> **SELinux out of the box:** On SELinux-enforcing hosts like **Fedora** and **RHEL**, Airlock automatically mounts host directories with the `:z` flag so containers have proper access without `Permission denied` errors. You can also manually control this behavior via `AIRLOCK_SELINUX=1` (force enable) or `AIRLOCK_SELINUX=0` (force disable).

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `AIRLOCK_USER` | Override container user and group (e.g. `1000:1000`, `root`) | Container default |
| `AIRLOCK_SELINUX` | Force enable (`1`) or disable (`0`) SELinux `:z` volume relabeling | Auto-detected |

## Airlock vs Toolbox

[Toolbox](https://containertoolbx.org/) is great for a persistent "pet" container on immutable distros — but it's built around one long-lived container tied to your host OS version. Airlock is the modern disposable-first alternative: instant sandboxes per runtime, with persistence only when you ask for it.

| | Toolbox | Airlock |
|---|---|---|
| Model | One persistent pet container | Disposable per-runtime sandboxes + optional persistent devboxes |
| Startup | `toolbox create` / `enter` with a host-matched image | `airlock python` — 19 runtimes, zero setup |
| Runtimes | Single OS userland per toolbox | 10 languages, 6 distros, developer tools (AI & security) |
| Per-project config | None (set up tools by hand inside) | `.airlock` file: runtime, ports, env, network — plus `airlock init` generator |
| Workspace | Shares your entire `$HOME` | Mounts only the current dir at `/workspace`; gone on exit |
| Cleanup | Manual, state accumulates | Exit = gone (`--rm`); devboxes keep state only when you want it |
| Engine / hosts | Podman, Linux-focused | Podman everywhere; macOS and WSL2 supported |
| Shell completions | No | Bash, Zsh, Fish via `airlock completion` |

**Rule of thumb:** Toolbox when you want one persistent shell on an immutable host; Airlock when you want instant, reproducible, throwaway environments per project.

## Use cases

- **Polyglot development:** Test, compile, and run code in 10 languages without installing SDKs or compilers on your host
- **Run AI coding agents:** Run OpenCode inside a container without giving LLMs unrestricted host execution
- **Isolate untrusted dependencies:** Run `npm install`, `bundle install`, or `composer install` without trusting unknown scripts
- **Cross-distro testing:** Test scripts and binary packaging across Alpine, Arch, Debian, Fedora, and Ubuntu
- **Security audits:** Scan repositories for CVEs and secret leaks with Trivy, or inspect binaries in Kali Linux
- **Clean host system:** Keep your personal machine clean of global package managers, dev tools, and toolchains

## Contributing

Contributions are welcome! Fork the repo, create a branch, and open a pull request. Before submitting, check your changes with:

```bash
bash -n airlock
```

Please keep the script dependency-free (Bash + a container engine only) and update this README when adding runtimes or commands.

## License

MIT
