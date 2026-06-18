# Airlock

> A secure airlock between your machine and untrusted dependencies.

Airlock runs package managers inside disposable Docker or Podman containers, helping reduce the risk of malicious install scripts, supply-chain attacks, and polluted development environments.

Instead of running:

```bash
npm install
```

directly on your machine, run:

```bash
airlock
```

and install dependencies inside an isolated container.

---

## Why?

Modern projects often contain hundreds or thousands of dependencies.

Running:

```bash
npm install
```

on an unfamiliar repository means executing code you haven't reviewed.

Airlock helps by:

* Running package managers in disposable containers
* Keeping Node.js off your host system
* Supporting Docker and Podman
* Providing a simple interactive interface
* Updating itself automatically

---

## Features

* Disposable containers
* Docker support
* Podman fallback
* Self-updating CLI
* Interactive menu
* Direct command execution
* No Node.js installation required on the host

---

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/install.sh | bash
```

Verify installation:

```bash
airlock version
```

---

## Usage

Launch the interactive menu:

```bash
airlock
```

Run npm:

```bash
airlock npm install
```

Run pnpm:

```bash
airlock pnpm install
```

Run yarn:

```bash
airlock yarn install
```

Open a shell inside the sandbox:

```bash
airlock shell
```

Update Airlock:

```bash
airlock update
```

---

## Supported Runtimes

Airlock automatically detects:

1. Docker
2. Podman

Docker is preferred when both are available.

---

## Security Model

Airlock reduces risk by running package managers inside disposable containers.

However, the project directory is still mounted into the container. Always review unfamiliar code before running it.

Airlock improves isolation but is not a guarantee against every supply-chain attack.

---

## Roadmap

* Safe Install (`--ignore-scripts`)
* Install script inspection
* Risk scoring
* Cargo support
* Pip support
* Read-only mode
* Network isolation
* GitHub release-based updates

---

## Contributing

Issues and pull requests are welcome.

---

## License

MIT
