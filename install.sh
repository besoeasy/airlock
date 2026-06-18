#!/usr/bin/env bash
set -e

AIRLOCK_URL="https://cdn.jsdelivr.net/gh/besoeasy/airlock@main/airlock"
INSTALL_PATH="/usr/local/bin/airlock"

has_container_runtime() {
    command -v docker >/dev/null 2>&1 || command -v podman >/dev/null 2>&1
}

install_podman() {
    local id id_like

    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        id="${ID:-}"
        id_like="${ID_LIKE:-}"
    fi

    case "$id" in
        debian|ubuntu|raspbian|linuxmint|pop)
            echo "Installing Podman (apt)..."
            sudo apt-get update -qq
            sudo apt-get install -y podman
            ;;
        fedora)
            echo "Installing Podman (dnf)..."
            sudo dnf install -y podman
            ;;
        rhel|centos|rocky|almalinux|ol|amzn)
            echo "Installing Podman..."
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y podman
            else
                sudo yum install -y podman
            fi
            ;;
        arch|manjaro|endeavouros)
            echo "Installing Podman (pacman)..."
            sudo pacman -Sy --noconfirm podman
            ;;
        opensuse-leap|opensuse-tumbleweed|sles|opensuse)
            echo "Installing Podman (zypper)..."
            sudo zypper -n install podman
            ;;
        alpine)
            echo "Installing Podman (apk)..."
            sudo apk add --no-cache podman
            ;;
        *)
            case "$id_like" in
                *debian*)
                    echo "Installing Podman (apt)..."
                    sudo apt-get update -qq
                    sudo apt-get install -y podman
                    ;;
                *fedora*|*rhel*|*centos*)
                    echo "Installing Podman..."
                    if command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y podman
                    else
                        sudo yum install -y podman
                    fi
                    ;;
                *arch*)
                    echo "Installing Podman (pacman)..."
                    sudo pacman -Sy --noconfirm podman
                    ;;
                *)
                    if [ "$(uname -s)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
                        echo "Installing Podman (Homebrew)..."
                        brew install podman
                        echo "On macOS, run: podman machine init && podman machine start"
                        return 0
                    fi

                    echo "No container runtime found."
                    echo "Install Docker or Podman, then run: airlock"
                    return 1
                    ;;
            esac
            ;;
    esac
}

ensure_container_runtime() {
    if has_container_runtime; then
        return 0
    fi

    install_podman
}

install_binary() {
    local src="$1"

    if install -m 755 "$src" "$INSTALL_PATH" 2>/dev/null; then
        rm -f "$src"
        return 0
    fi

    if command -v sudo >/dev/null 2>&1; then
        sudo install -m 755 "$src" "$INSTALL_PATH"
        rm -f "$src"
        return 0
    fi

    rm -f "$src"
    echo "Failed to install to $INSTALL_PATH (permission denied)."
    echo "Run: sudo install -m 755 $src $INSTALL_PATH"
    exit 1
}

TMP_FILE=$(mktemp)
curl -fsSL "$AIRLOCK_URL" -o "$TMP_FILE"
chmod +x "$TMP_FILE"
install_binary "$TMP_FILE"

ensure_container_runtime

echo "Airlock installed. Run: airlock"