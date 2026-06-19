# Shared SSH agent across Termux sessions.
# Source this from ~/.bashrc:
#   . ~/repos/ansible-workstation-patcon/support/termux/ssh-agent.bash
#
# Uses kill -0 instead of ps -ef to check agent liveness, since ps cannot
# see all processes on Android/Termux.

SSH_ENV="$HOME/.ssh/environment"

function start_agent {
    echo "Initializing new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    ssh-add ~/.ssh/id_ed25519
}

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    kill -0 $SSH_AGENT_PID 2>/dev/null || {
        start_agent
    }
else
    start_agent
fi
