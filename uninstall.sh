#!/usr/bin/env bash
set -e

if [ -f /usr/local/bin/airlock ]; then
    sudo rm -f /usr/local/bin/airlock
    echo "Airlock removed."
fi
