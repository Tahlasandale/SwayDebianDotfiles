#!/bin/sh
# cursor-install.sh — Télécharge et installe le thème de curseur Catppuccin Mocha Sky (Cyan)
set -eu

THEME="${1:-catppuccin-mocha-sky-cursors}"
URL="https://github.com/catppuccin/cursors/releases/download/v2.0.0/${THEME}.zip"
DEST="$HOME/.local/share/icons"

mkdir -p "$DEST" "$HOME/.icons"
echo "=== Installation du thème de curseur $THEME ==="
echo "Téléchargement depuis $URL..."
curl -sSL "$URL" -o "/tmp/${THEME}.zip"

echo "Extraction dans $DEST/..."
unzip -q -o "/tmp/${THEME}.zip" -d "$DEST/"
rm -f "/tmp/${THEME}.zip"

# Symlink dans ~/.icons pour compatibilité maximale avec les anciennes applications
ln -sfn "$DEST/$THEME" "$HOME/.icons/$THEME"

echo "=== Curseur $THEME installé avec succès ! ==="
