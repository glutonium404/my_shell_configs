cls() {
	clear && ls;
}

clcd() {
	clear && cd && ls
}

lcd() {
	cd $1 && ls
}

mcd() {
	mkdir $1 && cd $1
}

cf() {
    # Use the first argument as the path, or default to the home directory if no argument is given
    local path="${1:-$HOME}"

    # Check if the specified path exists and is a directory
    if [[ ! -d "$path" ]]; then
        echo "Path does not exist or is not a directory." >&2
        return 1
    fi

    # Find all directories starting from the specified path and pipe them to fzf for selection
    local selected_directory
    selected_directory=$(find "$path" -type d 2>/dev/null | fzf)

    # Print the selected directory (if any)
    if [[ -n "$selected_directory" ]]; then
        echo "$selected_directory"
    fi
}









# custom key binding
bind '"\C-H": kill-whole-line' # delete whole line when ctrl + backspace is pressed
# bind -x '"\C-f":"cd $(find ~/ -type d | fzf) && pwd"' # lets u move to any dir using fuzzy finder. hit ctrl + f then select your dir

bind -x '"\C-f":"cd $(cf)"' # lets u move to any dir using fuzzy finder. hit ctrl + f then select your dir
