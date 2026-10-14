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
TARGETS=()

add_package() {
    local package="$1"
    local source="$2"
    local target="$3"

    if [ -e "$DOTFILES/$source" ]; then
        PACKAGES+=("$package")
        TARGETS+=("$target")
    fi
}

add_package bash \
    "bash/.bashrc" \
    "$HOME/.bashrc"

add_package niri \
    "niri/.config/niri" \
    "$HOME/.config/niri"

add_package alacritty \
    "alacritty/.config/alacritty" \
    "$HOME/.config/alacritty"

add_package dms \
    "dms/.config/DankMaterialShell" \
    "$HOME/.config/DankMaterialShell"

add_package wallpapers \
    "wallpapers/Images/Wallpapers" \
    "$HOME/Images/Wallpapers"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    echo "Aucun package valide trouvé."
    exit 1
fi

echo "Packages : ${PACKAGES[*]}"

# --------------------------------------------------
# Sauvegarde des configurations existantes
# --------------------------------------------------

backup() {
    local target="$1"

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        return 0
    fi

    # Ne pas sauvegarder un lien déjà géré par ce dépôt.
    if [ -L "$target" ]; then
        local resolved
        resolved="$(readlink -f "$target" || true)"

        case "$resolved" in
            "$DOTFILES"/*)
                echo "Lien déjà géré par ce dépôt : $target"
                return 0
                ;;
        esac
    fi

    local relative="${target#"$HOME"/}"
    local destination="$BACKUP_DIR/$relative"

    mkdir -p "$(dirname "$destination")"

    echo "Sauvegarde : $target"
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$destination"
}

for target in "${TARGETS[@]}"; do
    backup "$target"
done

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
    echo "Sauvegardes disponibles dans :"
    echo "$BACKUP_DIR"
fi
