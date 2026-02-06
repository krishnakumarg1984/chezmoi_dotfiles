# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:
# shellcheck shell=sh
# shellcheck disable=SC1091

# # command_exists (((
# # Prevent reloading if functions are already defined
# if ! type "command_exists" > /dev/null 2>&1; then
#
#     # Cache delimiter
#     cmd_cache_delim="|"
#
#     # Trim leading and trailing whitespace (simplified)
#     trim_spaces() {
#         s="$1"
#         # Remove leading spaces
#         while [ -n "$s" ] && { [ "${s%"${s#?}"}" = " " ] || [ "${s%"${s#?}"}" = $'\t' ]; }; do
#             s="${s#?}"
#         done
#         # Remove trailing spaces
#         while [ -n "$s" ] && { [ "${s%"${s%?}"}" = " " ] || [ "${s%"${s%?}"}" = $'\t' ]; }; do
#             s="${s%?}"
#         done
#         printf "%s" "$s"
#     }
#
#     # Validate command name (alphanumeric + ., _, +, -)
#     is_valid_command_name() {
#         case "$1" in
#             ""|*[!A-Za-z0-9._+-]*)
#                 return 1
#                 ;;
#             *)
#                 return 0
#                 ;;
#         esac
#     }
#
#     # Check if file exists and is executable
#     _is_executable() {
#         [ -f "$1" ] && [ -x "$1" ]
#     }
#
#     # Search for command in PATH
#     command_path() {
#         name="$1"
#         cmd_path_value=""
#         [ -z "$PATH" ] && return 1
#
#         oldIFS="$IFS"
#         IFS=":"
#         for dir in $PATH; do
#             dir=$(trim_spaces "$dir")  # Trim spaces in directories
#             [ -z "$dir" ] && continue
#             if [ "$dir" = "." ]; then
#                 continue  # Skip current directory
#             fi
#             if [ ! -d "$dir" ] || [ ! -x "$dir" ]; then
#                 continue  # Skip invalid or inaccessible directories
#             fi
#             file="$dir/$name"
#             if _is_executable "$file"; then
#                 cmd_path_value="$file"
#                 IFS="$oldIFS"  # Restore IFS
#                 return 0
#             fi
#         done
#         IFS="$oldIFS"  # Restore IFS
#         return 1
#     }
#
#     # Look up command in cache
#     cache_lookup() {
#         cache="$1"
#         name="$2"
#         cmd_cache_lookup_value=""
#         [ -z "$name" ] && return 1
#         [ -z "$cache" ] && return 1
#
#         name=$(trim_spaces "$name")  # Trim spaces in name
#         rest="$cache"
#         while [ -n "$rest" ]; do
#             entry="${rest%%$cmd_cache_delim*}"
#             rest="${rest#*$cmd_cache_delim}"
#             entry=$(trim_spaces "$entry")
#             [ -z "$entry" ] && continue
#             # Ensure entry contains '=' as key=value pair
#             if [ "${entry#*=}" = "$entry" ] || [ -z "${entry%%=*}" ] || [ -z "${entry#*=}" ]; then
#                 continue  # Skip malformed entries
#             fi
#
#             key="${entry%%=*}"
#             value="${entry#*=}"
#             key=$(trim_spaces "$key")
#             value=$(trim_spaces "$value")
#
#             # Skip empty key or value
#             if [ -z "$key" ] || [ -z "$value" ]; then
#                 continue
#             fi
#
#             if [ "$key" = "$name" ]; then
#                 cmd_cache_lookup_value="$value"
#                 return 0
#             fi
#         done
#         return 1
#     }
#
#     # Update cache with new name=value pair
#     cache_set() {
#         cache="$1"
#         name="$2"
#         value="$3"
#
#         # Default value if not provided
#         [ -z "$value" ] && value="not_found"
#
#         # Reject names/values containing the delimiter or equal sign
#         case "$name" in *$cmd_cache_delim*|*"="*) return 1; esac
#         case "$value" in *$cmd_cache_delim*|*"="*) return 1; esac
#
#         # Handle empty cache case
#         if [ -z "$cache" ]; then
#             cache="$name=$value"
#         else
#             new_cache=""
#             # Manually process cache entries to avoid any delimiter breaking
#             while [ -n "$cache" ]; do
#                 # Extract key-value pair
#                 entry="${cache%%$cmd_cache_delim*}"
#                 cache="${cache#*$cmd_cache_delim}"
#
#                 # Skip malformed entries
#                 [ -z "$entry" ] && continue
#
#                 key="${entry%%=*}"
#                 value="${entry#*=}"
#
#                 # Skip malformed key-value pairs
#                 [ -z "$key" ] || [ -z "$value" ] && continue
#
#                 if [ "$key" = "$name" ]; then
#                     new_cache="$new_cache${new_cache:+$cmd_cache_delim}$name=$value"
#                 else
#                     new_cache="$new_cache${new_cache:+$cmd_cache_delim}$entry"
#                 fi
#             done
#             cache="$new_cache"
#         fi
#
#         printf "%s" "$cache"
#     }
#
#     # Check if command exists (cache or PATH)
#     command_exists() {
#         name="$1"
#         cache="$2"  # Pass the cache as an argument
#
#         [ -z "$name" ] && return 1
#
#         # If the input is a full path, check directly if it's executable
#         if [ "${name%/*}" != "$name" ]; then
#             _is_executable "$name" && return 0
#         fi
#
#         if ! is_valid_command_name "$name"; then
#             return 1
#         fi
#
#         # First, check the cache
#         cache_lookup "$cache" "$name"
#         if [ -n "$cmd_cache_lookup_value" ] && [ "$cmd_cache_lookup_value" != "not_found" ]; then
#             return 0  # Found in cache
#         fi
#
#         # If not found in cache, check if the command is executable
#         if _is_executable "$name"; then
#             cache=$(cache_set "$cache" "$name" "executable")
#             return 0
#         fi
#
#         # If not found in PATH
#         if command_path "$name"; then
#             cache=$(cache_set "$cache" "$name" "$cmd_path_value")
#             return 0
#         fi
#
#         # If still not found, cache the result and return failure
#         cache=$(cache_set "$cache" "$name" "not_found")
#         return 1
#     }
#
#     # Security check for "." in PATH
#     check_path_for_dots() {
#         if [ -z "$PATH" ] || [ "$(trim_spaces "$PATH")" = "" ]; then
#             echo "Warning: PATH is empty or unset. This may cause commands to fail."
#             return 1  # No PATH set, skip the check
#         fi
#
#         new_path=""
#         oldIFS="$IFS"
#         IFS=":"
#         for dir in $PATH; do
#             dir=$(trim_spaces "$dir")  # Trim spaces in directories
#             [ -z "$dir" ] && continue
#             [ "$dir" = "." ] && continue  # Skip current directory
#             new_path="$new_path$dir:"
#         done
#         IFS="$oldIFS"
#
#         # If PATH becomes empty after removing ".", warn and exit
#         if [ -z "$new_path" ] || [ "$new_path" = "." ]; then
#             echo "Error: No valid directories left in PATH!" >&2
#             return 1
#         fi
#         PATH="${new_path%:}"  # Remove trailing colon
#     }
#
#     # Run security check on PATH before using it
#     check_path_for_dots
#
# fi
# # )))

# Environment manager (((
# ============================================================
# _u_canon: canonicalize a single entry
# $1 = value
# $2 = mode: "dir" or "syntactic"
# ============================================================
_u_canon() {
    p=$1
    # skip empty or non-printable
    case "$p" in ""|*[![:print:]]*) return 1 ;; esac

    # strip trailing slashes except root "/"
    while [ "$p" != "/" ] && [ "${p%/}" != "$p" ]; do
        p=${p%/}
    done

    # directory check if mode=dir
    case "$2" in
        dir) [ -d "$p" ] || return 1 ;;
        *) : ;;
    esac

    printf '%s\n' "$p"
}

# ============================================================
# update_env_var: add entries to environment variable using flags
# ------------------------------------------------------------
# Usage:
#   update_env_var VAR [--append|--prepend] [--check dir|syntactic]
#                    [--separator SEP] ENTRY1 [ENTRY2 ...]
# Flags:
#   --prepend      : prepend entries (default)
#   --append       : append entries
#   --check MODE   : "dir" or "syntactic" (default: syntactic)
#   --separator SEP: single-character separator (default ":")
# ============================================================
update_env_var() {
    # first argument is the variable name
    var=$1
    shift

    # default options
    mode="prepend"
    check="syntactic"
    sep=":"

    # parse optional flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --prepend) mode="prepend"; shift ;;
            --append)  mode="append"; shift ;;
            --check)
                shift
                [ $# -gt 0 ] || return 1
                check=$1
                shift
                ;;
            --separator)
                shift
                [ $# -gt 0 ] || return 1
                sep=$1
                shift
                ;;
            --) shift; break ;;  # end of flags
            --*) echo "Unknown flag: $1" >&2; return 1 ;;
            *) break ;;          # first non-flag is entry
        esac
    done

    # remaining arguments are the entries to add
    if [ $# -eq 0 ]; then
        return 0  # nothing to add
    fi

    # get current value
    eval old=\${$var}

    # build new value by adding all entries in order
    new="$old"
    for val in "$@"; do
        c=$(_u_canon "$val" "$check") || continue

        # skip duplicates
        case "${sep}${new}${sep}" in
            *"${sep}${c}${sep}"*) continue ;;
        esac

        # prepend or append
        case "$mode" in
            append) new="${new:+$new$sep}$c" ;;
            prepend|*) new="$c${new:+$sep$new}" ;;
        esac
    done

    # normalize full variable: canonicalize + dedupe
    final=
    IFS=$sep
    for e in $new; do
        ce=$(_u_canon "$e" "$check") || continue
        case "${sep}${final}${sep}" in
            *"${sep}${ce}${sep}"*) ;;
            *) final="${final:+$final$sep}$ce" ;;
        esac
    done
    unset IFS

    # assign back
    eval "$var=\$final"
}

# ============================================================
# ------------------- USAGE EXAMPLES -------------------------
# ============================================================

# PATH example: prepend multiple dirs (dir check)
# update_env_var PATH --prepend --check dir /opt/bin /custom/bin
# Append multiple dirs
# update_env_var PATH --append --check dir /usr/local/bin /usr/bin
# echo $PATH  # Expected: /opt/bin:/custom/bin:/usr/local/bin:/usr/bin

# Comma-separated list: syntactic mode with custom separator
# update_env_var FOO --separator , alpha beta gamma
# echo $FOO  # Expected: alpha,beta,gamma

# Space-separated list: prepend entries
# update_env_var TAGS --prepend --separator " " delta epsilon
# echo $TAGS  # Expected: delta epsilon ...

# ============================================================
# ------------------- TEST CASES ----------------------------
# ------------------------------------------------------------
# Uncomment to run tests

# Test 1: dir mode skips non-existent
# VAR_DIR=""
# update_env_var VAR_DIR --check dir /nonexistent /tmp
# echo $VAR_DIR
# Expected: /tmp

# Test 2: deduplication
# VAR_DEDUPE="/usr/bin:/usr/bin"
# update_env_var VAR_DEDUPE --append /usr/bin /bin
# echo $VAR_DEDUPE
# Expected: /usr/bin:/bin

# Test 3: prepend/append flag order
# VAR_SEQ=""
# update_env_var VAR_SEQ --append a b
# update_env_var VAR_SEQ --prepend c d
# echo $VAR_SEQ
# Expected: c:d:a:b

# Test 4: syntactic separator
# VAR_CSV="foo,bar"
# update_env_var VAR_CSV --separator , baz foo
# echo $VAR_CSV
# Expected: baz,foo,bar

# )))

# # update_env_var (((
# #
# # Pure POSIX shell function to manipulate environment variables (PATH-style).
# # Supports deduplicate, prepend, append operations with custom delimiter.
# # Fully safe for ~/.profile, login scripts, or minimal shells (dash, ash, ksh).
# #
# # Usage:
# #   update_env_var VAR VALUE [deduplicate|append|prepend] [--delim D] [--verbose]
# #
# # Arguments:
# #   VAR       : The environment variable name to update (must be valid POSIX identifier)
# #   VALUE     : The value to add/move in the variable
# #   deduplicate (default) : Ensure VALUE appears exactly once (preserves first occurrence)
# #   prepend   : Move VALUE to the beginning (first entry)
# #   append    : Move VALUE to the end (last entry)
# #   --delim D : Optional single-character delimiter (defaults to ':')
# #   --verbose : Prints the variable after modification
# #
# # Examples:
# #   # Add /opt/bin to PATH if not present (deduplicate by default)
# #   update_env_var PATH /opt/bin
# #
# #   # Move /opt/bin to the front of PATH
# #   update_env_var PATH /opt/bin prepend
# #
# #   # Move /opt/bin to the end of PATH
# #   update_env_var PATH /opt/bin append
# #
# #   # Use a different delimiter (semicolon) and print result
# #   update_env_var MANPATH /custom/man --delim ';' --verbose
# #
# #   # Deduplicate MANPATH and print result
# #   update_env_var MANPATH /usr/local/man --verbose
# #
# #   # Multiple operations in ~/.profile safely
# #   update_env_var PATH /usr/local/bin prepend
# #   update_env_var PATH /opt/bin append
# #
# #
# # Notes / POSIX constraints:
# #   - Single-character delimiter only
# #   - Values cannot contain the delimiter
# #   - Empty fields in PATH-style variables are removed
# #   - Fully subshell-free, external-command-free
# #   - Subshell-free – no ( ), $(), or pipelines.
# #   - External-command-free – uses only POSIX built-ins: eval, export, printf, for, case, [ ].
# #   - Deduplicate preserves first occurrence – repeated entries later are removed.
# #   - Prepend/Append moves existing entries – ensures uniqueness.
# #   - Safe for ~/.profile – can modify PATH, MANPATH, etc., without breaking login shell.
# #   - Verbose mode – print updated variable if --verbose is passed.#
# # -----------------------------------------------------------------------------
# update_env_var() {
#     # -----------------------------
#     # Defaults
#     # -----------------------------
#     _op=deduplicate    # Default operation
#     _delim=:           # Default delimiter
#     _verbose=0         # Silent by default
#
#     # -----------------------------
#     # Require VAR and VALUE
#     # -----------------------------
#     [ $# -ge 2 ] || return 1
#     _var=$1
#     _val=$2
#     shift 2
#
#     # -----------------------------
#     # Validate variable name (POSIX identifier)
#     # Only letters, digits, underscore, cannot start with digit
#     # -----------------------------
#     case $_var in
#         [A-Za-z_]*[!A-Za-z0-9_]*|'')
#             return 2
#             ;;
#     esac
#
#     # -----------------------------
#     # Parse optional arguments
#     # -----------------------------
#     while [ $# -gt 0 ]; do
#         case $1 in
#             deduplicate|append|prepend)
#                 _op=$1
#                 ;;
#             --delim)
#                 shift || return 1
#                 _delim=$1
#                 ;;
#             --verbose)
#                 _verbose=1
#                 ;;
#             *)
#                 # Unrecognized argument
#                 return 1
#                 ;;
#         esac
#         shift
#     done
#
#     # -----------------------------
#     # Fetch current variable value safely
#     # -----------------------------
#     eval _cur=\${$_var}
#
#     _new=
#     _found=0
#
#     _old_ifs=$IFS
#     IFS=$_delim  # Split on delimiter
#
#     # -----------------------------
#     # Operation logic
#     # -----------------------------
#     case $_op in
#         # -------------------------
#         # Deduplicate: preserve first occurrence
#         # -------------------------
#         deduplicate)
#             for _item in $_cur; do
#                 [ -z "$_item" ] && continue   # Skip empty fields
#                 if [ "$_item" = "$_val" ]; then
#                     [ $_found -eq 1 ] && continue  # Skip duplicates
#                     _found=1
#                 fi
#                 if [ -n "$_new" ]; then
#                     _new=$_new$_delim$_item
#                 else
#                     _new=$_item
#                 fi
#             done
#
#             # Append VALUE if not already found
#             if [ $_found -eq 0 ]; then
#                 if [ -n "$_new" ]; then
#                     _new=$_new$_delim$_val
#                 else
#                     _new=$_val
#                 fi
#             fi
#             ;;
#
#         # -------------------------
#         # Prepend / Append: move VALUE to front or end
#         # -------------------------
#         prepend|append)
#             # Remove all existing occurrences first
#             for _item in $_cur; do
#                 [ -z "$_item" ] && continue
#                 [ "$_item" = "$_val" ] && continue
#                 if [ -n "$_new" ]; then
#                     _new=$_new$_delim$_item
#                 else
#                     _new=$_item
#                 fi
#             done
#
#             # Insert VALUE
#             if [ "$_op" = prepend ]; then
#                 if [ -n "$_new" ]; then
#                     _new=$_val$_delim$_new
#                 else
#                     _new=$_val
#                 fi
#             else
#                 if [ -n "$_new" ]; then
#                     _new=$_new$_delim$_val
#                 else
#                     _new=$_val
#                 fi
#             fi
#             ;;
#     esac
#
#     IFS=$_old_ifs  # Restore IFS
#
#     # -----------------------------
#     # Assign back and export
#     # -----------------------------
#     eval $_var=\$_new
#     export $_var
#
#     # -----------------------------
#     # Optional verbose output
#     # -----------------------------
#     if [ $_verbose -eq 1 ]; then
#         printf '%s=%s\n' "$_var" "$_new"
#     fi
# }
#
# # ----------------------------
# # Test cases for update_env_var
# # ----------------------------
#
# # 1. Basic deduplicate (default)
# # PATH="/bin:/usr/bin:/bin:/sbin"
# # update_env_var PATH /bin
# # Expected: /bin:/usr/bin:/sbin
#
# # PATH=""
# # update_env_var PATH /usr/local/bin
# # Expected: /usr/local/bin
#
# # PATH="/bin"
# # update_env_var PATH /usr/bin
# # Expected: /bin:/usr/bin
#
# # ----------------------------
# # 2. Prepend
# # ----------------------------
# # PATH="/usr/bin:/bin"
# # update_env_var PATH /bin prepend
# # Expected: /bin:/usr/bin
#
# # PATH="/usr/bin"
# # update_env_var PATH /usr/local/bin prepend
# # Expected: /usr/local/bin:/usr/bin
#
# # PATH=""
# # update_env_var PATH /bin prepend
# # Expected: /bin
#
# # ----------------------------
# # 3. Append
# # ----------------------------
# # PATH="/bin:/usr/bin"
# # update_env_var PATH /bin append
# # Expected: /usr/bin:/bin
#
# # PATH="/usr/bin"
# # update_env_var PATH /usr/local/bin append
# # Expected: /usr/bin:/usr/local/bin
#
# # PATH=""
# # update_env_var PATH /bin append
# # Expected: /bin
#
# # ----------------------------
# # 4. Deduplicate preserves first occurrence
# # ----------------------------
# # PATH="/bin:/usr/bin:/bin:/sbin:/bin"
# # update_env_var PATH /bin
# # Expected: /bin:/usr/bin:/sbin
#
# # PATH="/usr/bin:/bin:/usr/bin:/sbin"
# # update_env_var PATH /usr/bin
# # Expected: /usr/bin:/bin:/sbin
#
# # ----------------------------
# # 5. Custom delimiter
# # ----------------------------
# # MANPATH="/usr/share/man;/usr/local/share/man;/usr/share/man"
# # update_env_var MANPATH /usr/local/share/man deduplicate --delim ';' --verbose
# # Expected: /usr/share/man;/usr/local/share/man
#
# # MANPATH="/usr/share/man;/usr/local/share/man"
# # update_env_var MANPATH /opt/man prepend --delim ';' --verbose
# # Expected: /opt/man;/usr/share/man;/usr/local/share/man
#
# # MANPATH="/usr/share/man;/usr/local/share/man"
# # update_env_var MANPATH /opt/man append --delim ';' --verbose
# # Expected: /usr/share/man;/usr/local/share/man;/opt/man
#
# # ----------------------------
# # 6. Empty fields handling
# # ----------------------------
# # PATH=":/bin::/usr/bin:"
# # update_env_var PATH /bin
# # Expected: /bin:/usr/bin
#
# # PATH="::"
# # update_env_var PATH /bin
# # Expected: /bin
#
# # PATH=""
# # update_env_var PATH /bin
# # Expected: /bin
#
# # ----------------------------
# # 7. Already at correct position
# # ----------------------------
# # PATH="/bin:/usr/bin:/sbin"
# # update_env_var PATH /bin prepend
# # Expected: /bin:/usr/bin:/sbin
#
# # PATH="/bin:/usr/bin:/sbin"
# # update_env_var PATH /sbin append
# # Expected: /bin:/usr/bin:/sbin
#
# # ----------------------------
# # 8. Multiple duplicates removed
# # ----------------------------
# # PATH="/bin:/usr/bin:/bin:/sbin:/usr/bin:/bin"
# # update_env_var PATH /usr/bin
# # Expected: /bin:/usr/bin:/sbin
#
# # PATH="/bin:/bin:/bin"
# # update_env_var PATH /bin
# # Expected: /bin
#
# # ----------------------------
# # 9. Verbose mode
# # ----------------------------
# # PATH="/bin:/usr/bin"
# # update_env_var PATH /opt/bin prepend --verbose
# # Expected printed: PATH=/opt/bin:/bin:/usr/bin
#
# # PATH="/bin:/usr/bin"
# # update_env_var PATH /opt/bin append --verbose
# # Expected printed: PATH=/bin:/usr/bin:/opt/bin
#
# # ----------------------------
# # 10. Invalid variable name (should fail)
# # ----------------------------
# # update_env_var "1INVALID" /bin
# # Returns 2, no change
#
# # update_env_var "VAR!" /bin
# # Returns 2, no change
#
#
# # )))
