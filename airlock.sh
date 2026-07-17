#!/usr/bin/env bash
set -e

detect_runtime() {
    if command -v docker >/dev/null 2>&1; then
        echo "docker"
    elif command -v podman >/dev/null 2>&1; then
        echo "podman"
    else
        echo "Error: docker or podman required." >&2
        exit 1
    fi
}

RUNTIME=$(detect_runtime)

case "${1:-}" in
    node)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e npm_config_cache=/workspace/.npm-cache \
            node:lts bash
        ;;
    bun)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e BUN_INSTALL_CACHE_DIR=/workspace/.bun-cache \
            oven/bun:latest bash
        ;;
    deno)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e DENO_DIR=/workspace/.deno-cache \
            --entrypoint /bin/bash \
            denoland/deno:latest
        ;;
    python)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e PIP_CACHE_DIR=/workspace/.pip-cache \
            -e HOME=/workspace \
            python:3 bash
        ;;
    go)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e GOPATH=/workspace/.go -e HOME=/workspace \
            golang:latest bash
        ;;
    rust)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e CARGO_HOME=/workspace/.cargo -e HOME=/workspace \
            rust:latest bash
        ;;
    zig)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e ZIG_GLOBAL_CACHE_DIR=/workspace/.zig-cache \
            --entrypoint /bin/sh \
            euantorano/zig:latest
        ;;
    debian)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e HOME=/workspace \
            debian:stable bash
        ;;
    alpine)
        $RUNTIME run -it --rm --pids-limit 256 \
            -v "${PWD}:/workspace" -w /workspace \
            -e HOME=/workspace \
            alpine:latest sh
        ;;
    *)
        echo "Usage: airlock <runtime>"
        echo
        echo "Runtimes: node, bun, deno, python, go, rust, zig, debian, alpine"
        exit 1
        ;;
esac
