# vim: ft=sh:foldmarker=(((,))):fdm=marker:foldlevel=0:tw=145:syntax=sh:
# shellcheck shell=sh
# shellcheck disable=SC1091

# Environment manager (((
if ! command -v "update_env_var" > /dev/null 2>&1; then

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
fi

# )))
