##################################################
##########     custom key binding   ##############
##################################################

# delete whole line when ctrl + backspace is pressed
bind '"\C-H": kill-whole-line'

bind -x '"\C-f":"cdd"'

# moving between the command history using j and k to keep things related to vim key binding
bind '"\C-j": history-search-forward'
bind '"\C-k": history-search-backward'
