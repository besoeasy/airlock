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

launch() {
    local name="$1"
    local rt
    rt=$(detect_runtime)

    case "$name" in
        node)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e npm_config_cache=/workspace/.npm-cache \
                node:lts bash
            ;;
        bun)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e BUN_INSTALL_CACHE_DIR=/workspace/.bun-cache \
                oven/bun:latest bash
            ;;
        deno)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e DENO_DIR=/workspace/.deno-cache \
                --entrypoint /bin/bash \
                denoland/deno:latest
            ;;
        python)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e PIP_CACHE_DIR=/workspace/.pip-cache \
                -e HOME=/workspace \
                python:3 bash
            ;;
        go)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e GOPATH=/workspace/.go -e HOME=/workspace \
                golang:latest bash
            ;;
        rust)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e CARGO_HOME=/workspace/.cargo -e HOME=/workspace \
                rust:latest bash
            ;;
        zig)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e ZIG_GLOBAL_CACHE_DIR=/workspace/.zig-cache \
                --entrypoint /bin/sh \
                euantorano/zig:latest
            ;;
        debian)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e HOME=/workspace \
                debian:stable bash
            ;;
        alpine)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e HOME=/workspace \
                alpine:latest sh
            ;;
        opencode)
            $rt run -it --rm --pids-limit 256 --network host \
                -v "${PWD}:/workspace" -w /workspace \
                -e HOME=/workspace \
                ghcr.io/anomalyco/opencode
            ;;
        *)
            echo "Unknown runtime: $name" >&2
            echo "Runtimes: node, bun, deno, python, go, rust, zig, debian, alpine, opencode" >&2
            exit 1
            ;;
    esac
}

menu() {
    local rt
    rt=$(detect_runtime)
    echo "Airlock — $rt detected"
    echo
    echo "1) Node.js"
    echo "2) Bun"
    echo "3) Deno"
    echo "4) Python"
    echo "5) Go"
    echo "6) Rust"
    echo "7) Zig"
    echo "8) Debian"
    echo "9) Alpine"
    echo "10) OpenCode"
    echo
    read -rp "Select runtime: " choice

    case "$choice" in
        1) launch node ;;
        2) launch bun ;;
        3) launch deno ;;
        4) launch python ;;
        5) launch go ;;
        6) launch rust ;;
        7) launch zig ;;
        8) launch debian ;;
        9) launch alpine ;;
        10) launch opencode ;;
        *) echo "Invalid option." >&2; exit 1 ;;
    esac
}

if [ -n "${1:-}" ]; then
    launch "$1"
else
    menu
fi
