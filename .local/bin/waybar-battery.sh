#!/bin/sh
# waybar-battery.sh — Module de batterie intelligent avec bascule Pourcentage <-> Temps restant

python3 -c "
import os, glob, json

uid = os.getuid()
mode_file = f'/run/user/{uid}/waybar-battery-mode'
mode = 'percent'
if os.path.exists(mode_file):
    try:
        with open(mode_file) as f:
            mode = f.read().strip()
    except Exception:
        pass

bats = glob.glob('/sys/class/power_supply/BAT*')
if not bats:
    print(json.dumps({'text': 'N/A', 'tooltip': 'Aucune batterie détectée', 'class': 'unknown'}))
    exit(0)

bat = bats[0]
def read_val(name, default='0'):
    p = os.path.join(bat, name)
    if os.path.exists(p):
        try:
            with open(p) as f:
                return f.read().strip()
        except Exception:
            pass
    return default

status = read_val('status', 'Unknown')
capacity = int(read_val('capacity', '0'))
charge_now = int(read_val('charge_now', read_val('energy_now', '0')))
charge_full = int(read_val('charge_full', read_val('energy_full', '0')))
charge_full_design = int(read_val('charge_full_design', read_val('energy_full_design', '0')))
current_now = int(read_val('current_now', read_val('power_now', '0')))
voltage_now = int(read_val('voltage_now', '0'))
cycles = read_val('cycle_count', 'N/A')

# Calcul de la puissance en Watts
power_w = 0.0
if current_now > 0 and voltage_now > 0:
    power_w = round((current_now * voltage_now) / 1e12, 1)

# Santé de la batterie
health = 100.0
if charge_full_design > 0:
    health = round((charge_full / charge_full_design) * 100, 1)

# Icônes de jauge
icons = ['', '', '', '', '']
icon_idx = min(4, max(0, capacity // 20))
base_icon = icons[icon_idx]

# Calcul de la durée restante
time_str = ''
tooltip_time = ''
if status == 'Discharging':
    icon = base_icon
    if current_now > 0:
        h = charge_now / current_now
        hours = int(h)
        mins = int((h - hours) * 60)
        time_str = f'{hours}h{mins:02d}m'
        tooltip_time = f'Restant : {hours} h {mins:02d} min'
    else:
        time_str = f'{capacity}%'
        tooltip_time = 'Décharge (calcul en cours...)'
elif status == 'Charging':
    icon = f'{base_icon} '
    if current_now > 0:
        h = max(0, charge_full - charge_now) / current_now
        hours = int(h)
        mins = int((h - hours) * 60)
        time_str = f'Charge: {hours}h{mins:02d}m' if hours > 0 else f'Charge: {mins}m'
        tooltip_time = f'Plein dans : {hours} h {mins:02d} min'
    else:
        time_str = 'En charge'
        tooltip_time = 'En charge...'
elif status in ('Full', 'Plugged') or capacity >= 99:
    icon = f'{base_icon} '
    time_str = 'Plein'
    tooltip_time = 'Batterie pleine (sur secteur)'
else:
    icon = f'{base_icon} '
    time_str = 'Secteur'
    tooltip_time = f'Sur secteur ({status})'

# Sélection du texte selon le mode actif
if mode == 'time':
    display_text = f'{time_str} {icon}'
else:
    display_text = f'{capacity}% {icon}'

# Classes CSS
classes = []
if status == 'Charging':
    classes.append('charging')
elif status in ('Full', 'Plugged'):
    classes.append('plugged')
elif status == 'Discharging':
    classes.append('discharging')

if capacity <= 15 and status != 'Charging':
    classes.append('critical')
elif capacity <= 30 and status != 'Charging':
    classes.append('warning')

tooltip = f'{tooltip_time} ({capacity}%)\n• Santé : {health}%\n• Cycles : {cycles}\n• Puissance : {power_w} W\n• Clic : Basculer Pourcentage / Durée'

print(json.dumps({
    'text': display_text,
    'tooltip': tooltip,
    'class': ' '.join(classes),
    'alt': mode
}))
"
