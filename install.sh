# --------------------------------------------------
# Détection des packages et création des répertoires
# --------------------------------------------------

PACKAGES=()
TARGETS=()

# Répertoire des images défini par l'utilisateur.
WALLPAPERS_HOME="$(xdg-user-dir PICTURES 2>/dev/null || true)"

if [ -z "$WALLPAPERS_HOME" ] || [ "$WALLPAPERS_HOME" = "$HOME" ]; then
    WALLPAPERS_HOME="$HOME/Images"
fi

add_package() {
    local package="$1"
    local source="$2"
    local target="$3"

    if [ -e "$DOTFILES/$source" ]; then
        PACKAGES+=("$package")
        TARGETS+=("$target")

        # Créer uniquement le répertoire parent de la cible.
        mkdir -p "$(dirname "$target")"
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
    "wallpapers/Images/Fonds d'écran" \
    "$WALLPAPERS_HOME/Fonds d'écran"

if [ "${#PACKAGES[@]}" -eq 0 ]; then
    echo "Aucun package valide trouvé."
    exit 1
fi

echo "Packages : ${PACKAGES[*]}"
echo "Répertoire des fonds d'écran : $WALLPAPERS_HOME/Fonds d'écran"
