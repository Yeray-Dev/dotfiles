# dotfiles

Configuración de mi entorno de desarrollo, versionada para poder reconstruirla en
cualquier máquina con un comando. Cubre tres sistemas que uso a diario: Arch
(Omarchy), macOS y Debian.

El repo está pensado para ser idempotente: ejecutarlo dos veces no rompe nada, y
apartará cualquier configuración previa antes de tocarla.

## Contenido

| Paquete     | Destino                    | Qué incluye                                              |
|-------------|----------------------------|----------------------------------------------------------|
| `nvim`      | `~/.config/nvim`           | LazyVim, lockfile de plugins, resaltado propio            |
| `alacritty` | `~/.config/alacritty`      | Terminal, con tema y tamaño de fuente desacoplados        |
| `starship`  | `~/.config/starship.toml`  | Prompt, idéntico en bash y zsh                            |
| `git`       | `~/.config/git/config`     | Alias, `pull.rebase`, `rerere`, autoría explícita         |
| `shell`     | `~/.config/shell`          | Alias y funciones comunes a bash y zsh                    |

Fuera de stow, por no ser configuración enlazable:

- `karabiner/` — regla de Karabiner-Elements que mapea Caps Lock a Escape solo
  dentro de Alacritty. macOS únicamente; Karabiner reescribe su propio
  `karabiner.json`, así que la regla se importa en vez de enlazarse.
- `scripts/` — la lógica de instalación.

## Instalación

En una máquina nueva:

```sh
curl -fsSL https://raw.githubusercontent.com/Yeray-Dev/dotfiles/main/install.sh | bash
```

`install.sh` hace lo mínimo imprescindible: consigue `git` y `make` según el
sistema, clona el repo en `~/dotfiles` y delega en el Makefile. En macOS instala
antes las Command Line Tools y Homebrew si faltan.

Si prefieres ver qué va a pasar antes de ejecutarlo:

```sh
git clone https://github.com/Yeray-Dev/dotfiles.git ~/dotfiles
cd ~/dotfiles
make            # ayuda
make -n all     # simula la instalación completa sin tocar nada
make all
```

## Uso

```
make all              Entorno completo (dependencias + SSH + todos los paquetes)
make deps             Solo dependencias del sistema
make ssh              Genera la clave SSH y autentica gh
make check            Diagnóstico: qué está enlazado y qué falta
make nvim             Un paquete suelto (también alacritty, starship, git, shell)
make unstow-nvim      Deshace un paquete
make backup-omarchy   Copia la configuración de hypr/waybar al repo
make karabiner        Importa la regla de Karabiner (solo macOS)
```

Cualquier target acepta `-n` para ver qué haría sin ejecutarlo.

Cada paquete pasa por tres fases: `deps.sh` instala lo que necesite,
`link.sh` aparta lo que hubiera y lo enlaza con stow, y `post.sh` aplica los
ajustes que no se resuelven con un symlink.

## Decisiones

Algunas cosas están hechas de una manera concreta por un motivo:

**GNU stow en vez de un script de enlaces propio.** Cada directorio de primer
nivel replica la estructura de `$HOME`, de forma que `stow nvim` enlaza
`nvim/.config/nvim` en `~/.config/nvim`. Desenlazar es simétrico y no requiere
mantener una lista de rutas.

**Backup antes de enlazar.** `link.sh` detecta si el destino ya es un enlace al
propio repo (en cuyo caso no hace nada) y, si no, aparta lo que haya a
`*.bak-<fecha>` antes de que stow falle. No se sobrescribe nada en silencio.

**`Lazy! restore` en lugar de `sync`.** La instalación de plugins de Neovim
respeta `lazy-lock.json`. Un `sync` actualizaría a la última versión de cada
plugin y haría que dos máquinas instaladas con una semana de diferencia no
tuvieran el mismo entorno.

**En Arch solo se instala lo ausente.** Actualizar paquetes sueltos con
`pacman -S` provoca actualizaciones parciales, que no están soportadas y pueden
dejar dependencias rotas. `deps.sh` comprueba primero con `pacman -Qq` y solo
instala lo que falta.

**Lo específico de cada máquina no se versiona.** El tamaño de fuente y las
decoraciones de ventana de Alacritty viven en un `local.toml` ignorado por Git,
que `post.sh` genera a partir de las plantillas de `locals/`. El tema va en un
`theme.toml` aparte: en Omarchy es un symlink al tema activo del sistema, lo que
permite el cambio en caliente; en el resto es una copia del fallback versionado.
La configuración de Neovim sigue el mismo esquema.

**`.bashrc` no se versiona.** Omarchy lo gestiona y no respeta XDG. `post.sh`
se limita a añadirle una línea que carga `~/.config/shell/common.sh`, y
comprueba antes que no esté ya.

**Autoría de los commits.** `user.useConfigOnly = true` hace que el commit falle
si no hay un email configurado, en vez de inventarse uno a partir del hostname.
El email es el `noreply` de GitHub.

**Secretos.** El repo es público. El `.gitignore` bloquea explícitamente
`gh/hosts.yml`, `.npmrc`, `.env` y cualquier fichero cuyo nombre contenga
`token` o `credential`. `make ssh` genera la clave en la máquina; aquí no hay
ninguna.

## Requisitos

`git`, `make`, `curl` y `stow`. El resto lo instala `make deps` según el gestor
de paquetes detectado (`pacman`, `apt-get` o `brew`).

Neovim 0.11 o superior. Los parsers de Treesitter se compilan en la máquina, así
que hace falta un compilador de C.

## Fuera del alcance

- La configuración de Hyprland y waybar solo se respalda (`make backup-omarchy`),
  no se instala: la uso únicamente en Omarchy y prefiero no reproducirla a ciegas
  en otro sistema.
- No hay gestión de secretos ni de claves. Lo que no se puede publicar, no está.
