#!/usr/bin/env bash
# Instala las dependencias de un paquete concreto, o de todos con 'all'.
#
#   deps.sh nvim
#   deps.sh all

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

OS="$(detect_os)"
NVIM_MIN="0.11.0"

# ---------------------------------------------------------------- instaladores


pm_install() {
  [ $# -eq 0 ] && return 0
  local missing=() p

  case "$OS" in
    arch)
      # Instalar solo lo ausente. Actualizar paquetes sueltos en Arch provoca
      # actualizaciones parciales, que no están soportadas y rompen dependencias.
      for p in "$@"; do
        pacman -Qq "$p" >/dev/null 2>&1 || missing+=("$p")
      done
      [ ${#missing[@]} -eq 0 ] && return 0
      sudo pacman -S --needed --noconfirm "${missing[@]}"
      ;;
    debian)
      for p in "$@"; do
        dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p")
      done
      [ ${#missing[@]} -eq 0 ] && return 0
      sudo apt-get install -y "${missing[@]}"
      ;;
    macos)
      for p in "$@"; do
        brew list --formula "$p" >/dev/null 2>&1 || missing+=("$p")
      done
      [ ${#missing[@]} -eq 0 ] && return 0
      brew install "${missing[@]}"
      ;;
    *)
      warn "Instala a mano: $*"
      ;;
  esac
}

ensure_brew() {
  [ "$OS" = macos ] || return 0
  have brew && return 0
  info "Instalando Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon instala en /opt/homebrew, que no está en el PATH por defecto.
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
}

apt_refreshed=0
apt_update_once() {
  [ "$OS" = debian ] || return 0
  [ "$apt_refreshed" -eq 1 ] && return 0
  sudo apt-get update
  apt_refreshed=1
}

# Neovim de los repos de Debian suele ir muy por detrás: binario oficial como plan B.
install_nvim_tarball() {
  local arch asset tmp
  case "$(uname -m)" in
    x86_64|amd64)  arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) die "Sin binario oficial para $(uname -m)" ;;
  esac
  asset="nvim-linux-${arch}.tar.gz"

  info "Descargando Neovim estable ($asset)"
  tmp="$(mktemp -d)"
  curl -fsSL -o "$tmp/$asset" \
    "https://github.com/neovim/neovim/releases/latest/download/$asset" \
    || die "No se pudo descargar $asset"

  rm -rf "$HOME/.local/nvim"
  mkdir -p "$HOME/.local/nvim" "$HOME/.local/bin"
  tar -xzf "$tmp/$asset" -C "$HOME/.local/nvim" --strip-components=1
  ln -sf "$HOME/.local/nvim/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmp"

  export PATH="$HOME/.local/bin:$PATH"
  warn "Neovim en ~/.local/bin — asegúrate de tener ese directorio en el PATH"
}

install_nerd_font() {
  case "$OS" in
    arch)  pm_install ttf-jetbrains-mono-nerd ;;
    macos) brew install --cask font-jetbrains-mono-nerd-font ;;
    debian)
      local dir="$HOME/.local/share/fonts"
      [ -f "$dir/JetBrainsMonoNerdFont-Regular.ttf" ] && return 0
      info "Descargando JetBrainsMono Nerd Font"
      mkdir -p "$dir"
      curl -fsSL -o /tmp/jbmono.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
      unzip -oq /tmp/jbmono.zip -d "$dir"
      rm -f /tmp/jbmono.zip
      fc-cache -f >/dev/null
      ;;
  esac
}

# ------------------------------------------------------------------- por paquete

deps_base() {
  ensure_brew
  apt_update_once
  case "$OS" in
    arch)   pm_install git curl unzip tar stow ;;
    debian) pm_install git curl unzip tar stow ;;
    macos)  pm_install git curl stow ;;
  esac
}

deps_nvim() {
  case "$OS" in
    arch)   pm_install neovim ripgrep fd base-devel wl-clipboard python-pynvim ;;
    debian) pm_install ripgrep fd-find build-essential xclip python3-venv
            pm_install neovim || true ;;
    macos)  pm_install neovim ripgrep fd ;;
  esac

  # Node solo si no hay ya uno (mise, nvm, fnm...): no pisamos tu gestor de versiones.
  have node || pm_install nodejs npm
  # En Debian el binario se llama fdfind; Telescope y snacks buscan 'fd'.
  if [ "$OS" = debian ] && have fdfind && ! have fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  if ! have nvim || ! version_ge "$(nvim --version | head -1 | sed 's/^NVIM v//; s/-.*//')" "$NVIM_MIN"; then
    warn "Neovim ausente o anterior a $NVIM_MIN"
    [ "$OS" = macos ] && die "Revisa tu Homebrew: brew upgrade neovim"
    install_nvim_tarball
  fi
}

deps_alacritty() {
  case "$OS" in
    arch)   pm_install alacritty ;;
    debian) pm_install alacritty ;;
    macos)  brew install --cask alacritty ;;
  esac
  install_nerd_font
}

deps_starship() {
  if have starship; then return 0; fi
  case "$OS" in
    arch|macos) pm_install starship ;;
    debian)
      # No está en los repos de Debian estable.
      info "Instalando starship desde su instalador oficial"
      curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
      ;;
  esac
}

deps_git() {
  pm_install git
  have gh || case "$OS" in
    arch)   pm_install github-cli ;;
    debian) pm_install gh || warn "gh no disponible en apt; instálalo desde cli.github.com" ;;
    macos)  pm_install gh ;;
  esac
}

deps_shell() { :; }   # el shell ya existe en cualquier sistema

# ------------------------------------------------------------------------- main

target="${1:-all}"

deps_base

case "$target" in
  all)
    for p in nvim alacritty starship git shell; do "deps_$p"; done
    ;;
  nvim|alacritty|starship|git|shell)
    "deps_$target"
    ;;
  *)
    die "Paquete desconocido: $target"
    ;;
esac

done_ "Dependencias listas ($target, $OS)"
