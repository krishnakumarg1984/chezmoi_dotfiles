# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:
# shellcheck shell=sh
# shellcheck disable=SC1091

# FUNCTION: update_env_var_generic (((
# ------------------------------------
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
#         "verbose" - Enable verbose output (override default).
#         "quiet"   - Suppress verbose output (override default).
#
# Returns:
#   - Updates the specified environment variable.
# ============================================================
update_env_var_generic() {
    var="$1"
    new="$2"        # New entry to add.
    mode="append"   # Default mode is "append".
    move="no"       # Default: don't move entry.
    verbose=0       # Default to quiet mode
    shift 1         # Shift past the variable name.

    # Check if running interactively or via script (quiet mode by default)
    if [[ "$-" == *i* ]]; then
        verbose=1  # Default to verbose in interactive shells
    fi

    # Parse optional arguments (prepend, append, move, verbose, quiet).
    if [ -n "$new" ]; then
        shift
        for arg in "$@"; do
            case "$arg" in
                prepend|append) mode="$arg" ;;  # Set mode.
                move) move="yes" ;;             # Enable move.
                verbose) verbose=1 ;;           # Enable verbose output.
                quiet) verbose=0 ;;             # Enable quiet output.
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
            if [ "$verbose" -eq 1 ]; then
                echo "Added new entry '$new' to $var ($mode)"
            fi
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
            if [ "$verbose" -eq 1 ]; then
                echo "Moved entry '$new' in $var to $mode"
            fi
        fi
    fi

    # Final step: Export the updated environment variable.
    set_env_var "$var" "$entries"

    # Verbose output for completion (if interactive or VERBOSE=true)
    if [ "$verbose" -eq 1 ]; then
        echo "Updated $var: $entries"
    fi
}

# )))

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
