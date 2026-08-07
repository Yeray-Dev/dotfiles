#!/usr/bin/env bash
# Copia (no enlaza) la configuración de Hyprland y waybar al repo.
#
# Es copia deliberadamente: Omarchy gestiona esos ficheros y no quiero que un
# symlink haga que sus actualizaciones escriban dentro del repo. Como copia, se
# queda desactualizada sola — reejecuta esto cuando cambies algo.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

is_omarchy || die "Esto solo tiene sentido en Omarchy"

dest="$DOTFILES/omarchy"
mkdir -p "$dest"

for dir in hypr waybar; do
  if [ -d "$HOME/.config/$dir" ]; then
    rm -rf "${dest:?}/$dir"
    cp -rL "$HOME/.config/$dir" "$dest/$dir"
    info "Copiado: ~/.config/$dir"
  else
    warn "No existe ~/.config/$dir"
  fi
done

done_ "Copia hecha. Recuerda commitear si hay cambios."
