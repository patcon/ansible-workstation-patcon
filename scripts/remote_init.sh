#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Warning: not running as root. Package installation may fail."
fi

apt update
apt install -y git software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible make

git clone https://github.com/patcon/ansible-workstation-patcon /tmp/ansible-workstation-patcon
cd /tmp/ansible-workstation-patcon
make local_bootstrap
