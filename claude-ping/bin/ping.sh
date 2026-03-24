#!/bin/bash
# claude-bell — macOS notification for Claude Code hooks

EVENT="${1:-finished}"
TITLE="Claude Code"

# ── Locale detection ─────────────────────────────────────
_detect_lang() {
    local lang="${LANG:-${LC_ALL:-${LC_MESSAGES:-}}}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local al; al=$(defaults read -g AppleLocale 2>/dev/null)
        [ -n "$al" ] && lang="$al"
    fi
    case "$lang" in
        zh_TW*|zh_HK*|zh_CN*|zh_*) echo "zh" ;;
        *) echo "en" ;;
    esac
}

_LANG=$(_detect_lang)

# ── Message i18n ─────────────────────────────────────────
case "$EVENT" in
    finished)
        [ "$_LANG" = "zh" ] && MESSAGE="Claude 已完成任務" || MESSAGE="Claude finished"
        ;;
    input)
        [ "$_LANG" = "zh" ] && MESSAGE="Claude 需要你的確認" || MESSAGE="Claude needs your input"
        ;;
    *)
        MESSAGE="$EVENT"
        ;;
esac

# ── 前景視窗偵測 ──────────────────────────────────────────
# 依終端機支援程度分三層：
#   精確偵測（session/pane 層級）：iTerm2、WezTerm
#   App 層級偵測（有多視窗時仍會誤判）：其餘支援的終端機
front_app=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)

case "$front_app" in
    iTerm2|iTerm)
        # 往上找有 TTY 的父程序（hook 本身沒有 TTY，需往上找 shell）
        _get_ancestor_tty() {
            local pid=$$
            while [[ $pid -gt 1 ]]; do
                local t; t=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
                if [[ -n "$t" && "$t" != "??" ]]; then echo "/dev/$t"; return; fi
                pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
            done
        }
        current_tty=$(_get_ancestor_tty)
        focused_tty=$(osascript -e 'tell application "iTerm2" to get tty of current session of current window' 2>/dev/null)
        [[ -n "$current_tty" && "$current_tty" == "$focused_tty" ]] && exit 0
        ;;
    WezTerm)
        # 比對當前 pane ID 與 WezTerm active pane
        if command -v wezterm &>/dev/null && [[ -n "$WEZTERM_PANE" ]]; then
            focused=$(wezterm cli list --format json 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for p in d:
        if str(p.get('pane_id', '')) == '${WEZTERM_PANE}' and p.get('is_active', False):
            print('yes'); break
except: pass
" 2>/dev/null)
            [[ "$focused" == "yes" ]] && exit 0
        fi
        ;;
    Terminal|Warp|Hyper|Alacritty|kitty|Tabby|Ghostty|Rio)
        # App 層級：無法精確判斷分頁，直接跳過
        exit 0
        ;;
esac

osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\"" 2>/dev/null
