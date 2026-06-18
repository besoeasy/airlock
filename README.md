# Airlock

> Stop running untrusted code on your host.

Airlock launches isolated development environments using Docker or Podman.

Instead of installing runtimes, SDKs, and dependencies directly on your machine, launch a disposable container and work inside it.

## Why?

Cloning a repository should not mean trusting it.

Modern projects execute thousands of lines of third-party code during installation, builds, testing, and development.

Airlock provides an isolation layer between your machine and untrusted projects.

* Disposable containers
* Isolated runtimes
* Docker and Podman support
* Self-updating CLI
* No language runtimes required on the host

The goal is simple:

**Get pwned less.**

## Install

Requires Docker or Podman. The install script installs Airlock and, if neither runtime is present, installs Podman from your distro's official repositories (Debian, Ubuntu, Fedora, Arch, openSUSE, and others).

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/install.sh | bash
```

## Uninstall

```bash
sudo rm -f /usr/local/bin/airlock
```

## Usage

```bash
airlock
```

Or launch directly:

```bash
airlock debian
airlock alpine
airlock node
airlock python
airlock go
airlock bun
airlock rust
airlock java
airlock ubuntu
airlock arch
airlock fedora
airlock deno
airlock zig
airlock nix
```

## Project config

Add a `.airlock` file in your project root to define defaults for that repo:

```
image=node
command=npm test
```

| Key | Description |
|-----|-------------|
| `image` | Image alias (`node`, `python`, …) or full reference (`node:22`, `ghcr.io/org/image`) |
| `command` | Optional command to run instead of an interactive shell |

Running `airlock` with no arguments uses `.airlock` when the file is present. Each built-in image uses a tailored container setup (shell, cache dirs, and runtime-specific env). Custom image references use a generic workspace mount.

## Security

Airlock reduces risk by running development environments inside containers instead of directly on your host.

Airlock is not a security boundary and does not guarantee protection against malicious software.

Always review unfamiliar code before executing it.

## License

MIT
