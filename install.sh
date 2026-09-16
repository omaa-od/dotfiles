#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installation des dotfiles depuis $DOTFILES"

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

PACKAGES=()

[ -d "$DOTFILES/bash" ] && PACKAGES+=("bash")
[ -d "$DOTFILES/git" ] && PACKAGES+=("git")
[ -d "$DOTFILES/tmux" ] && PACKAGES+=("tmux")
[ -d "$DOTFILES/niri/.config/niri" ] && PACKAGES+=("niri")

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    echo "Aucun package à installer."
    exit 0
fi

cd "$DOTFILES"

echo "Packages : ${PACKAGES[*]}"

stow --target="$HOME" "${PACKAGES[@]}"

echo "Installation terminée."
