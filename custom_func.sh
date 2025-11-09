##################################################
##########      custom functions    ##############
##################################################

mcd() {
    local dir="$1"

    # check if no argument is given
    if [[ -z "$dir" ]]; then
        echo "Usage: mcd <directory>"
        return 1
    fi

    if mkdir "$dir"; then
        cd "$dir"
    fi
}

cd() {
    builtin cd $1 && ls
}

# select multiple files and delete them together
rm() {
    # if -m flag is passed
    if [[ "$1" == "-m" ]]; then
        # remove the flag from args
        shift
        # use fzf to select multiple files
        local files
        files=$(fzf -m) || return  # exit if nothing selected

        # confirm and remove selected files
        echo "Deleting:"
        echo "$files"
        command rm "$@" $files
    else
        # fallback to normal rm
        command rm "$@"
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
            printf "\e[0m\e[1;91m($branch)\e[0m "
        else
            # Clean working tree
            printf "\e[0m\e[1;92m($branch)\e[0m "
        fi
    fi
}

function yt {
    local search_query=$(echo $1 | tr " " +) # replace all white space with +
    local url="https://www.youtube.com/results?search_query=$search_query"
    echo $url
    x-www-browser --url $url # opens the url in the browser
}

function findfile {
    local selected_file

    selected_file=$(find ${1:-$HOME} -type f \
        -not -regex '.*/\(node_modules\|.local\|.cache\|.git\)/.*' -printf "%P\n" | \
        fzf --preview='batcat --paging=never \
        --color=always --style=numbers \
        --line-range=:500 $HOME/{}'\
    )

    if [ -n "$selected_file" ]; then
        echo "$HOME/$selected_file"
    fi
}

function finddir {
  local selected_dir
  selected_dir=$(find ${1:-$HOME} -type d -not -regex '.*/\(node_modules\|.local\|.cache\|.git\)/.*' -printf '%P\n' | fzf)
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
    fdfind -t d --hidden \
        --exclude node_modules \
        --exclude .local \
        --exclude .cache \
        --exclude .git \
        --base-directory "$HOME" > "$HOME/.local/fzf_cache/dirs.txt"
}

function cdd {
    local dir
    dir=$(cat "$HOME/.local/fzf_cache/dirs.txt" | fzf)

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

function gitadd {
    local files
    # files="$(git status -s | fzf -m | awk '{print $2}' | tr '\n' ' ')"
    files="$(git diff --name-only | fzf -m | tr '\n' ' ')"

    if [ -z "$files" ]; then

        echo "Please select at least one file"
        return
    fi

    git add $files && git status -s
}

function mdpdf {
    local view=false

    if [[ "$1" == "-v" ]]; then
        view=true
    fi

    local md_files
    md_files=$(fdfind -e md --max-depth 1) || return

    if [[ -z "$md_files" ]]; then
        echo "No markdown files found."
        return
    fi

    # check if md_files contain only one file
    local file
    if [[ $(echo "$md_files" | wc -l) -eq 1 ]]; then
        file="$md_files"
    else
        file=$(echo "$md_files" | fzf --prompt="Select a markdown file: ") || return
    fi

    local fileNameWithoutExt="${file%.*}"
    pandoc --pdf-engine=wkhtmltopdf "$file" -o "${fileNameWithoutExt}.pdf"

    if $view; then
        echo "Opening ${fileNameWithoutExt}.pdf..."
        x-www-browser "${fileNameWithoutExt}.pdf"
    fi
}

function copy {
    local FILE="$1"

    # If no file provided, show usage
    if [[ -z "$FILE" ]]; then
        echo "Usage: copy <file>"
        return
    fi

    # Check if file exists
    if [[ ! -f "$FILE" ]]; then
        echo "File not found: $FILE"
        return
    fi

    printf "\033]52;c;$(cat $FILE | base64)\a"
}

function repo {
    local repo_name=$(gh repo list | awk '{print $1}' | fzf)
    [[ -z "$repo_name" ]] && return
    x-www-browser --url "https://github.com/$repo_name"
}
