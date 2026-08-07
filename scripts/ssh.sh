#!/usr/bin/env bash
# Clave SSH para GitHub y autenticación de gh.
# Nada de esto se versiona: la clave privada no sale de ~/.ssh.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

key="$HOME/.ssh/id_ed25519"

# ssh-keygen pide passphrase y hay que pegar la clave en GitHub: sin TTY no tiene sentido.
if [ ! -t 0 ]; then
  warn "Sin terminal interactiva, me salto SSH. Ejecuta luego: make ssh"
  exit 0
fi

if ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q 'successfully authenticated'; then
  done_ "SSH con GitHub ya funciona"
else
  if [ -f "$key" ]; then
    info "Existe $key pero GitHub no la reconoce; puede que falte añadirla a tu cuenta"
  else
    info "Generando clave SSH (pon passphrase: sin ella, quien te coja el equipo tiene push)"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$(whoami)@$(uname -n)-$(date +%Y%m%d)" -f "$key"
  fi

  [ -n "${SSH_AUTH_SOCK:-}" ] || eval "$(ssh-agent -s)" >/dev/null
  if [ "$(detect_os)" = macos ]; then
    ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key"
  else
    ssh-add "$key" 2>/dev/null || true
  fi

  if have gh; then
    info "Subiendo la clave con gh"
    gh auth login --git-protocol ssh --hostname github.com --web || \
      warn "gh auth login no completó; añade la clave a mano"
  else
    echo
    info "Añade esta clave en https://github.com/settings/ssh/new"
    echo
    cat "$key.pub"
    echo
    read -r -p "Pulsa Enter cuando la hayas añadido "
  fi

  if ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 | grep -q 'successfully authenticated'; then
    done_ "SSH configurado"
  else
    warn "Sigue sin autenticar. Revisa la clave en GitHub."
  fi
fi

# gh usa su propio token, independiente de la clave SSH.
if have gh && ! gh auth status >/dev/null 2>&1; then
  info "gh no está autenticado; lanzando login"
  gh auth login --git-protocol ssh --hostname github.com --web || \
    warn "Puedes hacerlo luego con: gh auth login"
fi
