# https://blog.petdance.com/2019/10/31/tab-completion-for-ssh-scp/
# shellcheck shell=bash
# shellcheck disable=SC1091

__complete_ssh_host() {
    local CONFIG_LIST="" ssh_config_file line host

    # Use Bash globbing to find SSH config files and iterate through them
    for ssh_config_file in "$HOME/.ssh/"*_ssh_config; do
        # Check if the file exists and is readable
        if [[ -r "$ssh_config_file" ]]; then
            # Read the file line by line and extract hosts (lines starting with 'Host')
            while IFS= read -r line; do
                # Match lines starting with "Host" and extract the host names using Bash regex
                if [[ "$line" =~ ^Host[[:space:]]+([A-Za-z0-9_-]+) ]]; then
                    host="${BASH_REMATCH[1]}"  # Capture the host name
                    CONFIG_LIST="$CONFIG_LIST $host"  # Append to the list
                fi
            done < "$ssh_config_file"
        fi
    done

    # Get the current partial word being typed
    local PARTIAL_WORD="${COMP_WORDS[COMP_CWORD]}"

    # Perform completion by filtering matching hosts
    COMPREPLY=()
    for host in $CONFIG_LIST; do
        if [[ "$host" == "$PARTIAL_WORD"* ]]; then
            COMPREPLY+=("$host")
        fi
    done

    return 0
}

# Enable tab completion for `ssh` and `scp` using the function
complete -F __complete_ssh_host ssh
complete -F __complete_ssh_host scp
