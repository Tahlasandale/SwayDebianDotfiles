# ~/.bash_aliases — sourced by ~/.bashrc

# eza (remplace ls) avec icones Nerd Font + couleurs Catppuccin Mocha
alias ls='eza --icons=auto --group-directories-first'
alias l='eza -1 --icons=auto --group-directories-first'
alias ll='eza -lh --icons=auto --group-directories-first --git'
alias la='eza -lah --icons=auto --group-directories-first --git'
alias lt='eza --tree --level=2 --icons=auto --group-directories-first'

# bat (remplace cat) avec theme Catppuccin Mocha
alias cat='bat --paging=never'
