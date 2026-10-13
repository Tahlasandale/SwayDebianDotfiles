#!/bin/sh
# Deplace la fenetre active vers le bureau $1 et bascule la vue dessus.
# Les deux swaymsg sont sequentiels et bloquants : le second ne part
# qu'une fois que sway a confirme le deplacement (pas de race condition).
swaymsg "move container to workspace number $1" >/dev/null
swaymsg "workspace number $1" >/dev/null