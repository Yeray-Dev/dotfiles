alias dot='cd ~/dotfiles'
alias dotv='cd ~/dotfiles && nvim .'

# Prompt. Omarchy ya inicializa starship en su .bashrc; solo lo hacemos aquí si
# nadie lo ha hecho antes (starship exporta STARSHIP_SHELL al arrancar).
if command -v starship >/dev/null 2>&1 && [ -z "${STARSHIP_SHELL:-}" ]; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(starship init zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(starship init bash)"
  fi
fi
