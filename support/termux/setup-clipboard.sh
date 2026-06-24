#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pkg install -y termux-api netcat-openbsd

mkdir -p ~/.local/bin

install -m 0755 "$SCRIPT_DIR/clipboard-receiver" ~/.local/bin/clipboard-receiver
install -m 0755 "$SCRIPT_DIR/pbcopy"             ~/.local/bin/pbcopy
install -m 0755 "$SCRIPT_DIR/pbpaste"            ~/.local/bin/pbpaste
install -m 0755 "$SCRIPT_DIR/ssh-clipboard"      ~/.local/bin/ssh-clipboard

echo "Done. Use 'ssh-clipboard <host>' to connect with clipboard forwarding."
