<img width="910" height="592" alt="airlock" src="https://github.com/user-attachments/assets/8dce039c-01e6-459a-b03a-d8630774a38d" />


<div align="center">

# Airlock

**Instant, disposable development environments and sandboxes.**  
*Run, build, and test code without cluttering or risking your host machine.*

</div>

## Install & Update

### One-line installer (Recommended)

Handles rootless and system-wide installations automatically, configures `$PATH` across shells (Bash, Zsh, Fish), and updates Airlock when run again:

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/install.sh | bash
```

### System-wide with sudo (Alternative)

Installs directly to `/usr/local/bin` for all users and shells:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/airlock -o /usr/local/bin/airlock && sudo chmod +x /usr/local/bin/airlock
```

## Usage

```bash
airlock            # launches .airlock if present, or opens interactive menu
airlock [runtime]  # directly launch a specific runtime (e.g. airlock python)
airlock --version  # show local and remote versions
airlock --help     # show help and available runtimes
```

## Configuration (`.airlock`)

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

### Ready-to-use Examples

Explore pre-configured `.airlock` templates in the [**example/**](./example) directory:

- [**Node.js Web API**](./example/node-api/.airlock) — Port forwarding (`3000`, `8080`) & environment variables
- [**Python FastAPI**](./example/python-fastapi/.airlock) — Port `8000` & unbuffered stdout
- [**Rust CLI**](./example/rust-cli/.airlock) — Host networking & backtrace configuration
- [**Go Microservice**](./example/go-service/.airlock) — Port `8080` & `CGO_ENABLED=0`
- [**Minimal Single-Token**](./example/minimal/.airlock) — 1-line format (`python`)
- [**Security Audit**](./example/security-audit/.airlock) — Filesystem & secret scanning with Trivy

## Features

- **Disposable containers** — exit and everything inside the container is gone
- **Live workspace mounting** — mounts your current directory at `/workspace` with instant file sync
- **Zero-prompt launch** — drop a `.airlock` file in any project to bypass menus and prompts
- **Automatic Docker user mapping** — maps host UID/GID (`--user $(id -u):$(id -g)`) to eliminate `root:root` file ownership issues
- **Fork bomb protection** — enforced process limit (`--pids-limit 256`)
- **Engine auto-detection** — automatically detects and prefers Podman, with full Docker support
- **SELinux out of the box** — automatic `:z` volume relabeling for Fedora, RHEL, and CentOS
- **AI agent ready** — automatically forwards LLM API keys (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `OPENROUTER_API_KEY`, `DEEPSEEK_API_KEY`) to Aider
- **20 runtimes organized into 4 categories:**
  - **Programming Languages:** Bun, C/C++ (GCC), Deno, Go, Node.js, PHP, Python, Ruby, Rust, Zig
  - **Linux Distributions:** Alpine, Arch Linux, Debian, Fedora, Nix, Ubuntu
  - **AI Coding Agents:** Aider, OpenCode
  - **Security & Auditing:** Kali Linux, Trivy (Security Scanner)

> [!TIP]
> Airlock recommends and works best with **[Podman](https://podman.io/)** — rootless and daemonless containers provide an extra layer of security when running untrusted code. Docker is also supported.

## Supported Host Operating Systems

Airlock runs on any operating system equipped with **Podman** or **Docker**:

| Host OS | Recommended Engine | Security System | Support Status |
|---|---|---|:---:|
| **Fedora** | Podman | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **Red Hat Enterprise Linux (RHEL)** | Podman | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **CentOS Stream / Rocky / AlmaLinux** | Podman | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **Ubuntu** | Podman / Docker | AppArmor | Verified |
| **Debian** | Podman / Docker | AppArmor | Verified |
| **Arch Linux / Manjaro** | Podman / Docker | Standard | Verified |
| **openSUSE** (Leap / Tumbleweed) | Podman / Docker | AppArmor / SELinux | Verified |
| **Alpine Linux** | Podman / Docker | Standard | Verified |
| **macOS** | Podman Desktop / Docker Desktop / OrbStack | Hypervisor VM Isolation | Verified |
| **Windows (via WSL2)** | Podman / Docker Desktop | WSL2 Linux Subsystem | Verified |

> [!NOTE]
> **SELinux out of the box:** On SELinux-enforcing hosts like **Fedora** and **RHEL**, Airlock automatically mounts host directories with the `:z` flag so containers have proper access without `Permission denied` errors. You can also manually control this behavior via `AIRLOCK_SELINUX=1` (force enable) or `AIRLOCK_SELINUX=0` (force disable).

> [!NOTE]
> **Host user mapping:** When using Docker, Airlock automatically runs containers with your host user and group IDs (`--user $(id -u):$(id -g)`), ensuring that files, build artifacts, and dependencies created in `/workspace` are owned by you instead of `root:root`. You can override this behavior using `AIRLOCK_USER=root` or `AIRLOCK_USER=<uid:gid>`.

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `AIRLOCK_USER` | Override container user and group (e.g. `1000:1000`, `root`) | Host user for Docker; container default for Podman |
| `AIRLOCK_SELINUX` | Force enable (`1`) or disable (`0`) SELinux `:z` volume relabeling | Auto-detected |

## Use cases

- **Polyglot development:** Test, compile, and run code in 10+ languages without installing SDKs or compilers on your host
- **Run AI coding agents:** Run Aider or OpenCode inside a container without giving LLMs unrestricted host execution
- **Isolate untrusted dependencies:** Run `npm install`, `bundle install`, or `composer install` without trusting unknown scripts
- **Cross-distro testing:** Test scripts and binary packaging across Alpine, Arch, Debian, Fedora, and Ubuntu
- **Security audits:** Scan repositories for CVEs and secret leaks with Trivy, or inspect binaries in Kali Linux
- **Clean host system:** Keep your personal machine clean of global package managers, dev tools, and toolchains

## License

MIT
