#!/bin/sh
# boot-restore-defaults.sh — Rétablit tous les services au démarrage automatique par défaut
set -eu

echo "=== Rétablissement des services au boot par défaut ==="
sudo systemctl enable docker.service containerd.service 2>/dev/null || true
sudo systemctl enable snapd.service snapd.socket snapd.seeded.service snapd.apparmor.service 2>/dev/null || true
sudo systemctl enable blueman-mechanism.service ModemManager.service smartmontools.service 2>/dev/null || true
sudo systemctl unmask plymouth-start.service plymouth-read-write.service 2>/dev/null || true
sudo systemctl unmask systemd-journal-flush.service 2>/dev/null || true
sudo systemctl disable --now journal-deferred-flush.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/journal-deferred-flush.service
sudo rm -f /etc/systemd/journald.conf.d/max-size.conf
sudo systemctl daemon-reload
sudo systemctl restart systemd-journald 2>/dev/null || true

echo "Configuration par défaut rétablie."
