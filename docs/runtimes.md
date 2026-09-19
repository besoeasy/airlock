# Supported Runtimes

Airlock supports **25 disposable runtimes** organized into 3 distinct categories.

Run any runtime directly using:
```bash
airlock <runtime>
```

When started, your current directory is mounted at `/workspace`. Changes to your files are synced live to your host machine. Any files written outside `/workspace` or packages installed inside the container are discarded immediately when you exit (`--rm`).

---

## 1. Programming Languages (10 Runtimes)

Pre-configured development toolchains for building, running, and testing code without installing compilers or language SDKs on your host.

| Runtime | Container Image | Aliases / Shell | Description |
|---|---|---|---|
| `bun` | `docker.io/oven/bun:latest` | `bash` | All-in-one JavaScript & TypeScript runtime, bundler, and package manager |
| `c` | `docker.io/library/gcc:latest` | `cpp`, `gcc` — `bash` | GCC GNU Compiler Collection for C and C++ |
| `deno` | `docker.io/denoland/deno:latest` | `bash` via `--entrypoint /bin/bash` | Modern, secure JavaScript and TypeScript runtime |
| `go` | `docker.io/library/golang:latest` | `bash` | Go programming language toolchain and compiler |
| `node` | `docker.io/library/node:lts` | `bash` | Node.js Long Term Support (LTS) with `npm` and `corepack` |
| `php` | `docker.io/library/php:cli` | `bash` | PHP Command Line Interface (CLI) |
| `python` | `docker.io/library/python:3` | `bash` | Python 3 with `pip` |
| `ruby` | `docker.io/library/ruby:latest` | `bash` | Ruby with `gem` and `bundler` |
| `rust` | `docker.io/library/rust:latest` | `bash` | Rust toolchain with `rustc` and `cargo` |
| `zig` | `docker.io/euantorano/zig:latest` | `sh` via `--entrypoint /bin/sh` | Zig compiler and build system |

---

## 2. Linux Distributions (6 Runtimes)

Clean, minimal operating system environments for cross-distribution testing, shell scripting, package validation, and debugging.

| Runtime | Container Image | Aliases / Shell | Description |
|---|---|---|---|
| `alpine` | `docker.io/library/alpine:latest` | `sh` | Ultra-lightweight security-oriented distribution based on musl and BusyBox |
| `archlinux` | `docker.io/library/archlinux:latest` | `arch` — `bash` | Bleeding-edge rolling release with `pacman` |
| `debian` | `docker.io/library/debian:stable` | `bash` | Rock-solid stable distribution with `apt` (default Devbox OS) |
| `fedora` | `docker.io/library/fedora:latest` | `bash` | Upstream Linux distribution featuring `dnf` |
| `nix` | `docker.io/nixos/nix:latest` | `sh` | Purely functional package manager and reproducible environment |
| `ubuntu` | `docker.io/library/ubuntu:latest` | `bash` | Canonical Ubuntu LTS environment with `apt` |

---

## 3. Tools & Utilities (9 Runtimes)

Specialized developer tools, code linters, security auditors, network scanners, and AI coding agents.

| Subcategory | Runtime | Container Image | Execution / Shell | Description |
|---|---|---|---|---|
| **Linters & Quality** | `hadolint` | `docker.io/hadolint/hadolint:latest-alpine` | `sh` | Smarter Dockerfile linter validating against Docker best practices |
| **Linters & Quality** | `semgrep` | `docker.io/semgrep/semgrep:latest` | `semgrep scan` | Fast static analysis tool (SAST) for finding bugs and enforcing standards |
| **Linters & Quality** | `shellcheck` | `docker.io/koalaman/shellcheck-alpine:latest` | `sh` | Static analysis and linting tool for `sh`/`bash` scripts |
| **Security & Secrets** | `gitleaks` | `docker.io/zricethezav/gitleaks:latest` | `detect --source /workspace -v` | Scans git repos and workspace files for hardcoded secrets and API keys |
| **Security & Secrets** | `grype` | `docker.io/anchore/grype:latest` | `grype /workspace` | Fast vulnerability scanner for container images and filesystem directories |
| **Security & Secrets** | `kali` | `docker.io/kalilinux/kali-rolling:latest` | `kalilinux` — `bash` | Kali Linux rolling security, penetration testing, and forensic toolkit |
| **Security & Secrets** | `nmap` | `docker.io/instrumentisto/nmap:latest` | `sh` via `--entrypoint /bin/sh` | Network discovery and security auditing tool |
| **Security & Secrets** | `trivy` | `docker.io/aquasec/trivy:latest` | `trivy fs /workspace` | Comprehensive security scanner for CVEs, IaC misconfigs, and SBOMs |
| **AI Coding Agents** | `opencode` | `ghcr.io/anomalyco/opencode` | Entrypoint | Autonomous terminal AI coding agent running safely inside an airlocked sandbox |

---

## Running Scanners Non-Interactively

Several tools execute scans automatically when launched:
```bash
# Scan current repository for hardcoded secrets
airlock gitleaks

# Scan dependencies and filesystem for known vulnerabilities (CVEs)
airlock grype

# Run static application security testing (SAST)
airlock semgrep

# Scan directory for vulnerabilities, secrets, and misconfigurations
airlock trivy
```

For interactive tools (like `kali`, `shellcheck`, `hadolint`, or `nmap`), Airlock drops you into the container shell with `/workspace` mounted so you can run commands directly.
