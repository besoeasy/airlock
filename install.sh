#!/usr/bin/env bash
set -e

REPO="besoeasy/airlock"
RELEASE_API_URL="https://api.github.com/repos/${REPO}/releases/latest"

echo "==> Airlock Installer"

# Resolve latest release tag (e.g. 2026.09.16) via GitHub Releases API.
# Falls back to 'main' when offline, rate-limited, or no releases exist yet.
# NOTE: only called in the download branch below — local installs skip the API.
resolve_source_ref() {
    local api_json tag
    if command -v curl >/dev/null 2>&1; then
        api_json=$(curl -fsSL --connect-timeout 3 --max-time 8 "$RELEASE_API_URL" 2>/dev/null) || { echo "main"; return 0; }
    elif command -v wget >/dev/null 2>&1; then
        api_json=$(wget -qO- --connect-timeout=3 --timeout=8 "$RELEASE_API_URL" 2>/dev/null) || { echo "main"; return 0; }
    else
        echo "main"
        return 0
    fi
    tag=$(printf '%s' "$api_json" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')
    tag=$(printf '%s' "$tag" | tr -d '[:space:]')
    if [ -n "$tag" ]; then
        echo "$tag"
    else
        echo "main"
    fi
}

# 1. Determine target directory
if [ "$(id -u)" -eq 0 ] || [ -w "/usr/local/bin" ]; then
    TARGET_DIR="/usr/local/bin"
    USE_SUDO=false
elif [ -f "$HOME/.local/bin/airlock" ]; then
    TARGET_DIR="$HOME/.local/bin"
    USE_SUDO=false
elif [ -f "/usr/local/bin/airlock" ] && sudo -n true 2>/dev/null; then
    TARGET_DIR="/usr/local/bin"
    USE_SUDO=true
else
    TARGET_DIR="$HOME/.local/bin"
    USE_SUDO=false
fi

TARGET_BIN="${TARGET_DIR}/airlock"
IS_UPDATE=false
if [ -f "$TARGET_BIN" ]; then
    IS_UPDATE=true
fi

if [ "$IS_UPDATE" = true ]; then
    echo "Updating Airlock at ${TARGET_BIN}..."
else
    echo "Installing Airlock to ${TARGET_BIN}..."
fi

# 2. Ensure target directory exists
if [ "$USE_SUDO" = true ]; then
    sudo mkdir -p "$TARGET_DIR"
else
    mkdir -p "$TARGET_DIR"
fi

# 3. Obtain airlock binary
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE" "${TMP_FILE}.stamped"' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
if [ -f "${SCRIPT_DIR}/airlock" ] && [ "${SCRIPT_DIR}" != "$TARGET_DIR" ]; then
    echo "Installing from local copy (${SCRIPT_DIR}/airlock)..."
    cp "${SCRIPT_DIR}/airlock" "$TMP_FILE"
else
    SOURCE_REF="$(resolve_source_ref)"
    AIRLOCK_URL="https://raw.githubusercontent.com/${REPO}/${SOURCE_REF}/airlock"
    if [ "$SOURCE_REF" = "main" ]; then
        echo "Using development branch (main) — no release found or offline."
    else
        echo "Using latest release: ${SOURCE_REF}"
    fi
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$AIRLOCK_URL" -o "$TMP_FILE"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TMP_FILE" "$AIRLOCK_URL"
    else
        echo "Error: curl or wget is required to install Airlock." >&2
        exit 1
    fi
fi

chmod +x "$TMP_FILE"

# 3b. Stamp the installed copy with the resolved ref so 'airlock --version'
# knows what it was installed from (the repo itself keeps VERSION="dev").
# Local-copy installs skip this and stay "dev". No sed -i (not portable to
# macOS/BSD), and never fatal: a stamp failure must not break an install.
if [ -n "${SOURCE_REF:-}" ]; then
    STAMP_VER="${SOURCE_REF#v}"
    case "$STAMP_VER" in
        *[!A-Za-z0-9_.-]*)
            echo "Warning: unusual release ref ($SOURCE_REF); installing unstamped." >&2
            ;;
        *)
            if sed -E "s/^VERSION=\"[^\"]*\"/VERSION=\"$STAMP_VER\"/" "$TMP_FILE" > "${TMP_FILE}.stamped" 2>/dev/null \
                && grep -qxF "VERSION=\"$STAMP_VER\"" "${TMP_FILE}.stamped" 2>/dev/null; then
                mv "${TMP_FILE}.stamped" "$TMP_FILE"
            else
                echo "Warning: could not stamp version ($SOURCE_REF); installing unstamped." >&2
                rm -f "${TMP_FILE}.stamped"
            fi
            ;;
    esac
fi

# 4. Install binary
if [ "$USE_SUDO" = true ]; then
    sudo mv "$TMP_FILE" "$TARGET_BIN"
    if command -v restorecon >/dev/null 2>&1; then
        sudo restorecon "$TARGET_BIN" 2>/dev/null || true
    fi
else
    mv "$TMP_FILE" "$TARGET_BIN"
    if command -v restorecon >/dev/null 2>&1; then
        restorecon "$TARGET_BIN" 2>/dev/null || true
    fi
fi

# 5. Check PATH if installed to ~/.local/bin
PATH_UPDATED=false
SHELL_RC=""
if [ "$TARGET_DIR" = "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    SHELL_NAME="$(basename "${SHELL:-bash}")"
    case "$SHELL_NAME" in
        zsh)
            SHELL_RC="$HOME/.zshrc"
            ;;
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                SHELL_RC="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                SHELL_RC="$HOME/.bash_profile"
            else
                SHELL_RC="$HOME/.bashrc"
            fi
            ;;
        fish)
            SHELL_RC="$HOME/.config/fish/config.fish"
            ;;
        *)
            if [ -f "$HOME/.profile" ]; then
                SHELL_RC="$HOME/.profile"
            else
                SHELL_RC="$HOME/.bashrc"
            fi
            ;;
    esac

    if [ "$SHELL_NAME" = "fish" ]; then
        mkdir -p "$HOME/.config/fish"
        if ! grep -qs 'fish_add_path.*\.local/bin' "$SHELL_RC" 2>/dev/null; then
            echo 'fish_add_path $HOME/.local/bin' >> "$SHELL_RC"
            PATH_UPDATED=true
        fi
    else
        if ! grep -qs 'PATH=.*\.local/bin' "$SHELL_RC" 2>/dev/null; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
            PATH_UPDATED=true
        fi
    fi
fi

# 6. Check for container engine
CONTAINER_MSG=""
if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
    CONTAINER_MSG="Note: Podman or Docker is required to run containers. Podman is recommended (https://podman.io)."
fi

# 7. Print completion message
echo
if [ "$IS_UPDATE" = true ]; then
    echo "✓ Airlock successfully updated at ${TARGET_BIN}"
else
    echo "✓ Airlock successfully installed at ${TARGET_BIN}"
fi

if [ -n "$CONTAINER_MSG" ]; then
    echo
    echo "$CONTAINER_MSG"
fi

if [ "$PATH_UPDATED" = true ]; then
    echo
    echo "Notice: Added ~/.local/bin to ${SHELL_RC}"
    echo "To use 'airlock' immediately in your current terminal session, run:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "Or start a new terminal session."
else
    echo
    echo "Run 'airlock' to get started."
fi
