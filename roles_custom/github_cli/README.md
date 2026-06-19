# github_cli

Installs the [GitHub CLI](https://cli.github.com/) (`gh`) via the official apt repository.

## Requirements

- Debian/Ubuntu-based system with `apt`

## Role Variables

None.

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: github_cli
```
