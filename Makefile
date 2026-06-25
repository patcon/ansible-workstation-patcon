# These are just a set of helpers for common tasks and usage demonstrations.

REMOTE_HOST ?= workstation

prereq_check: ## Check local SSH config prereqs before running converge
	python3 scripts/prereq_check.py

install_roles: ## Install external roles and collections from Ansible Galaxy
	ansible-galaxy install --role-file roles_external.yml
	ansible-galaxy collection install --requirements-file collections.yml
	python3 scripts/external_roles_monkeypatch.py

remote_init: ## SSH into fresh server, install Ansible, and run local_bootstrap (override: REMOTE_HOST=other)
	ssh root@$(REMOTE_HOST) 'bash -s' < scripts/remote_init.sh

remote_bootstrap: install_roles ## Run bootstrap role on remote host (override: REMOTE_HOST=other)
	ansible-playbook --inventory "$(REMOTE_HOST)," --user root playbooks/workstation.yml --tags bootstrap

remote_converge: install_roles ## Full converge on remote host (override: REMOTE_HOST=other)
	ansible-playbook --inventory "$(REMOTE_HOST)," --user root playbooks/workstation.yml

local_bootstrap: install_roles ## Run bootstrap locally on this machine (used by remote_init) (usually faster)
	ansible-playbook playbooks/workstation.yml --tags bootstrap --connection=local

local_converge: install_roles ## Converge the workstation locally (usually faster)
	ansible-playbook playbooks/workstation.yml --connection=local

device_termux: ## Install Termux support scripts locally (clipboard, ssh-clipboard)
	bash support/termux/setup-clipboard.sh
	bash support/termux/customize-keyboard.sh

device_ubuntu: ## Install ubuntu-desktop support scripts locally (clipboard, ssh-clipboard)
	bash support/ubuntu-desktop/setup.sh

check: install_roles ## Dry-run the workstation playbook
	ansible-playbook playbooks/workstation.yml --check --diff

%:
	@true

.PHONY: help

help:
	@echo 'Usage: make <command>'
	@echo
	@echo 'where <command> is one of the following:'
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
