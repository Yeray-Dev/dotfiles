#!/usr/bin/env bash
# Regla de Karabiner: Caps Lock -> Escape, solo en la terminal.
#
# No es un paquete de stow: Karabiner reescribe karabiner.json por su cuenta,
# así que enlazamos únicamente el fichero de la regla.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

[ "$(detect_os)" = macos ] || die "Karabiner solo existe en macOS"

if ! [ -d /Applications/Karabiner-Elements.app ]; then
  info "Instalando Karabiner-Elements"
  brew install --cask karabiner-elements
fi

dest="$HOME/.config/karabiner/assets/complex_modifications"
mkdir -p "$dest"
ln -sf "$DOTFILES/karabiner/caps-escape-terminal.json" "$dest/caps-escape-terminal.json"

done_ "Regla enlazada"
warn "Actívala en Karabiner-Elements > Complex Modifications > Add rule"
warn "Y concede permisos en Ajustes > Privacidad > Monitorización de entrada"
