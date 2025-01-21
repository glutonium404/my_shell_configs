##################################################
##########     custom key binding   ##############
##################################################

# delete whole line when ctrl + backspace is pressed
bind '"\C-H": kill-whole-line'

# bind -x '"\C-f":"cd $(find ~/ -type d | fzf) && pwd"' # lets u move to any dir using fuzzy finder. hit ctrl + f then select your dir

# lets u move to any dir using fuzzy finder. hit ctrl + f then select your dir
bind -x '"\C-f":"cf"'

# moving between the command history using j and k to keep things related to vim key binding
bind '"\C-j": history-search-forward'
bind '"\C-k": history-search-backward'
