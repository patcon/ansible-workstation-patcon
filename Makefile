# These are just a set of helpers for common tasks and usage demonstrations.

prereq_check: ## Check local SSH config prereqs before running converge
	python3 scripts/prereq_check.py

install_roles: ## Install external roles and collections from Ansible Galaxy
	ansible-galaxy install --role-file roles_external.yml
	ansible-galaxy collection install --requirements-file collections.yml
	python3 scripts/external_roles_monkeypatch.py

converge: install_roles ## Converge the workstation over SSH
	ansible-playbook playbooks/workstation.yml

bootstrap: install_roles ## Create the sudo user and authorize SSH keys, before hardening locks out root
	ansible-playbook playbooks/workstation.yml --tags bootstrap

converge_local: install_roles ## Converge the workstation locally
	ansible-playbook playbooks/workstation.yml --connection=local

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
