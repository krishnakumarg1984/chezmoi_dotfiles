# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:expandtab
# shellcheck shell=bash
# shellcheck disable=SC1091

# dedup() and pushd() (((
dedup() {
  declare -a new=() copy=("${DIRSTACK[@]:1}")
  declare -A seen
  local v i
  seen[$PWD]=1
  for v in "${copy[@]}"; do
    if [ "${seen[$v]}" = "" ]; then
      new+=("$v")
      seen[$v]=1
    fi
  done
  dirs -c
  for ((i = ${#new[@]} - 1; i >= 0; i--)); do
    builtin pushd -n "${new[i]}" >/dev/null
  done
}

pushd() {
  builtin pushd "$@" >/dev/null
  dedup
}
# )))

# mkcd() (((
# https://unix.stackexchange.com/a/9124
mkcd() {
  case "$1" in
  */.. | */../) cd -- "$1" ;; # that doesn't make any sense unless the directory already exists
  /*/../*) (cd "${1%/../*}/.." && mkdir -p "./${1##*/../}") && cd -- "$1" ;;
  /*) mkdir -p "$1" && cd "$1" ;;
  */../*) (cd "./${1%/../*}/.." && mkdir -p "./${1##*/../}") && cd "./$1" ;;
  ../*) (cd .. && mkdir -p "${1#.}") && cd "$1" ;;
  *) mkdir -p "./$1" && cd "./$1" ;;
  esac
}

# mkcd() {
#     mkdir -p -v -- "$@" && cd -P -- "$_" || exit
#     # The '--' makes sure you’re not accidentally passing an extra argument to the command. For example, if you try to create a directory that starts with - (dash) without using -- the directory name will be interpreted as a command argument.
# }
# )))

# ccd() for changing into chezmoi's data directory (((
if [ -x "$(command -v chezmoi)" ]; then
  ccd() {
    cd "$(chezmoi source-path)" || return
  }
fi
# )))

# goup() function to navigate upwards in the filesystem by n directories (((
# https://unix.stackexchange.com/a/13101
# (c) 2007 stefan w. GPLv3
function goup {
  ups=""
  for i in "$(seq 1 "$1")"; do
    ups=$ups"../"
  done
  cd "$ups"
}
# )))

# commented-out functions (((

# # custom tab completions (((

# # https://unix.stackexchange.com/a/6823
# if type complete >/dev/null 2>&1; then
#   if complete -o >/dev/null 2>&1; then
#     COMPDEF="-o complete"
#   else
#     COMPDEF="-o default"
#   fi
#   complete -a alias unalias
#   complete -d cd pushd popd pd po
#   complete "$COMPDEF" -g chgrp 2>/dev/null
#   complete "$COMPDEF" -u chown
#   complete -j fg
#   complete -j kill
#   complete "$COMPDEF" -c command
#   complete "$COMPDEF" -c exec
#   complete "$COMPDEF" -c man
#   complete -e printenv
#   complete -G "*.java" javac
#   complete -F complete_runner -o nospace -o default nohup 2>/dev/null
#   complete -F complete_runner -o nospace -o default sudo 2>/dev/null
#   complete -F complete_services service
#   # completion function for commands such as sudo that take a
#   # command as the first argument but should complete the second
#   # argument as if it was the first
#   complete_runner() {
#     # completing the command name
#     # $1 = sudo
#     # $3 = sudo
#     # $2 = partial command (or complete command but no space was typed)
#     if test "$1" = "$3"; then
#       set -- "$(compgen -c "$2")"
#     # completing other arguments
#     else
#       # $1 = sudo
#       # $3 = command after sudo (i.e. second word)
#       # $2 = arguments to command
#       # use the custom completion as printed by complete -p,
#       # fall back to filename/bashdefault
#       local comps
#       comps=$(complete -p "$3" 2>/dev/null)
#       # "complete -o default -c man" => "-o default -c"
#       # "" => "-o bashdefault -f"
#       comps=${comps#complete }
#       comps=${comps% *}
#       comps=${comps:--o bashdefault -f}
#       set -- "$(compgen "$comps" "$2")"
#     fi
#     COMPREPLY=("$@")
#   }
#
#   # completion function for Red Hat service command
#   complete_services() {
#     OIFS="$IFS"
#     IFS='
#         '
#     local i=0
#     for file in "$(find /etc/init.d/ -type f -name "$2*" -perm -u+rx)"; do
#       file=${file##*/}
#       COMPREPLY[$i]=$file
#       i=$(($i + 1))
#     done
#     IFS="$OIFS"
#   }
# fi
# # )))

# # mise completions (((
# _mise() {
#   if ! command -v usage &>/dev/null; then
#     echo "Error: usage not found. This is required for completions to work in mise." >&2
#     return 1
#   fi
#
#   if [[ -z ${_USAGE_SPEC_MISE:-} ]]; then
#     _USAGE_SPEC_MISE="$(mise usage)"
#   fi
#
#   COMPREPLY=("$(usage complete-word -s "$_USAGE_SPEC_MISE" --cword="$COMP_CWORD" -- "${COMP_WORDS[@]}")")
#   if [[ $? -ne 0 ]]; then
#     unset COMPREPLY
#   fi
#   return 0
# }
#
# shopt -u hostcomplete && complete -o nospace -o bashdefault -o nosort -F _mise mise
# # )))

# https://wiki.archlinux.org/title/Bash
# run-help() { help "$READLINE_LINE" 2>/dev/null || man "$READLINE_LINE"; }
# bind -m vi-insert -x '"\eh": run-help'
# bind -m emacs -x     '"\eh": run-help'

# # https://unix.stackexchange.com/a/683602
# function cd() { # (((
#     if [[ -f ./.reframe_completion ]] ; then
#         sed -e 's/^/un/;s/=.*$//' ./.reframe_completion >/tmp/myaliases.$$ 2>/dev/null
#         source /tmp/reframe_completion.$$ 2>/dev/null
#         rm -f /tmp/reframe_completion.$$
#     fi
#
#     builtin cd "$*"
#
#     if [[ -f ./.reframe_completion ]]; then
#         source ./.reframe_completion 2>/dev/null
#     fi
# } # )))

# https://wiki.archlinux.org/title/Bash/Functions (((
# To set trap to intercept a non-zero return code of the last program run:
# EC() {
#   echo -e '\e[1;33m'code $?'\e[m\n'
# }
# trap EC ERR
# )))

# Compile and execute a C source on the fly (((
# csource() {
#     [[ $1 ]]    || { echo "Missing operand" >&2; return 1; }
#     [[ -r $1 ]] || { printf "File %s does not exist or is not readable\n" "$1" >&2; return 1; }
#     local output_path=${TMPDIR:-/tmp}/${1##*/};
#     gcc "$1" -o "$output_path" && "$output_path";
#     rm "$output_path";
#     return 0;
# }
# )))

# https://superuser.com/a/1516712 (((
# Truncate input(s) to the current terminal width
# Usage: trunc [-r] [FILE...]
# trunc() {
#   local B='^' A=
#   if [ -z "$COLUMNS" ]; then COLUMNS="$(tput cols)"; fi
#   if [ "$1" = '-r' ]; then shift; B= A='$'; fi
#   expand "$@" |GREP_COLORS=ms= egrep -o "$B.{0,$COLUMNS}$A"
# }
# )))

# https://gist.github.com/cinatic/5e54a87a1bef019fe1848e00c2bf86f1 (((
# watch1 () {
#   firstArg=$1
#   shift;
#   rest=$@
#
#   resolvedCmd=$(alias $firstArg 2>/dev/null | cut -d\' -f2)
#
#   if [ -z "$resolvedCmd" ]; then
#         resolvedCmd=$firstArg
#   fi
#
#   watch -n 1 "$resolvedCmd $rest"
# }
# )))

# https://gist.github.com/ablacklama/550420c597f9599cf804d57dd6aad131 (((
# swatch_usage() {
#     cat <<EOF >&2
# NAME
#        swatch - execute a program periodically with "watch". Supports aliases.
# SYNOPSIS
#        swatch [options] command
# OPTIONS
#        -n, --interval seconds (default: 1)
#               Specify update interval.  The command will not allow quicker than
#               0.1 second interval.
# EOF
# }
#
# swatch() {
#     if [ $# -eq 0 ]; then
#         swatch_usage
#         return 1
#     fi
#     seconds=1
#
#     case "$1" in
#     -n)
#         seconds="$2"
#         args=${*:3}
#         ;;
#     -h)
#         swatch_usage
#         return 1
#         ;;
#     *)
#         seconds=1
#         args=${*:1}
#         ;;
#
#     esac
#
#     watch --color -n "$seconds" --exec bash -ic "$args || true"
# }
# )))

# # This function is used to create a directory and then immediately cd into it (((
# # using pre-existing libraries to ensure robust application
# # https://raw.githubusercontent.com/CraigOpie/shellScripts/refs/heads/master/bash_scripts/mcdir.sh
#
# function mcdir() {
#   if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]
#     then
#       echo "Usage: mcdir [-m MODE] [-p] DIRECTORY"
#       echo "Create a directory and change into it."
#       echo
#       echo "Options:"
#       echo "   -m, --mode MODE     Sets the access mode for the new directory. Default is 755."
#       echo "   -p, --path          Create all directories in path."
#       echo "   -h, --help          Shows this helpful information."
#       echo
#       echo "Examples:"
#       echo "   mcdir -m 777 new_dir"
#       echo "   mcdir -p new_dir/sub_dir"
#       return 0
#   fi
#
#   # set default variables
#   local accessMode=755
#   local makePath=false
#   local directory
#
#   while (( "$#" )); do
#     case "$1" in
#       -m|--mode)
#         if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
#           accessMode=$2
#           shift 2
#         else
#           echo "Error: Argument for $1 is missing" >&2
#           exit 1
#         fi
#         ;;
#       -p|--path)
#         makePath=true
#         shift
#         ;;
#       -*|--*=)
#         echo "Error: Unsupported flag $1" >&2
#         exit 1
#         ;;
#       *)
#         directory=$1
#         shift
#         ;;
#     esac
#   done
#
#   # execute function based on arguments provided
#   local mkdirCommand="mkdir -m $accessMode"
#
#   if [ "$makePath" = true ]; then
#     mkdirCommand+=" -p"
#   fi
#
#   $mkdirCommand "$directory"
#   if [ $? -ne 0 ]; then
#     echo "There was a problem creating your directory."
#     return 1
#   fi
#
#   cd "$directory"
#   if [ $? -ne 0 ]; then
#     echo "Unable to change into that directory."
#     return 1
#   fi
#
#   return 0
# }
# export -f mcdir
# )))

# # custom _exit() function (aliases to 'x') to prevent closing the shell when jobs are running (((
# alias _x='_exit'
#
# # prevent running "exit" if the user is still running jobs in the background
# # the user is expected to close the jobs or disown them
# _exit() {
#   case $- in *m*)
#     # this way works in bash and zsh
#     jobs | wc -l | grep -q '^ *0 *$'
#     if test $? -eq 0; then
#       command exit "$@"
#     else
#       jobs
#     fi
#     ;;
#   *)
#     command exit "$@"
#     ;;
#   esac
# }
# # )))
# )))

# pacman/paru helper functions (((
# https://unix.stackexchange.com/a/736682
if [ -x "$(command -v paru)" ]; then
  pmig() {
    paru -Q | grep "$1" | cut -d ' ' -f 1
  }

  pmrg() {
    paru -Ssq | grep "$1"
  }

  pmnig() {
    local installed="|$(pmig "$1" | tr '\n' '|')"
    pmrg "$1" | grep -E -v \'"$installed"\'
  }

  pmnigv() {
    paru -Ss "$1" | grep -v "$(paru -Ss "$1" | grep "\[installed\]" -A1)" | grep -v "\[installed\]"
  }

fi
# )))
