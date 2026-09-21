#!/bin/sh
# Affiche "AAAA-MM-JJ HH:MM:SS (duree boot, duree session)".
# Boot : total systemd-analyze (firmware -> graphical.target).
# Session : user@UID.service -> demarrage du process Sway (login -> affichage).
export LC_ALL=C # sortie ASCII : decimales a point quelle que soit la locale
BOOT=$(uptime -s 2>/dev/null)
DUR=$(systemd-analyze 2>/dev/null | grep -oP '= \K.*' | head -n 1 | sed 's/ *$//')

SESS=""
LOGIN_MONO=$(systemctl show "user@$(id -u).service" -p ActiveEnterTimestampMonotonic 2>/dev/null | cut -d= -f2)
SPID=$(pidof sway 2>/dev/null | awk '{print $1}')
if [ -n "$LOGIN_MONO" ] && [ -n "$SPID" ] && [ -r "/proc/$SPID/stat" ]; then
    TICKS=$(awk '{print $22}' "/proc/$SPID/stat" 2>/dev/null)
    HZ=$(getconf CLK_TCK 2>/dev/null || echo 100)
    case "$TICKS" in
        ''|*[!0-9]*) ;;
        *) SESS=$(awk -v t="$TICKS" -v h="$HZ" -v l="$LOGIN_MONO" \
            'BEGIN{d=(t*1000000/h-l)/1000000; if(d>=0) printf "%.1fs", d}') ;;
    esac
fi

OUT="$BOOT"
EXTRA=""
[ -n "$DUR" ] && EXTRA="$DUR boot"
[ -n "$SESS" ] && EXTRA="${EXTRA:+$EXTRA, }$SESS session"
[ -n "$EXTRA" ] && OUT="$OUT ($EXTRA)"
printf '%s' "$OUT"
