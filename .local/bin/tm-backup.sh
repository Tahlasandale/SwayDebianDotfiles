#!/bin/sh
# tm-backup.sh — Exporte l'état de TrackMania vers ~/.config/trackmania-sources/ pour le repo dotfiles
set -eu

SRC_DOC="$HOME/Documents/TmForever"
SRC_WINE="$HOME/snap/tmnationsforever/common/.wine/drive_c/ProgramData/TmForever"
DEST="$HOME/.config/trackmania-sources"

echo "=== Sauvegarde de TrackMania Nations Forever vers le repo dotfiles ==="
mkdir -p "$DEST/Documents" "$DEST/WineData"

if [ ! -d "$SRC_DOC" ]; then
    echo "Erreur : dossier $SRC_DOC introuvable." >&2
    exit 1
fi

# 1. Sauvegarde des profils, scores, configs et circuits (sans les skins multijoueur)
rsync -a --delete \
    --exclude "Skins" \
    --exclude "LogCrash" \
    --exclude "Cache" \
    "$SRC_DOC/" "$DEST/Documents/"

# 2. Sauvegarde des scores de campagne Wine
if [ -d "$SRC_WINE" ]; then
    rsync -a --delete \
        --exclude "Cache" \
        "$SRC_WINE/CampaignsScores" \
        "$SRC_WINE/LadderScores" \
        "$SRC_WINE/radial.cdb" \
        "$DEST/WineData/"
fi

echo "Sauvegarde TrackMania terminée avec succès !"
echo "Emplacement : $DEST"
echo "Taille totale : $(du -sh "$DEST" | cut -f1)"
