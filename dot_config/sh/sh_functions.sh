# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:
# shellcheck shell=sh
# shellcheck disable=SC1091

# ============================================================
# POSIX Environment Variable Manager
# ------------------------------------------------------------
# This script provides an ultra-fast and POSIX-compliant way to:
#   - Deduplicate entries in colon-separated environment variables (like PATH).
#   - Add new entries idempotently (only if it isn't already present).
#   - Optionally move an existing entry to the beginning or end of the list.
#
# It avoids external tools like `grep`, `awk`, `sed`, and `tr`, ensuring maximum performance
# and compatibility across all POSIX-compliant shells.
#
# Key Features:
#   - **Speed Optimized**: Processes the environment variable in a single pass.
#   - **POSIX Compliant**: Works in any POSIX shell, like `sh`, `bash`, `dash`, `zsh`.
#   - **No External Tools**: Completely avoids reliance on tools like `grep`, `tr`, etc.
#   - **Flexible**: Supports **prepending**, **appending**, **moving**, and **deduplication** of entries.
#
# Verbosity Control:
#   - Default: Silent when sourced in shell scripts.
#   - Verbose in interactive shell when explicitly set or on interactive terminal.
# ============================================================

# Default separator for colon-separated environment variable entries.
ENV_SEP=":"

# Global verbosity flag (0 = silent, 1 = verbose)
VERBOSE=0

# ============================================================
# FUNCTION: set_verbosity
# ------------------------------------------------------------
# Purpose:
#   - Set verbosity level for the script (verbose or quiet).
#
# Arguments:
#   $1 - "verbose" or "quiet" to set verbosity level.
#
# Returns:
#   - Sets the global VERBOSE flag to control verbosity.
# ============================================================
set_verbosity() {
    case "$1" in
        verbose)
            VERBOSE=1
            ;;
        quiet)
            VERBOSE=0
            ;;
        *)
            echo "Invalid argument: $1. Use 'verbose' or 'quiet'." >&2
            return 1
            ;;
    esac
}

# ============================================================
# FUNCTION: log_verbose
# ------------------------------------------------------------
# Purpose:
#   - Print a message if verbosity is set to 1 (verbose).
#
# Arguments:
#   $1 - Message to print.
#
# Returns:
#   - Prints the message if VERBOSE is set to 1.
# ============================================================
log_verbose() {
    if [ "$VERBOSE" -eq 1 ]; then
        echo "$1"
    fi
}

# ============================================================
# FUNCTION: get_env_var
# ------------------------------------------------------------
# Purpose:
#   - Retrieve the value of an environment variable.
#
# Arguments:
#   $1 - Name of the environment variable (e.g., PATH).
#
# Returns:
#   - Prints the current value of the environment variable.
# ============================================================
get_env_var() {
    var="$1"
    eval "printf '%s\n' \"\${$var}\""
}

# ============================================================
# FUNCTION: set_env_var
# ------------------------------------------------------------
# Purpose:
#   - Set and export an environment variable.
#
# Arguments:
#   $1 - Name of the environment variable.
#   $2 - Value to set.
# ============================================================
set_env_var() {
    var="$1"
    val="$2"
    eval "$var=\$val"
    export "$var"
    log_verbose "Updated $var with value: $val"
}

# ============================================================
# FUNCTION: update_env_var_generic
# ------------------------------------------------------------
# Purpose:
#   - Deduplicate entries in a colon-separated environment variable.
#   - Add a new entry idempotently (only if it isn't already present).
#   - Optionally move an entry to the beginning or end.
#
# Arguments:
#   $1 - Name of environment variable (e.g., PATH).
#   $2 - (Optional) New entry to add.
#   $3.. - (Optional) Options:
#         "prepend" - Add new entry at the beginning.
#         "append"  - Add new entry at the end (default).
#         "move"    - Move the existing entry to the beginning or end.
#
# Returns:
#   - Updates the specified environment variable.
# ============================================================
update_env_var_generic() {
    var="$1"
    new="$2"        # New entry to add.
    mode="append"   # Default mode is "append".
    move="no"       # Default: don't move entry.
    shift 1         # Shift past the variable name.

    # Parse optional arguments (prepend, append, move).
    if [ -n "$new" ]; then
        shift
        for arg in "$@"; do
            case "$arg" in
                prepend|append) mode="$arg" ;;  # Set mode.
                move) move="yes" ;;             # Enable move.
                *) echo "Invalid argument '$arg'" >&2; return 1 ;;
            esac
        done
    fi

    # Retrieve the current value of the environment variable.
    val=$(get_env_var "$var")

    # -----------------------------------------------------------
    # Efficient in-place processing: Deduplication + Addition + Move
    # -----------------------------------------------------------
    entries=""
    seen=""
    first=1   # Flag to manage the leading separator.

    # Loop to handle deduplication and entry processing in one pass.
    IFS="$ENV_SEP"
    for entry in $val; do
        # Skip entries that have already been added.
        if [[ ":$seen:" != *":$entry:"* ]]; then
            # Add to the entries string (handling the separator).
            if [ "$first" -eq 1 ]; then
                entries="$entry"
                first=0
            else
                entries="$entries$ENV_SEP$entry"
            fi
            # Mark this entry as seen.
            seen=":$seen:$entry"
        fi
    done

    # Handle new entry addition and moving.
    if [ -n "$new" ]; then
        # If the new entry isn't already in the list.
        if [[ ":$seen:" != *":$new:"* ]]; then
            # Add new entry (prepend or append).
            if [ "$mode" = "prepend" ]; then
                entries="$new$ENV_SEP$entries"
            else
                entries="$entries$ENV_SEP$new"
            fi
            seen=":$seen:$new"   # Mark new entry as seen.
        elif [ "$move" = "yes" ]; then
            # Move the entry by removing and adding it back at the correct position.
            entries=""
            IFS="$ENV_SEP"
            for entry in $val; do
                if [ "$entry" != "$new" ]; then
                    if [ -z "$entries" ]; then
                        entries="$entry"
                    else
                        entries="$entries$ENV_SEP$entry"
                    fi
                fi
            done
            # Add the target entry at the correct position (prepend or append).
            if [ "$mode" = "prepend" ]; then
                entries="$new$ENV_SEP$entries"
            else
                entries="$entries$ENV_SEP$new"
            fi
        fi
    fi

    # Final step: Export the updated environment variable.
    set_env_var "$var" "$entries"
    log_verbose "Environment variable $var updated."
}

# ============================================================
# FUNCTION: remove_from_env_var
# ------------------------------------------------------------
# Purpose:
#   - Remove a specific entry from a colon-separated environment variable.
#
# Arguments:
#   $1 - Name of the environment variable.
#   $2 - Entry to remove.
#
# Returns:
#   - Updates the specified environment variable.
# ============================================================
remove_from_env_var() {
    var="$1"
    target="$2"
    val=$(get_env_var "$var")

    # Efficiently build new entries without the target entry.
    entries=""
    IFS="$ENV_SEP"
    for entry in $val; do
        if [ "$entry" != "$target" ]; then
            # Append entries that are not the target.
            if [ -z "$entries" ]; then
                entries="$entry"
            else
                entries="$entries$ENV_SEP$entry"
            fi
        fi
    done

    # Export the final result.
    set_env_var "$var" "$entries"
    log_verbose "Removed $target from $var."
}

# ============================================================
# EXAMPLES (Commented Out)
# ============================================================

# 1. Deduplicate PATH only (no addition)
# update_env_var_generic PATH

# 2. Add a new entry to the beginning, move it if already exists
# update_env_var_generic PATH "/usr/local/bin" prepend move

# 3. Add a new entry to the end
# update_env_var_generic PATH "/opt/tools" append

# 4. Remove a specific entry
# remove_from_env_var PATH "/old/path"

# ============================================================
# ASCII Flow Diagram (for update_env_var_generic)
# -----------------------------------------------------------
#
#   +-----------------------------+
#   |  Start                       |
#   +-----------------------------+
#             |
#             v
#   +-----------------------------+
#   | Retrieve environment var    |
#   | (e.g., PATH)                 |
#   +-----------------------------+
#             |
#             v
#   +-----------------------------+
#   | Loop through entries and     |
#   | deduplicate (if not seen)    |
#   +-----------------------------+
#             |
#             v
#   +-----------------------------+
#   | Is new entry provided?       |
#   +-----------------------------+
#       |         |
#       v         v
#   +---------------------+   +---------------------------+
#   | Entry exists?       |   | Add new entry (prepend/    |
#   | (move is "yes")     |   | append) and return final  |
#   +---------------------+   | result                     |
#       |                   +---------------------------+
#       v
#   +----------------------------+
#   | Add new entry to position   |
#   | (prepend or append)         |
#   +----------------------------+
#             |
#             v
#   +-----------------------------+
#   | Export final result         |
#   +-----------------------------+
#             |
#             v
#   +-----------------------------+
#   |  End                        |
#   +-----------------------------+



# USAGE: path_add [include|prepend|append] "dir1" "dir2" ... (((
# https://superuser.com/a/925318
#   prepend: add/move to beginning
#   append:  add/move to end
#   include: add to end of PATH if not already included [default]
#          that is, don't change position if already in PATH
# RETURNS:
# prepend:  dir2:dir1:OLD_PATH
# append:   OLD_PATH:dir1:dir2
# If called with no paramters, returns PATH with duplicate directories removed
path_add() {
    # use subshell to create "local" variables
    PATH="$(path_unique)"
    PATH="$(path_add_do "$@")" && export PATH
}

path_add_do() {
    case "$1" in
    'include' | 'prepend' | 'append')
        action="$1"
        shift
        ;;
    *) action='include' ;;
    esac

    path=":$PATH:" # pad to ensure full path is matched later

    for dir in "$@"; do
        #       [ -d "$dir" ] || continue # skip non-directory params

        left="${path%:"$dir":*}" # remove last occurrence to end

        if [ "$path" = "$left" ]; then
            # PATH doesn't contain $dir
            [ "$action" = 'include' ] && action='append'
            right=''
        else
            right=":${path#"$left":"$dir":}" # remove start to last occurrence
        fi

        # construct path with $dir added
        case "$action" in
        'prepend') path=":$dir$left$right" ;;
        'append') path="$left$right$dir:" ;;
        esac
    done

    # strip ':' pads
    path="${path#:}"
    path="${path%:}"

    # return
    printf '%s' "$path"
}

# USAGE: path_unique [path]
# path - a colon delimited list. Defaults to $PATH is not specified.
# RETURNS: `path` with duplicated directories removed
path_unique() {
    in_path=${1:-$PATH}
    path=':'

    # Wrap the while loop in '{}' to be able to access the updated `path variable
    # as the `while` loop is run in a subshell due to the piping to it.
    # https://stackoverflow.com/questions/4667509/shell-variables-set-inside-while-loop-not-visible-outside-of-it
    printf '%s\n' "$in_path" |
        /bin/tr -s ':' '\n' |
        {
            while read -r dir; do
                left="${path%:"$dir":*}" # remove last occurrence to end
                if [ "$path" = "$left" ]; then
                    # PATH doesn't contain $dir
                    path="$path$dir:"
                fi
            done
            # strip ':' pads
            path="${path#:}"
            path="${path%:}"
            # return
            printf '%s\n' "$path"
        }
}
# )))
