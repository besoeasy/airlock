# Project Configuration (`.airlock`)

Airlock supports repository-level configuration via a `.airlock` file.

When a `.airlock` file is present in your current directory, running `airlock` automatically launches the container using your pre-configured settings and **bypasses all menus and prompts**.

---

## Quick Generation: `airlock init`

You can generate a starter configuration file using `airlock init`:

```bash
airlock init          # Auto-detects runtime from project files
airlock init node     # Explicitly configure for Node.js
airlock init --force  # Overwrite existing .airlock
```

### Auto-Detection Manifests

When run without a runtime argument, `airlock init` inspects your directory for known project manifests:

| Project Manifest | Detected Runtime |
|---|---|
| `package.json` | `node` |
| `Cargo.toml` | `rust` |
| `go.mod` | `go` |
| `pyproject.toml`, `requirements.txt`, `.python-version` | `python` |
| `deno.json`, `deno.jsonc` | `deno` |
| `bun.lockb`, `bunfig.toml` | `bun` |
| `composer.json` | `php` |
| `Gemfile` | `ruby` |
| `build.zig`, `build.zig.zon` | `zig` |
| `Makefile`, `CMakeLists.txt` | `c` |

If no recognized file is found and the terminal is interactive, `airlock init` prompts you for a runtime name.

---

## Supported Configuration Keys

A `.airlock` file uses key-value syntax (`key=value`). Blank lines and comments starting with `#` are ignored.

| Key | Description | Example | Default |
|---|---|---|---|
| `runtime` | Target container runtime | `runtime=node` | Prompt / None |
| `ports` | Space-separated port mappings (`host:container` or `port`) | `ports=3000 8080:80` | None |
| `network` | Container network mode (`host`, `bridge`, `none`) | `network=host` | `host` |
| `user` | Container user & group override (`UID:GID` or `username`) | `user=1000:1000` | Container default |
| `env` | Environment variable (*repeatable*) | `env=NODE_ENV=development` | None |
| `selinux` | SELinux `:z` volume relabeling flag override (`1` or `0`) | `selinux=1` | Auto-detected |
| `setup` | Lifecycle command to execute on start before shell | `setup=npm install` | None |
| `shell` | Shell override (`bash`, `sh`; auto-detected by default) | `shell=bash` | Auto-detected |

---

## Project Lifecycle Hooks (`setup=`)

The `setup=` key allows you to define a command or script that automatically executes inside the container whenever you launch the environment, right before dropping into the interactive shell.

```ini
runtime=node
setup=npm install
```

### How Shell Compatibility Works

Containers differ in the shells they provide (e.g. Alpine, Zig, and Nix only have `/bin/sh`, whereas Ubuntu, Debian, Python, and Node have `/bin/bash`).

1. **Universal POSIX Bootstrap**:
   By default, Airlock executes your setup command with `/bin/sh` (guaranteed across 100% of POSIX container images) and then promotes to `/bin/bash` if available:
   ```bash
   sh -c "$CFG_SETUP && { command -v bash >/dev/null 2>&1 && exec bash || exec sh; }"
   ```
2. **Error Guard**:
   If the setup command fails (returns a non-zero exit code), Airlock halts immediately with an error instead of dropping into a broken session.
3. **Explicit Shell Override (`shell=`)**:
   If your setup script relies on specific shell features, specify the shell explicitly:
   ```ini
   runtime=alpine
   setup=apk add --no-cache bash curl && echo "Ready!"
   shell=bash
   ```

---

## Single-Token `.airlock` Files

Similar to `.nvmrc` or `.python-version`, Airlock supports single-token configuration files:

```text
python
```

When `.airlock` consists of only a runtime name, Airlock detects it immediately and launches that runtime with default settings.

---

## Example Configurations

### Node.js Full-Stack Application
```ini
# .airlock
runtime=node
ports=3000 9229
env=PORT=3000
env=NODE_ENV=development
setup=npm install
```

### Python FastAPI Application
```ini
# .airlock
runtime=python
ports=8000
env=PYTHONUNBUFFERED=1
setup=pip install -r requirements.txt
```

### Rust Development
```ini
# .airlock
runtime=rust
ports=8080
env=RUST_BACKTRACE=1
setup=cargo build
```

### Alpine Linux with Custom Packages
```ini
# .airlock
runtime=alpine
setup=apk add --no-cache bash git curl jq
shell=bash
```
