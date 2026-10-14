#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

# Installer GNU Stow si nécessaire
if ! command -v stow >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y stow
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y stow
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed stow
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y stow
    else
        echo "Erreur : installez GNU Stow manuellement."
        exit 1
    fi
fi

# Packages à installer
PACKAGES=(bash niri alacritty dms wallpapers)
INSTALLED=()

for package in "${PACKAGES[@]}"; do
    if [ -d "$DOTFILES/$package" ]; then
        INSTALLED+=("$package")
    else
        echo "Package absent, ignoré : $package"
    fi
done

if [ "${#INSTALLED[@]}" -eq 0 ]; then
    echo "Erreur : aucun package trouvé dans $DOTFILES"
    exit 1
fi

# Sauvegarder les configurations existantes
TARGETS=(
    "$HOME/.bashrc"
    "$HOME/.config/niri"
    "$HOME/.config/alacritty"
    "$HOME/.config/DankMaterialShell"
    "$HOME/Images/Fonds d'écran"
)

for target in "${TARGETS[@]}"; do
    # Ne traiter que les cibles appartenant aux packages installés
    case "$target" in
        "$HOME/.bashrc") package=bash ;;
        "$HOME/.config/niri") package=niri ;;
        "$HOME/.config/alacritty") package=alacritty ;;
        "$HOME/.config/DankMaterialShell") package=dms ;;
        "$HOME/Images/Fonds d'écran") package=wallpapers ;;
    esac

    [[ " ${INSTALLED[*]} " == *" $package "* ]] || continue

    if [ -L "$target" ] &&
       [[ "$(readlink -f "$target" 2>/dev/null || true)" == "$DOTFILES/"* ]]; then
        continue
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        destination="$BACKUP/${target#"$HOME/"}"
        mkdir -p "$(dirname "$destination")"
        mkdir -p "$BACKUP"
        mv "$target" "$destination"
        echo "Sauvegardé : $target -> $destination"
    fi
done

# Installer les packages
cd "$DOTFILES"
stow --target="$HOME" "${INSTALLED[@]}"

echo "Installation terminée."
