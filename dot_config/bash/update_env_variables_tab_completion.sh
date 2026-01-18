# -----------------------------------------
# Bash completion for update_env_var
# Fully built-in, recursive directory completion
# No subshells, no external commands
# -----------------------------------------

# Recursive helper function for directory completion
# Arguments:
#   $1 = prefix directory to scan
#   $2 = current word being completed
#   $3 = recursion depth (used internally)
_update_env_var_recursive_dirs() {
    local prefix="$1" cur="$2" depth="$3" max_depth=5
    # Stop recursion if max depth reached
    [[ $depth -ge $max_depth ]] && return

    local IFS_SAVE=$IFS
    IFS=$'\n'  # iterate entries line by line

    local f
    shopt -s nullglob dotglob  # include hidden dirs, prevent literal '*'
    for f in "$prefix"/*; do
        [[ -d "$f" ]] || continue   # skip non-directories
        local name="${f%/}"          # remove trailing slash
        # skip special entries '.' and '..'
        [[ ${name##*/} == . || ${name##*/} == .. ]] && continue
        # add to completion if it matches the current input
        [[ $name == "$cur"* ]] && COMPREPLY+=("$name/")
        # recurse into subdirectories
        _update_env_var_recursive_dirs "$f" "$cur" $((depth + 1))
    done
    shopt -u nullglob dotglob
    IFS=$IFS_SAVE
}

# Main completion function for update_env_var
_update_env_var_completion() {
    local cur prev var opts IFS_SAVE
    COMPREPLY=()  # clear previous completions

    cur="${COMP_WORDS[COMP_CWORD]}"           # current word being completed
    prev="${COMP_WORDS[COMP_CWORD-1]}"        # previous word
    var="${COMP_WORDS[1]}"                     # first argument = variable name

    # allowed operations and options
    opts=("deduplicate" "append" "prepend" "--delim" "--verbose")

    # -----------------------------
    # First argument: variable name
    # -----------------------------
    if [[ $COMP_CWORD -eq 1 ]]; then
        # pure Bash cannot enumerate all variables, so use a common set
        local common_vars=("PATH" "MANPATH" "LD_LIBRARY_PATH" "PYTHONPATH" "EDITOR" "HOME")
        local v
        for v in "${common_vars[@]}"; do
            [[ $v == "$cur"* ]] && COMPREPLY+=("$v")
        done
        return
    fi

    # -----------------------------
    # Second argument: value
    # -----------------------------
    if [[ $COMP_CWORD -eq 2 ]]; then
        if [[ $var == "PATH" ]]; then
            # Determine starting prefix for directory scanning
            local prefix
            if [[ $cur == /* ]]; then
                prefix="/"                  # absolute path
            elif [[ $cur == */* ]]; then
                prefix="${cur%/*}"          # directory part of path
            else
                prefix="."                  # relative path
            fi
            # recursive directory completion
            _update_env_var_recursive_dirs "$prefix" "$cur" 0
        else
            # Complete existing colon-separated entries for other variables
            local val entries entry
            IFS_SAVE=$IFS
            IFS=':'  # split on colon
            val="${!var}"  # indirect expansion to get variable value
            read -ra entries <<< "$val"
            for entry in "${entries[@]}"; do
                # skip empty entries
                [[ -n $entry && $entry == "$cur"* ]] && COMPREPLY+=("$entry")
            done
            IFS=$IFS_SAVE
        fi
        return
    fi

    # -----------------------------
    # Third or later argument: operation/options
    # -----------------------------
    if [[ $COMP_CWORD -ge 3 ]]; then
        local opt
        for opt in "${opts[@]}"; do
            [[ $opt == "$cur"* ]] && COMPREPLY+=("$opt")
        done
        return
    fi
}

# Enable the completion function for update_env_var
complete -F _update_env_var_completion update_env_var

# -----------------------------------------
# Example usage of completion (for reference)
# Copy-paste as comments in your ~/.bashrc
# -----------------------------------------

# # Complete variable name
# update_env_var [TAB]
# # => PATH
# # => MANPATH
# # => LD_LIBRARY_PATH
# # => PYTHONPATH
# # => EDITOR
# # => HOME

# # Complete PATH directories recursively
# update_env_var PATH /u[TAB]
# # => /usr/
# update_env_var PATH /usr/l[TAB]
# # => /usr/local/
# update_env_var PATH /usr/local/b[TAB]
# # => /usr/local/bin/

# # Complete colon-separated values for other variables
# update_env_var MANPATH /usr/s[TAB]
# # => /usr/share/man/

# # Complete operations/options
# update_env_var PATH /usr/local/bin d[TAB]
# # => deduplicate
# update_env_var PATH /usr/local/bin a[TAB]
# # => append
# update_env_var PATH /usr/local/bin p[TAB]
# # => prepend
# update_env_var PATH /usr/local/bin --v[TAB]
# # => --verbose

