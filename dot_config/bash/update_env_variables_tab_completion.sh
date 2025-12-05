# update_env_var_completions.sh
# ============================================================
# Purpose:
#   This script provides Bash tab-completion for the `update_env_var`
#   function. It uses an optimized approach with associative arrays and
#   precomputed lists to speed up the completion process, particularly
#   for large environments or complex variable setups.
#
# ============================================================
# Suggested Testing Plan:
#
# 1. **Basic Tab Completion**:
#    - **Test 1**: Type `update_env_var` and press **Tab**.
#      - **Expected Result**: It should complete common environment variables like `PATH`, `HOME`, etc.
#    - **Test 2**: Type `update_env_var PATH` and press **Tab**.
#      - **Expected Result**: It should complete available operations like `prepend`, `append`, `remove`, etc.
#
# 2. **File Path Completion**:
#    - **Test 3**: Type `update_env_var PATH /new/path` and press **Tab**.
#      - **Expected Result**: It should complete valid paths like `/usr`, `/bin`, `/home`, etc., and optionally regular files.
#
# 3. **Flags Completion**:
#    - **Test 4**: Type `update_env_var PATH /new/path append` and press **Tab**.
#      - **Expected Result**: It should complete flags like `--verbose`, `-v`, `--quiet`, etc.
#
# 4. **Edge Case Testing**:
#    - **Test 5**: Test with an environment variable that includes special characters or spaces (e.g., `PATH="/opt/bin /home/user/special path"`).
#      - **Expected Result**: The script should correctly handle spaces and special characters, without misinterpreting them.
#    - **Test 6**: Type an invalid operation or flag (e.g., `update_env_var PATH /new/path invalidflag`).
#      - **Expected Result**: It should either not complete or return a warning/error.
#
# 5. **Large Environment Test**:
#    - **Test 7**: Add a large number of environment variables (`100+`), either manually or with a script.
#      - **Expected Result**: Tab completion should still function quickly and correctly.
#
# 6. **Cross-Platform Testing**:
#    - **Test 8**: Test on **macOS** vs **Linux** (e.g., Ubuntu, CentOS).
#      - **Expected Result**: Tab completion should work consistently on both platforms, with no issues in finding variables or paths.
#
# 7. **Completion with Nested Paths**:
#    - **Test 9**: Test with nested directories in `PATH` or other variables (e.g., `/usr/bin:/usr/local/bin:/home/user/dir`).
#      - **Expected Result**: Tab completion should work on directories with subdirectories without issues.
#
# 8. **Test Cache Populating**:
#    - **Test 10**: Ensure that the environment variables are cached correctly.
#      - **Test**: After sourcing the script, manually test completion. Ensure that once cached, the environment variables are accessed directly from the associative array and not recalculated on every tab press.
#
# ============================================================

# Declare an associative array to store environment variable names
# This helps speed up the lookup by storing them in a cached array.
declare -A env_cache

# Precomputed static list of common environment variables
# These are some of the most commonly used environment variables that
# we expect users to modify frequently. This static list avoids
# unnecessary dynamic searching.
env_vars="PATH HOME USER LANG SHELL EDITOR TERM LD_LIBRARY_PATH HISTFILE"

# Function to cache the environment variables
# This function populates the `env_cache` associative array with common
# environment variables for fast completion.
_cache_env_vars() {
    # Check if the cache is already populated (i.e., it's empty)
    if [ ${#env_cache[@]} -eq 0 ]; then
        # Populate cache with predefined common environment variables
        for var in $env_vars; do
            env_cache["$var"]=1  # Mark the variable as cached
        done

        # Optionally, dynamically add more environment variables from the system
        # Uncomment below if you want to fetch more variables dynamically.
        # Here we use `compgen -v` to list all environment variables and add them.
        # for var in $(compgen -v); do
        #     env_cache["$var"]=1
        # done
    fi
}

# Function to complete environment variable names (e.g., PATH, HOME)
_env_var_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed in the completion

    # Ensure that the environment variables are cached
    _cache_env_vars

    # Use the cached environment variables for completion
    # `compgen -W` generates completions from the list of environment variable names
    COMPREPLY=($(compgen -W "${!env_cache[@]}" -- "$cur"))
}

# Function to complete operation types (e.g., prepend, append, movefirst)
_operations_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed in the completion
    local operations="prepend append movefirst movelast remove"  # List of operations

    # Complete from the predefined list of operations
    COMPREPLY=($(compgen -W "$operations" -- "$cur"))
}

# Function to complete flags (e.g., --verbose, -v, --quiet, -q)
_flags_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed in the completion
    local flags="--verbose -v --quiet -q --delimiter -d"  # List of flags

    # Complete from the predefined list of flags
    COMPREPLY=($(compgen -W "$flags" -- "$cur"))
}

# Function to complete entries (file paths or values) for environment variables
_entries_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"  # Current word being typed in the completion

    # Predefined list of common system paths (to speed up matching)
    # These paths are common directories in Unix-based systems that users are
    # likely to complete when updating an environment variable.
    local common_paths="/usr /etc /home /var /opt /tmp /bin /sbin"

    # First attempt to complete against the common system paths
    COMPREPLY=($(compgen -W "$common_paths" -- "$cur"))

    # If no match was found, fall back to regular file path completion
    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        COMPREPLY=($(compgen -f -- "$cur"))  # `compgen -f` completes file paths
    fi
}

# Main function that handles tab completion logic for `update_env_var`
_update_env_var_completions() {
    # Determine which part of the command we are completing based on the argument position

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        # Complete environment variable names (e.g., PATH, HOME)
        _env_var_completions
    elif [[ ${COMP_CWORD} -eq 2 ]]; then
        # Complete the operation types (e.g., prepend, append, movefirst)
        _operations_completions
    elif [[ ${COMP_CWORD} -eq 3 ]]; then
        # Complete entries (values or file paths) for the variable
        _entries_completions
    elif [[ ${COMP_CWORD} -eq 4 ]]; then
        # Complete flags (e.g., --verbose, -v, --quiet)
        _flags_completions
    fi
}

# Register the completion function for `update_env_var`
# This tells Bash to use the `_update_env_var_completions` function for completing
# the `update_env_var` command.
complete -F _update_env_var_completions update_env_var

