#!/bin/sh
# grub-theme-install.sh — Installe le thème GRUB Astronaut et configure /etc/default/grub.d
set -eu

THEME_NAME="${1:-astronaut}"
SRC_DIR="$HOME/.config/grub-sources"
THEME_SRC="$SRC_DIR/themes/$THEME_NAME"
CFG_SRC="$SRC_DIR/theme.cfg"

DEST_THEME_DIR="/boot/grub/themes/$THEME_NAME"
DEST_CFG="/etc/default/grub.d/99-astronaut-theme.cfg"

echo "=== Déploiement du thème GRUB : $THEME_NAME ==="

if [ ! -d "$THEME_SRC" ]; then
    echo "Erreur : le thème source n'existe pas : $THEME_SRC" >&2
    exit 1
fi

if [ ! -f "$CFG_SRC" ]; then
    echo "Erreur : le fichier de configuration n'existe pas : $CFG_SRC" >&2
    exit 1
fi

echo "1. Copie des fichiers du thème vers $DEST_THEME_DIR..."
sudo mkdir -p "$DEST_THEME_DIR"
sudo cp -r "$THEME_SRC"/* "$DEST_THEME_DIR/"

echo "2. Installation du fichier drop-in $DEST_CFG..."
sudo mkdir -p /etc/default/grub.d
sudo install -m 644 "$CFG_SRC" "$DEST_CFG"

echo "3. Génération de la configuration GRUB (update-grub)..."
sudo update-grub

echo "=== Thème GRUB '$THEME_NAME' installé et activé avec succès ! ==="
