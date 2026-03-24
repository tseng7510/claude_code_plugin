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
- macOS / Linux / Windows 均支援，無額外依賴

### 通知時機

| 時機 | 說明 |
|------|------|
| Claude 完成任務 | `Stop` hook 觸發，通知「Claude finished」 |
| Claude 等待確認 | `Notification` hook 觸發，通知「Claude needs your input」 |

### 平台支援

| 平台 | 通知方式 |
|------|----------|
| macOS | `osascript`（原生通知 + 音效） |
| Linux | `notify-send` |
| Windows (Git Bash / MSYS) | PowerShell Toast 通知 |
| WSL | PowerShell.exe Toast 通知 |

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
- No extra dependencies. Works on macOS, Linux, and Windows out of the box.

### When it notifies

| Event | Message |
|-------|---------|
| Claude finishes | `Stop` hook → "Claude finished" |
| Claude needs input | `Notification` hook → "Claude needs your input" |

### Platform support

| Platform | Method |
|----------|--------|
| macOS | `osascript` (native notification + sound) |
| Linux | `notify-send` |
| Windows (Git Bash / MSYS) | PowerShell Toast notification |
| WSL | PowerShell.exe Toast notification |

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
