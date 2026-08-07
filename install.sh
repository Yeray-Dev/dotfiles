#!/usr/bin/env bash
#
# Bootstrap de una máquina nueva.
#
#   curl -fsSL https://raw.githubusercontent.com/Yeray-Dev/dotfiles/main/install.sh | bash
#   ./install.sh                # todo
#   ./install.sh nvim git       # solo esos paquetes
#
# Este script hace lo mínimo imprescindible: conseguir git y make, traer el repo
# y delegar en el Makefile. Toda la lógica real vive en scripts/, no aquí.

set -euo pipefail

REPO_URL="${DOTFILES_REPO:-https://github.com/Yeray-Dev/dotfiles.git}"
DEST="${DOTFILES_DIR:-$HOME/dotfiles}"

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# ------------------------------------------------------------------ prerequisitos

bootstrap_macos() {
  # git y make llegan con las Command Line Tools; treesitter también las necesita.
  if ! xcode-select -p >/dev/null 2>&1; then
    info "Instalando las Command Line Tools (acepta el diálogo y espera)"
    xcode-select --install || true
    until xcode-select -p >/dev/null 2>&1; do sleep 10; done
  fi

  if ! have brew; then
    info "Instalando Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Apple Silicon lo instala en /opt/homebrew, fuera del PATH por defecto.
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  [ -x /usr/local/bin/brew ]    && eval "$(/usr/local/bin/brew shellenv)"
  return 0
}

bootstrap_linux() {
  if have pacman; then
    sudo pacman -S --needed --noconfirm git make curl
  elif have apt-get; then
    sudo apt-get update
    sudo apt-get install -y git make curl
  else
    die "Sistema no soportado. Instala git y make a mano y vuelve a ejecutar."
  fi
}

ensure_prereqs() {
  case "$(uname -s)" in
    Darwin) bootstrap_macos ;;
    Linux)  bootstrap_linux ;;
    *)      die "Sistema no soportado: $(uname -s)" ;;
  esac

  have git  || die "git sigue sin estar disponible"
  have make || die "make sigue sin estar disponible"
}

# -------------------------------------------------------------------------- repo

fetch_repo() {
  if [ -d "$DEST/.git" ]; then
    info "El repo ya está en $DEST, actualizando"
    git -C "$DEST" pull --ff-only || warn "No se pudo actualizar; sigo con lo que hay"
  elif [ -e "$DEST" ]; then
    die "$DEST existe y no es un repo git. Muévelo o define DOTFILES_DIR."
  else
    info "Clonando en $DEST"
    git clone "$REPO_URL" "$DEST"
  fi
}

# -------------------------------------------------------------------------- main

main() {
  info "Sistema: $(uname -s) $(uname -m)"

  ensure_prereqs
  fetch_repo

  cd "$DEST"

  if [ ! -t 0 ]; then
    # Ejecutado vía curl | bash: sin TTY, make ssh no puede pedir passphrase.
    warn "Sin terminal interactiva: la configuración de SSH se omitirá."
    warn "Complétala luego con:  cd $DEST && make ssh"
  fi

  if [ $# -gt 0 ]; then
    info "Ejecutando: make $*"
    make "$@"
  else
    info "Ejecutando: make all"
    make all
  fi

  echo
  make check
}

main "$@"
