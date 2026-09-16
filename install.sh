#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

echo "Installation des dotfiles depuis : $DOTFILES"

# --------------------------------------------------
# Installation de GNU Stow si nécessaire
# --------------------------------------------------

if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow n'est pas installé."

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y stow
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed stow
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y stow
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y stow
    else
        echo "Impossible d'installer GNU Stow automatiquement."
        exit 1
    fi
fi

# --------------------------------------------------
# Détection des packages
# --------------------------------------------------

PACKAGES=()

[ -f "$DOTFILES/bash/.bashrc" ] && PACKAGES+=("bash")
[ -f "$DOTFILES/git/.gitconfig" ] && PACKAGES+=("git")
[ -f "$DOTFILES/tmux/.tmux.conf" ] && PACKAGES+=("tmux")
[ -d "$DOTFILES/niri/.config/niri" ] && PACKAGES+=("niri")

echo "Packages : ${PACKAGES[*]}"

# --------------------------------------------------
# Sauvegarde des configurations existantes
# --------------------------------------------------

backup() {
    local target="$1"

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"

        local relative="${target#$HOME/}"
        local destination="$BACKUP_DIR/$relative"

        mkdir -p "$(dirname "$destination")"

        echo "Sauvegarde : $target"
        mv "$target" "$destination"
    fi
}

backup "$HOME/.bashrc"
backup "$HOME/.gitconfig"
backup "$HOME/.tmux.conf"
backup "$HOME/.config/niri"

# --------------------------------------------------
# Installation avec GNU Stow
# --------------------------------------------------

cd "$DOTFILES"

echo
echo "Installation des dotfiles..."

stow --target="$HOME" "${PACKAGES[@]}"

echo
echo "Installation terminée."

if [ -d "$BACKUP_DIR" ]; then
    echo
    echo "Sauvegardes créées dans :"
    echo "$BACKUP_DIR"
fi
