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
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | bash

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
- **25 runtimes organized into 3 categories** — see [Supported Runtimes](#supported-runtimes) for the full image table

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
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | bash
```

### System-wide with sudo (Alternative)

Installs directly to `/usr/local/bin` for all users and shells (running the installer as root also records the release version, so `airlock --version` stays accurate):

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | sudo bash
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

25 disposable runtimes organized into 3 categories. Run with `airlock <runtime>` (e.g. `airlock python`, `airlock gitleaks`). Your current directory is mounted at `/workspace`.

### Programming Languages (10 runtimes)

| Runtime | Container Image | Aliases / Shell |
|---|---|---|
| `bun` | `docker.io/oven/bun:latest` | `bash` |
| `c` | `docker.io/library/gcc:latest` | `cpp`, `gcc` — `bash` |
| `deno` | `docker.io/denoland/deno:latest` | `bash` via `--entrypoint /bin/bash` |
| `go` | `docker.io/library/golang:latest` | `bash` |
| `node` | `docker.io/library/node:lts` | `bash` |
| `php` | `docker.io/library/php:cli` | `bash` |
| `python` | `docker.io/library/python:3` | `bash` |
| `ruby` | `docker.io/library/ruby:latest` | `bash` |
| `rust` | `docker.io/library/rust:latest` | `bash` |
| `zig` | `docker.io/euantorano/zig:latest` | `sh` via `--entrypoint /bin/sh` |

### Linux Distributions (6 runtimes)

| Runtime | Container Image | Aliases / Shell |
|---|---|---|
| `alpine` | `docker.io/library/alpine:latest` | `sh` |
| `archlinux` | `docker.io/library/archlinux:latest` | `arch` — `bash` |
| `debian` | `docker.io/library/debian:stable` | `bash` — default box OS |
| `fedora` | `docker.io/library/fedora:latest` | `bash` |
| `nix` | `docker.io/nixos/nix:latest` | `sh` |
| `ubuntu` | `docker.io/library/ubuntu:latest` | `bash` |

### Tools & Utilities (9 runtimes)

| Subcategory | Runtime | Container Image | Description / Notes |
|---|---|---|---|
| **Linters & Quality** | `hadolint` | `docker.io/hadolint/hadolint:latest-alpine` | Dockerfile linter — `sh` |
| **Linters & Quality** | `semgrep` | `docker.io/semgrep/semgrep:latest` | Static analysis & SAST — runs `semgrep scan` |
| **Linters & Quality** | `shellcheck` | `docker.io/koalaman/shellcheck-alpine:latest` | Shell script static analysis tool — `sh` |
| **Security & Secrets** | `gitleaks` | `docker.io/zricethezav/gitleaks:latest` | Hardcoded secrets & API key detector — runs `detect` |
| **Security & Secrets** | `grype` | `docker.io/anchore/grype:latest` | Dependency & container vulnerability scanner |
| **Security & Secrets** | `kali` | `docker.io/kalilinux/kali-rolling:latest` | `kalilinux` — Penetration testing & auditing (`bash`) |
| **Security & Secrets** | `nmap` | `docker.io/instrumentisto/nmap:latest` | Network discovery & security scanner — `sh` |
| **Security & Secrets** | `trivy` | `docker.io/aquasec/trivy:latest` | Vulnerability & misconfiguration scanner (`fs /workspace`) |
| **AI Coding Agents** | `opencode` | `ghcr.io/anomalyco/opencode` | Autonomous terminal AI coding agent |

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
| Startup | `toolbox create` / `enter` with a host-matched image | `airlock python` — 25 runtimes, zero setup |
| Runtimes | Single OS userland per toolbox | 10 languages, 6 distros, 9 developer tools |
| Per-project config | None (set up tools by hand inside) | `.airlock` file: runtime, ports, env, network — plus `airlock init` generator |
| Workspace | Shares your entire `$HOME` | Mounts only the current dir at `/workspace`; gone on exit |
| Cleanup | Manual, state accumulates | Exit = gone (`--rm`); devboxes keep state only when you want it |
| Engine / hosts | Podman, Linux-focused | Podman everywhere; macOS and WSL2 supported |
| Shell completions | No | Bash, Zsh, Fish via `airlock completion` |

**Rule of thumb:** Toolbox when you want one persistent shell on an immutable host; Airlock when you want instant, reproducible, throwaway environments per project.

## Use cases

- **Polyglot development:** Test, compile, and run code in 10 languages without installing SDKs or compilers on your host
- **Code quality & linting:** Run ShellCheck, Hadolint, and Semgrep to lint scripts, Dockerfiles, and code without local toolchains
- **Security & secret audits:** Scan repositories for CVEs and leaked credentials with Trivy, Grype, Gitleaks, and Nmap, or test tools in Kali Linux
- **Run AI coding agents:** Run OpenCode inside a container without giving LLMs unrestricted host execution
- **Isolate untrusted dependencies:** Run `npm install`, `bundle install`, or `composer install` without trusting unknown scripts
- **Cross-distro testing:** Test scripts and binary packaging across Alpine, Arch, Debian, Fedora, Nix, and Ubuntu
- **Clean host system:** Keep your personal machine clean of global package managers, dev tools, and toolchains

## Contributing

Contributions are welcome! Fork the repo, create a branch, and open a pull request. Before submitting, check your changes with:

```bash
bash -n airlock
```

Please keep the script dependency-free (Bash + a container engine only) and update this README when adding runtimes or commands.

## License

MIT
