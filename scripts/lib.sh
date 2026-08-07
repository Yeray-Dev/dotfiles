#!/usr/bin/env bash
# Utilidades compartidas por el resto de scripts.
# Se puede llamar directamente para logging desde el Makefile:  lib.sh info "texto"

set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
done_() { printf '\033[1;32mok\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# ¿$1 >= $2?
version_ge() {
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]
}

# Devuelve: arch | debian | macos | unknown
detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      if   have pacman; then echo arch
      elif have apt-get; then echo debian
      else echo unknown
      fi
      ;;
    *) echo unknown ;;
  esac
}

is_omarchy() { [ -d "$HOME/.config/omarchy" ]; }

# Rutas que stow enlazará para un paquete, relativas a $HOME.
# Un paquete es  <pkg>/.config/<algo>  o  <pkg>/.<algo>
pkg_targets() {
  local pkg="$DOTFILES/$1" entry base child
  [ -d "$pkg" ] || die "El paquete '$1' no existe en $DOTFILES"

  for entry in "$pkg"/.[!.]*; do
    [ -e "$entry" ] || continue
    base="$(basename "$entry")"
    if [ "$base" = ".config" ]; then
      for child in "$entry"/*; do
        [ -e "$child" ] || continue
        printf '.config/%s\n' "$(basename "$child")"
      done
    else
      printf '%s\n' "$base"
    fi
  done
}

# Llamada directa desde el Makefile: lib.sh info "mensaje"
if [ "${BASH_SOURCE[0]}" = "${0}" ] && [ $# -gt 0 ]; then
  case "$1" in
    info) shift; info "$@" ;;
    warn) shift; warn "$@" ;;
    done) shift; done_ "$@" ;;
    os)   detect_os ;;
    *) die "Uso: lib.sh {info|warn|done|os} [mensaje]" ;;
  esac
fi
