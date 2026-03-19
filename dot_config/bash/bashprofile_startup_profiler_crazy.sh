# # ================================================================
# # Bash Startup Profiler - All-in-One
# # ================================================================
# # Features:
# # 1. Live per-command profiling with delta bars (▓)
# # 2. Cumulative overlay (░) behind delta bars
# # 3. Heatmap for top-N slowest functions (bright red)
# # 4. Stacked indentation to indicate call depth
# # 5. Terminal-width scaled bars
# # 6. CSV logs: functions + top-N slowest lines
# # 7. Auto-disable trap at first interactive prompt
# # 8. Works with high-resolution Bash ≥5 timing
# # ================================================================
#
# __STARTUP_PROFILER_DONE="${__STARTUP_PROFILER_DONE:-0}"
# if [ "$__STARTUP_PROFILER_DONE" -eq 0 ] && [ -n "${BASH_VERSION:-}" ]; then
#   __STARTUP_PROFILER_DONE=1
#
#   # ----------------------------
#   # Log setup
#   # ----------------------------
#   LOG_DIR="$HOME/.local/state/bash"
#   mkdir -p "$LOG_DIR"
#   STARTUP_PROFILE_LOG="$LOG_DIR/bash_startup_profile.log"
#   FUNCTION_CSV="$LOG_DIR/bash_startup_functions.csv"
#   TOPLINES_CSV="$LOG_DIR/bash_startup_top_lines.csv"
#   TOPN=10
#
#   # Clear previous logs safely
#   : >| "$STARTUP_PROFILE_LOG"
#   : >| "$FUNCTION_CSV"
#   : >| "$TOPLINES_CSV"
#
#   # ----------------------------
#   # Terminal width for dynamic bars
#   # ----------------------------
#   TERM_WIDTH=$(tput cols 2>/dev/null)
#   [ -z "$TERM_WIDTH" ] && TERM_WIDTH=80
#
#   # ----------------------------
#   # High-resolution timing (Bash ≥5)
#   # ----------------------------
#   if [ "${BASH_VERSINFO:-0}" -ge 5 ] && [ -n "${EPOCHREALTIME:-}" ]; then
#     __USE_HIGHRES=1
#     __START_US=${EPOCHREALTIME/./}
#     __LAST_US=$__START_US
#     __MAX_DELTA=1
#     __MAX_CUMULATIVE=1
#   else
#     __USE_HIGHRES=0
#     echo "⚠ Bash <5 detected. High-resolution timing unavailable." >&2
#   fi
#
#   # ----------------------------
#   # Colors
#   # ----------------------------
#   if [ -t 1 ]; then
#     COLOR_RESET="\e[0m"; COLOR_GREEN="\e[1;32m"; COLOR_YELLOW="\e[1;33m"
#     COLOR_RED="\e[1;31m"; COLOR_CYAN="\e[1;36m"; COLOR_DIM="\e[2m"
#   else
#     COLOR_RESET=""; COLOR_GREEN=""; COLOR_YELLOW=""; COLOR_RED=""; COLOR_CYAN=""; COLOR_DIM=""
#   fi
#
#   # ----------------------------
#   # Thresholds and depth
#   # ----------------------------
#   FAST_THRESHOLD=10
#   MEDIUM_THRESHOLD=50
#   MAX_DEPTH=20
#   declare -a __FLAME_DEPTH_TIME
#   declare -a __FLAME_LINES
#   declare -a __FLAME_CUMULATIVE_LINES
#
#   _STARTUP_COMPLETE=0
#
#   # ================================================================
#   # Debug trap: logs each command during startup
#   # ================================================================
#   __profiler_debug_trap() {
#     [ "$_STARTUP_COMPLETE" -eq 1 ] && return
#
#     # Auto-disable at first interactive prompt
#     if [[ $- == *i* && -n "$PS1" ]]; then
#       _STARTUP_COMPLETE=1
#       __disable_startup_profiler
#       return
#     fi
#
#     # High-resolution timing
#     if [ "$__USE_HIGHRES" -eq 1 ]; then
#       now=${EPOCHREALTIME/./}
#       delta=$((now - __LAST_US))
#       __LAST_US=$now
#       cumulative=$((now - __START_US))
#       [ "$delta" -gt "$__MAX_DELTA" ] && __MAX_DELTA=$delta
#       [ "$cumulative" -gt "$__MAX_CUMULATIVE" ] && __MAX_CUMULATIVE=$cumulative
#     else
#       delta=0; cumulative=0; __MAX_DELTA=1; __MAX_CUMULATIVE=1
#     fi
#
#     # Call depth
#     depth=$(( ${#FUNCNAME[@]} - 1 )); [ "$depth" -gt $MAX_DEPTH ] && depth=$MAX_DEPTH
#     __FLAME_DEPTH_TIME[$depth]=$(( ${__FLAME_DEPTH_TIME[$depth]:-0} + delta ))
#     indent=""; for ((i=1;i<depth;i++)); do indent="$indent│ "; done
#
#     # Color by delta time
#     ms=$((delta / 1000))
#     if [ "$ms" -le $FAST_THRESHOLD ]; then COLOR_SPEED="$COLOR_GREEN"
#     elif [ "$ms" -le $MEDIUM_THRESHOLD ]; then COLOR_SPEED="$COLOR_YELLOW"
#     else COLOR_SPEED="$COLOR_RED"; fi
#     COLOR_SOURCE=""; [ "${BASH_SOURCE[0]}" != "$0" ] && COLOR_SOURCE="$COLOR_CYAN"
#     COLOR="${COLOR_SOURCE}${COLOR_SPEED}"
#
#     func=${FUNCNAME[0]:-main}; file=${BASH_SOURCE##*/}; line=${LINENO}
#     timestamp=$(date +"%H:%M:%S")
#
#     # Bars scaling
#     usable_width=$((TERM_WIDTH - depth*2 - 30))
#     [ $usable_width -lt 10 ] && usable_width=10
#     delta_bar_len=$(( delta * usable_width / (__MAX_DELTA) )); [ $delta_bar_len -lt 1 ] && delta_bar_len=1
#     cumulative_bar_len=$(( cumulative * usable_width / (__MAX_CUMULATIVE) )); [ $cumulative_bar_len -lt 1 ] && cumulative_bar_len=1
#
#     delta_bar=""; cumulative_bar=""
#     for ((i=0;i<delta_bar_len;i++)); do delta_bar="${delta_bar}▓"; done
#     for ((i=0;i<cumulative_bar_len;i++)); do cumulative_bar="${cumulative_bar}░"; done
#
#     # Print live bar
#     printf "%s%s%s()${COLOR_RESET} Δ%4dms | CUM%6dms [%s:%s] @ %s %s%s\n" \
#       "$indent" "$COLOR" "$func" "$ms" "$((cumulative/1000))" "$file" "$line" "$timestamp" "$delta_bar" "$cumulative_bar" >&2
#
#     # Save logs & flame graph arrays
#     echo "$file:$line,$func,$delta,$cumulative,$timestamp" >> "$STARTUP_PROFILE_LOG"
#     __FLAME_LINES[$depth]+="${delta_bar}"
#     __FLAME_CUMULATIVE_LINES[$depth]+="${cumulative_bar}"
#   }
#
#   trap '__profiler_debug_trap' DEBUG
#   set -x
#
#   # ================================================================
#   # Disable profiler after startup & generate graphs/logs
#   # ================================================================
#   __disable_startup_profiler() {
#     set +x
#     trap - DEBUG
#     echo -e "\n=== Bash Startup Profiling Complete ==="
#
#     # CSV generation
#     if [ "$__USE_HIGHRES" -eq 1 ]; then
#       awk -F',' '{ count[$2]++; total[$2]+=$3 } END { print "Function,Calls,Total(s)"; for(f in total) printf "%s,%d,%.6f\n", f,count[f],total[f]/1000000 }' \
#         "$STARTUP_PROFILE_LOG" | sort -t, -k3 -nr > "$FUNCTION_CSV"
#
#       awk -F',' '{ total[$1]+=$3 } END { print "FileLine,Total(s)"; for(k in total) printf "%s,%.6f\n", k,total[k]/1000000 }' \
#         "$STARTUP_PROFILE_LOG" | sort -t, -k2 -nr | head -n "$TOPN" > "$TOPLINES_CSV"
#
#       echo "CSV saved to: $FUNCTION_CSV, $TOPLINES_CSV"
#     fi
#
#     # Top-N slowest
#     __SLOW_FUNCS=()
#     while IFS=, read -r func calls total; do
#       __SLOW_FUNCS+=("$func")
#     done < <(head -n "$TOPN" "$FUNCTION_CSV")
#
#     # ASCII Flame Graph with cumulative overlay & heatmap
#     echo -e "\nASCII Flame Graph with Cumulative Overlay (Top $TOPN functions red):"
#     for depth in "${!__FLAME_LINES[@]}"; do
#       indent=""; for ((i=1;i<depth;i++)); do indent="$indent│ "; done
#       delta_line="${__FLAME_LINES[$depth]}"
#       cum_line="${__FLAME_CUMULATIVE_LINES[$depth]}"
#       combined_line=""
#
#       for ((i=0;i<${#cum_line};i++)); do
#         char_delta="${delta_line:i:1}"
#         char_cum="${cum_line:i:1}"
#         if [ "$char_delta" = "▓" ]; then
#           combined_line+="$char_delta"
#         elif [ "$char_cum" = "░" ]; then
#           combined_line+="${COLOR_DIM}░${COLOR_RESET}"
#         else
#           combined_line+=" "
#         fi
#       done
#
#       for slow_func in "${__SLOW_FUNCS[@]}"; do
#         combined_line="${combined_line//▓/$(printf "\e[1;31m▓\e[0m")}"
#       done
#
#       echo -e "${indent}${combined_line}"
#     done
#
#     # Cumulative time per depth
#     echo -e "\n=== Cumulative Time per Depth ==="
#     for depth in "${!__FLAME_DEPTH_TIME[@]}"; do
#       ms=$((__FLAME_DEPTH_TIME[$depth]/1000))
#       echo "Depth $depth : $ms ms"
#     done
#   }
# fi
#
# # ================================================================
# # ASCII Legend for Reference
# # ================================================================
# # │ = call depth
# # ▓ = delta time (color-coded)
# # ░ = faint cumulative overlay
# # Bright red ▓ = top-N slowest
# # Example:
# # ▓▓▓▓▓ main() Δ120ms | CUM420ms
# # │ ▓▓▓▓▓ sourced_func() Δ85ms | CUM300ms
# # │ │ ▓▓▓▓▓ nested_func() Δ40ms | CUM180ms
# # │ │ ░░░░░ helper() Δ5ms | CUM60ms
# # │ ▓▓▓▓▓▓ another_func() Δ70ms | CUM250ms
# # ▓▓▓▓▓ finalization() Δ20ms | CUM420ms
# # ================================================================
#
# # ================================================================
# # Live Example Output (Startup)
# # ================================================================
# # ▓▓▓▓▓▓ main() Δ120ms | CUM420ms
# # │ ▓▓▓▓▓▓ sourced_func() Δ85ms | CUM300ms
# # │ │ ▓▓▓▓▓ nested_func() Δ40ms | CUM180ms
# # │ │ ░░░░░ helper() Δ5ms | CUM60ms
# # │ ▓▓▓▓▓▓ another_func() Δ70ms | CUM250ms
# # ▓▓▓▓▓ finalization() Δ20ms | CUM420ms
# # Bright red bars indicate top-N slowest functions.
# # Bars are scaled dynamically, dim bars are cumulative overlays.
# # Output auto-disables at first interactive prompt.
# # ================================================================
