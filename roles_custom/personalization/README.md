# personalization

Configures the workstation for the primary user: shell environment, git identity, repo cloning, and user-facing tools.

## Requirements

- Debian/Ubuntu-based system with `apt`
- SSH agent forwarding enabled (for repo cloning via git+ssh)

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `workstation_user` | `patcon` | Primary user to configure |
| `personalization_repos_dir` | `~/repos` | Directory to clone repos into |
| `personalization_repos` | (list) | Git repos to clone |
| `personalization_git_name` | `patcon` | Git `user.name` |
| `personalization_git_email` | `patrick.c.connolly@gmail.com` | Git `user.email` |

## Installed Tools

### `repo-salvage`

Installed to `~/.local/bin/repo-salvage`. Scans `~/repos` for work that could be lost before decommissioning a server.

```
repo-salvage [scan|push] [repos-dir]
```

| Subcommand | Description |
|---|---|
| `scan` (default) | Reports uncommitted changes, stashes, and unpushed/remoteless branches across all repos |
| `push` | Pushes all unpushed branches; sets upstream for branches that have none |

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: personalization
```
