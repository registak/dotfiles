#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# ---------------------------------------------------------------------------
# ANSI color codes
# ---------------------------------------------------------------------------
C_RESET='\033[0m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_CYAN='\033[36m'
C_DIM='\033[2m'

# ---------------------------------------------------------------------------
# Color picker: green < 50%, yellow 50-80%, red > 80%
# ---------------------------------------------------------------------------
pct_color() {
    local pct="$1"
    local int_pct
    int_pct=$(printf '%.0f' "$pct")
    if (( int_pct >= 80 )); then
        echo "$C_RED"
    elif (( int_pct >= 50 )); then
        echo "$C_YELLOW"
    else
        echo "$C_GREEN"
    fi
}

# ---------------------------------------------------------------------------
# Model name: strip "Claude " prefix, keep concise
# ---------------------------------------------------------------------------
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
model_display=""
if [[ -n "$model_name" ]]; then
    model_display="${model_name#Claude }"
    model_display="${model_display%% (*}"
fi

# ---------------------------------------------------------------------------
# Progress bar helper: 7-char bar, returns "filled_chars|empty_chars"
# Usage: make_bar <used_pct_0_to_100>
# ---------------------------------------------------------------------------
make_bar() {
    local pct="$1"
    local total=7
    local filled
    filled=$(printf '%.0f' "$(echo "$pct * $total / 100" | bc -l 2>/dev/null || echo 0)")
    (( filled > total )) && filled=$total
    (( filled < 0 )) && filled=0
    local int_pct
    int_pct=$(printf '%.0f' "$pct")
    (( int_pct > 0 && filled == 0 )) && filled=1
    local f="" e=""
    for (( i=0; i<filled; i++ )); do f="${f}⣿"; done
    for (( i=filled; i<total; i++ )); do e="${e}⣀"; done
    echo "${f}|${e}"
}

# ---------------------------------------------------------------------------
# Current working directory (shorten $HOME to ~)
# ---------------------------------------------------------------------------
cwd=$(echo "$input" | jq -r '.cwd // empty')
cwd_display=""
if [[ -n "$cwd" ]]; then
    cwd_display="${cwd/#$HOME/~}"
fi

# ---------------------------------------------------------------------------
# Session duration
# ---------------------------------------------------------------------------
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
duration_display=""
if [[ -n "$duration_ms" ]]; then
    total_sec=$(( duration_ms / 1000 ))
    if (( total_sec >= 3600 )); then
        d_h=$(( total_sec / 3600 ))
        d_m=$(( (total_sec % 3600) / 60 ))
        duration_display="${d_h}h${d_m}m"
    elif (( total_sec >= 60 )); then
        d_m=$(( total_sec / 60 ))
        d_s=$(( total_sec % 60 ))
        duration_display="${d_m}m${d_s}s"
    else
        duration_display="${total_sec}s"
    fi
fi

# ---------------------------------------------------------------------------
# 5-hour rate limit (with color)
# ---------------------------------------------------------------------------
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
five_display=""
if [[ -n "$five_pct" ]]; then
    five_color=$(pct_color "$five_pct")
    five_raw=$(make_bar "$five_pct")
    five_filled="${five_raw%%|*}"
    five_empty="${five_raw##*|}"
    five_int=$(printf '%.0f' "$five_pct")
    reset_part=""
    if [[ -n "$five_resets" ]]; then
        now=$(date +%s)
        remaining_sec=$(( five_resets - now ))
        if (( remaining_sec > 0 )); then
            rm_h=$(( remaining_sec / 3600 ))
            rm_m=$(( (remaining_sec % 3600) / 60 ))
            reset_part="($(printf '%d:%02d' "$rm_h" "$rm_m"))"
        fi
    fi
    five_display="5h:${five_color}${five_filled}${C_RESET}${C_DIM}${five_empty}${C_RESET} ${five_int}%${reset_part}"
fi

# ---------------------------------------------------------------------------
# 7-day rate limit (with color)
# ---------------------------------------------------------------------------
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_display=""
if [[ -n "$seven_pct" ]]; then
    seven_color=$(pct_color "$seven_pct")
    seven_raw=$(make_bar "$seven_pct")
    seven_filled="${seven_raw%%|*}"
    seven_empty="${seven_raw##*|}"
    seven_int=$(printf '%.0f' "$seven_pct")
    seven_display="7d:${seven_color}${seven_filled}${C_RESET}${C_DIM}${seven_empty}${C_RESET} ${seven_int}%"
fi

# ---------------------------------------------------------------------------
# Context window usage (with color)
# ---------------------------------------------------------------------------
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_display=""
if [[ -n "$ctx_pct" ]]; then
    ctx_color=$(pct_color "$ctx_pct")
    ctx_raw=$(make_bar "$ctx_pct")
    ctx_filled="${ctx_raw%%|*}"
    ctx_empty="${ctx_raw##*|}"
    ctx_int=$(printf '%.0f' "$ctx_pct")
    ctx_display="ctx:${ctx_color}${ctx_filled}${C_RESET}${C_DIM}${ctx_empty}${C_RESET} ${ctx_int}%"
fi

# ---------------------------------------------------------------------------
# Lines added/removed
# ---------------------------------------------------------------------------
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
lines_display=""
if [[ -n "$lines_added" && -n "$lines_removed" ]]; then
    lines_display="${C_GREEN}+${lines_added}${C_RESET}/${C_RED}-${lines_removed}${C_RESET}"
fi

# ---------------------------------------------------------------------------
# Cost (API / Team plan)
# ---------------------------------------------------------------------------
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
cost_display=""
if [[ -n "$cost_usd" ]]; then
    cost_display="\$$(printf '%.2f' "$cost_usd")"
fi

# ---------------------------------------------------------------------------
# Resume command from session_id
# ---------------------------------------------------------------------------
session_id=$(echo "$input" | jq -r '.session_id // empty')
resume_display=""
if [[ -n "$session_id" ]]; then
    resume_display="${C_DIM}claude --resume ${session_id}${C_RESET}"
fi

# ---------------------------------------------------------------------------
# Build status line (4 rows)
# Row 1: model | ctx | cost
# Row 2: 5h | 7d
# Row 3: cwd | duration | lines
# Row 4: resume
# ---------------------------------------------------------------------------
join_parts() {
    local sep=" | "
    local result=""
    for part in "$@"; do
        [[ -n "$result" ]] && result="${result}${sep}"
        result="${result}${part}"
    done
    echo "$result"
}

row1_parts=()
[[ -n "$model_display" ]] && row1_parts+=("$model_display")
[[ -n "$ctx_display" ]]   && row1_parts+=("$ctx_display")
[[ -n "$cost_display" ]]  && row1_parts+=("$cost_display")

row2_parts=()
[[ -n "$five_display" ]]  && row2_parts+=("$five_display")
[[ -n "$seven_display" ]] && row2_parts+=("$seven_display")

row3_parts=()
[[ -n "$cwd_display" ]]      && row3_parts+=("${C_CYAN}${cwd_display}${C_RESET}")
[[ -n "$duration_display" ]] && row3_parts+=("${C_DIM}${duration_display}${C_RESET}")
[[ -n "$lines_display" ]]    && row3_parts+=("$lines_display")

row1=$(join_parts "${row1_parts[@]}")
row2=$(join_parts "${row2_parts[@]}")
row3=$(join_parts "${row3_parts[@]}")

[[ -n "$row1" ]] && echo -e "$row1"
[[ -n "$row2" ]] && echo -e "$row2"
[[ -n "$row3" ]] && echo -e "$row3"
[[ -n "$resume_display" ]] && echo -e "$resume_display"
