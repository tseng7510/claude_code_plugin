#!/bin/bash
set -f

input=$(cat)

if [ -z "$input" ]; then
    printf "✦ Claude"
    exit 0
fi

# ── Colors ──────────────────────────────────────────────
red='\033[38;2;255;100;100m'
yellow='\033[38;2;255;210;80m'
green='\033[38;2;100;220;120m'
blue='\033[38;2;80;160;255m'
lavender='\033[38;2;180;140;255m'
cyan='\033[38;2;86;182;194m'
white='\033[38;2;220;220;220m'
dim='\033[2m'
muted='\033[38;2;144;144;144m'  # fixed gray — visible on both dark and light bg
reset='\033[0m'

sep=" ${dim}·${reset} "

# ── Helpers ─────────────────────────────────────────────
color_for_pct() {
    local pct=$1
    if   [ "$pct" -ge 90 ]; then printf "$red"
    elif [ "$pct" -ge 70 ]; then printf "$yellow"
    elif [ "$pct" -ge 50 ]; then printf "$lavender"
    else printf "$green"; fi
}

# ── Theme ────────────────────────────────────────────────
# Set via CLAUDE_HEARTS_THEME env var. Default: hearts
# Available: hearts, stars, dots, blocks, flowers, diamonds, sparks, pawprints,
#            bears, triangles, snowflakes, music, sakura, arrows
THEME="${CLAUDE_HEARTS_THEME:-hearts}"

# ── Direction ─────────────────────────────────────────────
# fill    — bar fills up as usage increases, % shows used (default)
# deplete — bar depletes as usage increases, % shows remaining
DIRECTION="${CLAUDE_HEARTS_DIRECTION:-fill}"

theme_chars() {
    case "$THEME" in
        hearts)     echo "♥ ♡" ;;
        stars)      echo "★ ☆" ;;
        dots)       echo "● ○" ;;
        blocks)     echo "█ ░" ;;
        flowers)    echo "✿ ❀" ;;
        diamonds)   echo "◆ ◇" ;;
        sparks)     echo "✦ ✧" ;;
        pawprints)  echo "🐾 ·" ;;   # emoji can't be colored; shape distinction only
        bears)      echo "ᴥ ᴥ" ;;   # bear nose, fully colorable
        triangles)  echo "▲ △" ;;
        snowflakes) echo "❄ ❅" ;;
        music)      echo "♪ ♩" ;;
        sakura)     echo "✾ ✽" ;;
        arrows)     echo "❯ ›" ;;
        *)          echo "♥ ♡" ;;
    esac
}

usage_bar() {
    local pct=$1 total=10
    local filled=$(( pct * total / 100 ))
    local empty=$(( total - filled ))
    local color; color=$(color_for_pct "$pct")
    local chars; chars=$(theme_chars)
    local on="${chars%% *}"
    local off="${chars##* }"
    local h=""
    if [ "$DIRECTION" = "deplete" ]; then
        # Bar depletes: remaining = colored, used = muted
        local remaining=$(( total - filled ))
        if [ "$THEME" = "pawprints" ]; then
            for ((i=0; i<remaining; i++)); do h+="${on} "; done
            for ((i=0; i<filled;    i++)); do h+="${muted}${off}${reset} "; done
        else
            for ((i=0; i<remaining; i++)); do h+="${color}${on}${reset} "; done
            for ((i=0; i<filled;    i++)); do h+="${muted}${off}${reset} "; done
        fi
    else
        # Bar fills: used = colored, remaining = muted
        if [ "$THEME" = "pawprints" ]; then
            for ((i=0; i<filled; i++)); do h+="${on} "; done
            for ((i=0; i<empty;  i++)); do h+="${muted}${off}${reset} "; done
        else
            for ((i=0; i<filled; i++)); do h+="${color}${on}${reset} "; done
            for ((i=0; i<empty;  i++)); do h+="${muted}${off}${reset} "; done
        fi
    fi
    printf "%b" "$h"
}

bear_face() {
    local pct=$1
    local color; color=$(color_for_pct "$pct")
    local face
    if   [ "$pct" -ge 90 ]; then face="ʕ×ᴥ×ʔ"
    elif [ "$pct" -ge 70 ]; then face="ʕ；ᴥ；ʔ"
    elif [ "$pct" -ge 50 ]; then face="ʕ-ᴥ-ʔ"
    else face="ʕ•ᴥ•ʔ"; fi
    printf "%b" "${color}${face}${reset}"
}

format_tokens() {
    local num=$1
    if   [ "$num" -ge 1000000 ]; then awk "BEGIN {printf \"%.1fm\", $num/1000000}"
    elif [ "$num" -ge 1000 ];    then awk "BEGIN {printf \"%.0fk\", $num/1000}"
    else printf "%d" "$num"; fi
}

iso_to_epoch() {
    local iso="$1"
    # GNU date (Linux) — handles timezone natively
    local epoch
    epoch=$(date -d "$iso" +%s 2>/dev/null)
    [ -n "$epoch" ] && echo "$epoch" && return

    # macOS: strip microseconds
    local bare
    bare=$(echo "$iso" | sed 's/\.[0-9]*//')

    # Extract timezone offset in seconds (independent of local timezone)
    local tz_offset=0
    if [[ "$bare" == *"Z" ]]; then
        bare="${bare%Z}"
        tz_offset=0
    elif [[ "$bare" =~ ([+-])([0-9]{2}):([0-9]{2})$ ]]; then
        local sign="${BASH_REMATCH[1]}"
        local hh="${BASH_REMATCH[2]}"
        local mm="${BASH_REMATCH[3]}"
        tz_offset=$(( (10#$hh * 3600 + 10#$mm * 60) ))
        [ "$sign" = "-" ] && tz_offset=$(( -tz_offset ))
        bare="${bare%${BASH_REMATCH[0]}}"
    fi

    epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$bare" +%s 2>/dev/null)
    [ -z "$epoch" ] && epoch=$(TZ=UTC date -d "$bare" +%s 2>/dev/null)
    [ -z "$epoch" ] && return

    echo $(( epoch - tz_offset ))
}

time_remaining() {
    local iso="$1"
    [ -z "$iso" ] || [ "$iso" = "null" ] && return
    local epoch; epoch=$(iso_to_epoch "$iso") || return
    local now; now=$(date +%s)
    local diff=$(( epoch - now ))
    [ "$diff" -le 0 ] && printf "now" && return
    local h=$(( diff / 3600 ))
    local m=$(( (diff % 3600) / 60 ))
    if   [ "$h" -gt 0 ]; then printf "${h}h${m}m"
    elif [ "$m" -gt 0 ]; then printf "${m}m"
    else printf "${diff}s"; fi
}

# ── Extract JSON data (via node) ─────────────────────────
_input_parsed=$(echo "$input" | node -e "
const d = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
const r = n => Math.round(Number(n) || 0);
console.log(d.model?.display_name ?? 'Claude');
console.log(d.workspace?.current_dir ?? d.cwd ?? '');
console.log(d.cost?.total_cost_usd ?? 0);
console.log(r(d.context_window?.used_percentage ?? 0));
console.log(d.context_window?.context_window_size ?? '');
console.log(r(d.context_window?.current_usage?.input_tokens ?? 0));
console.log(r(d.context_window?.current_usage?.cache_creation_input_tokens ?? 0));
console.log(r(d.context_window?.current_usage?.cache_read_input_tokens ?? 0));
" 2>/dev/null)

model=$(echo "$_input_parsed"    | sed -n '1p')
cwd=$(echo "$_input_parsed"      | sed -n '2p')
cost=$(echo "$_input_parsed"     | sed -n '3p')
ctx_pct=$(echo "$_input_parsed"  | sed -n '4p')
ctx_size=$(echo "$_input_parsed" | sed -n '5p')
ctx_in=$(echo "$_input_parsed"   | sed -n '6p')
ctx_cc=$(echo "$_input_parsed"   | sed -n '7p')
ctx_cr=$(echo "$_input_parsed"   | sed -n '8p')

[ -z "$model" ] && model="Claude"
[ -z "$cwd" ] || [ "$cwd" = "null" ] && cwd=$(pwd)
[ -z "$cost" ] && cost=0
[ -z "$ctx_pct" ] && ctx_pct=0
cost_fmt=$(awk "BEGIN {printf \"\$%.4f\", $cost}")
ctx_cur=$(( ctx_in + ctx_cc + ctx_cr ))
ctx_used=$(format_tokens "$ctx_cur")
[ -n "$ctx_size" ] && ctx_total=$(format_tokens "$ctx_size") || ctx_total="?"

# git branch
git_info=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    [ -n "$dirty" ] && dot="${red}*${reset}" || dot=""
    git_info=" ${dim}(${reset}${cyan}${branch}${dot}${dim})${reset}"
fi

dirname="${cwd/#$HOME/\~}"

# ── OAuth Token ──────────────────────────────────────────
_parse_token() {
    node -e "
try {
    const d = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
    process.stdout.write(d.claudeAiOauth?.accessToken ?? '');
} catch(e) {}
" 2>/dev/null
}

get_token() {
    [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ] && echo "$CLAUDE_CODE_OAUTH_TOKEN" && return

    if command -v security >/dev/null 2>&1; then
        local blob; blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$blob" ]; then
            local tok; tok=$(echo "$blob" | _parse_token)
            [ -n "$tok" ] && echo "$tok" && return
        fi
    fi

    local creds="$HOME/.claude/.credentials.json"
    if [ -f "$creds" ]; then
        local tok; tok=$(cat "$creds" | _parse_token)
        [ -n "$tok" ] && echo "$tok" && return
    fi

    if command -v secret-tool >/dev/null 2>&1; then
        local blob; blob=$(timeout 2 secret-tool lookup service "Claude Code-credentials" 2>/dev/null)
        if [ -n "$blob" ]; then
            local tok; tok=$(echo "$blob" | _parse_token)
            [ -n "$tok" ] && echo "$tok" && return
        fi
    fi

    echo ""
}

# ── Fetch usage (cached 60s) ─────────────────────────────
cache_dir="/tmp/claude-hearts"
cache_file="$cache_dir/usage.json"
mkdir -p "$cache_dir"

usage_data=""
needs_refresh=true

if [ -f "$cache_file" ]; then
    cache_mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
    now=$(date +%s)
    [ $(( now - cache_mtime )) -lt 60 ] && needs_refresh=false && usage_data=$(cat "$cache_file")
fi

if $needs_refresh; then
    token=$(get_token)
    if [ -n "$token" ]; then
        resp=$(curl -s --max-time 5 \
            -H "Accept: application/json" \
            -H "Authorization: Bearer $token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "User-Agent: claude-hearts-statusline/1.0.0" \
            "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
        if echo "$resp" | node -e "
try { const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); process.exit(d.five_hour ? 0 : 1); } catch(e) { process.exit(1); }
" 2>/dev/null; then
            usage_data="$resp"
            echo "$resp" > "$cache_file"
        fi
    fi
    [ -z "$usage_data" ] && [ -f "$cache_file" ] && usage_data=$(cat "$cache_file")
fi

# ── Line 1: model · dir (branch) · context · cost ────────
[ "$DIRECTION" = "deplete" ] && ctx_pct_display=$(( 100 - ctx_pct )) || ctx_pct_display=$ctx_pct
ctx_color=$(color_for_pct "$ctx_pct")
line1="${lavender}✦ ${model}${reset}"
line1+="${sep}${cyan}${dirname}${reset}${git_info}"
line1+="${sep}${ctx_color}${ctx_used}${dim}/${reset}${white}${ctx_total}${reset} ${dim}ctx${reset}"
line1+="${sep}${dim}${cost_fmt}${reset}"

# ── Line 2-3: rate limits ────────────────────────────────
rate_lines=""

if [ -n "$usage_data" ]; then
    _usage_parsed=$(echo "$usage_data" | node -e "
try {
    const d = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
    const r = n => Math.round(Number(n) || 0);
    console.log(r(d.five_hour?.utilization ?? 0));
    console.log(d.five_hour?.resets_at ?? '');
    console.log(r(d.seven_day?.utilization ?? 0));
    console.log(d.seven_day?.resets_at ?? '');
    console.log(d.extra_usage?.is_enabled ?? false);
    console.log(r(d.extra_usage?.utilization ?? 0));
    console.log(d.extra_usage?.used_credits ?? 0);
    console.log(d.extra_usage?.monthly_limit ?? 0);
} catch(e) { process.exit(1); }
" 2>/dev/null)

    if [ -n "$_usage_parsed" ]; then
        fh_pct=$(echo "$_usage_parsed"    | sed -n '1p')
        fh_reset=$(echo "$_usage_parsed"  | sed -n '2p')
        wd_pct=$(echo "$_usage_parsed"    | sed -n '3p')
        wd_reset=$(echo "$_usage_parsed"  | sed -n '4p')
        extra_on=$(echo "$_usage_parsed"  | sed -n '5p')
        ex_pct=$(echo "$_usage_parsed"    | sed -n '6p')
        ex_used_raw=$(echo "$_usage_parsed" | sed -n '7p')
        ex_limit_raw=$(echo "$_usage_parsed" | sed -n '8p')

        fh_remain=$(time_remaining "$fh_reset")
        fh_bar=$(usage_bar "$fh_pct")
        fh_color=$(color_for_pct "$fh_pct")
        if [ "$DIRECTION" = "deplete" ]; then
            fh_pct_pad=$(printf "%3d" $(( 100 - fh_pct )))
        else
            fh_pct_pad=$(printf "%3d" "$fh_pct")
        fi

        wd_remain=$(time_remaining "$wd_reset")
        wd_bar=$(usage_bar "$wd_pct")
        wd_color=$(color_for_pct "$wd_pct")
        if [ "$DIRECTION" = "deplete" ]; then
            wd_pct_pad=$(printf "%3d" $(( 100 - wd_pct )))
        else
            wd_pct_pad=$(printf "%3d" "$wd_pct")
        fi

        fh_bear=""; wd_bear=""
        [ "$THEME" = "bears" ] && fh_bear=" $(bear_face "$fh_pct")" && wd_bear=" $(bear_face "$wd_pct")"

        rate_lines="  ${dim}5h${reset} ${fh_bar} ${fh_color}${fh_pct_pad}%${reset}${fh_bear}"
        [ -n "$fh_remain" ] && rate_lines+=" ${dim}resets in ${reset}${fh_color}${fh_remain}${reset}"
        rate_lines+="\n  ${dim}7d${reset} ${wd_bar} ${wd_color}${wd_pct_pad}%${reset}${wd_bear}"
        [ -n "$wd_remain" ] && rate_lines+=" ${dim}resets in ${reset}${wd_color}${wd_remain}${reset}"

        if [ "$extra_on" = "true" ]; then
            ex_used=$(awk "BEGIN {printf \"%.2f\", $ex_used_raw/100}")
            ex_limit=$(awk "BEGIN {printf \"%.2f\", $ex_limit_raw/100}")
            ex_bar=$(usage_bar "$ex_pct")
            ex_color=$(color_for_pct "$ex_pct")
            rate_lines+="\n  ${dim}+$${reset}  ${ex_bar} ${ex_color}\$${ex_used}${dim}/${reset}${white}\$${ex_limit}${reset}"
        fi
    fi
fi

# ── Output ───────────────────────────────────────────────
printf "%b" "$line1"
[ -n "$rate_lines" ] && printf "\n\n%b" "$rate_lines"
printf "\n"

exit 0
