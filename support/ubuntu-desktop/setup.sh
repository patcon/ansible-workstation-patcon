#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo apt-get install -y xclip netcat-openbsd

mkdir -p ~/.local/bin ~/.ssh/config.d

install -m 0644 "$SCRIPT_DIR/../common/ssh-config-clipboard" ~/.ssh/config.d/workstation-clipboard
grep -qF 'Include config.d/*' ~/.ssh/config || sed -i '1s/^/Include config.d\/*\n\n/' ~/.ssh/config

install -m 0755 "$SCRIPT_DIR/clipboard-receiver" ~/.local/bin/clipboard-receiver
install -m 0755 "$SCRIPT_DIR/pbcopy"             ~/.local/bin/pbcopy
install -m 0755 "$SCRIPT_DIR/pbpaste"            ~/.local/bin/pbpaste
install -m 0755 "$SCRIPT_DIR/ssh-clipboard"      ~/.local/bin/ssh-clipboard


echo "Done. Use 'ssh-clipboard <host>' to connect with clipboard forwarding."
