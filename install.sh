#!/usr/bin/env bash
set -e

AIRLOCK_URL="https://raw.githubusercontent.com/besoeasy/airlock/main/airlock"
INSTALL_PATH="/usr/local/bin/airlock"

TMP_FILE=$(mktemp)
curl -fsSL "$AIRLOCK_URL" -o "$TMP_FILE"
chmod +x "$TMP_FILE"

if [ -w /usr/local/bin ]; then
    mv "$TMP_FILE" "$INSTALL_PATH"
else
    sudo mv "$TMP_FILE" "$INSTALL_PATH"
fi

echo "Airlock installed. Run: airlock"
