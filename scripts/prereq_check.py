#!/usr/bin/env python3
import subprocess
import sys
import os

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INVENTORY_FILE = os.path.join(REPO_ROOT, 'inventory', 'workstation.ini')

IS_MACOS = sys.platform == 'darwin'

CHECKS = [
    {
        'key': 'forwardagent',
        'expected': 'yes',
        'option': 'ForwardAgent yes',
        'reason': 'required so the remote host can pull from GitHub during converge_local',
        'scope': 'host',
    },
    {
        'key': 'addkeystoagent',
        'expected': 'yes',
        'option': 'AddKeysToAgent yes',
        'reason': 'loads your SSH key into the agent automatically on first use',
        'scope': 'global',
    },
    {
        'key': 'usekeychain',
        'expected': 'yes',
        'option': 'UseKeychain yes',
        'reason': 'persists your key passphrase in macOS Keychain across reboots',
        'scope': 'global',
        'macos_only': True,
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
    result = subprocess.run(['ssh', '-G', host], capture_output=True, text=True)
    config = {}
    for line in result.stdout.splitlines():
        key, _, value = line.partition(' ')
        config[key.lower()] = value.lower()
    return config


def main():
    host = get_workstation_host()
    if not host:
        print('ERROR: No host found in [workstation] section of inventory/workstation.ini')
        sys.exit(1)

    print(f'Workstation: {host}')
    print(f'Checking ~/.ssh/config ...')
    print()

    ssh_config = get_effective_ssh_config(host)

    failed_host = []
    failed_global = []

    for check in CHECKS:
        if check.get('macos_only') and not IS_MACOS:
            continue
        passed = ssh_config.get(check['key']) == check['expected']
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
