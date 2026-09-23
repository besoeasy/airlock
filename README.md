<p align="center">
  <img width="800" alt="Airlock terminal demo" src="https://github.com/user-attachments/assets/37de4ead-a3a0-41dd-8af5-46d3e848f184" />
</p>

<h1 align="center">Airlock</h1>

<p align="center">
  <strong>Instant, disposable development environments and sandboxes.</strong><br>
  Run, build, scan, and test code without cluttering or putting your host machine at risk.
</p>

<p align="center">
  <a href="https://github.com/besoeasy/airlock/releases"><img alt="Latest release" src="https://img.shields.io/github/v/release/besoeasy/airlock"></a>
  <a href="https://github.com/besoeasy/airlock/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/besoeasy/airlock"></a>
  <a href="https://github.com/besoeasy/airlock/commits/main"><img alt="Last commit" src="https://img.shields.io/github/last-commit/besoeasy/airlock"></a>
</p>

## Introduction

Airlock puts your project inside a preconfigured [rootless Podman](https://podman.io/) container. Your working directory stays available at `/workspace`, while toolchains, packages, and other changes outside the workspace disappear with the container.

Use a throwaway sandbox for one-off builds and scans, or create a persistent devbox when you want to keep your environment between sessions. Airlock supports Linux, macOS, and WSL2.

## Install

Install Airlock and its container engine with one command:

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/install.sh | bash
```

The installer adds `airlock` to your `PATH` and installs Podman when needed. Re-run the same command whenever you want to update Airlock.

## Usage

Launch an environment for your project:

```bash
cd my-project
airlock
```

With no `.airlock` file, running `airlock` opens an interactive menu where you can choose a runtime instead.

## Why We Built Airlock

Installing every SDK, scanner, and test tool on your host machine is slow, difficult to reproduce, and easy to pollute. Running unfamiliar project scripts with your normal user account is also risky.

Airlock gives you a clean environment on demand: launch the tools you need, keep your source mounted in place, and throw the rest away when you are done. When a longer-lived setup is useful, a persistent devbox provides the same isolation without the cleanup.

## Features

- **26 preconfigured runtimes** across programming languages, Linux distributions, security tools, and AI coding agents.
- **Disposable by default** — containers are removed automatically when you exit.
- **Live workspace mounting** — edit the same files from the host and container in real time.
- **Project configuration** — define runtimes, ports, environment variables, and setup commands in `.airlock`.
- **Persistent devboxes** — keep packages and configuration across multiple sessions.
- **Rootless and security-conscious** — uses rootless Podman, automatic SELinux relabeling, and process limits.
- **Dependency-free CLI** — one Bash script with no framework or third-party runtime required.

## Documentation

| Guide | What it covers |
|---|---|
| [CLI Reference](docs/cli-reference.md) | Commands, options, aliases, examples, and shell completions |
| [Supported Runtimes](docs/runtimes.md) | Available languages, distributions, tools, and scanner behavior |
| [Project Configuration](docs/configuration.md) | `.airlock` keys, lifecycle hooks, and port configuration |
| [Persistent Devboxes](docs/devboxes.md) | Creating, entering, listing, and deleting long-lived environments |
| [Platforms & Security](docs/platforms-and-security.md) | Host support, Podman setup, SELinux, macOS, and WSL2 |
| [Airlock vs Toolbox](docs/airlock-vs-toolbox.md) | Comparing disposable and persistent container workflows |
