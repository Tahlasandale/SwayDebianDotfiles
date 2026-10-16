# SwayDebianDotfiles

Rice du poste Debian 13 « bison » : **Sway** (Wayland) au quotidien, **KDE Plasma** en cohabitation, thème **Catppuccin Mocha** partout (rose/violet unique).

## Tools

| Outil | Rôle |
|---|---|
| Sway | Composant fenêtres Wayland (workspaces 1-5 persistants, cycle circulaire, gestures) |
| Waybar | Barre en overlay flottant (son, wifi, batterie, Verr Maj/Num, power) |
| mako | Notifications (thème officiel Catppuccin Mocha) |
| foot | Terminal |
| tofi | Launcher (compilé depuis source, palette mauve `#cba6f7`) |
| swaylock | Verrouillage écran — fork *jirutka/swaylock-effects* (horloge + date, ext-session-lock) |
| emptty | Greeter TUI sur tty1 (MOTD art bison dynamique, sessions Sway/Plasma) |
| micro | Éditeur (LSP, Catppuccin) |
| yazi | Explorateur de fichiers |
| fastfetch | Infos système (profil `minifetch` léger + alias `clear`) |
| **figlet** | Bannières ASCII |
| GRUB | Bootloader — thème *Astronaut* (base Catppuccin Mocha, JetBrains Mono, 1080p) |
| pactl / pavucontrol | Son (scroll natif inversé, mute, volume UI) |
| nmtui | Réseau (clic droit sur le wifi Waybar) |
| systemd (user) | Timers maison : alertes batterie, rotation de fond d'écran |

Scripts maison dans `~/.local/bin/` : `sway-cycle-workspaces.sh`, `sway-move-to-ws.sh`, `battery-alert.sh`, `boot-info.sh`, `sway-next-wallpaper.sh`, `swaylock-effects-build.sh`, `grub-theme-install.sh`, `tmnationsforever`, `tm-backup.sh`, `tm-restore.sh`, `boot-optimize.sh`, `boot-restore-defaults.sh`, `dotfiles-commit.sh`.

## Réinstallation & Inventaire

Pour réinstaller fidèlement ce setup sur une nouvelle machine Debian 13 (liste des paquets APT, Flatpak, Snaps, runtimes et services systemd), consulter le guide dédié :
👉 [INVENTORY.md](file:///home/bison/INVENTORY.md)

## Workflow

Dépôt git « bare » (`~/.dotfiles`) avec liste de fichiers **curée** — jamais de `-A`, garde-fou secrets intégré :

```sh
dotfiles                     # statut
dotfiles-commit.sh "message" # commit + push (après validation manuelle)
```