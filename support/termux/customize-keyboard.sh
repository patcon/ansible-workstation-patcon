#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.termux
install -m 0644 "$SCRIPT_DIR/termux.properties" ~/.termux/termux.properties
termux-reload-settings
