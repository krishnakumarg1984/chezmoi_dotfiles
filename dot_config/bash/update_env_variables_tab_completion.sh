# ============================================================
# Smart Bash completion for update_env_var (built-ins only)
# ============================================================

_update_env_var_completion() {
    local cur prev opts check_opts check_mode var_name var_value IFS i entry
    local -a existing_entries env_vars

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Top-level flags
    opts="--prepend --append --check --separator"
    check_opts="dir syntactic"

    # -----------------------------
    # 1) First argument: variable name
    # -----------------------------
    if [ $COMP_CWORD -eq 1 ]; then
        # get all exported variable names
        env_vars=($(compgen -v))
        COMPREPLY=( $(compgen -W "${env_vars[*]}" -- "$cur") )
        return
    fi

    # second argument and beyond
    var_name="${COMP_WORDS[1]}"
    if [ -n "$var_name" ]; then
        eval var_value=\${$var_name}
        IFS=':' read -r -a existing_entries <<< "$var_value"
    fi

    # -----------------------------
    # 2) --check argument completion
    # -----------------------------
    if [[ "$prev" == "--check" ]]; then
        COMPREPLY=( $(compgen -W "$check_opts" -- "$cur") )
        return
    fi

    # -----------------------------
    # 3) Flags completion
    # -----------------------------
    if [[ "$cur" == --* ]]; then
        COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
        return
    fi

    # -----------------------------
    # 4) Determine check mode
    # -----------------------------
    check_mode="syntactic"  # default
    for ((i=1;i<COMP_CWORD;i++)); do
        if [[ "${COMP_WORDS[i]}" == "--check" && $((i+1)) -lt ${#COMP_WORDS[@]} ]]; then
            check_mode="${COMP_WORDS[i+1]}"
            break
        fi
    done

    # -----------------------------
    # 5) Complete existing entries
    # -----------------------------
    COMPREPLY=()
    if [ ${#existing_entries[@]} -gt 0 ]; then
        for entry in "${existing_entries[@]}"; do
            [[ "$entry" == "$cur"* ]] && COMPREPLY+=("$entry")
        done
    fi

    # -----------------------------
    # 6) Complete directories if dir mode
    # -----------------------------
    if [[ "$check_mode" == "dir" ]]; then
        local dir_prefix
        if [[ "$cur" == */* ]]; then
            dir_prefix="${cur%/*}/"
            for d in "$dir_prefix"*; do
                [[ -d "$d" ]] || continue
                COMPREPLY+=("$d")
            done
        else
            for d in /*; do
                [[ -d "$d" ]] || continue
                [[ "$d" == "$cur"* ]] && COMPREPLY+=("$d")
            done
        fi
    fi
}

# Register completion
complete -F _update_env_var_completion update_env_var

# update_env_var [TAB]              # completes: PATH, FOO, TAGS, etc.
# update_env_var PATH --[TAB]       # completes: --prepend, --append, --check, --separator
# update_env_var PATH --check [TAB] # completes: dir, syntactic
# update_env_var PATH /u[TAB]       # completes directories in dir mode + existing PATH entries
# update_env_var FOO a[TAB]         # completes existing FOO entries starting with 'a'
#
