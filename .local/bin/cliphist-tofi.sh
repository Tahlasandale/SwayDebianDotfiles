#!/bin/sh
# cliphist-tofi.sh — Menu historique du presse-papier Catppuccin Mocha via tofi
# Déclenche la recherche floue, copie l'élément sélectionné et le colle automatiquement.

export PATH="$HOME/.local/bin:$PATH"

# 1. Identifier précisément le conteneur et l'application active AVANT l'ouverture de tofi (ultra-rapide en C)
target_info=$(sway-focused-info 2>/dev/null || true)
target_id=$(printf "%s" "$target_info" | cut -d'|' -f1)
target_app=$(printf "%s" "$target_info" | cut -d'|' -f2)

# 2. Affichage du menu tofi
selection=$(cliphist list | tofi \
    --config "$HOME/.config/tofi/config" \
    --prompt-text "📋 Presse-papier: " \
    --drun-launch=false \
    --width 50% \
    --height 45% \
    --corner-radius 12)

[ -z "$selection" ] && exit 0

# 3. Décode et place le contenu dans le presse-papier (-t text/plain évite 700ms de recherche xdg-mime)
case "$selection" in
    *"binary data"*)
        printf "%s" "$selection" | cliphist decode | wl-copy
        ;;
    *)
        printf "%s" "$selection" | cliphist decode | wl-copy -t text/plain
        ;;
esac

# 4. Refocaliser immédiatement la fenêtre active
if [ -n "$target_id" ]; then
    swaymsg "[con_id=$target_id] focus" >/dev/null 2>&1
fi

# Pause minimale pour synchronisation Wayland
sleep 0.02

# 5. Simulation du collage automatique ultra-rapide
case "$target_app" in
    *foot*|*terminal*|*alacritty*|*kitty*|*xterm*|*urxvt*)
        wtype -M ctrl -M shift -k v -m shift -m ctrl 2>/dev/null || true
        ;;
    *)
        wtype -M ctrl -k v -m ctrl 2>/dev/null || true
        ;;
esac
