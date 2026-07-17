<div align="center">

# Airlock

**Run untrusted code without trusting it.**

Pick a runtime. Paste the command. Exit and it's gone.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/airlock.sh -o /tmp/airlock.sh && chmod +x /tmp/airlock.sh && sed -i '/# airlock-start/,/# airlock-end/d' ~/.bashrc 2>/dev/null; printf '\n# airlock-start\nairlock() { bash /tmp/airlock.sh "$@"; }\n# airlock-end\n' >> ~/.bashrc && source ~/.bashrc
```

## Runtimes

Node.js, Bun, Deno, Python, Go, Rust, Zig, Debian, Alpine

---

## License

MIT
