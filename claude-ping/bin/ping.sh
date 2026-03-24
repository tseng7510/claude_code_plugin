#!/bin/bash
# claude-bell — cross-platform notification for Claude Code hooks

MESSAGE="${1:-Claude Code}"
TITLE="Claude Code"

# ── macOS ────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"Glass\"" 2>/dev/null
    exit 0
fi

# ── WSL (Windows Subsystem for Linux) ───────────────────
if grep -qi microsoft /proc/version 2>/dev/null; then
    powershell.exe -Command "
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
        \$t = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(0)
        \$t.SelectSingleNode('//text[@id=1]').InnerText = '$MESSAGE'
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('$TITLE').Show([Windows.UI.Notifications.ToastNotification]::new(\$t))
    " 2>/dev/null
    exit 0
fi

# ── Windows (Git Bash / MSYS / Cygwin) ──────────────────
if [[ "$OSTYPE" == "msys"* ]] || [[ "$OSTYPE" == "cygwin"* ]]; then
    powershell -Command "
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
        \$t = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(0)
        \$t.SelectSingleNode('//text[@id=1]').InnerText = '$MESSAGE'
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('$TITLE').Show([Windows.UI.Notifications.ToastNotification]::new(\$t))
    " 2>/dev/null
    exit 0
fi

# ── Linux ────────────────────────────────────────────────
if command -v notify-send >/dev/null 2>&1; then
    notify-send "$TITLE" "$MESSAGE" 2>/dev/null
    exit 0
fi
