# .sh
# shell/common.sh
# Configuración compartida entre bash y zsh.

# Solo en shells interactivas: evita ejecutar nada de esto en scripts,
# hooks de git o subshells lanzadas por make.
case $- in *i*) ;; *) return ;; esac

# ── Aliases ────────────────────────────────────────────────────────────────
alias dot='cd ~/dotfiles'
alias dotv='cd ~/dotfiles && nvim .'
alias dotup='git -C ~/dotfiles pull && make -C ~/dotfiles link'

# ── Prompt ─────────────────────────────────────────────────────────────────
# Omarchy ya inicializa starship en su .bashrc; solo lo hacemos aquí si
# nadie lo ha hecho antes (starship exporta STARSHIP_SHELL al arrancar).
if command -v starship >/dev/null 2>&1 && [ -z "${STARSHIP_SHELL:-}" ]; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(starship init zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(starship init bash)"
  fi
fi

# ── Sincronización de dotfiles ─────────────────────────────────────────────
# Actualiza el repo solo si es un fast-forward limpio; en cualquier otro
# caso avisa e indica el motivo. Nunca toca los symlinks por su cuenta.
dotfiles_check() {
  local repo="$HOME/dotfiles"
  [ -d "$repo/.git" ] || return

  # Fetch en segundo plano, como mucho una vez cada 6 horas.
  local stamp="$repo/.git/.last_fetch"
  local now last=0
  now=$(date +%s)
  [ -f "$stamp" ] && last=$(cat "$stamp")
  if [ $((now - last)) -gt 21600 ]; then
    ( ( GIT_TERMINAL_PROMPT=0 git -C "$repo" fetch --quiet 2>/dev/null \
        && echo "$now" > "$stamp" ) & )
  fi

  local behind ahead dirty
  behind=$(git -C "$repo" rev-list --count 'HEAD..@{u}' 2>/dev/null) || return
  [ -n "$behind" ] && [ "$behind" -gt 0 ] || return

  ahead=$(git -C "$repo" rev-list --count '@{u}..HEAD' 2>/dev/null)
  dirty=$(git -C "$repo" status --porcelain 2>/dev/null)

  if [ -n "$dirty" ]; then
    printf '\033[33mdotfiles: %s commit(s) nuevos, pero hay cambios sin commitear. Revisa: dot\033[0m\n' "$behind"
    return
  fi

  if [ "$ahead" -gt 0 ]; then
    printf '\033[33mdotfiles: %s commit(s) nuevos y %s local(es) sin subir. Resuelve a mano: dotup\033[0m\n' "$behind" "$ahead"
    return
  fi

  # Camino seguro: working tree limpio, sin commits locales, fast-forward.
  local old new changed
  old=$(git -C "$repo" rev-parse HEAD)

  if ! git -C "$repo" merge --ff-only --quiet '@{u}' 2>/dev/null; then
    printf '\033[33mdotfiles: %s commit(s) nuevos, fast-forward no posible. Revisa: dot\033[0m\n' "$behind"
    return
  fi

  new=$(git -C "$repo" rev-parse HEAD)
  printf '\033[32mdotfiles: actualizado (%s commit(s))\033[0m\n' "$behind"

  # Solo avisamos de rehacer symlinks si se han añadido o borrado ficheros.
  changed=$(git -C "$repo" diff --name-only --diff-filter=AD "$old" "$new")
  if [ -n "$changed" ]; then
    printf '\033[33mdotfiles: hay ficheros nuevos o borrados; ejecuta: make -C ~/dotfiles link\033[0m\n'
  fi
}

dotfiles_check
