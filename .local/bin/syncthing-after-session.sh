#!/bin/sh
set -eu

is_sway_session() {
    case " ${XDG_CURRENT_DESKTOP:-} ${XDG_SESSION_DESKTOP:-} " in
        *sway*) return 0 ;;
    esac

    [ -n "${SWAYSOCK:-}" ] && return 0
    command -v pgrep >/dev/null 2>&1 && pgrep -x sway >/dev/null 2>&1
}

# Le service utilisateur peut demarrer avant la publication de l'environnement Sway.
# Donner a Sway quelques secondes pour apparaitre, sans bloquer les autres DE.
waited=0
while [ "$waited" -lt 15 ] && ! is_sway_session; do
    case " ${XDG_CURRENT_DESKTOP:-} " in
        KDE*|GNOME*|XFCE*|MATE*|Cinnamon*|LXQt*|Budgie*) break ;;
    esac
    sleep 1
    waited=$((waited + 1))
done

# Sous Sway, attendre la sortie graphique et la levee d'un eventuel verrouillage.
if is_sway_session; then
    while [ -z "${SWAYSOCK:-}" ] || ! swaymsg -t get_outputs >/dev/null 2>&1; do
        sleep 1
    done

    while pgrep -x swaylock >/dev/null 2>&1; do
        sleep 1
    done
fi

exec /home/bison/.local/bin/syncthing serve
