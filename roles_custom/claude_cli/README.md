# claude_cli

Installs the [Claude Code](https://claude.ai/code) CLI for a given user and configures it to authenticate via a forwarded SSH environment variable rather than interactive login.

## How authentication works

Claude normally launches an interactive OAuth wizard on first run. This role bypasses that by:

1. Deploying a minimal `settings.json` so Claude doesn't prompt for setup
2. Deploying `~/.claude.json` with `hasCompletedOnboarding: true`
3. Removing `~/.claude/.credentials.json` on each converge — if a credentials file exists, Claude ignores `CLAUDE_CODE_OAUTH_TOKEN`; removing it ensures the forwarded env var is the sole auth source

The SSH server must be configured to accept `CLAUDE_CODE_OAUTH_TOKEN` from the client session (see `dev-sec.ssh-hardening` config in this repo).

## Requirements

- `curl` available on the target host
- SSH session with `CLAUDE_CODE_OAUTH_TOKEN` forwarded from the client

## Role Variables

```yaml
claude_cli_user: patcon    # User to install and configure Claude CLI for
```

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: claude_cli
      vars:
        claude_cli_user: patcon
```
