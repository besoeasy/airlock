<img width="800" height="562" alt="j" src="https://github.com/user-attachments/assets/37de4ead-a3a0-41dd-8af5-46d3e848f184" />


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

- [Key Features](#key-features)
- [Installation](#installation)
- [Quick Command Cheat Sheet](#quick-command-cheat-sheet)
- [Supported Runtimes at a Glance](#supported-runtimes-at-a-glance)
- [Project Configuration (`.airlock`)](#project-configuration-airlock)
- [Documentation Hub](#documentation-hub)
- [Supported Host OS](#supported-host-os)
- [Use Cases](#use-cases)
- [Contributing](#contributing)
- [License](#license)

---

## Key Features

- ⚡ **Disposable by Default** — Exit the shell and the container is destroyed (`--rm`). Zero host clutter.
- 🧰 **Persistent Devboxes** — Keep long-lived, multi-session environments via `airlock enter / list / delete`.
- 📂 **Live Workspace Sync** — Mounts your current working directory at `/workspace` with instant bidirectional file sync.
- ⚙️ **Zero-Prompt Launch** — Drop a `.airlock` file in any repository to configure ports, env vars, and setup hooks.
- 🛡️ **Rootless & Secure** — Powered by rootless Podman. Files in `/workspace` retain your host user ownership (no `root:root` locks).
- 🔒 **SELinux Out of the Box** — Automatic `:z` volume relabeling on Fedora, RHEL, and CentOS Stream.
- 🛑 **Fork Bomb Protection** — Hard process limits (`--pids-limit 1024`) to guard against runaway scripts.
- 📦 **25 Supported Runtimes** — 10 programming languages, 6 Linux distributions, and 9 developer tools & scanners.

---

## Installation

### One-line installer (Recommended)

Handles rootless and system-wide setups automatically, configures `$PATH` across shells (Bash, Zsh, Fish), installs Podman when missing, and updates Airlock when run again:

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | bash
```

### System-wide with sudo (Alternative)

Installs directly to `/usr/local/bin` for all users and shells:

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | sudo bash
```

> [!TIP]
> Airlock requires [**Podman**](https://podman.io/). Podman is rootless and daemonless, ensuring containerized processes never run with elevated host privileges. See [Platforms & Security](docs/platforms-and-security.md) for manual distro commands, macOS, and WSL2 setups.

### Run it in your project

That's it — just run `airlock` in your project directory:

```bash
cd your-project
airlock
```

Airlock auto-detects your runtime, or opens the menu to pick one.

---

## Quick Command Cheat Sheet

| Command | Action |
|---|---|
| `airlock` | Launch `.airlock` if present, or open the interactive category menu |
| `airlock <runtime>` | Launch a disposable runtime sandbox (e.g. `airlock node`, `airlock rust`) |
| `airlock init [runtime]` | Create a starter `.airlock` config file (auto-detects from project files) |
| `airlock enter <name>` | Enter or create a persistent development box (prompts for distro if new) |
| `airlock list` | List all persistent development boxes (`airlock-*`) |
| `airlock delete <name>` | Delete a persistent development box (aliases: `rm`, `remove`) |
| `airlock completion <shell>` | Generate shell autocompletions (`bash`, `zsh`, `fish`) |
| `airlock -v` / `--version` | Show version, Podman status, active config, and check for updates |
| `airlock -h` / `--help` | Show full help and available runtimes |

👉 **Full CLI Guide:** See [CLI Reference](docs/cli-reference.md) for detailed argument descriptions, aliases, and examples.

---

## Supported Runtimes at a Glance

Airlock includes **25 pre-configured container runtimes** across 3 categories:

- **Programming Languages (10):** `bun`, `c` (`cpp`, `gcc`), `deno`, `go`, `node`, `php`, `python`, `ruby`, `rust`, `zig`
- **Linux Distributions (6):** `alpine`, `archlinux` (`arch`), `debian`, `fedora`, `nix`, `ubuntu`
- **Tools & Utilities (9):**
  - *Linters & SAST:* `hadolint`, `semgrep`, `shellcheck`
  - *Security & Secrets:* `gitleaks`, `grype`, `kali` (`kalilinux`), `nmap`, `trivy`
  - *AI Coding Agents:* `opencode`

👉 **Full Runtimes Catalog:** See [Supported Runtimes](docs/runtimes.md) for container images, shells, and non-interactive scanner behaviors.

---

## Project Configuration (`.airlock`)

Add a `.airlock` file to any project repository to pre-configure its environment:

```ini
# .airlock
runtime=node
ports=3000 8080
env=PORT=3000
env=NODE_ENV=development
setup=npm install
```

When `.airlock` is present, simply running `airlock` launches your container immediately with all ports mapped, environment variables injected, and the setup command executed.

👉 **Full Configuration Guide:** See [Project Configuration (`.airlock`)](docs/configuration.md) for supported keys, lifecycle hooks, and project auto-detection manifests.

---

## Documentation Hub

Detailed guides are modularized under the [`docs/`](docs/) directory:

| Guide | Description |
|---|---|
| 📖 [**CLI Reference**](docs/cli-reference.md) | Complete command synopsis, argument reference table, options, and shell autocompletion. |
| 📦 [**Supported Runtimes**](docs/runtimes.md) | Full 25-runtime catalog with container images, shell overrides, and scanner behaviors. |
| ⚙️ [**Project Configuration**](docs/configuration.md) | `.airlock` configuration keys, lifecycle hooks (`setup=`), shell detection, and auto-detection manifests. |
| 🧰 [**Persistent Devboxes**](docs/devboxes.md) | Guide to long-lived containers: base OS options (Debian, Alpine, Fedora, Ubuntu, Arch), data persistence, and root privileges. |
| 🛡️ [**Platforms & Security**](docs/platforms-and-security.md) | Host OS compatibility matrix, rootless Podman setup, SELinux automatic `:z` relabeling, macOS / WSL2 setups, and environment variables. |
| ⚖️ [**Airlock vs Toolbox**](docs/airlock-vs-toolbox.md) | In-depth comparison between Airlock and Toolbx for disposable vs persistent workflows. |

---

## Supported Host OS

| Platform | Podman Installation | Security Mechanism | Status |
|---|---|---|:---:|
| **Fedora / RHEL / CentOS Stream** | `sudo dnf install podman` | SELinux (automatic `:z` relabeling) | Verified |
| **Ubuntu / Debian** | `sudo apt install podman` | AppArmor | Verified |
| **Arch Linux / Manjaro** | `sudo pacman -S podman` | Standard Namespaces | Verified |
| **openSUSE** (Leap / Tumbleweed) | `sudo zypper install podman` | AppArmor / SELinux | Verified |
| **Alpine Linux** | `sudo apk add podman` | Standard Namespaces | Verified |
| **macOS** | `brew install podman` | Hypervisor VM Isolation | Verified |
| **Windows (via WSL2)** | Install Podman in WSL2 distro | WSL2 Subsystem | Verified |

👉 See [Platforms & Security](docs/platforms-and-security.md) for setup details.

---

## Use Cases

- **Polyglot Development:** Test, compile, and run code in 10 languages without installing local SDKs or compilers.
- **Code Quality & Linting:** Run ShellCheck, Hadolint, and Semgrep without managing local package managers or dependencies.
- **Security & Secret Audits:** Scan repositories for CVEs, leaked secrets, and misconfigurations using Trivy, Grype, Gitleaks, and Nmap.
- **Run AI Coding Agents:** Run OpenCode in an isolated sandbox without granting LLMs unrestricted host execution.
- **Isolate Untrusted Dependencies:** Run `npm install`, `pip install`, or `cargo build` on untrusted repos safely.
- **Cross-Distro Testing:** Validate bash scripts and binary packages across Alpine, Arch, Debian, Fedora, Nix, and Ubuntu.
- **Clean Host Machine:** Keep your personal machine clean of global toolchains, SDKs, and temporary packages.

---

## Contributing

Contributions are welcome! Fork the repo, create a branch, and open a pull request. Before submitting, verify your changes with:

```bash
bash -n airlock
bash -n install.sh
```

Please keep Airlock dependency-free (Bash + Podman only) and update documentation in `docs/` when adding runtimes or features.

---

## License

[MIT](LICENSE)
