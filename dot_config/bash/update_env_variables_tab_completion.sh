#!/bin/bash

# ============================================================
# Bash Completion Script for Ultra High-Performance POSIX
# Environment Variable Manager
# ------------------------------------------------------------
# This script provides autocompletion for the shell functions
# defined in the environment variable manager script. It includes:
#   - Autocompletion for environment variable names (e.g., PATH).
#   - Autocompletion for the options available for update_env_var_generic and remove_from_env_var.
#
# This script should be sourced in the shell's initialization files
# like `.bashrc` for bash completion support.
# ============================================================

# Function to generate completion for environment variable names.
complete_env_vars() {
    # List of environment variables that are commonly used in the shell
    # and can be dynamically sourced from the environment.
    # Using `compgen` to list all variables set in the shell environment.
    compgen -v
}

# Function to complete the options for `update_env_var_generic`.
complete_update_env_var_options() {
    # The valid options for the function `update_env_var_generic`.
    # Arguments like 'prepend', 'append', 'move' are expected.
    COMPREPLY=()
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local valid_options="prepend append move"

    if [[ $current_word == * ]] ; then
        # If no word is typed, complete all the options.
        COMPREPLY=( $(compgen -W "$valid_options" -- "$current_word") )
    fi
}

# Function to complete environment variables for `remove_from_env_var`.
complete_remove_from_env_var() {
    # This function handles autocompletion for the `remove_from_env_var` function
    # It will first complete the environment variable name and then the entry to be removed.
    if [ "${COMP_CWORD}" -eq 2 ]; then
        # Complete environment variables (like PATH)
        complete_env_vars
    elif [ "${COMP_CWORD}" -eq 3 ]; then
        # Complete entries inside the selected environment variable
        local var_name="${COMP_WORDS[2]}"
        local var_value
        var_value=$(eval echo \$$var_name)  # Get the value of the environment variable.

        # If the variable has a value, we complete its entries (split by $ENV_SEP)
        if [ -n "$var_value" ]; then
            local entries=""
            IFS="$ENV_SEP" # Separator for colon-separated values (e.g., PATH).
            for entry in $var_value; do
                entries="$entries$entry"$'\n'
            done
            COMPREPLY=( $(compgen -W "$entries" -- "${COMP_WORDS[COMP_CWORD]}") )
        fi
    fi
}

# Main Completion Setup
# ----------------------------------------------
# 1. Autocompletion for environment variable names (e.g., PATH, LD_LIBRARY_PATH).
complete -F complete_env_vars update_env_var_generic remove_from_env_var

# 2. Autocompletion for options like prepend, append, move for update_env_var_generic.
complete -F complete_update_env_var_options update_env_var_generic

# 3. Autocompletion for entries to remove from environment variables.
complete -F complete_remove_from_env_var remove_from_env_var
