# Airlock vs Toolbox

A technical and architectural comparison between **Airlock** and [**Toolbox** (Toolbx)](https://containertoolbx.org/).

---

## Architectural Comparison

| Dimension | Toolbox (Toolbx) | Airlock |
|---|---|---|
| **Primary Philosophy** | "Pet" container for immutable host OS | Instant, disposable sandboxes per project/runtime |
| **Startup** | `toolbox create` with host OS image | `airlock <runtime>` — 26 ready-to-run environments |
| **Workspace Scope** | Mounts entire `$HOME` directory | Mounts strictly current directory at `/workspace` |
| **Host Isolation** | Low isolation (shares host home, config, dotfiles) | High isolation (isolated filesystem, disposable container) |
| **Runtimes** | Single distro userland | 10 languages, 6 Linux distros, 9 developer tools |
| **Per-Project Config** | None (manual tool configuration) | Declarative `.airlock` file |
| **Cleanup** | Manual state accumulation | Automatic disposal on exit (`--rm`) |
| **Long-Lived State** | Always persistent | Opt-in via `airlock enter <name>` devboxes |
| **Engine & Platforms** | Podman, Linux-centric | Podman everywhere; verified on Linux, macOS, WSL2 |
| **Shell Completions** | No | Native completions for Bash, Zsh, and Fish |

---

## When to Use Which?

### Use Toolbox when:
- You are running an immutable desktop OS (such as Fedora Silverblue, Kinoite, or openSUSE MicroOS) and need a continuous terminal workspace with persistent command-line tools installed via the system package manager.
- You want your container to share all host config files, dotfiles, and home directory data.

### Use Airlock when:
- You want **zero toolchain clutter** on your host machine.
- You need to test, build, or debug code across **multiple languages or distros** (Python, Node, Rust, Go, Zig, Alpine, Arch, etc.) without managing version managers like nvm, pyenv, or rustup.
- You need to run **security audits, secret scanners, or linters** (Gitleaks, Grype, Trivy, Semgrep, ShellCheck, Hadolint) without installing them globally.
- You want to run **AI coding agents** (like OpenCode) in a sandbox with restricted execution scope.
- You collaborate on repositories and want a shared, declarative `.airlock` configuration that teammates can launch in one keystroke.
