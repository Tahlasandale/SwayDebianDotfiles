#!/bin/bash
# Win+O : fzf sur les dossiers de $HOME (cdd), puis opencode dans le dossier choisi.
# Échap ou liste vide dans fzf -> rien ne se lance, le terminal se ferme.
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
shopt -s expand_aliases
source ~/.bash_aliases
cd_to_dir && exec opencode
