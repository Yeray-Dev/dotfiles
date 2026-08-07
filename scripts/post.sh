#!/usr/bin/env bash
# Ajustes que hay que hacer después de enlazar cada paquete.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

pkg="${1:?Uso: post.sh <paquete>}"

post_nvim() {
  have nvim || { warn "nvim no disponible, me salto la instalación de plugins"; return 0; }
  info "Instalando plugins según lazy-lock.json"
  # 'restore' respeta el lockfile; 'sync' actualizaría y rompería la reproducibilidad.
  nvim --headless "+Lazy! restore" +qa
  nvim --headless "+MasonUpdate" +qa 2>/dev/null || true
}

post_alacritty() {
  local theme="$HOME/.config/alacritty/theme.toml"

  if is_omarchy; then
    # theme.toml apunta al tema activo de Omarchy: permite el cambio en caliente.
    ln -sf "$HOME/.config/omarchy/current/theme/alacritty.toml" "$theme"
    info "theme.toml enlazado al tema de Omarchy"
  else
    [ -e "$theme" ] && return 0
    cp "$DOTFILES/alacritty/.config/alacritty/themes/default.toml" "$theme"
    info "theme.toml copiado desde themes/default.toml"
  fi
}

post_shell() {
  local line='[ -f ~/.config/shell/common.sh ] && . ~/.config/shell/common.sh'
  local rc

  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    if grep -qF 'shell/common.sh' "$rc"; then
      info "$(basename "$rc") ya carga common.sh"
      continue
    fi
    # No versionamos .bashrc (lo gestiona Omarchy): solo le añadimos el enganche.
    printf '\n# dotfiles\n%s\n' "$line" >> "$rc"
    info "Enganche añadido a $(basename "$rc")"
  done
}

post_starship() { :; }
post_git()      { :; }

case "$pkg" in
  nvim|alacritty|starship|git|shell) "post_$pkg" ;;
  *) die "Paquete desconocido: $pkg" ;;
esac
