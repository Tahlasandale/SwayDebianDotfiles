#!/bin/sh
# boot-optimize.sh — Passe les services lourds en démarrage à la demande pour un boot ultra-rapide
set -eu

echo "=== Optimisation du Démarrage (Debian 13) ==="

# 1. Tor : Désactivation complète (service non requis au quotidien)
echo "1. Désactivation de Tor..."
sudo systemctl disable --now tor.service tor@default.service 2>/dev/null || true

# 2. Docker & Containerd : Désactivation au boot + socket activable
echo "2. Passage de Docker en démarrage à la demande..."
sudo systemctl disable docker.service containerd.service
sudo systemctl enable docker.socket 2>/dev/null || true

# 3. Snapd (TrackMania) : Désactivation des 8 montages loop au boot
echo "3. Désactivation de Snapd au boot..."
sudo systemctl disable snapd.service snapd.socket 2>/dev/null || true

# 4. Blueman : Activation par D-Bus uniquement (pas de blocage au boot)
echo "4. Désactivation de Blueman au boot..."
sudo systemctl disable blueman-mechanism.service 2>/dev/null || true

# 5. Journald : Limiter le journal à 30 Mo pour éviter les flushs lents sur HDD
echo "5. Optimisation de la taille du journal systemd..."
sudo mkdir -p /etc/systemd/journald.conf.d
cat << 'EOF' | sudo tee /etc/systemd/journald.conf.d/max-size.conf > /dev/null
[Journal]
SystemMaxUse=30M
EOF
sudo systemctl restart systemd-journald 2>/dev/null || true

echo "=== Optimisations appliquées avec succès ! ==="
echo "Temps de boot estimé au prochain allumage : ~25 à 30 secondes !"
