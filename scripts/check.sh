#!/usr/bin/env bash
# Diagnóstico: qué está enlazado, qué herramientas hay y qué falta.

set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

printf '\n\033[1mSistema\033[0m\n'
printf '  SO           %s\n' "$(detect_os)"
printf '  Omarchy      %s\n' "$(is_omarchy && echo sí || echo no)"
printf '  Repo         %s\n' "$DOTFILES"

printf '\n\033[1mHerramientas\033[0m\n'
for t in stow nvim alacritty starship git gh rg fd node mise; do
  if have "$t"; then
    printf '  \033[1;32m✓\033[0m %-12s %s\n' "$t" "$(command -v "$t")"
  else
    printf '  \033[1;31m✗\033[0m %-12s ausente\n' "$t"
  fi
done


printf '\n\033[1mEnlaces\033[0m\n'
for pkg in nvim alacritty starship git shell; do
  [ -d "$DOTFILES/$pkg" ] || continue
  while IFS= read -r rel; do
    dest="$HOME/$rel"
    if [ -L "$dest" ]; then
      printf '  \033[1;32m✓\033[0m %-28s -> %s\n' "~/$rel" "$(readlink "$dest")"
    elif [ -e "$dest" ]; then
      printf '  \033[1;33m!\033[0m %-28s existe pero NO es enlace\n' "~/$rel"
    else
      printf '  \033[1;31m✗\033[0m %-28s sin enlazar\n' "~/$rel"
    fi
  done < <(pkg_targets "$pkg")
done

printf '\n\033[1mGit\033[0m\n'
printf '  user.name    %s\n' "$(git config --global user.name || echo '(sin definir)')"
printf '  user.email   %s\n' "$(git config --global user.email || echo '(sin definir)')"
case "$(git config --global user.email || true)" in
  *users.noreply.github.com) ;;
  *) printf '  \033[1;33m!\033[0m El correo no es el noreply de GitHub\n' ;;
esac

backups="$(find "$HOME/.config" -maxdepth 1 -name '*.bak-*' 2>/dev/null | wc -l | tr -d ' ')"
[ "$backups" != 0 ] && printf '\n\033[1;33m!\033[0m Hay %s backup(s) en ~/.config pendientes de revisar\n' "$backups"

printf '\n'
