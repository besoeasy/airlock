#!/usr/bin/env bash
set -e

REPO="besoeasy/airlock"
RELEASE_WEB_URL="https://github.com/${REPO}/releases/latest"

echo "==> Airlock Installer"

# Resolve latest release tag (e.g. 2026.09.16) via GitHub releases web redirect.
# Falls back to 'main' when offline or no releases exist yet.
# NOTE: only called in the download branch below — local installs skip this.
resolve_source_ref() {
    local effective_url="" tag=""
    if command -v curl >/dev/null 2>&1; then
        effective_url=$(curl -fsSL --connect-timeout 3 --max-time 8 -o /dev/null -w "%{url_effective}" "$RELEASE_WEB_URL" 2>/dev/null || true)
    elif command -v wget >/dev/null 2>&1; then
        effective_url=$(wget -q -S --spider --timeout=8 "$RELEASE_WEB_URL" 2>&1 | grep -i '^[[:space:]]*location:' | tail -n1 | awk '{print $2}')
    fi
    tag="${effective_url##*/}"
    tag="${tag#v}"
    if [[ "$tag" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
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
    AIRLOCK_URL="https://cdn.jsdelivr.net/gh/${REPO}@${SOURCE_REF}/airlock"
    FALLBACK_URL="https://raw.githubusercontent.com/${REPO}/${SOURCE_REF}/airlock"
    if [ "$SOURCE_REF" = "main" ]; then
        echo "Using development branch (main) — no release found or offline."
    else
        echo "Using latest release: ${SOURCE_REF}"
    fi
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$AIRLOCK_URL" -o "$TMP_FILE" 2>/dev/null || curl -fsSL "$FALLBACK_URL" -o "$TMP_FILE"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TMP_FILE" "$AIRLOCK_URL" 2>/dev/null || wget -qO "$TMP_FILE" "$FALLBACK_URL"
    else
        echo "Error: curl or wget is required to install Airlock." >&2
        exit 1
    fi
fi

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

# chmod AFTER stamping: the stamp step rewrites the file via redirect,
# which would clobber an earlier +x.
chmod +x "$TMP_FILE"

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

# 6. Ensure Podman is installed (the only supported engine).
# Prints every command before running it; uses sudo when not root.
# Never fatal: exotic systems fall through with manual instructions
# and the Airlock install still completes.
ensure_podman() {
    command -v podman >/dev/null 2>&1 && return 0

    echo
    echo "Podman not found — installing it automatically (required by Airlock)..."

    # Atomic/immutable systems manage packages differently; don't guess.
    if command -v rpm-ostree >/dev/null 2>&1; then
        echo "This looks like an rpm-ostree system (Silverblue/Kinoite/Universal Blue)." >&2
        echo "Podman is usually preinstalled; otherwise run: rpm-ostree install podman (then reboot)." >&2
        return 1
    fi

    local sudo_cmd=()
    if [ "$(id -u)" -ne 0 ]; then
        if ! command -v sudo >/dev/null 2>&1; then
            echo "Need root or sudo to install Podman; then re-run this script." >&2
            return 1
        fi
        sudo_cmd=(sudo)
    fi

    if [ "$(uname -s)" = "Darwin" ]; then
        if ! command -v brew >/dev/null 2>&1; then
            echo "macOS needs Homebrew first: https://brew.sh — then: brew install podman" >&2
            return 1
        fi
        if [ "$(id -u)" -eq 0 ]; then
            echo "Homebrew refuses to run as root; install Podman manually: brew install podman" >&2
            return 1
        fi
        echo "+ brew install podman"
        brew install podman || return 1
        echo "Next: podman machine init && podman machine start"
    else
        local os_id="" os_like=""
        if [ -f /etc/os-release ]; then
            os_id="$(grep -E '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')"
            os_like="$(grep -E '^ID_LIKE=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')"
        fi
        case " $os_id $os_like " in
            *" debian "*|*" ubuntu "*|*" raspbian "*|*" linuxmint "*|*" pop "*)
                echo "+ ${sudo_cmd[*]} apt-get update && ${sudo_cmd[*]} apt-get install -y podman"
                "${sudo_cmd[@]}" apt-get update && "${sudo_cmd[@]}" apt-get install -y podman || return 1
                ;;
            *" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" alma "*|*" almalinux "*)
                if command -v dnf >/dev/null 2>&1; then
                    echo "+ ${sudo_cmd[*]} dnf install -y podman"
                    "${sudo_cmd[@]}" dnf install -y podman || return 1
                else
                    echo "+ ${sudo_cmd[*]} yum install -y podman"
                    "${sudo_cmd[@]}" yum install -y podman || return 1
                fi
                ;;
            *" arch "*|*" manjaro "*|*" endeavouros "*|*" cachyos "*)
                echo "+ ${sudo_cmd[*]} pacman -Sy --noconfirm podman"
                "${sudo_cmd[@]}" pacman -Sy --noconfirm podman || return 1
                ;;
            *" opensuse "*|*" suse "*|*" sled "*|*" sles "*)
                echo "+ ${sudo_cmd[*]} zypper --non-interactive install podman"
                "${sudo_cmd[@]}" zypper --non-interactive install podman || return 1
                ;;
            *" alpine "*)
                echo "+ ${sudo_cmd[*]} apk add podman"
                "${sudo_cmd[@]}" apk add podman || return 1
                ;;
            *)
                echo "Unsupported distro for automatic install ($os_id). Install Podman manually: https://podman.io/docs/installation" >&2
                return 1
                ;;
        esac
    fi

    if command -v podman >/dev/null 2>&1; then
        echo "Podman installed successfully."
        return 0
    fi
    echo "Podman install seemed to succeed but 'podman' is still not on PATH." >&2
    return 1
}

CONTAINER_MSG=""
if ! ensure_podman; then
    CONTAINER_MSG="Note: Podman is required to run containers but could not be installed automatically. Install it manually (https://podman.io/docs/installation), then use Airlock normally."
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
