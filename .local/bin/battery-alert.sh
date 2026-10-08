#!/bin/sh
# battery-alert.sh [--test] — notif mako :
#   decharge   -> alerte si cap <= 20 (critique <= 10)
#   sur secteur-> info si cap >= 75 (urgente >= 90)
# Timer : toutes les 5 min. Aucun cooldown, aucun fichier d'etat.
set -u
BAT=${BAT:-/sys/class/power_supply/BAT1}
LOW=20
HIGH=75

# --- etat secteur : /sys/class/power_supply/AC*/online ---
ONLINE=
for d in "$BAT"/../AC*/online; do
    [ -r "$d" ] && { ONLINE=$d; break; }
done

if [ "${1:-}" = "--test" ]; then
    cap=19; ac=0; st=Discharging
else
    [ -r "$BAT/capacity" ] || exit 0
    cap=$(cat "$BAT/capacity")
    st=$(cat "$BAT/status" 2>/dev/null)
    case $cap in ''|*[!0-9]*) exit 0 ;; esac
    if [ -n "$ONLINE" ]; then
        ac=$(cat "$ONLINE" 2>/dev/null) || ac=0
    else
        case $st in Charging|Full) ac=1 ;; *) ac=0 ;; esac
    fi
    [ "$ac" = "1" ] || ac=0
fi

# --- matrice : seuls les couples coherents notifient ---
if [ "$ac" = "0" ]; then              # debranche
    [ "$cap" -le "$LOW" ] || exit 0
    if [ "$cap" -le 10 ]; then
        title="Batterie critique"; urgency=2
        body="$cap% restant — arret imminent !"
    else
        title="Batterie basse"; urgency=1
        body="$cap% restant — branchez le chargeur."
    fi
elif [ "$cap" -ge "$HIGH" ]; then      # branche
    if [ "$cap" -ge 90 ]; then urgency=1; else urgency=0; fi
    title="Batterie haute"
    case $st in
        Full)          body="$cap% — charge complete, au-dessus de $HIGH%." ;;
        *Charging)     body="$cap% — en charge, au-dessus de $HIGH%." ;;
        *)             body="$cap% — charge bloquee par le systeme, au-dessus de $HIGH%." ;;
    esac
else
    exit 0                             # branché <=20% ou debranché >=75% : silence
fi

gdbus call --session --dest org.freedesktop.Notifications \
  --object-path /org/freedesktop/Notifications \
  --method org.freedesktop.Notifications.Notify \
  "battery-alert" 0 "" "$title" "$body" "[]" "{\"urgency\": <byte $urgency>}" 10000 \
  >/dev/null 2>&1 || exit 1