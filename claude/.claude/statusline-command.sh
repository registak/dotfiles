#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# ---------------------------------------------------------------------------
# ANSI color codes (catppuccin mocha palette to match Starship theme)
# ---------------------------------------------------------------------------
C_RESET='\033[0m'
C_DIM='\033[2m'
# catppuccin mocha: green=#a6e3a1, yellow=#f9e2af, red=#f38ba8
# peach=#fab387, blue=#89b4fa, lavender=#b4befe, mauve=#cba6f7, teal=#94e2d5
C_GREEN='\033[38;2;166;227;161m'    # green
C_YELLOW='\033[38;2;249;226;175m'   # yellow
C_RED='\033[38;2;243;139;168m'      # red
C_PEACH='\033[38;2;250;179;135m'    # peach (directory / cwd)
C_BLUE='\033[38;2;137;180;250m'     # blue (git branch)
C_MAUVE='\033[38;2;203;166;247m'    # mauve (git status)
C_LAVENDER='\033[38;2;180;190;254m' # lavender (model)
C_TEAL='\033[38;2;148;226;213m'     # teal (accents)

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
    short="${model_name#Claude }"
    short="${short%% (*}"
    model_icon=$(printf '\xef\x83\xa7')
    model_display="${C_LAVENDER}${model_icon} ${short}${C_RESET}"
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
    cwd_icon=$(printf '\xef\x81\xbb')
    cwd_display="${C_PEACH}${cwd_icon} ${cwd/#$HOME/~}${C_RESET}"
fi

# ---------------------------------------------------------------------------
# Git branch (worktree branch or current branch from cwd)
# ---------------------------------------------------------------------------
git_branch=$(echo "$input" | jq -r '.worktree.branch // empty')
if [[ -z "$git_branch" && -n "$cwd" ]]; then
    git_branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi
branch_display=""
if [[ -n "$git_branch" ]]; then
    git_icon=$(printf '\xee\x82\xa0')
    branch_display="${C_BLUE}${git_icon} ${git_branch}${C_RESET}"
fi

# ---------------------------------------------------------------------------
# Vim mode (if vim mode is active)
# ---------------------------------------------------------------------------
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
vim_display=""
if [[ -n "$vim_mode" ]]; then
    if [[ "$vim_mode" == "INSERT" ]]; then
        vim_display="${C_GREEN}INSERT${C_RESET}"
    else
        vim_display="${C_MAUVE}NORMAL${C_RESET}"
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
            reset_part="${C_DIM}($(printf '%d:%02d' "$rm_h" "$rm_m"))${C_RESET}"
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
# Resume command from session_id
# ---------------------------------------------------------------------------
session_id=$(echo "$input" | jq -r '.session_id // empty')
resume_display=""
if [[ -n "$session_id" ]]; then
    resume_display="${C_DIM}claude --resume ${session_id}${C_RESET}"
fi

# ---------------------------------------------------------------------------
# Build status line (up to 4 rows)
# Row 1: model | ctx
# Row 2: 5h | 7d  (only when rate limits are available)
# Row 3: cwd [branch] [vim mode]
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

row2_parts=()
[[ -n "$five_display" ]]  && row2_parts+=("$five_display")
[[ -n "$seven_display" ]] && row2_parts+=("$seven_display")

row3_parts=()
[[ -n "$cwd_display" ]]       && row3_parts+=("$cwd_display")
[[ -n "$branch_display" ]]    && row3_parts+=("$branch_display")
[[ -n "$vim_display" ]]       && row3_parts+=("$vim_display")

row1=$(join_parts "${row1_parts[@]}")
row2=$(join_parts "${row2_parts[@]}")
row3=$(join_parts "${row3_parts[@]}")

[[ -n "$row1" ]] && printf "%b\n" "$row1"
[[ -n "$row2" ]] && printf "%b\n" "$row2"
[[ -n "$row3" ]] && printf "%b\n" "$row3"
[[ -n "$resume_display" ]] && printf "%b\n" "$resume_display"
