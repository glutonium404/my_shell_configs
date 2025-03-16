alias bat="batcat --paging=never --color=always --style=numbers --line-range=:500"
alias fzf='fzf --preview "batcat --paging=never --color=always --style=numbers --line-range=:500 $HOME/{}"'
alias cls='clear && ls;'
alias clcd='clear && cd'
alias dir='dir --color=always'

source "$HOME/.shell_custom_config/custom_func.sh"
source "$HOME/.shell_custom_config/custom_key_bind.sh"
