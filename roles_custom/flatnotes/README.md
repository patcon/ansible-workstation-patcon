# flatnotes

Runs [flatnotes](https://github.com/dullage/flatnotes) as a Docker container — a self-hosted, flat-file markdown note editor accessible via a web UI.

Also installs `flatnotes-mount`, a management script for bind-mounting individual files into the container so they appear as editable notes.

## Requirements

- Docker (e.g. via the `geerlingguy.docker` role)
- `community.docker` Ansible collection

## Role Variables

```yaml
flatnotes_enabled: true          # Set to false to remove the container
flatnotes_port: 8080             # Host port to expose the web UI on
flatnotes_data_dir: /opt/flatnotes/data

# Auth type — one of: none, read_only, password, totp
flatnotes_auth_type: none

# Required for password and totp auth types.
# flatnotes_secret_key should be a random 32-character string.
flatnotes_username: ~
flatnotes_password: ~
flatnotes_secret_key: ~

# Required for totp auth type only. Random 32-character string.
# On first start, flatnotes prints a QR code to register with an authenticator app.
flatnotes_totp_key: ~
```

## Managing extra file mounts

`flatnotes-mount` lets you bind-mount individual files from the host into `/data/` so they appear in the flatnotes UI. The mount list persists in `extra-mounts.conf` and is re-applied on each converge.

```sh
sudo flatnotes-mount add /home/patcon/repos/myproject/README.md
sudo flatnotes-mount remove /home/patcon/repos/myproject/README.md
sudo flatnotes-mount list
```

Note: flatnotes only reads `.md` files at the top level of `/data/` — subdirectory mounts are not visible in the UI.

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: flatnotes
      vars:
        flatnotes_port: 8080
        flatnotes_auth_type: password
        flatnotes_username: patcon
        flatnotes_password: "{{ vault_flatnotes_password }}"
        flatnotes_secret_key: "{{ vault_flatnotes_secret_key }}"
```
