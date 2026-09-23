# Airlock CLI Reference

Complete command-line interface documentation for **Airlock** (`airlock`).

## Synopsis

```text
airlock [options]
airlock [runtime]
airlock <command> [arguments...]
```

---

## Command & Option Reference Table

| Command / Option | Arguments | Aliases | Description |
|---|---|---|---|
| *(no arguments)* | — | — | Launches `.airlock` in current directory if present; otherwise opens interactive menu |
| `<runtime>` | `<name>` | `cpp`, `gcc`, `arch`, `kalilinux` | Launch a disposable container sandbox with `/workspace` mounted |
| `enter` | `<name>` | — | Enter an existing devbox, or create a new persistent devbox (prompts for distro) |
| `list` | — | `ls` *(menu)* | List all persistent devbox containers (`airlock-*`) and their runtime status |
| `delete` | `<name>` | `rm`, `remove` | Permanently stop and delete a persistent devbox container and its state |
| `completion` | `<bash\|zsh\|fish>` | — | Output shell autocompletion script to stdout |
| `-h`, `--help` | — | — | Display help message, available commands, runtimes, and config keys |
| `-v`, `--version` | — | — | Display version, container engine, SELinux status, active config, and check for updates |

---

## Commands & Arguments in Detail

### 1. Interactive Menu & Auto-Configuration (No Arguments)

```bash
airlock
```

- **If `.airlock` is present in the current directory**:
  Airlock automatically loads the configuration, binds configured ports, sets environment variables, applies user/SELinux overrides, executes the `setup=` lifecycle hook, and drops into the container shell. Bypasses all menus and prompts.
- **If no `.airlock` exists**:
  Opens an interactive terminal menu allowing you to browse categories:
  1. Programming Languages
  2. Linux Distributions
  3. Tools & Utilities
  4. Development Boxes

---

### 2. Disposable Runtime Sandboxes: `airlock <runtime>`

```bash
airlock <runtime>
```

Launches an instant, throwaway sandbox with your current working directory mounted at `/workspace`. Changes made to your project files in `/workspace` are preserved in real-time on your host machine. Any files installed outside `/workspace` or container system modifications are discarded upon exit (`--rm`).

- **Arguments:**
  - `<runtime>`: *(Required)* Name of any supported runtime or alias (e.g. `node`, `python`, `rust`, `go`, `alpine`, `ubuntu`, `gitleaks`, `semgrep`). See [Supported Runtimes](runtimes.md) for the complete list.
- **Supported Aliases:**
  - `c`, `cpp`, `gcc` &rarr; `docker.io/library/gcc:latest`
  - `arch`, `archlinux` &rarr; `docker.io/library/archlinux:latest`
  - `kali`, `kalilinux` &rarr; `docker.io/kalilinux/kali-rolling:latest`
- **Default Flags Applied by Airlock:**
  - `--rm`: Auto-removes container on exit.
  - `-v "$PWD:/workspace:z"`: Live workspace mount with SELinux `:z` label when applicable.
  - `-w /workspace`: Starts shell in workspace directory.
  - `--network host`: Direct access to host ports (or bridge if configured).
  - `--pids-limit 1024`: Prevents runaway fork bombs.
- **Examples:**
  ```bash
  airlock python      # Launch Python 3 sandbox with /workspace mounted
  airlock rust        # Launch Rust sandbox with cargo toolchain
  airlock cpp         # Launch GCC C/C++ compiler sandbox
  airlock gitleaks    # Scan current repository for hardcoded secrets
  airlock trivy       # Scan current repository for vulnerabilities
  ```

---

### 3. Persistent Devboxes: `airlock enter <name>`

```bash
airlock enter <name>
```

Enters a long-lived, persistent development container running in the background with host networking. State, installed packages, and custom configurations persist across exits and host reboots.

- **Arguments:**
  - `<name>`: *(Required)* Name of the devbox. Must contain only alphanumeric characters, dots (`.`), underscores (`_`), or hyphens (`-`). The underlying container is named `airlock-<name>`.
- **First-Time Creation:**
  If `<name>` does not exist, Airlock prompts you to select a base operating system:
  1. Debian (`docker.io/library/debian:stable` - default)
  2. Alpine (`docker.io/library/alpine:latest`)
  3. Fedora (`docker.io/library/fedora:latest`)
  4. Ubuntu (`docker.io/library/ubuntu:latest`)
  5. Arch Linux (`docker.io/library/archlinux:latest`)
- **Resuming:**
  If the devbox already exists but is stopped, Airlock restarts it automatically before attaching an interactive shell.
- **Examples:**
  ```bash
  airlock enter mybox         # Enter or create devbox 'mybox'
  airlock enter test-env      # Enter or create devbox 'test-env'
  ```

See [Development Boxes](devboxes.md) for full documentation.

---

### 4. List Devboxes: `airlock list`

```bash
airlock list
```

Displays a tabular list of all existing persistent development boxes (`airlock-*`), including container names, container images, and current running status.

- **Arguments:** None. (Takes no parameters; suggests `airlock enter <name>` if an argument is passed).
- **Example:**
  ```bash
  airlock list
  # NAMES              IMAGE                             STATUS
  # airlock-mybox      docker.io/library/debian:stable   Up 2 hours
  # airlock-test-env   docker.io/library/alpine:latest   Exited (0) 5 minutes ago
  ```

---

### 5. Delete Devboxes: `airlock delete <name>`

```bash
airlock delete <name>
airlock rm <name>
airlock remove <name>
```

Permanently stops and removes a persistent devbox container and deletes its internal storage/state (`podman rm -f airlock-<name>`).

- **Arguments:**
  - `<name>`: *(Required)* Name of the devbox to delete.
- **Aliases:** `delete`, `rm`, `remove`
- **Examples:**
  ```bash
  airlock delete mybox
  airlock rm test-env
  ```

---

### 6. Shell Autocompletion: `airlock completion <shell>`

```bash
airlock completion <bash|zsh|fish>
```

Generates ready-to-use shell completion scripts to standard output, enabling tab-completion for all commands, subcommands, and runtimes.

- **Arguments:**
  - `<shell>`: Shell type (`bash`, `zsh`, or `fish`).
  - `-h`, `--help`: Display completion usage instructions.
- **Installation Examples:**
  ```bash
  # Bash (append to ~/.bashrc or ~/.bash_profile)
  airlock completion bash >> ~/.bashrc

  # Zsh (save to your zsh completions directory)
  airlock completion zsh > ~/.zfunc/_airlock

  # Fish (save to fish completions directory)
  airlock completion fish > ~/.config/fish/completions/airlock.fish
  ```

---

### 7. Global Flags

#### Help: `airlock -h` / `airlock --help`

Displays the command synopsis, available runtime categories, persistent box commands, configuration keys, and environment variables.

#### Version: `airlock -v` / `airlock --version`

Displays comprehensive runtime and environment diagnostic information:
- Installed Airlock version
- Container engine detection (`podman`)
- SELinux status and `:z` volume relabeling state
- Active container user override (if set via `AIRLOCK_USER` or `.airlock`)
- Detected `.airlock` configuration and startup setup hook (if present in the current directory)
- Upstream release check with update notification if a newer version is available on GitHub
