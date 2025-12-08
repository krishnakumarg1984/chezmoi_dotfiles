# Optimized update_env_var tab completion function using only Bash built-ins (no subshells, no external tools)
_update_env_var_completions() {
    local cur prev opts var entry val entries IFS

    # Set the possible operations
    opts="prepend append movefirst movelast remove deduplicate"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Completion for the operation argument
    if [[ $COMP_CWORD -eq 2 ]]; then
        COMPREPLY=(${opts[@]// /$'\n'})  # Fast completion for operations
        return 0
    fi

    # Completion for the environment variable (like PATH, LD_LIBRARY_PATH)
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=()

        # Loop over environment variables directly from the shell's internal variable list
        for var in $(compgen -v); do
            if [[ "$var" == "$cur"* ]]; then
                COMPREPLY+=("$var")
            fi
        done
        return 0
    fi

    # If the operation requires an entry (prepend, append, movefirst, movelast, remove)
    if [[ "$prev" =~ ^(prepend|append|movefirst|movelast|remove)$ ]]; then
        COMPREPLY=()

        # Use globbing to match directories within the current directory
        for dir in $cur*/; do
            if [[ -d "$dir" && "$dir" == "$cur"* ]]; then
                COMPREPLY+=("$dir")
            fi
        done
        return 0
    fi

    # If the operation is remove, we may want to complete entries in the environment variable
    if [[ "$prev" == "remove" && $COMP_CWORD -eq 3 ]]; then
        var="${COMP_WORDS[1]}"
        val="${!var}"

        # Split the value into a list of entries using the delimiter ":"
        IFS=':' read -ra entries <<< "$val"

        COMPREPLY=()
        for entry in "${entries[@]}"; do
            if [[ "$entry" == "$cur"* ]]; then
                COMPREPLY+=("$entry")
            fi
        done
        return 0
    fi

    # Completion for the --delimiter option (optional)
    if [[ "$prev" == "--delimiter" || "$prev" == "-d" ]]; then
        COMPREPLY=(":" ";" "," "|")  # Common delimiter characters for completion
        return 0
    fi
}

# Bind the tab completion function for the update_env_var command
complete -F _update_env_var_completions update_env_var

