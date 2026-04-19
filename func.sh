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
parse_git_branch() {
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

yt() {
    local search_query=$(echo $1 | tr " " +) # replace all white space with +
    local url="https://www.youtube.com/results?search_query=$search_query"
    echo $url
    x-www-browser --url $url # opens the url in the browser
}

findfile() {
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

finddir() {
  local selected_dir
  selected_dir=$(find ${1:-$HOME} -type d -not -regex '.*/\(node_modules\|.local\|.cache\|.git\)/.*' -printf '%P\n' | fzf)
  if [ -n "$selected_dir" ]; then
    echo "$HOME/$selected_dir"
  fi
}

fat() {
    local selected_file
    selected_file=$(findfile $1)

    if [ -n $selected_file ]; then
        bat $selected_file
    fi
}

cddr() {
    # try with `fd` if `fdfind` doesn't work. refer to the doc for other issues
    fdfind -t d -L --hidden \
        --exclude node_modules \
        --exclude .local \
        --exclude .cache \
        --exclude .git \
        --max-depth 20 \
        --base-directory "$HOME" \
        > "$HOME/.local/fzf_cache/dirs.txt"
}

cdd() {
    local dir
    dir=$(cat "$HOME/.local/fzf_cache/dirs.txt" | fzf)

    if [[ -n "$dir" ]]; then
        cd "$HOME/$dir" || exit
    else
        echo "No directory selected."
    fi
}

mkdir() {
    # makes sure mkdir ran without error before appending the dir
    if /bin/mkdir "$@" ; then
        local curr_path
        curr_path=$(pwd)

        local dir_name
        dir_name="$1"

        echo "$curr_path/$dir_name" >> "$HOME/.local/fzf_cache/dirs.txt"
    fi
}

gitadd() {
    local files
    # files="$(git status -s | fzf -m | awk '{print $2}' | tr '\n' ' ')"
    files="$(git diff --name-only | fzf -m | tr '\n' ' ')"

    if [ -z "$files" ]; then
        echo "Please select at least one file"
        return
    fi

    git add $files && git status -s
}

mdpdf() {
    local view=false
    local style=false

    # check if -v or --view flag is passed or -s or --style flag is passed
    while [[ "$1" != "" ]]; do
        case $1 in
            -v | --view )    view=true
                             ;;
            -s | --style )   style=true
                             ;;
            * )              echo "Usage: mdpdf [-v|--view] [-s|--style]"
                             return
        esac
        shift
    done

    local md_files
    md_files=$(fdfind -e md --maxdepth 1) || return

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

    if $style; then
        local css_file
        css_file=$(find . -type f -name "style.css" --maxdepth 1)

        if [[ -z "$css_file" ]]; then
            css_file=$(fdfind . -e css --maxdepth 1 | fzf --prompt="Select a CSS file: ") || return
        fi

        pandoc --pdf-engine=wkhtmltopdf "$file" -o "${fileNameWithoutExt}.pdf" -c "$css_file"
    else
        pandoc --pdf-engine=wkhtmltopdf "$file" -o "${fileNameWithoutExt}.pdf"
    fi

    if $view; then
        echo "Opening ${fileNameWithoutExt}.pdf..."
        x-www-browser "${fileNameWithoutExt}.pdf"
    fi
}

copy() {
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

repo() {
    local repo_name=$(gh repo list | awk '{print $1}' | fzf)
    [[ -z "$repo_name" ]] && return
    x-www-browser --url "https://github.com/$repo_name"
}

run() {
    local save_dir="$HOME/.local/my_dir"
    local save_file="$save_dir/my_variables.sh"

    # 1. Load saved state if it exists so -p works in new sessions
    if [[ -f "$save_file" ]]; then
        source "$save_file"
    fi

    case "$1" in
        -p)
            if [[ -z "$PREVIOUSLY_RAN_CPP" ]]; then
                echo "No previous file recorded."
            elif [[ ! -f "$PREVIOUSLY_RAN_CPP" ]]; then
                echo "Previous file no longer exists: $PREVIOUSLY_RAN_CPP"
            else
                g++ "$PREVIOUSLY_RAN_CPP" && ./a.out && rm a.out
            fi
            ;;
        "")
            # 2. Check for fd or fdfind
            local fd_cmd
            fd_cmd=$(command -v fdfind || command -v fd)

            if [[ -z "$fd_cmd" ]]; then
                echo "Error: fd or fdfind is not installed."
                return 1
            fi

            local file
            file=$($fd_cmd . -e cpp -e c | fzf)

            if [[ -z "$file" ]]; then
                echo "No file selected."
                return
            fi

            # 3. Setup directory and save absolute path
            mkdir -p "$save_dir"
            local abs_path
            abs_path=$(realpath "$file")

            echo "PREVIOUSLY_RAN_CPP=\"$abs_path\"" > "$save_file"
            source "$save_file"

            g++ "$abs_path" && ./a.out && rm a.out
            ;;
        *)
            echo "Usage: run [-p]"
            return 1
            ;;
    esac


bashrc() {
    local file="$HOME/.bashrc"
    local _pwd="$(pwd)"

    case "$1" in
        -o)
            cat "$file"
            ;;
        -e)
            nvim "$file"
            ;;
        "")
            # shellcheck disable=SC1090
            source "$file"
            echo "✔ ~/.bashrc sourced"
            ;;
        *)
            echo "Usage: bashrc [-o | -e]"
            return 1
            ;;
    esac
}

function chtsh {
    curl cht.sh/$1 | batcat
}

function clone {
    local repo_name=$(gh repo list | awk '{print $1}' | fzf)
    [[ -z "$repo_name" ]] && return
    gh repo clone $repo_name
}

function gem {
    local temp_file=$(mktemp)
    gemini $@ > $temp_file
    batcat "$temp_file"
    cat $temp_file
    rm "$temp_file"
}
