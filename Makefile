# These are just a set of helpers for common tasks and usage demonstrations.

install_roles: ## Install external roles from Ansible Galaxy
	ansible-galaxy install --role-file roles_external.yml

converge: install_roles ## Converge the workstation over SSH
	ansible-playbook playbooks/workstation.yml

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
