#!/usr/bin/env bash
# Aparta la configuración que ya hubiera en el destino y enlaza el paquete con stow.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

pkg="${1:?Uso: link.sh <paquete>}"

have stow || die "stow no está instalado (make deps)"

backed_up=0

while IFS= read -r rel; do
  dest="$HOME/$rel"

  # Ya es un enlace nuestro: nada que hacer, stow es idempotente.
  # stow crea enlaces relativos, así que hay que resolverlos contra su directorio.
  if [ -L "$dest" ]; then
    link="$(readlink "$dest")"
    resolved="$(cd "$(dirname "$dest")" 2>/dev/null && cd "$(dirname "$link")" 2>/dev/null && pwd -P)"
    case "${resolved:-}/$(basename "$link")" in
      "$DOTFILES"/*) continue ;;
    esac
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.bak-$STAMP"
    info "Apartado: $dest -> $dest.bak-$STAMP"
    backed_up=1
  fi
done < <(pkg_targets "$pkg")

stow -t "$HOME" -d "$DOTFILES" "$pkg"
done_ "Enlazado: $pkg"

[ "$backed_up" -eq 1 ] && \
  warn "Había configuración previa. Revísala en los *.bak-$STAMP y bórralos cuando confirmes."

exit 0
