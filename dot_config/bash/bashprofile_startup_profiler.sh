# ================================================================
# Bash Startup Profiler - Scrollable ASCII Flamegraph
# ================================================================

__STARTUP_PROFILER_DONE="${__STARTUP_PROFILER_DONE:-0}"
if [ "$__STARTUP_PROFILER_DONE" -eq 0 ] && [ -n "${BASH_VERSION:-}" ]; then
  __STARTUP_PROFILER_DONE=1
  [ -n "$DISABLE_BASH_PROFILER" ] && return

  LOG_DIR="$HOME/.local/state/bash"
  mkdir -p "$LOG_DIR"
  STARTUP_PROFILE_LOG="$LOG_DIR/bash_startup_profile.log"
  FUNCTION_CSV="$LOG_DIR/bash_startup_functions.csv"
  TOPLINES_CSV="$LOG_DIR/bash_startup_top_lines.csv"
  : >| "$STARTUP_PROFILE_LOG"
  : >| "$FUNCTION_CSV"
  : >| "$TOPLINES_CSV"
  TOPN=10

  if [ "${BASH_VERSINFO:-0}" -ge 5 ] && [ -n "${EPOCHREALTIME:-}" ]; then
    __START_US=${EPOCHREALTIME/./}
    __LAST_US=$__START_US
    __MAX_DELTA=1
    __GLOBAL_MAX_CUMULATIVE=1
    __USE_HIGHRES=1
  else
    __USE_HIGHRES=0
  fi

  if [ -t 1 ]; then
    COLOR_RESET="\033[0m"
    COLOR_GREEN="\033[1;32m"
    COLOR_YELLOW="\033[1;33m"
    COLOR_RED="\033[1;31m"
    COLOR_DIM="\033[2m"
  else
    COLOR_RESET=""; COLOR_GREEN=""; COLOR_YELLOW=""; COLOR_RED=""; COLOR_DIM=""
  fi

  MAX_DEPTH=20
  declare -a __TL_START __TL_END __TL_FUNC __TL_DEPTH __TL_DELTA
  __TL_INDEX=0
  __LINE_COUNT=0
  MAX_LINES=5000

  __spark_char() {
    local r=$1
    if   (( r < 10 )); then echo "."
    elif (( r < 25 )); then echo ":"
    elif (( r < 40 )); then echo "-"
    elif (( r < 55 )); then echo "="
    elif (( r < 70 )); then echo "+"
    elif (( r < 85 )); then echo "*"
    elif (( r < 95 )); then echo "#"
    else echo "%"
    fi
  }

  __heat_color() {
    local ratio=$1
    if (( ratio < 33 )); then echo -n "$COLOR_GREEN"
    elif (( ratio < 66 )); then echo -n "$COLOR_YELLOW"
    else echo -n "$COLOR_RED"
    fi
  }

  __heat_bar() {
    local len=$1 start_ratio=$2 end_ratio=$3 delta=$4 max_delta=$5
    local bar=""
    for ((i=0;i<len;i++)); do
      local ratio=$(( start_ratio + (i*(end_ratio-start_ratio)/len) ))
      micro_ratio=$(( delta * 100 / max_delta ))
      micro_char=$(__spark_char $micro_ratio)
      bar+="$(__heat_color $ratio)$micro_char$COLOR_RESET"
    done
    echo "$bar"
  }

  __profiler_debug_trap() {
    case "${FUNCNAME[1]}" in __bp_*|preexec*|precmd*) return ;; esac
    (( __LINE_COUNT++ )); (( __LINE_COUNT > MAX_LINES )) && return

    if [ "$__USE_HIGHRES" -eq 1 ]; then
      now=${EPOCHREALTIME/./}
      delta=$((now - __LAST_US))
      __LAST_US=$now
      cumulative=$((now - __START_US))
      (( delta > __MAX_DELTA )) && __MAX_DELTA=$delta
      (( cumulative > __GLOBAL_MAX_CUMULATIVE )) && __GLOBAL_MAX_CUMULATIVE=$cumulative
    else
      delta=1
      cumulative=$((__TL_INDEX+1))
    fi

    func=${FUNCNAME[1]:-main}
    file=${BASH_SOURCE[1]##*/}
    line=${BASH_LINENO[0]}

    __TL_START[$__TL_INDEX]=$(( cumulative - delta ))
    __TL_END[$__TL_INDEX]=$cumulative
    __TL_FUNC[$__TL_INDEX]=$func
    __TL_DEPTH[$__TL_INDEX]=$(( ${#FUNCNAME[@]} - 2 ))
    __TL_DELTA[$__TL_INDEX]=$delta
    (( __TL_INDEX++ ))

    echo "$file:$line,$func,$delta,$cumulative" >> "$STARTUP_PROFILE_LOG"
  }

  trap '__profiler_debug_trap' DEBUG

  __disable_startup_profiler() {
    trap - DEBUG
    echo -e "\n=== Bash Startup Profiling Complete ==="
    [ ! -s "$STARTUP_PROFILE_LOG" ] && { echo "No data collected."; return; }

    # CSV logs
    awk -F',' '{ c[$2]++; t[$2]+=$3 } END { print "Function,Calls,Total(s)"; for(f in t) printf "%s,%d,%.6f\n", f,c[f],t[f]/1000000 }' \
      "$STARTUP_PROFILE_LOG" | sort -t, -k3 -nr >| "$FUNCTION_CSV"
    awk -F',' '{ t[$1]+=$3 } END { print "FileLine,Total(s)"; for(k in t) printf "%s,%.6f\n", k,t[k]/1000000 }' \
      "$STARTUP_PROFILE_LOG" | sort -t, -k2 -nr | head -n "$TOPN" >| "$TOPLINES_CSV"

    # Scrollable view
    TERM_WIDTH=${COLUMNS:-80}; (( TERM_WIDTH < 60 )) && TERM_WIDTH=60
    TOTAL=$__GLOBAL_MAX_CUMULATIVE; (( TOTAL == 0 )) && TOTAL=1
    WINDOW_START=0
    WINDOW_WIDTH=$TERM_WIDTH

    declare -A DEPTH_LINES
    for ((i=0;i<__TL_INDEX;i++)); do
      f=${__TL_FUNC[$i]}; d=${__TL_DEPTH[$i]}; s=${__TL_START[$i]}; e=${__TL_END[$i]}; delta=${__TL_DELTA[$i]}
      sc=$(( s * TOTAL / TOTAL )); ec=$(( e * TOTAL / TOTAL ))
      sc=$(( s * TOTAL / TOTAL )); ec=$(( e * TOTAL / TOTAL )); (( ec <= sc )) && ec=$(( sc + 1 ))
      start_ratio=$(( s * 100 / TOTAL )); end_ratio=$(( e * 100 / TOTAL ))

      # Determine visible window
      win_sc=$(( sc - WINDOW_START ))
      win_ec=$(( ec - WINDOW_START ))
      [ $win_ec -le 0 ] && continue
      [ $win_sc -lt 0 ] && win_sc=0
      [ $win_ec -gt $WINDOW_WIDTH ] && win_ec=$WINDOW_WIDTH

      line="${DEPTH_LINES[$d]:-}"
      while ((${#line} < $WINDOW_WIDTH)); do line+=" "; done
      heat=$(__heat_bar $((win_ec-win_sc)) $start_ratio $end_ratio $delta $__MAX_DELTA)
      line="${line:0:win_sc}$heat${line:win_ec}"
      DEPTH_LINES[$d]="$line"
    done

    echo -e "\n=== Scrollable ASCII Flamegraph Timeline (Heat + Sparkline) ==="
    for d in $(seq 0 $MAX_DEPTH); do
      [ -n "${DEPTH_LINES[$d]}" ] && printf "%-${d}s│%s\n" "" "${DEPTH_LINES[$d]}"
    done

    echo -e "\nTop slow functions:"
    head -n 6 "$FUNCTION_CSV"
  }

  PROMPT_COMMAND="__disable_startup_profiler; $PROMPT_COMMAND"
fi
