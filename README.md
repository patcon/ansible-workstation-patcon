# ansible-workstation-patcon

Provisions a Hetzner VPS workstation via Ansible.

## Termux Shortcuts

The `support/termux/shortcuts/` directory contains scripts for [Termux:Widget](https://f-droid.org/packages/com.termux.widget/) shortcuts. Symlink it as `~/.shortcuts` to make them available:

```sh
ln -s ~/repos/ansible-workstation-patcon/support/termux/shortcuts ~/.shortcuts
```

Available shortcuts:

- **workstation-up** — create a new workstation server (auto-named), then bootstrap and converge it
- **workstation-list** — list all servers

## Bootstrap from Termux

1. Install [Termux](https://f-droid.org/packages/com.termux/) from F-Droid
2. Generate an SSH key: `ssh-keygen -t ed25519`
3. Create `~/.ssh/config` with your workstation host:
   ```
   Host workstation
       HostName <ip>
       User root
       ForwardAgent yes
       AddKeysToAgent yes
   ```
4. Install git: `pkg install git`
5. Clone this repo: `git clone https://github.com/patcon/ansible-workstation-patcon.git && cd ansible-workstation-patcon`
6. Bootstrap the remote host (installs Ansible, clones repo, runs bootstrap role):
   ```
   make remote_init
   ```
7. Apply the full playbook:
   ```
   make remote_converge
   ```
   To target a different host: `make remote_converge REMOTE_HOST=<ip>`
