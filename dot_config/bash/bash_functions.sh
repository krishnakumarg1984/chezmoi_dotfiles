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

# Lazy-load SSH hosts completion using only Bash builtins (((
__lazy_ssh_completion() {
    local hosts=() line file

    # Main ssh config
    file="$HOME/.ssh/config"
    if [[ -f "$file" ]]; then
        while IFS= read -r line; do
            [[ $line == Host[[:space:]]* ]] || continue
            # Extract words after 'Host' (ignore '?' and '*')
            for host in ${line#Host }; do
                [[ $host == *[\?\*]* ]] && continue
                hosts+=("$host")
            done
        done <"$file"
    fi

    # Modular ssh configs
    if [[ -d "$HOME/.ssh/config/modular_ssh_configs" ]]; then
        for file in "$HOME/.ssh/config/modular_ssh_configs"/*; do
            [[ -f "$file" ]] || continue
            while IFS= read -r line; do
                [[ $line == Host[[:space:]]* ]] || continue
                for host in ${line#Host }; do
                    [[ $host == *[\?\*]* ]] && continue
                    hosts+=("$host")
                done
            done <"$file"
        done
    fi

    # Register completion
    complete -o default -o nospace -W "${hosts[*]}" ssh scp sftp ssh-copy-id
    unset -f __lazy_ssh_completion
}

# Lazy-load on first TAB
for cmd in ssh scp sftp ssh-copy-id; do
    complete -F __lazy_ssh_completion "$cmd"
done
# )))

