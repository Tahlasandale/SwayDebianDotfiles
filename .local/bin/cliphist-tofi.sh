#!/bin/sh
# cliphist-tofi.sh — Menu historique du presse-papier Catppuccin Mocha via tofi
# Déclenche la recherche floue, copie l'élément sélectionné et le colle automatiquement.

export PATH="$HOME/.local/bin:$PATH"

# 1. Identifier précisément le conteneur et l'application active AVANT l'ouverture de tofi
target_info=$(python3 -c "
import json, subprocess
try:
    tree = json.loads(subprocess.check_output(['swaymsg', '-t', 'get_tree']))
    def find_focused(n):
        if n.get('focused'):
            return n
        for c in n.get('nodes', []) + n.get('floating_nodes', []):
            r = find_focused(c)
            if r:
                return r
        return None
    node = find_focused(tree)
    if node:
        app = (node.get('app_id') or (node.get('window_properties') or {}).get('class') or '').lower()
        print(f'{node.get(\"id\")}|{app}')
except Exception:
    pass
" 2>/dev/null || true)

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

# 3. Décode et place le contenu dans le presse-papier ET la sélection primaire
decoded=$(printf "%s" "$selection" | cliphist decode)
printf "%s" "$decoded" | wl-copy
printf "%s" "$decoded" | wl-copy --primary

# 4. Refocaliser explicitement la fenêtre qui avait le focus avant tofi
if [ -n "$target_id" ]; then
    swaymsg "[con_id=$target_id] focus" >/dev/null 2>&1
fi

# Pause calibrée pour que le compositeur et le client valident le focus
sleep 0.12

# 5. Simulation du collage automatique avec modificateurs sécurisés
case "$target_app" in
    *foot*|*terminal*|*alacritty*|*kitty*|*xterm*|*urxvt*)
        wtype -M ctrl -M shift -s 25 -k v -s 25 -m shift -m ctrl 2>/dev/null || true
        ;;
    *)
        wtype -M ctrl -s 25 -k v -s 25 -m ctrl 2>/dev/null || true
        ;;
esac
