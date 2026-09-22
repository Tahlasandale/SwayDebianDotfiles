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
  ~/.config/systemd/user/waybar.service ~/.config/systemd/user/mako.service ~/.config/systemd/user/foot-server.service ~/.config/systemd/user/foot-server.socket \
  ~/.bashrc ~/.bash_aliases ~/.tmux.conf ~/.profile \
  ~/.local/bin/boot-info.sh ~/.local/bin/sway-next-wallpaper.sh \
  ~/.local/bin/sway-cycle-workspace.sh \
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
