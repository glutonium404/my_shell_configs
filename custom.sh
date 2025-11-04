alias bat="batcat --paging=never --color=always --style=numbers --line-range=:500"
alias fzf='fzf --preview ""'
alias cls='clear && ls;'
alias clcd='clear && cd'
alias dir='dir --color=always'
alias run='g++ $(fzf) && ./a.out && rm a.out'

source "$HOME/.shell_custom_config/custom_func.sh"
source "$HOME/.shell_custom_config/custom_key_bind.sh"
