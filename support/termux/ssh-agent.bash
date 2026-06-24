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

# Three cases on source:
#   1. No saved env → start a fresh agent (also adds key).
#   2. Saved env exists, agent dead → restart agent (also adds key).
#   3. Saved env exists, agent alive → restore socket/pid, then add key if
#      missing. On long-lived runtimes (WSL, desktop Linux) the agent process
#      can survive across sessions with no keys loaded, so we can't assume a
#      live agent already has keys.
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    kill -0 $SSH_AGENT_PID 2>/dev/null || start_agent
    ssh-add -l > /dev/null 2>&1 || ssh-add ~/.ssh/id_ed25519
else
    start_agent
fi
