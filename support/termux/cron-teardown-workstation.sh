#!/data/data/com.termux/files/usr/bin/bash
#
# Tears down the Hetzner workstation server by name.
# Runs daily via cron to ensure the server isn't left running.
#
# SETUP (one-time, on phone):
#
#   1. Install dependencies:
#        pkg install cronie
#
#   2. Install hcloud CLI (grab the linux_arm64 build):
#        https://github.com/hetznercloud/cli/releases/latest
#        mv hcloud ~/bin/hcloud && chmod +x ~/bin/hcloud
#
#   3. Configure hcloud with your API token:
#        hcloud context create workstation
#      (prompts for token; stored in ~/.config/hcloud/cli.toml)
#
#   4. Clone the repo and symlink this script into place:
#        git clone https://github.com/patcon/ansible-workstation-patcon ~/repos/ansible-workstation-patcon
#        mkdir -p ~/bin
#        ln -s ~/repos/ansible-workstation-patcon/support/termux/teardown-workstation.sh ~/bin/teardown-workstation.sh
#        chmod +x ~/bin/teardown-workstation.sh
#
#   5. Add to crontab (runs at 2am daily):
#        crontab -e
#      Add this line:
#        0 2 * * * ~/bin/teardown-workstation.sh >> ~/teardown-workstation.log 2>&1
#
#   6. Start crond now and on boot:
#        crond
#      For auto-start on boot, install the Termux:Boot app, then:
#        mkdir -p ~/.termux/boot
#        echo 'crond' > ~/.termux/boot/start-crond.sh
#        chmod +x ~/.termux/boot/start-crond.sh

SERVER_NAME="workstation-test1"

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
echo "$(date): Running teardown for '$SERVER_NAME'"
"$SCRIPT_DIR/../../scripts/hcloud-workstation" down "$SERVER_NAME" --yes
