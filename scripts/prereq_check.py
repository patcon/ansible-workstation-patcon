#!/usr/bin/env python3
import subprocess
import sys
import os
import re

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INVENTORY_FILE = os.path.join(REPO_ROOT, 'inventory', 'workstation.ini')
SSH_CONFIG_FILE = os.path.expanduser('~/.ssh/config')

IS_MACOS = sys.platform == 'darwin'

# Both yes and true are valid SSH config boolean values
SSH_TRUE = {'yes', 'true'}

CHECKS = [
    {
        'key': 'forwardagent',
        'option': 'ForwardAgent yes',
        'reason': 'required so the remote host can pull from GitHub during converge_local',
        'scope': 'host',
    },
    {
        'key': 'addkeystoagent',
        'option': 'AddKeysToAgent yes',
        'reason': 'loads your SSH key into the agent automatically on first use',
        'scope': 'global',
    },
    {
        'key': 'usekeychain',
        'option': 'UseKeychain yes',
        'reason': 'persists your key passphrase in macOS Keychain across reboots',
        'scope': 'global',
        'macos_only': True,
        # Apple extension: not output by `ssh -G`; parse ~/.ssh/config directly
        'parse_raw': True,
    },
]


def get_workstation_host():
    with open(INVENTORY_FILE) as f:
        lines = f.readlines()
    in_section = False
    for line in lines:
        line = line.strip()
        if line == '[workstation]':
            in_section = True
            continue
        if in_section:
            if not line or line.startswith('['):
                break
            if not line.startswith('#'):
                return line
    return None


def get_effective_ssh_config(host):
    """Use `ssh -G` to get the merged effective config for a host."""
    result = subprocess.run(['ssh', '-G', host], capture_output=True, text=True)
    config = {}
    for line in result.stdout.splitlines():
        key, _, value = line.partition(' ')
        config[key.lower()] = value.lower()
    return config


def get_raw_ssh_config_keys():
    """Parse ~/.ssh/config for option keys present in any block (case-insensitive).
    Used for Apple-specific options that ssh -G doesn't output."""
    if not os.path.exists(SSH_CONFIG_FILE):
        return set()
    keys = set()
    with open(SSH_CONFIG_FILE) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#'):
                key, _, value = line.partition(' ')
                if value.strip().lower() in SSH_TRUE:
                    keys.add(key.lower())
    return keys


def main():
    host = get_workstation_host()
    if not host:
        print('ERROR: No host found in [workstation] section of inventory/workstation.ini')
        sys.exit(1)

    print(f'Workstation: {host}')
    print(f'Checking ~/.ssh/config ...')
    print()

    ssh_config = get_effective_ssh_config(host)
    raw_keys = get_raw_ssh_config_keys()

    failed_host = []
    failed_global = []

    for check in CHECKS:
        if check.get('macos_only') and not IS_MACOS:
            continue
        if check.get('parse_raw'):
            passed = check['key'] in raw_keys
        else:
            passed = ssh_config.get(check['key']) in SSH_TRUE
        status = 'ok    ' if passed else 'MISSING'
        print(f'  [{status}]  {check["option"]:30s}  # {check["reason"]}')
        if not passed:
            if check['scope'] == 'host':
                failed_host.append(check['option'])
            else:
                failed_global.append(check['option'])

    if not failed_host and not failed_global:
        print()
        print('All checks passed.')
        return

    print()
    print('Add the following to ~/.ssh/config:')
    print()
    if failed_host:
        print(f'Host {host}')
        for opt in failed_host:
            print(f'    {opt}')
        print()
    if failed_global:
        print('Host *')
        for opt in failed_global:
            print(f'    {opt}')
        print()

    sys.exit(1)


if __name__ == '__main__':
    main()
