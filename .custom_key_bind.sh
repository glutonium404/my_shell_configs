##################################################
##########     custom key binding   ##############
##################################################

bind '"\C-H": kill-whole-line' # delete whole line when ctrl + backspace is pressed
# bind -x '"\C-f":"cd $(find ~/ -type d | fzf) && pwd"' # lets u move to any dir using fuzzy finder. hit ctrl + f then select your dir

bind -x '"\C-f":"cd $(cf)"' # lets u move to any dir using fuzzy finder. hit ctrl + f then select your dir
