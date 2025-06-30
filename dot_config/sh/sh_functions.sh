# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:
# shellcheck shell=sh
# shellcheck disable=SC1091

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

# # ((( _path_prepend() & _path_append() idempotent functions (with example usage)
# # https://superuser.com/questions/39751/add-directory-to-path-if-its-not-already-there
# # - Is a generalized approach that works with any PATH variable.
# # - POSIX compliant
# # - Doesn't use Bash's declare -n
#
# # ((( Define _path_prepend()
# _path_prepend() {
#     if [ "$2" != "" ]; then
#         case ":$(eval "echo \$$1"):" in
#         *":$2:"*) : ;;
#         *) eval "export $1=$2$(eval "echo \${$1:+\":\$$1\"}")" ;;
#             # *) eval "export $1=$2:$(eval "echo \$$1")" ;;
#         esac
#     else
#         case ":$PATH:" in
#         *":$1:"*) : ;;
#         *) export PATH="$1${PATH:+":$PATH"}" ;;
#             # *) export PATH="$1:$PATH" ;;
#         esac
#     fi
# }
# # ))) Define _path_prepend()
#
# # ((( Define _path_append()
# _path_append() {
#     if [ "$2" != "" ]; then
#         case ":$(eval "echo \$$1"):" in
#         *":$2:"*) : ;;
#         *) eval "export $1=$(eval "echo \${$1:+\"\$$1:\"}")$2" ;;
#             # *) eval "export $1=$(eval "echo \$$1"):$2" ;;
#         esac
#     else
#         case ":$PATH:" in
#         *":$1:"*) : ;;
#         *) export PATH="${PATH:+"$PATH:"}$1" ;;
#             # *) export PATH="$PATH:$1" ;;
#         esac
#     fi
# }
# # ))) Define _path_append()
#
# # ((( Example usage of _path_prepend() and _path_append()
# # Usage
# # -------
# # ➤ alfa=
# # ➤ _path_prepend alfa one; echo "$alfa"
# # one
# # ➤ _path_prepend alfa two; echo "$alfa"
# # two:one
# # ➤ _path_prepend alfa three; echo "$alfa"
# # three:two:one
# #
# # ➤ bravo=
# # ➤ _path_append bravo one; echo "$bravo"
# # one
# # ➤ _path_append bravo two; echo "$bravo"
# # one:two
# # ➤ _path_append bravo three; echo "$bravo"
# # one:two:three
# # ))) Example Usage of _path_prepend() and _path_append()
#
# # ))) Define idempotent _path_prepend() & _path_append() functions (with example usage)
