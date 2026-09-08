# Airlock Configuration Examples

This directory contains example `.airlock` configuration files for common development environments and use cases.

To test any example, navigate to its subfolder and run `airlock`:

```bash
cd example/node-api
airlock
```

Airlock will detect the `.airlock` file in the current directory and immediately launch the container with the preconfigured runtime, ports, and environment variables—**skipping all interactive questions**.

---

## Example Directory

| Subfolder | Runtime | Style | Key Highlights |
|---|---|---|---|
| [`node-api/`](./node-api/.airlock) | Node.js (`node`) | Key-Value | Multi-port forwarding (`3000`, `8080`), environment variables |
| [`python-fastapi/`](./python-fastapi/.airlock) | Python (`python`) | Key-Value | Single port (`8000`), `PYTHONUNBUFFERED=1` |
| [`rust-cli/`](./rust-cli/.airlock) | Rust (`rust`) | Key-Value | Host networking, clean development build environment |
| [`go-service/`](./go-service/.airlock) | Go (`go`) | Key-Value | Port `8080`, custom environment variables (`CGO_ENABLED=0`) |
| [`minimal/`](./minimal/.airlock) | Python (`python`) | Single-Token | Ultra-minimal 1-line configuration (like `.nvmrc` or `.python-version`) |
| [`security-audit/`](./security-audit/.airlock) | Trivy (`trivy`) | Key-Value | Immediate filesystem vulnerability and secret scanning |
