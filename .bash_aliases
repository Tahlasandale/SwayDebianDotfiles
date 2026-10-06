# ~/.bash_aliases — sourced by ~/.bashrc

# eza (remplace ls) avec icones Nerd Font + couleurs Catppuccin Mocha
alias ls='eza --icons=auto --group-directories-first'
alias l='eza -1 --icons=auto --group-directories-first'
alias ll='eza -lh --icons=auto --group-directories-first --git'
alias la='eza -lah --icons=auto --group-directories-first --git'
alias lt='eza --tree --level=2 --icons=auto --group-directories-first'

# bat (remplace cat) avec theme Catppuccin Mocha
alias cat='bat --paging=never'

# clear = effacer + resume systeme
alias clear='clear && minifetch'

# --- Navigation clavier : fd + fzf + cd ---
# cdd = ouvre fzf sur les dossiers de $HOME, puis cd sur celui choisi.
# (fd = binaire local ~/.local/bin/fd ; sur une machine neuve, le reinstaller)
cd_to_dir() {
    local selected_dir
    selected_dir=$(fd --type d --absolute-path --max-depth 5 \
                        --exclude node_modules --exclude target \
                        . "$HOME" \
                  | fzf --height 50% --reverse \
                        --preview 'eza --tree --level=2 --color=always --icons=auto --group-directories-first {}')
    # Echap ou liste vide -> on ne bouge pas
    [ -n "$selected_dir" ] && cd "$selected_dir"
}
alias cdd='cd_to_dir'
