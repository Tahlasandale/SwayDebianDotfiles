# Inventaire Système & Guide de Réinstallation (Debian 13 « bison »)

Ce document répertorie l'ensemble des composants, outils, dépendances et services nécessaires pour reproduire fidèlement l'environnement de travail et de ricing **SwayDebianDotfiles** sur une nouvelle machine.

---

## 1. Guide de Réinstallation Rapide

### Étape 1 : Récupérer le dépôt bare dotfiles
```bash
git clone --bare https://github.com/Tahlasandale/SwayDebianDotfiles.git $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles checkout -f main
```

### Étape 2 : Installer les paquets APT
```bash
sudo apt update
sudo apt install -y $(cat ~/.config/system-sources/packages-apt.txt)
```

### Étape 3 : Installer les applications Flatpak & Snap
```bash
# Flatpak (Flathub)
flatpak install -y flathub io.github.alessandrojean.Blanket com.localsend.localsend_app

# Snap
sudo snap install tmnationsforever
```

### Étape 4 : Activer le thème GRUB & Emptty
```bash
# Thème GRUB Astronaut (Catppuccin Mocha)
grub-theme-install.sh

# Greeter TUI Emptty sur tty1
sudo install -m 644 ~/.config/emptty-sources/conf /etc/emptty/conf
sudo install -m 644 ~/.config/emptty-sources/conf /etc/emptty/conf-tty1
sudo install -m 744 ~/.config/emptty-sources/motd-gen.sh /etc/emptty/motd-gen.sh
sudo install -m 644 ~/.config/emptty-sources/motd-art.txt /etc/emptty/motd-art.txt
sudo systemctl enable emptty@tty1.service
```

### Étape 5 : Activer les services utilisateur
```bash
systemctl --user daemon-reload
systemctl --user enable --now sway-wallpaper.timer battery-alert.timer syncthing.service monoxide.service
```

### Étape 6 : Restaurer l'état TrackMania
```bash
tm-restore.sh
```

---

## 2. Inventaire des Logiciels par Gestionnaire

### APT (Paquets système manuels)
- **Fichier de référence** : [`~/.config/system-sources/packages-apt.txt`](file:///home/bison/.config/system-sources/packages-apt.txt) (268 paquets).
- **Composants clés** :
  - *Environnement graphique* : `sway`, `waybar`, `mako-notifier`, `foot`, `nwg-displays`, `pavucontrol`, `blueman`, `grim`, `scrot`.
  - *Utilitaires CLI & TUI* : `bat`, `btop`, `eza`, `fastfetch`, `fzf`, `micro`, `neomutt`, `tmux`, `figlet`, `lolcat`, `cmatrix`.
  - *Système & Conteneurs* : `docker.io`, `docker-compose`, `tlp`, `tailscale`, `tor`, `emptty`, `grub-pc`.
  - *Compilateurs & Build* : `build-essential`, `cmake`, `meson`, `ninja-build`, `pkg-config`, `golang-go`.

### Flatpak
| Application | Application ID | Rôle |
|---|---|---|
| **Blanket** | `io.github.alessandrojean.Blanket` | Générateur de bruits d'ambiance et concentration |
| **LocalSend** | `com.localsend.localsend_app` | Partage local de fichiers chiffré pair-à-pair |

### Snap
| Application | Rôle | Commande de lancement |
|---|---|---|
| **TrackMania Nations Forever** | Jeu de course arcade sous Wine | `tmnationsforever` (via script wrapper Wayland) |

### Applications Autonomes (`/opt` et `~`)
- **Obsidian** (`/opt/Obsidian`) : Prise de notes Markdown & base de connaissances personnelle.
- **MEGAsync** (`/opt/megasync`) : Client de synchronisation cloud MEGA.
- **Writer.Deck** (`~/Writer.Deck_0.1.0_amd64.AppImage`) : Application d'écriture déconnectée.
- **VS Code** (`/usr/bin/code`) : Éditeur principal avec intégrations LSP.
- **Opencode** (`~/.opencode/bin/opencode`) : Outil CLI d'assistance IA.
- **Antigravity CLI** (`~/.local/bin/agy`) : Agent d'ingénierie logicielle autonome.
- **llmfit** (`/usr/local/bin/llmfit`) : Calculateur d'empreinte mémoire pour modèles IA.

---

## 3. Runtimes de Développement

| Runtime / SDK | Version | Emplacement / Méthode |
|---|---|---|
| **Rust** | Stable 1.8x+ | Géré par `rustup` (`~/.cargo/bin`) |
| **Go** | 1.24 | `/usr/lib/go-1.24/bin/go` (symlink `~/.local/bin/go`) |
| **Node.js** | v24.21.0 | `~/.local/share/node-v24.21.0-linux-x64` (`node`, `npm`, `npx`) |
| **Python** | 3.13.5 | Standard Debian (`/usr/bin/python3`) |
| **Flutter SDK** | Stable | `~/dev/flutter` |
| **OpenJDK** | 17 LTS | `~/dev/jdk17` |
| **Docker** | 26.1 / Moby | Démon système `docker.socket` |

---

## 4. Services systemd

### Services Utilisateur (`systemctl --user`)
- `sway-wallpaper.timer` : Rotation automatique des fonds d'écran Sway (toutes les 5 min).
- `battery-alert.timer` : Alertes batterie seuils 20% / 75%.
- `monoxide.service` : Bridge local ProtonMail (IMAP/SMTP/CalDAV).
- `syncthing.service` : Synchronisation des notes Obsidian.
- `pipewire.service`, `pipewire-pulse.service`, `wireplumber.service` : Serveur multimédia Wayland.
- `mako.service`, `waybar.service`, `foot-server.service` : Écosystème bureau Sway.

### Services Système (`systemctl`)
- `emptty@tty1.service` : Greeter TUI sur le tty1 (lancement Sway/Wayland).
- `tlp.service` : Économie d'énergie pour PC portable.
- `tailscaled.service` : VPN Mesh Tailscale.
- `docker.socket` : Démon de conteneurs Docker.
- `NetworkManager.service`, `bluetooth.service` : Connectivité réseau et sans fil.

---

## 5. Sauvegarde & Restauration TrackMania

Les profils, médailles solo, temps officiels, scores de campagne et circuits téléchargés/créés sont sauvegardés directement dans le dépôt dotfiles ([`~/.config/trackmania-sources/`](file:///home/bison/.config/trackmania-sources/)).

- **Mettre à jour la sauvegarde** :
  ```bash
  tm-backup.sh
  dotfiles-commit.sh "tm: mise a jour de la sauvegarde de jeu"
  ```
- **Restaurer sur une nouvelle machine** :
  ```bash
  tm-restore.sh
  ```
