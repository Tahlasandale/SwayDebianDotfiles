#!/bin/sh
# boot-restore-defaults.sh — Rétablit les services au démarrage automatique par défaut
set -eu

echo "=== Rétablissement des services au boot par défaut ==="
sudo systemctl enable docker.service containerd.service
sudo systemctl enable snapd.service snapd.socket
sudo systemctl enable blueman-mechanism.service
sudo rm -f /etc/systemd/journald.conf.d/max-size.conf
sudo systemctl restart systemd-journald 2>/dev/null || true
echo "Configuration par défaut rétablie."
