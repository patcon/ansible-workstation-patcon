#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.ssh/config.d
chmod 700 ~/.ssh/config.d

if [[ ! -f ~/.ssh/config ]]; then
    touch ~/.ssh/config
    chmod 600 ~/.ssh/config
fi

if ! grep -qE 'Include\s+(~/.ssh/)?config.d/' ~/.ssh/config; then
    tmpfile=$(mktemp)
    { printf 'Include config.d/*\n\n'; cat ~/.ssh/config; } > "$tmpfile"
    mv "$tmpfile" ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo "Added 'Include config.d/*' to ~/.ssh/config"
fi

echo "SSH config.d ready at ~/.ssh/config.d"
