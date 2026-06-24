#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.local/bin ~/.config/systemd/user

install -m 0755 "$SCRIPT_DIR/clipboard-receiver" ~/.local/bin/clipboard-receiver
install -m 0755 "$SCRIPT_DIR/pbcopy"             ~/.local/bin/pbcopy
install -m 0755 "$SCRIPT_DIR/pbpaste"            ~/.local/bin/pbpaste
install -m 0755 "$SCRIPT_DIR/ssh-clipboard"      ~/.local/bin/ssh-clipboard

install -m 0644 "$SCRIPT_DIR/clipboard-receiver.service" ~/.config/systemd/user/clipboard-receiver.service

systemctl --user daemon-reload
systemctl --user enable clipboard-receiver

echo "Done. Use 'ssh-clipboard <host>' to connect with clipboard forwarding."
