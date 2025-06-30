# https://blog.petdance.com/2019/10/31/tab-completion-for-ssh-scp/
# shellcheck shell=bash
# shellcheck disable=SC1091

__complete_ssh_host() {
    local CONFIG_LIST=""
    for ssh_config_file in "$(find "$HOME/.ssh/" -name '*_ssh_config')"; do
        local CONFIG_FILE=$ssh_config_file
        if [ -r "$CONFIG_FILE" ]; then
            CONFIG_LIST="$CONFIG_LIST $(awk '/^Host [A-Za-z]+/ {print $2}' "$CONFIG_FILE")"
        fi
    done

    local PARTIAL_WORD="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=("$(compgen -W "$KNOWN_LIST$IFS$CONFIG_LIST" -- "$PARTIAL_WORD")")

    return 0
}

complete -F __complete_ssh_host ssh
complete -f -F __complete_ssh_host scp
