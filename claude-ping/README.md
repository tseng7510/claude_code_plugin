# claude-ping 🔔

> [中文說明](#中文說明) | [English](#english)

---

## 中文說明

為 [Claude Code](https://claude.ai/code) 打造的桌面通知套件。當終端機沒有 focus 時，Claude 完成任務或需要你確認，會自動發送系統通知。

### 安裝

```bash
git clone https://github.com/tseng7510/claude_code_plugin.git
cd claude_code_plugin/claude-ping
node bin/install.js
```

**前置需求**

- `node` — 執行安裝腳本
- macOS，無額外依賴

### 通知時機

| 時機 | 說明 |
|------|------|
| Claude 完成任務 | `Stop` hook 觸發，通知「Claude 已完成任務」 |
| Claude 等待確認 | `Notification` hook 觸發，通知「Claude 需要你的確認」 |

> **注意**：`Stop` hook 是在 **Claude Code session 結束**時觸發（不論是任務完成、手動關閉或視窗關閉）。若有背景中的 session 在你不知情下結束，也會跳通知，屬於正常行為。

### 前景視窗偵測

當 Claude Code 所在的終端機視窗處於 focus 狀態時，系統會自動略過通知。偵測精準度依終端機分為三個層級：

**精確偵測（Session / Pane 層級）**

可精確識別「哪個分頁在 focus」，開兩個終端機視窗時行為正確：

| 終端機 | 識別方式 |
|--------|---------|
| iTerm2 | `$ITERM_SESSION_ID` + AppleScript |
| WezTerm | `$WEZTERM_PANE` + `wezterm cli list` |

**App 層級偵測**

只能判斷「這個終端機 App 是否在前景」，無法區分不同視窗。**若同時開兩個視窗，即使 Claude Code 那個沒有 focus，通知也會被略過。**

| 終端機 |
|--------|
| Terminal（macOS 內建） |
| Warp |
| Hyper |
| Alacritty |
| kitty ¹ |
| Tabby |
| Ghostty |
| Rio |

> ¹ kitty 本身支援精確偵測，但需要在設定中啟用 `allow_remote_control`，為避免強迫用戶更動安全設定，目前退回 App 層級。

**不在支援清單**

無偵測，一律發送通知。若你使用的終端機不在列表中，可手動編輯 `~/.claude/ping.sh`，在 `case "$front_app" in` 加入對應的 App 名稱（名稱需與 macOS 顯示的完全一致）。

**macOS 注意事項**

若沒有收到通知，請至 **系統設定 → 通知 → Script Editor** 開啟允許通知。

### 移除

```bash
node bin/install.js --uninstall
```

自動移除腳本並清除 `~/.claude/settings.json` 中的 hooks。

### 隱私說明

- 不讀取任何 token 或個人資料
- 通知內容純為本機訊息，不傳送至任何外部服務

---

## English

Desktop notifications for [Claude Code](https://claude.ai/code). Sends a system notification when Claude finishes a task or needs your input — useful when your terminal is not in focus.

### Install

```bash
git clone https://github.com/tseng7510/claude_code_plugin.git
cd claude_code_plugin/claude-ping
node bin/install.js
```

**Requirements**

- `node` — to run the install script
- macOS only. No extra dependencies.

### When it notifies

| Event | Message |
|-------|---------|
| Claude finishes | `Stop` hook → "Claude finished" |
| Claude needs input | `Notification` hook → "Claude needs your input" |

> **Note**: The `Stop` hook fires when a **Claude Code session exits** — whether a task finishes, you close the terminal, or the window is dismissed. A session running in the background that exits will also trigger a notification; this is expected behaviour.

### Focus detection

Notifications are suppressed when the terminal window running Claude Code is in focus. Detection accuracy varies by terminal emulator:

**Precise detection (session / pane level)**

Correctly handles multiple terminal windows open at the same time:

| Terminal | Method |
|----------|--------|
| iTerm2 | `$ITERM_SESSION_ID` + AppleScript |
| WezTerm | `$WEZTERM_PANE` + `wezterm cli list` |

**App-level detection**

Only detects whether the terminal app is frontmost — cannot distinguish between individual windows. **If you have two windows open, notifications from the background window will also be suppressed, even if it is not in focus.**

| Terminal |
|----------|
| Terminal (macOS built-in) |
| Warp |
| Hyper |
| Alacritty |
| kitty ¹ |
| Tabby |
| Ghostty |
| Rio |

> ¹ kitty supports precise detection, but requires enabling `allow_remote_control` in its config. To avoid forcing users to change security settings, it falls back to app-level detection.

**Not listed**

No detection — notifications are always sent. If your terminal is not listed, edit `~/.claude/ping.sh` and add its name to the `case "$front_app" in` line. The name must match exactly as shown in macOS.

**macOS note**

If no notification appears, go to **System Settings → Notifications → Script Editor** and enable notifications.

### Uninstall

```bash
node bin/install.js --uninstall
```

Removes the script and cleans up hooks from `~/.claude/settings.json`.

### Privacy

- Does not read any tokens or personal data
- Notification messages are local only and never sent to any external service

## License

MIT
