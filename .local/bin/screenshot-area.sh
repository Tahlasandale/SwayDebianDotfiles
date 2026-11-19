#!/bin/sh
# screenshot-area.sh — Capture d'écran par sélection de zone (façon Win + Maj + S)
# Enregistre dans ~/Images/Screenshots, copie dans le presse-papier et notifie Mako.

export PATH="$HOME/.local/bin:$PATH"

TARGET_DIR="$HOME/Images/Screenshots"
mkdir -p "$TARGET_DIR"

FILENAME="$TARGET_DIR/Capture_$(date '+%Y-%m-%d_%H-%M-%S').png"

# Sélection interactive de zone Catppuccin Mocha via slurp
GEOMETRY=$(/home/bison/.local/bin/slurp -d -b 1e1e2e66 -c cba6f7 -s cba6f733 -w 2 2>/dev/null)

# Si l'utilisateur annule (Échap ou clic extérieur), quitter silencieusement
[ -z "$GEOMETRY" ] && exit 0

# Capture avec grim, enregistrement sur disque et copie directe dans le presse-papier Wayland
/usr/bin/grim -g "$GEOMETRY" - | tee "$FILENAME" | /home/bison/.local/bin/wl-copy --type image/png

# Notification de confirmation vers le démon Mako
python3 -c "
import dbus
try:
    bus = dbus.SessionBus()
    notify = bus.get_object('org.freedesktop.Notifications', '/org/freedesktop/Notifications')
    interface = dbus.Interface(notify, 'org.freedesktop.Notifications')
    interface.Notify('Screenshot', 0, 'image-x-generic', 'Capture d\'écran', 'Zone enregistrée et copiée dans le presse-papier !', [], {}, 2500)
except Exception:
    pass
" 2>/dev/null || true
