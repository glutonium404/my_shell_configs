##################################################
##########      custom functions    ##############
##################################################

mcd() {
    local dir=$1
    mkdir $dir && cd $dir
}

cd() {
    builtin cd $1 && ls
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


# Function to get the current Git branch and status. using it to modify the shell prompt
function parse_git_branch {
    # Get the current branch name
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Check for uncommitted changes
        if [ -n "$(git status --porcelain)" ]; then
            # Uncommitted changes detected
	    printf "\e[0m\e[1;91m[$branch ✗]\e[0m"
        else
            # Clean working tree
            printf "\e[0m\e[1;92m[$branch ✓]\e[0m"
        fi
    fi
}
