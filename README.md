<img width="910" height="592" alt="airlock" src="https://github.com/user-attachments/assets/8dce039c-01e6-459a-b03a-d8630774a38d" />


<div align="center">

# Airlock

**Run untrusted code without trusting it.**

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

## Features

- Disposable containers — exit and everything is gone
- Mounts your current directory at `/workspace`
- Automatic user mapping for Docker — prevents `root:root` file ownership on host
- No data leaks to host
- Fork bomb protection (`--pids-limit 256`)
- Auto-detects Docker or Podman (Podman recommended)
- SELinux support — automatic `:z` relabeling for Fedora, RHEL, and CentOS
- 20 runtimes organized into 4 categories:
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

## Use cases

- Run AI coding agents (Aider, OpenCode) safely in a sandbox without giving LLMs host access
- Run `npm install`, `bundle install`, or `composer install` from a cloned repo without trusting it
- Try a language or tool without installing it on your machine
- Scan cloned repositories for vulnerabilities and secrets with Trivy
- Inspect suspicious binaries and reverse-engineer safely in Kali Linux
- Isolate build processes from your host
- Test scripts and packages across different Linux distributions
- Run untrusted scripts safely

## License

MIT
