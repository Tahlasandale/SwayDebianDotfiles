#!/bin/sh
# dotfiles-commit.sh ["message"] — commit "correct" du bare repo ~/.dotfiles :
# ajoute SEULEMENT la liste curee, refuse tout secret, commit + push.
# Usage : dotfiles-commit.sh "bordures sway 5px"
# Workflow : plan -> build -> test (utilisateur) -> commit auto si "valide".
# Aucun commit sans validation explicite.
set -u
GIT="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

$GIT add -f \
  ~/.config/sway/config ~/.config/sway/catppuccin-mocha ~/.config/sway/wrapper.sh \
  ~/.config/waybar/config ~/.config/waybar/style.css ~/.config/waybar/mocha.css \
  ~/.config/tofi/config \
  ~/.config/mako/config \
  ~/.config/swaylock/config \
  ~/.config/emptty-sources/conf ~/.config/emptty-sources/motd-art.txt ~/.config/emptty-sources/motd-gen.sh \
  ~/.config/grub-sources/theme.cfg ~/.config/grub-sources/themes \
  ~/.local/bin/grub-theme-install.sh \
  ~/.local/bin/swaylock-effects-build.sh \
  ~/README.md \
  ~/.local/bin/sway-move-to-ws.sh ~/.local/bin/cdd-opencode.sh \
  ~/.config/foot/foot.ini \
  ~/.config/fastfetch/config.jsonc ~/.config/fastfetch/minifetch.jsonc ~/.config/fastfetch/logo \
  ~/.config/eza/theme.yml \
  ~/.config/bat/config ~/.config/bat/themes \
  ~/.config/btop/btop.conf ~/.config/btop/themes \
  ~/.config/yazi/theme.toml ~/.config/yazi/flavors \
  ~/.config/micro/settings.json ~/.config/micro/bindings.json ~/.config/micro/colorschemes ~/.config/micro/plug \
  ~/.config/oh-my-posh/catppuccin.omp.json \
  ~/.config/alacritty/alacritty.toml ~/.config/alacritty/themes \
  ~/.config/systemd/user/sway-wallpaper.service ~/.config/systemd/user/sway-wallpaper.timer \
  ~/.config/systemd/user/timers.target.wants/sway-wallpaper.timer \
  ~/.config/systemd/user/battery-alert.service ~/.config/systemd/user/battery-alert.timer \
  ~/.config/systemd/user/timers.target.wants/battery-alert.timer \
  ~/.config/systemd/user/waybar.service ~/.config/systemd/user/mako.service ~/.config/systemd/user/foot-server.service ~/.config/systemd/user/foot-server.socket \
  ~/.bashrc ~/.bash_aliases ~/.tmux.conf ~/.profile \
  ~/.config/sway/outputs \
  ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini ~/.config/xsettingsd/xsettingsd.conf ~/.gtkrc-2.0 \
  ~/.config/systemd/user/monoxide.service ~/.config/systemd/user/monoxide.env.example \
  ~/.local/bin/tmnationsforever ~/.local/bin/tmnf ~/.local/bin/tm-backup.sh ~/.local/bin/tm-restore.sh \
  ~/.local/bin/waybar-syncthing.sh ~/.local/bin/waybar-megasync.sh \
  ~/.config/trackmania-sources \
  ~/INVENTORY.md ~/.config/system-sources/packages-apt.txt \
  ~/.local/bin/boot-info.sh ~/.local/bin/sway-next-wallpaper.sh \
  ~/.local/bin/sway-cycle-workspace.sh \
  ~/.local/bin/battery-alert.sh \
  ~/.local/bin/boot-optimize.sh ~/.local/bin/boot-restore-defaults.sh \
  ~/.local/bin/cursor-install.sh ~/.icons/default/index.theme \
  ~/.local/bin/toggle-key.py \
  ~/.gitconfig \
  ~/.local/bin/dotfiles-commit.sh

# Garde-fou secrets : abort si l'index contient un chemin sensible
if $GIT diff --cached --name-only | grep -Ei 'gh/hosts\.yml|kdeconnect|/\.opencode/|opencode\.json|\.pem$|token|secret|/\.dotfiles/' >/dev/null; then
    echo "ABORT : fichier sensible detecte dans l'index :" >&2
    $GIT diff --cached --name-only | grep -Ei 'gh/hosts\.yml|kdeconnect|/\.opencode/|opencode\.json|\.pem$|token|secret|/\.dotfiles/' >&2
    exit 1
fi

if [ -z "$($GIT status --porcelain)" ]; then
    echo "Rien a commiter."
    exit 0
fi

MSG="${1:-sync auto $(date '+%F %H:%M')}"
$GIT commit -m "$MSG" || exit 1
$GIT push || $GIT pull --rebase && $GIT push
