#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pkg install -y termux-api netcat-openbsd

install -m 0755 "$SCRIPT_DIR/clipboard-receiver" "$PREFIX/bin/clipboard-receiver"
install -m 0755 "$SCRIPT_DIR/pbcopy"             "$PREFIX/bin/pbcopy"
install -m 0755 "$SCRIPT_DIR/pbpaste"            "$PREFIX/bin/pbpaste"
install -m 0755 "$SCRIPT_DIR/ssh-clipboard"      "$PREFIX/bin/ssh-clipboard"

echo "Done. Use 'ssh-clipboard <host>' to connect with clipboard forwarding."
