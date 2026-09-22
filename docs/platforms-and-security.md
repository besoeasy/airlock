# Platforms & Security Model

Airlock is designed from the ground up to run securely and reliably across modern Linux distributions, macOS, and Windows (via WSL2).

---

## Supported Host Operating Systems

Airlock requires **Podman** as its container runtime engine. The installer sets up Podman automatically on supported distros.

| Host OS | Manual Podman Command | Security Mechanism | Status |
|---|---|---|:---:|
| **Fedora** | `sudo dnf install podman` | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **Red Hat Enterprise Linux (RHEL)** | `sudo dnf install podman` | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **CentOS Stream / Rocky / AlmaLinux** | `sudo dnf install podman` | SELinux (Enforcing, automatic `:z` relabeling) | Verified |
| **Ubuntu** | `sudo apt install podman` | AppArmor | Verified |
| **Debian** | `sudo apt install podman` | AppArmor | Verified |
| **Arch Linux / Manjaro** | `sudo pacman -S podman` | Standard Linux Namespaces | Verified |
| **openSUSE** (Leap / Tumbleweed) | `sudo zypper install podman` | AppArmor / SELinux | Verified |
| **Alpine Linux** | `sudo apk add podman` | Standard Linux Namespaces | Verified |
| **macOS** | `brew install podman` | Hypervisor VM Isolation | Verified |
| **Windows (via WSL2)** | Install in WSL2 distro (e.g. `apt install podman`) | WSL2 Linux Subsystem | Verified |

---

## Platform Setup Details

### macOS
Podman on macOS runs inside a lightweight, Apple Hypervisor-backed virtual machine.
Initialize and start the virtual machine once before using Airlock:
```bash
brew install podman
podman machine init
podman machine start
```

### Windows (WSL2)
1. Ensure WSL2 is enabled: `wsl --install -d Ubuntu`
2. Open your WSL2 terminal and install Podman: `sudo apt update && sudo apt install podman`
3. Run `curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | bash` inside WSL2.

---

## Security Architecture

### 1. Rootless by Design
Airlock relies strictly on rootless Podman. Rootless containers run entirely within user namespaces without requiring a background daemon with root privileges.
- Files modified in `/workspace` retain your host user ID and ownership. You will never see `root:root` locked files created on your host filesystem.
- Processes running as `root` inside the container remain unprivileged on the host. Even in the event of a container escape, privileges cannot exceed those of your unprivileged user account.

### 2. SELinux Automatic Relabeling (`:z`)
On SELinux-enforcing distributions (such as **Fedora**, **RHEL**, and **CentOS Stream**), standard volume mounts fail with `Permission denied` errors because container processes run with isolated SELinux categories.

Airlock automatically detects whether SELinux is enforcing (`selinuxenabled` or `/sys/fs/selinux/enforce`). When active, Airlock appends the `:z` flag to the workspace mount:
```bash
-v "$PWD:/workspace:z"
```
This tells SELinux to safely share the volume label with container processes without modifying host permissions or disabling security protections.

You can manually control or override this behavior:
```bash
# Force enable SELinux :z flag
AIRLOCK_SELINUX=1 airlock python

# Force disable SELinux :z flag
AIRLOCK_SELINUX=0 airlock python
```

### 3. Fork Bomb & Process Exhaustion Protection
Untrusted dependencies or rogue recursive scripts can exhaust host PID limits. Airlock mitigates this by enforcing a hard limit on processes for all disposable containers:
```bash
--pids-limit 1024
```

---

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `AIRLOCK_USER` | Override container user and group inside the container (e.g. `1000:1000`, `root`) | Container default |
| `AIRLOCK_SELINUX` | Force enable (`1`) or disable (`0`) SELinux `:z` volume relabeling | Auto-detected |
