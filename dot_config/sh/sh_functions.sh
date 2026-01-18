# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:
# shellcheck shell=sh
# shellcheck disable=SC1091

# command_exists (strict POSIX) (((
# Prevent reloading if functions are already defined
if ! type "command_exists" > /dev/null 2>&1; then

    # Cache delimiter
    cmd_cache_delim="|"

    # Trim leading and trailing whitespace (simplified)
    trim_spaces() {
        s="$1"
        # Remove leading spaces
        while [ -n "$s" ] && { [ "${s%"${s#?}"}" = " " ] || [ "${s%"${s#?}"}" = $'\t' ]; }; do
            s="${s#?}"
        done
        # Remove trailing spaces
        while [ -n "$s" ] && { [ "${s%"${s%?}"}" = " " ] || [ "${s%"${s%?}"}" = $'\t' ]; }; do
            s="${s%?}"
        done
        printf "%s" "$s"
    }

    # Validate command name (alphanumeric + ., _, +, -)
    is_valid_command_name() {
        case "$1" in
            ""|*[!A-Za-z0-9._+-]*)
                return 1
                ;;
            *)
                return 0
                ;;
        esac
    }

    # Check if file exists and is executable
    _is_executable() {
        [ -f "$1" ] && [ -x "$1" ]
    }

    # Search for command in PATH
    command_path() {
        name="$1"
        cmd_path_value=""
        [ -z "$PATH" ] && return 1

        oldIFS="$IFS"
        IFS=":"
        for dir in $PATH; do
            dir=$(trim_spaces "$dir")  # Trim spaces in directories
            [ -z "$dir" ] && continue
            if [ "$dir" = "." ]; then
                continue  # Skip current directory
            fi
            if [ ! -d "$dir" ] || [ ! -x "$dir" ]; then
                continue  # Skip invalid or inaccessible directories
            fi
            file="$dir/$name"
            if _is_executable "$file"; then
                cmd_path_value="$file"
                IFS="$oldIFS"  # Restore IFS
                return 0
            fi
        done
        IFS="$oldIFS"  # Restore IFS
        return 1
    }

    # Look up command in cache
    cache_lookup() {
        cache="$1"
        name="$2"
        cmd_cache_lookup_value=""
        [ -z "$name" ] && return 1
        [ -z "$cache" ] && return 1

        name=$(trim_spaces "$name")  # Trim spaces in name
        rest="$cache"
        while [ -n "$rest" ]; do
            entry="${rest%%$cmd_cache_delim*}"
            rest="${rest#*$cmd_cache_delim}"
            entry=$(trim_spaces "$entry")
            [ -z "$entry" ] && continue
            # Ensure entry contains '=' as key=value pair
            if [ "${entry#*=}" = "$entry" ] || [ -z "${entry%%=*}" ] || [ -z "${entry#*=}" ]; then
                continue  # Skip malformed entries
            fi

            key="${entry%%=*}"
            value="${entry#*=}"
            key=$(trim_spaces "$key")
            value=$(trim_spaces "$value")

            # Skip empty key or value
            if [ -z "$key" ] || [ -z "$value" ]; then
                continue
            fi

            if [ "$key" = "$name" ]; then
                cmd_cache_lookup_value="$value"
                return 0
            fi
        done
        return 1
    }

    # Update cache with new name=value pair
    cache_set() {
        cache="$1"
        name="$2"
        value="$3"

        # Default value if not provided
        [ -z "$value" ] && value="not_found"

        # Reject names/values containing the delimiter or equal sign
        case "$name" in *$cmd_cache_delim*|*"="*) return 1; esac
        case "$value" in *$cmd_cache_delim*|*"="*) return 1; esac

        # Handle empty cache case
        if [ -z "$cache" ]; then
            cache="$name=$value"
        else
            new_cache=""
            # Manually process cache entries to avoid any delimiter breaking
            while [ -n "$cache" ]; do
                # Extract key-value pair
                entry="${cache%%$cmd_cache_delim*}"
                cache="${cache#*$cmd_cache_delim}"

                # Skip malformed entries
                [ -z "$entry" ] && continue

                key="${entry%%=*}"
                value="${entry#*=}"

                # Skip malformed key-value pairs
                [ -z "$key" ] || [ -z "$value" ] && continue

                if [ "$key" = "$name" ]; then
                    new_cache="$new_cache${new_cache:+$cmd_cache_delim}$name=$value"
                else
                    new_cache="$new_cache${new_cache:+$cmd_cache_delim}$entry"
                fi
            done
            cache="$new_cache"
        fi

        printf "%s" "$cache"
    }

    # Check if command exists (cache or PATH)
    command_exists() {
        name="$1"
        cache="$2"  # Pass the cache as an argument

        [ -z "$name" ] && return 1

        # If the input is a full path, check directly if it's executable
        if [ "${name%/*}" != "$name" ]; then
            _is_executable "$name" && return 0
        fi

        if ! is_valid_command_name "$name"; then
            return 1
        fi

        # First, check the cache
        cache_lookup "$cache" "$name"
        if [ -n "$cmd_cache_lookup_value" ] && [ "$cmd_cache_lookup_value" != "not_found" ]; then
            return 0  # Found in cache
        fi

        # If not found in cache, check if the command is executable
        if _is_executable "$name"; then
            cache=$(cache_set "$cache" "$name" "executable")
            return 0
        fi

        # If not found in PATH
        if command_path "$name"; then
            cache=$(cache_set "$cache" "$name" "$cmd_path_value")
            return 0
        fi

        # If still not found, cache the result and return failure
        cache=$(cache_set "$cache" "$name" "not_found")
        return 1
    }

    # Security check for "." in PATH
    check_path_for_dots() {
        if [ -z "$PATH" ] || [ "$(trim_spaces "$PATH")" = "" ]; then
            echo "Warning: PATH is empty or unset. This may cause commands to fail."
            return 1  # No PATH set, skip the check
        fi

        new_path=""
        oldIFS="$IFS"
        IFS=":"
        for dir in $PATH; do
            dir=$(trim_spaces "$dir")  # Trim spaces in directories
            [ -z "$dir" ] && continue
            [ "$dir" = "." ] && continue  # Skip current directory
            new_path="$new_path$dir:"
        done
        IFS="$oldIFS"

        # If PATH becomes empty after removing ".", warn and exit
        if [ -z "$new_path" ] || [ "$new_path" = "." ]; then
            echo "Error: No valid directories left in PATH!" >&2
            return 1
        fi
        PATH="${new_path%:}"  # Remove trailing colon
    }

    # Run security check on PATH before using it
    check_path_for_dots

fi
# )))

# # update_env_var (((
# if ! type "update_env_var" > /dev/null 2>&1; then
#   update_env_var() {
#     var="$1"
#     operation="deduplicate"
#     delimiter=":"  # Default delimiter
#     entry=""
#     verbose="no"
#     quiet="no"
#
#     shift
#     while [ $# -gt 0 ]; do
#       case "$1" in
#         --verbose|-v) verbose="yes" ;;
#         --quiet|-q) quiet="yes" ;;
#         prepend|append|movefirst|movelast|remove) operation="$1" ;;
#         --delimiter|-d) delimiter="$2"; shift ;;
#         *) entry="$1" ;;
#       esac
#       shift
#     done
#
#     # Get the value of the environment variable
#     val="${!var}"
#
#     # If the variable is empty or not set, initialize it to an empty string
#     [ -z "$val" ] && val=""
#
#     # If the variable is empty, just return early for remove operation
#     if [ -z "$val" ] && [ "$operation" = "remove" ]; then
#       echo "Error: Environment variable '$var' is empty or not set." >&2
#       return 1
#     fi
#
#     # Save the original IFS value
#     oldIFS="$IFS"
#     IFS="$delimiter"  # Set Internal Field Separator to delimiter
#
#     # Split the environment variable into a pseudo-array using the delimiter
#     result_list=""
#     remainder="$val"
#     while [ -n "$remainder" ]; do
#       # Extract the first entry before the delimiter
#       case "$remainder" in
#         *"$delimiter"*)
#           tmp="${remainder%%"$delimiter"*}"
#           # Skip empty entries
#           if [ -n "$tmp" ]; then
#             result_list="$result_list$delimiter$tmp"
#           fi
#           remainder="${remainder#*"$delimiter"}"
#           ;;
#         *)
#           result_list="$result_list$remainder"
#           remainder=""
#           ;;
#       esac
#     done
#
#     # Remove leading delimiter
#     result_list="${result_list#"$delimiter"}"
#
#     # Deduplicate the list
#     dedup_list=""
#     seen=""
#     for e in $result_list; do
#       [ -z "$e" ] && continue
#       # Check if we've seen this entry already
#       case "$seen" in
#         *"$delimiter$e$delimiter"*) continue ;;
#         *)
#           dedup_list="$dedup_list$e$delimiter"
#           seen="$seen$delimiter$e$delimiter"
#           ;;
#       esac
#     done
#
#     # Remove trailing delimiter after deduplication
#     dedup_list="${dedup_list%"$delimiter"}"
#
#     # Remove entry if the operation is "remove"
#     if [ "$operation" = "remove" ]; then
#       new_list=""
#       found="no"
#       for e in $dedup_list; do
#         if [ "$e" = "$entry" ]; then
#           found="yes"
#         else
#           new_list="$new_list$e$delimiter"
#         fi
#       done
#
#       if [ "$found" != "yes" ]; then
#         echo "Error: Entry '$entry' not found in $var." >&2
#         return 1
#       fi
#       # Remove trailing delimiter
#       dedup_list="${new_list%"$delimiter"}"
#     fi
#
#     # Prepend/Append/Move operations
#     if [ -n "$entry" ] && [ "$operation" != "remove" ]; then
#       # Prevent appending/Prepending empty entries
#       if [ -z "$entry" ]; then
#         echo "Error: Entry is empty." >&2
#         return 1
#       fi
#
#       new_list=""
#       for e in $dedup_list; do
#         if [ "$e" != "$entry" ]; then
#           new_list="$new_list$e$delimiter"
#         fi
#       done
#
#       case "$operation" in
#         prepend|movefirst) dedup_list="$entry$delimiter$new_list" ;;
#         append|movelast) dedup_list="$new_list$entry" ;;
#       esac
#     fi
#
#     # Final cleanup: Remove leading or trailing delimiters
#     dedup_list="${dedup_list#"$delimiter"}"
#     dedup_list="${dedup_list%"$delimiter"}"
#
#     # Avoid adding delimiter if the entry is the only element (for empty values)
#     if [ -z "$dedup_list" ]; then
#       dedup_list="$entry"
#     fi
#
#     # Set the environment variable directly without using eval
#     export "$var=$dedup_list"
#
#     # Verbose output only when appropriate
#     if [ "$quiet" != "yes" ] && [ "$verbose" = "yes" ]; then
#       printf "%s\n" "$dedup_list"
#     fi
#
#     # Restore IFS to original value
#     IFS="$oldIFS"
#   }
# fi
#
# # ============================================================
# # -------------------- USAGE EXAMPLES ------------------------
# # ============================================================
#
# # Update PATH by deduplicating
# # update_env_var PATH deduplicate --verbose
#
# # Prepend to PATH
# # update_env_var PATH prepend "/opt/bin" --verbose
#
# # Append to PATH
# # update_env_var PATH append "/home/user/bin" --verbose
#
# # Move directory to the start of PATH
# # update_env_var PATH movefirst "/usr/sbin" --verbose
#
# # Move directory to the end of PATH
# # update_env_var PATH movelast "/bin" --verbose
#
# # Remove a directory from PATH
# # update_env_var PATH remove "/sbin" --verbose
#
# # Prepend a directory with custom delimiter
# # update_env_var PATH prepend "/new/path" --delimiter "::" --verbose
# #
# # )))

# update_env_var (((
if ! type "update_env_var" > /dev/null 2>&1; then
  update_env_var() {
    var="$1"
    operation="deduplicate"
    delimiter=":"  # Default delimiter
    entry=""
    verbose="no"
    quiet="no"

    shift
    while [ $# -gt 0 ]; do
      case "$1" in
        --verbose|-v) verbose="yes" ;;
        --quiet|-q) quiet="yes" ;;
        prepend|append|movefirst|movelast|remove) operation="$1" ;;
        --delimiter|-d) delimiter="$2"; shift ;;
        *) entry="$1" ;;
      esac
      shift
    done

    # Get the value of the environment variable
    val="${!var}"

    # If the variable is empty or not set, initialize it to an empty string
    [ -z "$val" ] && val=""

    # If the variable is empty, just return early for remove operation
    if [ -z "$val" ] && [ "$operation" = "remove" ]; then
      echo "Error: Environment variable '$var' is empty or not set." >&2
      return 1
    fi

    # Save the original IFS value
    oldIFS="$IFS"
    IFS="$delimiter"  # Set Internal Field Separator to delimiter

    # Split the environment variable into a pseudo-array using the delimiter
    result_list=""
    remainder="$val"
    while [ -n "$remainder" ]; do
      # Extract the first entry before the delimiter
      case "$remainder" in
        *"$delimiter"*)
          tmp="${remainder%%"$delimiter"*}"
          # Skip empty entries
          if [ -n "$tmp" ]; then
            result_list="$result_list$delimiter$tmp"
          fi
          remainder="${remainder#*"$delimiter"}"
          ;;
        *)
          result_list="$result_list$remainder"
          remainder=""
          ;;
      esac
    done

    # Ensure no leading delimiter after splitting the value
    result_list="${result_list#"$delimiter"}"

    # Deduplicate the list
    dedup_list=""
    seen=""
    for e in $result_list; do
      [ -z "$e" ] && continue
      # Check if we've seen this entry already
      case "$seen" in
        *"$delimiter$e$delimiter"*) continue ;;
        *)
          dedup_list="$dedup_list$e$delimiter"
          seen="$seen$delimiter$e$delimiter"
      esac
    done

    # Remove trailing delimiter after deduplication to prevent growing last entry
    dedup_list="${dedup_list%"$delimiter"}"

    # Remove entry if the operation is "remove"
    if [ "$operation" = "remove" ]; then
      new_list=""
      found="no"
      for e in $dedup_list; do
        if [ "$e" = "$entry" ]; then
          found="yes"
        else
          new_list="$new_list$e$delimiter"
        fi
      done

      if [ "$found" != "yes" ]; then
        echo "Error: Entry '$entry' not found in $var." >&2
        return 1
      fi
      # Remove trailing delimiter
      dedup_list="${new_list%"$delimiter"}"
    fi

    # Prepend/Append/Move operations
    if [ -n "$entry" ] && [ "$operation" != "remove" ]; then
      # Prevent appending/Prepending empty entries
      if [ -z "$entry" ]; then
        echo "Error: Entry is empty." >&2
        return 1
      fi

      new_list=""
      for e in $dedup_list; do
        if [ "$e" != "$entry" ]; then
          new_list="$new_list$e$delimiter"
        fi
      done

      case "$operation" in
        prepend|movefirst) dedup_list="$entry$delimiter$new_list" ;;
        append|movelast) dedup_list="$new_list$entry" ;;
      esac
    fi

    # Final cleanup: Remove leading or trailing delimiters after all operations
    dedup_list="${dedup_list#"$delimiter"}"
    dedup_list="${dedup_list%"$delimiter"}"

    # Avoid adding delimiter if the entry is the only element (for empty values)
    if [ -z "$dedup_list" ]; then
      dedup_list="$entry"
    fi

    # Set the environment variable directly without using eval
    export "$var=$dedup_list"

    # Verbose output only when appropriate
    if [ "$quiet" != "yes" ] && [ "$verbose" = "yes" ]; then
      printf "%s\n" "$dedup_list"
    fi

    # Restore IFS to original value
    IFS="$oldIFS"
  }
fi
# )))
