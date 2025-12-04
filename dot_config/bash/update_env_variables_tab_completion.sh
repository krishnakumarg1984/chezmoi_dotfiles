# ============================================================
# Tab Completion for update_env_var_generic and remove_from_env_var
# ============================================================
#
# This script provides efficient and fast tab completion
# for `update_env_var_generic` and `remove_from_env_var`.
# It works for:
# 1. Environment variable names (e.g., PATH, HOME, etc.).
# 2. Modes (e.g., prepend, append, move).
# 3. Entries within environment variables (e.g., removing entries in PATH).
#
# Add this code to your .bashrc or .bash_profile to enable the tab completion.
# ============================================================

# ------------------------------------------------------------
# Tab Completion for Environment Variable Names (e.g., PATH)
# ------------------------------------------------------------
_env_var_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed
    COMPREPLY=()  # Initialize completion results

    # Iterate over the environment variable names and match against the current input
    for var in $(compgen -v); do
        if [[ "$var" == "$cur"* && "$var" != "$cur" ]]; then
            COMPREPLY+=("$var")  # Add matching variable name to the list of completions
        fi
    done

    return 0  # Success, so return completions
}

# ------------------------------------------------------------
# Tab Completion for Modes (prepend, append, move)
# ------------------------------------------------------------
_mode_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed
    COMPREPLY=()  # Initialize completion results

    # Match the mode keywords: prepend, append, move
    if [[ "$cur" == prepend* ]]; then
        COMPREPLY=("prepend")
    elif [[ "$cur" == append* ]]; then
        COMPREPLY=("append")
    elif [[ "$cur" == move* ]]; then
        COMPREPLY=("move")
    fi

    return 0  # Success, so return completions
}

# ------------------------------------------------------------
# Tab Completion for Removing Entries from Environment Variables
# ------------------------------------------------------------
_remove_entry_completions() {
    local var="${COMP_WORDS[1]}"  # Environment variable name to modify (e.g., PATH)
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed
    COMPREPLY=()  # Initialize completion results

    # If the environment variable is empty or not set, return no completions
    if [[ -z "${!var}" ]]; then
        return 0  # No completions since the variable is unset or empty
    fi

    # Split the value of the environment variable (e.g., PATH) by colon `:`
    IFS=":"  # Set the Internal Field Separator to colon
    for entry in ${!var}; do
        # Match the entry against the current word being typed (`$cur`)
        if [[ "$entry" == "$cur"* && "$entry" != "$cur" ]]; then
            COMPREPLY+=("$entry")  # Add matching entry to the list of completions
        fi
    done

    return 0  # Success, so return completions
}

# ------------------------------------------------------------
# Tab Completion for update_env_var_generic (Environment Variables, Modes, Entries)
# ------------------------------------------------------------
_complete_update_env_var_generic() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Get the current word being typed
    local var="${COMP_WORDS[1]}"  # Environment variable to modify (e.g., PATH)
    COMPREPLY=()  # Initialize completion results

    # Case 1: Completing environment variable names (first argument)
    if [[ "$COMP_CWORD" -eq 1 ]]; then
        _env_var_completions
    # Case 2: Completing entries inside a variable (e.g., PATH entries)
    elif [[ "$COMP_CWORD" -eq 2 && -n "$var" ]]; then
        _remove_entry_completions
    fi

    # Case 3: Completing modes (prepend, append, move) in the second argument
    if [[ "$COMP_CWORD" -eq 2 ]]; then
        _mode_completions
    fi
}

# ------------------------------------------------------------
# Bind Tab Completion Functions to Shell Commands
# ------------------------------------------------------------
# This part binds the tab completion functions to specific shell commands:
# - `update_env_var_generic` for environment variable and mode completions.
# - `remove_from_env_var` for environment variable and entry completions.

complete -F _complete_update_env_var_generic update_env_var_generic  # Bind environment variable and entry completions
complete -F _complete_update_env_var_generic remove_from_env_var    # Bind environment variable and entry completions for remove

# ------------------------------------------------------------
# Define the `update_env_var_generic` and `remove_from_env_var`
# Functions (Sample)
# ------------------------------------------------------------

# Example placeholder functions for `update_env_var_generic` and `remove_from_env_var`
# These functions are just an example, replace them with your actual implementations.

update_env_var_generic() {
    local var="$1"
    local mode="$2"
    local entry="$3"

    echo "Updating $var with mode $mode and entry $entry"
    # Add your actual implementation here
}

remove_from_env_var() {
    local var="$1"
    local entry="$2"

    echo "Removing $entry from $var"
    # Add your actual implementation here
}

