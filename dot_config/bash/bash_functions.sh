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

# )))

# ccd() for changing into chezmoi's data directory (((
if [ -x "$(command -v chezmoi)" ]; then
  ccd() {
    cd "$(chezmoi source-path)" || return
  }
fi
# )))
