#!/usr/bin/env python3
import subprocess
import sys
import os
import textwrap
import shutil

SSH_CONFIG_FILE = os.path.expanduser('~/.ssh/config')

IS_MACOS = sys.platform == 'darwin'
IS_TERMUX = os.path.isdir('/data/data/com.termux')

# Both yes and true are valid SSH config boolean values
SSH_TRUE = {'yes', 'true'}

ENV_VAR_CHECKS = [
    {
        'var': 'CLAUDE_CODE_OAUTH_TOKEN',
        'reason': 'forwarded to remote host for Claude Code authentication',
    },
    {
        'var': 'GITHUB_TOKEN',
        'reason': 'forwarded to remote host for GitHub access',
    },
]

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
        'skip_termux': True,
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


def find_workstation_aliases():
    """Return all Host entries in ~/.ssh/config matching 'workstation*'."""
    if not os.path.exists(SSH_CONFIG_FILE):
        return []
    aliases = []
    with open(SSH_CONFIG_FILE) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            key, _, value = line.partition(' ')
            if key.lower() == 'host':
                alias = value.strip()
                if alias.startswith('workstation') and '*' not in alias:
                    aliases.append(alias)
    return aliases


def get_effective_ssh_config(host):
    """Use `ssh -G` to get the merged effective config for a host."""
    result = subprocess.run(['ssh', '-G', host], capture_output=True, text=True)
    config = {}
    for line in result.stdout.splitlines():
        key, _, value = line.partition(' ')
        config[key.lower()] = value.lower()
    return config


def print_check(status, label, reason):
    width = shutil.get_terminal_size((60, 20)).columns
    indent = '        '
    print(f'    [{status}]  {label}')
    print(textwrap.fill(reason, width=width, initial_indent=indent, subsequent_indent=indent))


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
    aliases = find_workstation_aliases()
    if not aliases:
        print('ERROR: No Host entries matching workstation* found in ~/.ssh/config')
        sys.exit(1)

    print(f'Found workstation SSH hosts: {", ".join(aliases)}')
    print(f'Checking ~/.ssh/config ...')

    raw_keys = get_raw_ssh_config_keys()
    host_checks = [c for c in CHECKS if c['scope'] == 'host']
    global_checks = [c for c in CHECKS if c['scope'] == 'global']

    failed_hosts = {}
    failed_global = []

    for alias in aliases:
        print()
        print(f'  {alias}:')
        ssh_config = get_effective_ssh_config(alias)
        for check in host_checks:
            passed = ssh_config.get(check['key']) in SSH_TRUE
            status = 'ok    ' if passed else 'MISSING'
            print_check(status, check['option'], check['reason'])
            if not passed:
                failed_hosts.setdefault(alias, []).append(check['option'])

    print()
    print('  global:')
    for check in global_checks:
        if check.get('macos_only') and not IS_MACOS:
            continue
        if check.get('skip_termux') and IS_TERMUX:
            continue
        passed = check['key'] in raw_keys
        status = 'ok    ' if passed else 'MISSING'
        print_check(status, check['option'], check['reason'])
        if not passed:
            failed_global.append(check['option'])

    print()
    print('  ssh agent:')
    failed_agent = []
    agent_sock = os.environ.get('SSH_AUTH_SOCK', '')
    sock_ok = bool(agent_sock) and os.path.exists(agent_sock)
    status = 'ok    ' if sock_ok else 'MISSING'
    print_check(status, 'SSH_AUTH_SOCK', 'agent socket must exist for forwarding')
    if not sock_ok:
        failed_agent.append('SSH agent is not running (SSH_AUTH_SOCK unset or socket missing)')
    else:
        result = subprocess.run(['ssh-add', '-l'], capture_output=True)
        has_keys = result.returncode == 0
        status = 'ok    ' if has_keys else 'MISSING'
        print_check(status, 'ssh-add -l', 'at least one key must be loaded to forward')
        if not has_keys:
            failed_agent.append('No keys loaded in SSH agent — run: ssh-add ~/.ssh/id_ed25519 (or your key path)')

    print()
    print('  env vars:')
    warned_vars = []
    for check in ENV_VAR_CHECKS:
        present = check['var'] in os.environ
        status = 'ok    ' if present else 'UNSET '
        print_check(status, check['var'], check['reason'])
        if not present:
            warned_vars.append(check['var'])

    if not failed_hosts and not failed_global and not failed_agent:
        print()
        if warned_vars:
            print(f'WARNING: {", ".join(warned_vars)} not set — tokens will not be forwarded over SSH.')
        else:
            print('All checks passed.')
        return

    print()
    if failed_agent:
        print('Fix the following SSH agent issues:')
        print()
        for msg in failed_agent:
            print(f'  - {msg}')
        print()
    if failed_hosts or failed_global:
        print('Add the following to ~/.ssh/config:')
        print()
        for alias, opts in failed_hosts.items():
            print(f'Host {alias}')
            for opt in opts:
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
