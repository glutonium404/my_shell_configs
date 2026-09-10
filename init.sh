alias bat="batcat --paging=never --color=always --style=numbers --line-range=:500"
alias fzf='fzf --preview ""'
alias cls='clear && ls;'
alias clcd='clear && cd'
alias dir='dir --color=always'

source "$HOME/.shell_custom_config/func.sh"
source "$HOME/.shell_custom_config/keybind.sh"
source "$HOME/.shell_custom_config/env.sh"

export EDITOR=nvim
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#eb7b00,fg+:#000000,spinner:#f5e0dc,hl:#eb7b00 \
  --color=fg:#cdd6f4,header:#a6c6ff,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,prompt:#cba6f7,hl+:#ffffff \
  --color=selected-bg:-1 \
  --border=rounded \
  --border-label-pos=2 \
  --margin=1 \
  --padding=1 \
  --layout=reverse \
  --height=80% \
  --prompt='  ' \
  --pointer=' ' \
  --marker=' ' \
  --separator='─' \
  --scrollbar='│' \
  --info=inline-right"
