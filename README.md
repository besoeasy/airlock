<div align="center">

# Airlock

**Run untrusted code without trusting it.**

Pick a runtime. Paste the command. Exit and it's gone.

## Install

```bash
sed -i '/# airlock-start/,/# airlock-end/d' ~/.bashrc 2>/dev/null; curl -fsSL https://raw.githubusercontent.com/besoeasy/airlock/main/airlock.sh -o /tmp/airlock.sh && chmod +x /tmp/airlock.sh && printf '\n# airlock-start\nairlock() { bash /tmp/airlock.sh "$@"; }\n# airlock-end\n' >> ~/.bashrc && echo "Installed. Run: source ~/.bashrc"
```

Then use `airlock` from anywhere:

```bash
airlock          # shows menu
airlock node     # goes straight to Node.js
airlock python   # goes straight to Python
```

## Runtimes

Node.js, Bun, Deno, Python, Go, Rust, Zig, Debian, Alpine

---

## License

MIT
