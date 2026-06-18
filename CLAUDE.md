# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
make prereq_check    # Verify ~/.ssh/config has required settings before running remotely
make install_roles   # Download external roles/collections from Ansible Galaxy + apply patches
make bootstrap       # First-time setup: create sudo user and authorize SSH keys (run before hardening)
make converge        # Apply full playbook over SSH to the remote workstation
make converge_local  # Apply full playbook locally (requires ansible installed on target)
make check           # Dry-run with diff output (no changes applied)
```

`install_roles` is a prerequisite of all playbook targets; it always runs first.

To run only specific tags:
```sh
ansible-playbook playbooks/workstation.yml --tags bootstrap
ansible-playbook playbooks/workstation.yml --tags hardening
ansible-playbook playbooks/workstation.yml --tags personalization
```

## Architecture

Single Ansible playbook (`playbooks/workstation.yml`) targeting a Hetzner VPS defined in `inventory/workstation.ini`. Roles run in a fixed order with intentional dependencies:

1. **bootstrap** (custom role) — must run before hardening; creates the non-root sudo user (`patcon`) and authorizes SSH keys, since `dev-sec.ssh-hardening` disables root SSH login
2. **dev-sec.os-hardening** (external) — hardens OS-level sysctl/kernel settings
3. **dev-sec.ssh-hardening** (external) — hardens sshd; configured to allow agent forwarding and accept `CLAUDE_CODE_OAUTH_TOKEN`/`GITHUB_TOKEN` env vars from the SSH session
4. **github_cli** (custom role) — installs `gh` via the official apt repository
5. **personalization** (custom role) — sets git user config and clones personal repos into `~/repos/`

### Role layout

- `roles_custom/` — custom roles, committed to this repo
- `roles_external/` — installed by ansible-galaxy, **gitignored**; declared in `roles_external.yml`
- `ansible.cfg` sets `roles_path = roles_external:roles_custom` so both directories are resolved

### External role patching

`scripts/external_roles_monkeypatch.py` runs automatically after `make install_roles` and patches two known incompatibilities in `dev-sec.ssh-hardening` 9.7.0:
- Jinja2 3.x requires bare booleans in template headers (not quoted strings)
- OpenSSH 8.5+ renamed a KEx algorithm that the role still references by the old name

When upgrading external roles, re-verify these patches still apply or are no longer needed.

### SSH prerequisites

`make prereq_check` validates that `~/.ssh/config` has `ForwardAgent yes` for the workstation host (so the remote host can pull from GitHub during converge) and `AddKeysToAgent yes` globally. On macOS, `UseKeychain yes` is also checked.
