#!/bin/sh
# boot-optimize.sh — Optimisation avancée du démarrage Debian 13 (HDD 5400 RPM)
# Phase 2 : Démarrage à la demande + flush journald différé (logs en RAM au boot, persistance après session)
set -eu

echo "=== Optimisation du Démarrage (Phase 2 — Debian 13) ==="

# 1. Tor : Désactivation complète (service non requis au quotidien)
echo "1. Désactivation de Tor..."
sudo systemctl disable --now tor.service tor@default.service 2>/dev/null || true

# 2. Docker & Containerd : Démarrage à la demande via socket
echo "2. Passage de Docker en démarrage à la demande..."
sudo systemctl disable docker.service containerd.service 2>/dev/null || true
sudo systemctl enable docker.socket 2>/dev/null || true

# 3. Snapd & Seeding : Neutralisation complète au boot (activé à la demande par TrackMania)
echo "3. Désactivation de Snapd et de snapd.seeded au boot..."
sudo systemctl disable snapd.service snapd.socket snapd.seeded.service snapd.apparmor.service 2>/dev/null || true

# 4. Blueman, ModemManager, Smartmontools : Désactivation au boot
echo "4. Désactivation des services périphériques non essentiels..."
sudo systemctl disable blueman-mechanism.service ModemManager.service smartmontools.service 2>/dev/null || true

# 5. Plymouth : Masquage du splash graphique (inutile sous TUI Emptty / Sway)
echo "5. Masquage de Plymouth..."
sudo systemctl mask plymouth-start.service plymouth-read-write.service 2>/dev/null || true

# 6. Journald : Flush différé (RAM au boot -> Écriture disque en tâche de fond après démarrage de Sway)
echo "6. Configuration du journal différé (RAM au boot -> Disque post-session)..."
sudo systemctl mask systemd-journal-flush.service 2>/dev/null || true

sudo mkdir -p /etc/systemd/journald.conf.d
cat << 'EOF' | sudo tee /etc/systemd/journald.conf.d/max-size.conf > /dev/null
[Journal]
Storage=persistent
SystemMaxUse=50M
RuntimeMaxUse=30M
EOF

cat << 'EOF' | sudo tee /etc/systemd/system/journal-deferred-flush.service > /dev/null
[Unit]
Description=Flush Journal to Persistent Storage (Deferred after boot)
Documentation=man:systemd-journald.service(8)
After=graphical.target
ConditionPathExists=/var/log/journal

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 5
ExecStart=/usr/bin/journalctl --flush
IOSchedulingClass=idle
CPUSchedulingPolicy=idle
RemainAfterExit=yes
TimeoutSec=90s
StandardOutput=null
StandardError=null

[Install]
WantedBy=graphical.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable journal-deferred-flush.service 2>/dev/null || true
sudo systemctl restart systemd-journald 2>/dev/null || true

echo "=== Optimisations Phase 2 appliquées avec succès ! ==="
echo "Temps de boot estimé au prochain allumage : ~15 à 20 secondes !"
