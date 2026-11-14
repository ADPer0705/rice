SHELL := /usr/bin/bash
RICE  := bash bin/rice

.PHONY: help install deploy sync update status diff system timer fonts doctor lint

help:
	@printf '%s\n' \
	  'make install   - install packages, shell, plugins, uv/go tools' \
	  'make deploy    - copy configs into $$HOME (with backups)' \
	  'make sync      - capture $$HOME -> repo, commit, push' \
	  'make update    - pull, then deploy' \
	  'make status    - show drift' \
	  'make diff      - show drifted diffs' \
	  'make system    - preview root-owned file changes' \
	  'make timer     - install the daily capture timer' \
	  'make fonts     - refresh the font cache' \
	  'make doctor    - diagnose the setup' \
	  'make lint      - bash syntax check'

install:
	$(RICE) install

deploy:
	$(RICE) deploy

sync:
	$(RICE) sync

update:
	$(RICE) update

status:
	$(RICE) status

diff:
	$(RICE) diff

system:
	$(RICE) system

timer:
	$(RICE) timer install

fonts:
	$(RICE) fonts

doctor:
	$(RICE) doctor

lint:
	@bash -n bootstrap.sh bin/rice scripts/lib/*.sh
	@echo "bash syntax ok"
