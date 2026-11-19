#!/bin/sh
# cliphist-tofi.sh — Menu historique du presse-papier Catppuccin Mocha via tofi
# Déclenche la recherche floue, copie l'élément sélectionné et le colle automatiquement.

# Déterminer la fenêtre active AVANT que tofi ne prenne le focus
focused_app=$(python3 -c "
import json, subprocess
try:
    tree = json.loads(subprocess.check_output(['swaymsg', '-t', 'get_tree']))
    def find_focused(node):
        if node.get('focused'):
            return (node.get('app_id') or (node.get('window_properties') or {}).get('class') or '').lower()
        for c in node.get('nodes', []) + node.get('floating_nodes', []):
            res = find_focused(c)
            if res is not None:
                return res
        return ''
    print(find_focused(tree))
except Exception:
    print('')
" 2>/dev/null || true)

# Affichage du menu tofi
selection=$(cliphist list | tofi \
    --config "$HOME/.config/tofi/config" \
    --prompt-text "📋 Presse-papier: " \
    --drun-launch=false \
    --width 50% \
    --height 45% \
    --corner-radius 12)

[ -z "$selection" ] && exit 0

# Décode et place le contenu dans le presse-papier Wayland
printf "%s" "$selection" | cliphist decode | wl-copy

# Petite pause pour laisser Sway redonner le focus à l'application précédente
sleep 0.15

# Simulation du collage selon le type d'application (Terminal vs GUI)
case "$focused_app" in
    *foot*|*terminal*|*alacritty*|*kitty*|*xterm*)
        wtype -M ctrl -M shift -k v 2>/dev/null || true
        ;;
    *)
        wtype -M ctrl -k v 2>/dev/null || true
        ;;
esac
