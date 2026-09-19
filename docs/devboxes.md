# Persistent Development Boxes

While Airlock's primary model is **disposable-first**, it also provides built-in support for **persistent development boxes** (`devboxes`).

A devbox is a long-lived container that maintains its filesystem state, installed packages, user modifications, and services across sessions and host reboots.

---

## Disposable Runtimes vs Devboxes

| Feature | Disposable Runtime (`airlock <runtime>`) | Persistent Devbox (`airlock enter <name>`) |
|---|---|---|
| **Lifecycle** | Destroyed on exit (`--rm`) | Persists until explicitly deleted |
| **Workspace** | Mounts current directory at `/workspace` | Independent isolated filesystem |
| **Userland** | User-mapped (rootless) | Root inside container (isolated by Podman) |
| **Package Installs** | Lost on container exit | Persisted across sessions |
| **Best For** | Testing repos, building code, security audits | Long-running services, complex local dev stacks |

---

## Managing Devboxes

### 1. Enter or Create: `airlock enter <name>`

```bash
airlock enter mybox
```

- **Naming Rules:**
  Names must begin with an alphanumeric character and may contain letters, numbers, dots (`.`), underscores (`_`), and hyphens (`-`). The actual container on your system is prefixed as `airlock-<name>`.
- **First-Time Creation:**
  When entering a box name for the first time, Airlock detects that the container does not exist and prompts you to select an operating system:
  1. **Debian** (`docker.io/library/debian:stable` - default)
  2. **Alpine** (`docker.io/library/alpine:latest`)
  3. **Fedora** (`docker.io/library/fedora:latest`)
  4. **Ubuntu** (`docker.io/library/ubuntu:latest`)
  5. **Arch Linux** (`docker.io/library/archlinux:latest`)
- **Background Execution:**
  Airlock initializes the container with `sleep infinity` running under Podman with `--network host`.
- **Automatic Resume:**
  If a devbox was stopped (e.g. after host reboot), running `airlock enter <name>` automatically restarts the container before opening the interactive shell.

---

### 2. List Boxes: `airlock list`

```bash
airlock list
```

Lists all persistent Airlock containers on your host with their container name, underlying image, and current status:

```text
NAMES              IMAGE                             STATUS
airlock-mybox      docker.io/library/debian:stable   Up 3 hours
airlock-fedora-db  docker.io/library/fedora:latest   Exited (0) 2 days ago
```

---

### 3. Delete a Box: `airlock delete <name>`

```bash
airlock delete mybox
# Aliases:
airlock rm mybox
airlock remove mybox
```

Forcefully stops and deletes the container and permanently removes its internal storage (`podman rm -f airlock-<name>`).

---

## Inside a Devbox: Root Access & Safety

Because Airlock utilizes rootless Podman:
- You have `root` privileges **inside** the container, allowing you to run `apt install`, `dnf install`, or `pacman -S` freely without needing host sudo.
- Even as `root` inside the container, your privileges on the host are mapped to your unprivileged user account via user namespaces (`subuid`/`subgid`).
- Your host system remains completely protected against accidental corruption or rogue scripts.
