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

# Function to get the current Git branch and status. using it to modify the shell prompt
function parse_git_branch {
    # Get the current branch name
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Check for uncommitted changes
        if [ -n "$(git status --porcelain)" ]; then
            # Uncommitted changes detected
            printf "\e[0m\e[1;91m($branch)\e[0m "
        else
            # Clean working tree
            printf "\e[0m\e[1;92m($branch)\e[0m "
        fi
    fi
}


function nvimd {
    local dir_name=$1
    local lookup_path=${2:-$HOME}

    if [ -z "${dir_name}" ]; then
        echo "pls provide directory name"
        return 1
    fi

    nvim $(find $lookup_path -type d -name $dir_name | fzf)
}

function yt {
    local search_query=$(echo $1 | tr " " +) # replace all white space with +
    local url="https://www.youtube.com/results?search_query=$search_query"
    echo $url
    x-www-browser --url $url # opens the url in the browser
}

function findfile {
  local selected_file
  selected_file=$(find ${1:-$HOME} -type f -not -regex '.*/\(node_modules\|.local\|.cache\|.git\)/.*' -printf "%P\n" | fzf)
  if [ -n "$selected_file" ]; then
    echo "$HOME/$selected_file"
  fi
}

function finddir {
  local selected_dir
  selected_dir=$(find ${1:-$HOME} -type d -not -regex '.*/\(node_modules\|.local\|.cache\|.git\)/.*' -printf '%P\n' | fzf --preview='')
  if [ -n "$selected_dir" ]; then
    echo "$HOME/$selected_dir"
  fi
}

function fat {
    local selected_file
    selected_file=$(findfile $1)

    if [ -n $selected_file ]; then
        bat $selected_file
    fi
}

function cddr {
    # try with `fd` if `fdfind` doesn't work. refer to the doc for other issues
    fdfind -t d --hidden --exclude node_modules --exclude .local --exclude .cache --exclude .git \
        --base-directory "$HOME" > "$HOME/.local/fzf_cache/dirs.txt"
}

function cdd {
    local dir
    dir=$(cat "$HOME/.local/fzf_cache/dirs.txt" | fzf --preview "")
    if [[ -n "$dir" ]]; then
        cd "$HOME/$dir" || exit
    else
        echo "No directory selected."
    fi
}

function mkdir {
    # makes sure mkdir ran without error before appending the dir
    if /bin/mkdir "$@" ; then
        local curr_path
        curr_path=$(pwd)

        local dir_name
        dir_name="$1"

        echo "$curr_path/$dir_name" >> "$HOME/.local/fzf_cache/dirs.txt"
    fi
}
