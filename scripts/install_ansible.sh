#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Warning: not running as root. Package installation may fail."
fi

apt update
apt install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible
# Required to run the Makefile targets in this repo
apt install -y make
