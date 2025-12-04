# ================================
# Bash Completion for update_env_var_generic and remove_from_env_var
# ================================

# Complete environment variable names (e.g., PATH, LD_LIBRARY_PATH)
_complete_env_var_names() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Complete environment variable names using compgen
    COMPREPLY=($(compgen -v -- "$cur"))
}

# Complete function arguments for update_env_var_generic (e.g., prepend, append, move, verbose, quiet)
_complete_update_env_var_generic_args() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Complete flags: prepend, append, move, verbose, quiet
    local options="prepend append move verbose quiet"
    COMPREPLY=($(compgen -W "$options" -- "$cur"))
}

# Complete function arguments for remove_from_env_var (e.g., entry to remove)
_complete_remove_from_env_var_args() {
    local cur var entries
    var="${COMP_WORDS[1]}"
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Get current value of environment variable for removal (e.g., PATH entries)
    entries=$(eval echo \$$var)

    # Complete entries within the environment variable (based on the colon-separated list)
    IFS=':' read -r -a entry_array <<< "$entries"
    COMPREPLY=($(compgen -W "${entry_array[*]}" -- "$cur"))
}

# Main completion function for update_env_var_generic and remove_from_env_var
_complete_env_var_operations() {
    local cur prev
    prev="${COMP_WORDS[COMP_CWORD]-1}"
    cur="${COMP_WORDS[COMP_CWORD]}"

    # If it's the first word, complete environment variable names
    if [ $COMP_CWORD -eq 1 ]; then
        _complete_env_var_names
    # If it's the second word, complete entry to add (optional)
    elif [ $COMP_CWORD -eq 2 ]; then
        # Optionally, you can complete known paths (e.g., based on $PATH entries)
        COMPREPLY=($(compgen -f -- "$cur"))
    # If it's the third word, complete the flags for update_env_var_generic (prepend, append, move, verbose, quiet)
    elif [ $COMP_CWORD -ge 3 ]; then
        _complete_update_env_var_generic_args
    fi
}

# Main completion handler for remove_from_env_var
_complete_remove_from_env_var() {
    local cur prev
    prev="${COMP_WORDS[COMP_CWORD]-1}"
    cur="${COMP_WORDS[COMP_CWORD]}"

    # If the first word is remove_from_env_var, complete entries to remove
    if [ "$prev" = "remove_from_env_var" ]; then
        _complete_remove_from_env_var_args
    fi
}

# Register the completion function for the update_env_var_generic command
complete -F _complete_env_var_operations update_env_var_generic

# Register the completion function for the remove_from_env_var command
complete -F _complete_remove_from_env_var remove_from_env_var

