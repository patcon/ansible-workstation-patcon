#!/data/data/com.termux/files/usr/bin/bash
#
# Tears down the Hetzner workstation server by name.
# Runs daily via cron to ensure the server isn't left running.
#
# SETUP (one-time, on phone):
#   Reference: https://netzro.github.io/posts/2025/Jun/08/setting-up-cronie-and-scheduling-scripts-in-termux/
#
#   1. Install dependencies:
#        pkg install cronie termux-services
#
#   2. Enable crond as a persistent service (auto-starts with Termux):
#        sv-enable crond
#
#   3. Acquire a wake lock so Android doesn't kill Termux in the background:
#        termux-wake-lock
#      Also disable battery optimization for Termux in Android Settings.
#
#   4. Install hcloud CLI (grab the linux_arm64 build):
#        https://github.com/hetznercloud/cli/releases/latest
#        mv hcloud ~/bin/hcloud && chmod +x ~/bin/hcloud
#
#   5. Configure hcloud with your API token:
#        hcloud context create workstation
#      (prompts for token; stored in ~/.config/hcloud/cli.toml)
#
#   6. Clone the repo and symlink this script into place:
#        git clone https://github.com/patcon/ansible-workstation-patcon ~/repos/ansible-workstation-patcon
#        mkdir -p ~/bin
#        ln -s ~/repos/ansible-workstation-patcon/support/termux/cron-teardown-workstation.sh ~/bin/cron-teardown-workstation.sh
#        chmod +x ~/bin/cron-teardown-workstation.sh
#
#   7. Add to crontab (runs at 2am daily):
#        crontab -e
#      Add this line:
#        0 2 * * * /data/data/com.termux/files/home/bin/cron-teardown-workstation.sh >> /data/data/com.termux/files/home/cron-teardown-workstation.log 2>&1

SERVER_NAME="workstation-test1"

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
echo "$(date): Running teardown for '$SERVER_NAME'"
"$SCRIPT_DIR/../../scripts/hcloud-workstation" down "$SERVER_NAME" --yes
