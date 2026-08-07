# Dotfiles — instalación y gestión.
#
#   make            muestra esta ayuda
#   make all        entorno completo en una máquina nueva
#   make nvim       solo un paquete
#   make -n nvim    simula sin ejecutar nada

SHELL    := /bin/bash
DOTFILES := $(shell pwd)
S        := $(DOTFILES)/scripts
PACKAGES := nvim alacritty starship git shell

export DOTFILES

.DEFAULT_GOAL := help
.PHONY: help all deps ssh check backup-omarchy $(PACKAGES)

help:
	@printf '\n\033[1mDotfiles\033[0m — Omarchy / macOS / Debian\n\n'
	@printf '  \033[1;34mmake all\033[0m              Entorno completo (deps + ssh + todos los paquetes)\n'
	@printf '  \033[1;34mmake deps\033[0m             Solo dependencias del sistema\n'
	@printf '  \033[1;34mmake ssh\033[0m              Clave SSH y autenticación de gh\n'
	@printf '  \033[1;34mmake check\033[0m            Diagnóstico: qué está enlazado y qué falta\n\n'
	@printf '  Paquetes individuales:\n'
	@printf '  \033[1;34mmake %s\033[0m\n' $(PACKAGES)
	@printf '\n  \033[1;34mmake unstow-nvim\033[0m      Deshacer un paquete\n'
	@printf '  \033[1;34mmake backup-omarchy\033[0m   Copiar hypr/waybar al repo (solo Omarchy)\n\n'
	@printf '  Añade \033[1m-n\033[0m a cualquier target para ver qué haría sin hacerlo.\n\n'

all: deps ssh $(PACKAGES)
	@$(S)/lib.sh done "Entorno listo. Abre una terminal nueva."

deps:
	@$(S)/deps.sh all

ssh:
	@$(S)/ssh.sh

# Cada paquete: sus dependencias, backup de lo que haya, stow, y ajustes posteriores.
$(PACKAGES):
	@$(S)/deps.sh $@
	@$(S)/link.sh $@
	@$(S)/post.sh $@

unstow-%:
	@stow -D -t $(HOME) $*
	@$(S)/lib.sh info "Desenlazado: $*"

check:
	@$(S)/check.sh

backup-omarchy:
	@$(S)/backup-omarchy.sh
