#!/bin/bash
# 預覽所有主題圖樣，不打 API、不跑 statusline.sh

blue='\033[38;2;80;160;255m'
muted='\033[38;2;144;144;144m'
dim='\033[2m'
reset='\033[0m'

bar() {
    local on="$1" off="$2" filled=4 empty=6
    local h=""
    for ((i=0; i<filled; i++)); do h+="${blue}${on}${reset} "; done
    for ((i=0; i<empty;  i++)); do h+="${muted}${off}${reset} "; done
    printf "%b" "$h"
}

theme_chars() {
    case "$1" in
        hearts)     echo "♥ ♡" ;;
        stars)      echo "★ ☆" ;;
        dots)       echo "● ○" ;;
        blocks)     echo "█ ░" ;;
        flowers)    echo "✿ ❀" ;;
        diamonds)   echo "◆ ◇" ;;
        sparks)     echo "✦ ✧" ;;
        pawprints)  echo "🐾 ·" ;;
        bears)      echo "ᴥ ᴥ" ;;
        triangles)  echo "▲ △" ;;
        snowflakes) echo "❄ ❅" ;;
        music)      echo "♪ ♩" ;;
        sakura)     echo "✾ ✽" ;;
        arrows)     echo "❯ ›" ;;
    esac
}

printf "${dim}%-12s  %s${reset}\n" "theme" "filled → unused"
printf "${dim}%s${reset}\n" "────────────────────────────────"

THEMES=(hearts stars dots blocks flowers diamonds sparks pawprints bears triangles snowflakes music sakura arrows)

for theme in "${THEMES[@]}"; do
    chars=$(theme_chars "$theme")
    on="${chars%% *}"
    off="${chars##* }"
    printf "%-12s  " "$theme"
    bar "$on" "$off"
    echo ""
done
