# claude-hearts ✦

> [中文說明](#中文說明) | [English](#english)

---

## 中文說明

為 [Claude Code](https://claude.ai/code) 打造的可愛 statusline，支援多種主題，顯示用量限制、Context 使用量與本次費用。

![](.github/demo.png)

顏色隨用量變化：
- 💚 綠色 — 低於 50%
- 💜 紫色 — 50–69%
- 💛 黃色 — 70–89%
- ❤️ 紅色 — 90% 以上

### 安裝

```bash
git clone https://github.com/tseng7510/claude_code_plugin.git
cd claude_code_plugin/claude-hearts
node bin/install.js
```

自動備份原有 statusline 並設定 Claude Code。

**前置需求**

- `node` — JSON 解析
- `curl` — 取得用量資料
- `git` — 顯示分支名稱（選用）

### 主題

透過環境變數 `CLAUDE_HEARTS_THEME` 選擇主題，預設為 `hearts`。

![](.github/themes.png)

| 主題 | 已用 | 未用 | 說明 |
|------|------|------|------|
| `hearts` | ♥ | ♡ | 愛心（預設） |
| `stars` | ★ | ☆ | 星星 |
| `dots` | ● | ○ | 圓點 |
| `blocks` | █ | ░ | 方塊 |
| `flowers` | ✿ | ❀ | 花朵 |
| `diamonds` | ◆ | ◇ | 菱形 |
| `sparks` | ✦ | ✧ | 火花 |
| `pawprints` | 🐾 | · | 腳印（emoji 無顏色，靠形狀區分） |
| `bears` | ᴥ | ᴥ | 熊鼻，% 後顯示熊臉表情 |
| `triangles` | ▲ | △ | 三角形 |
| `snowflakes` | ❄ | ❅ | 雪花 |
| `music` | ♪ | ♩ | 音符 |
| `sakura` | ✾ | ✽ | 櫻花 |
| `arrows` | ❯ | › | 箭頭 |

在 `~/.claude/settings.json` 設定主題：

```json
{
  "statusLine": {
    "type": "command",
    "command": "CLAUDE_HEARTS_THEME=bears ~/.claude/statusline.sh"
  }
}
```

**bears 主題**

熊臉表情會隨用量變化出現在百分比後方：

```
5h ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ   34% ʕ•ᴥ•ʔ resets in 3h42m  ← 綠，元氣滿
5h ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ   62% ʕ-ᴥ-ʔ resets in 2h10m  ← 紫，有點累
5h ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ   78% ʕ；ᴥ；ʔ resets in 1h05m  ← 黃，快撐不住
5h ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ ᴥ   95% ʕ×ᴥ×ʔ resets in 10m    ← 紅，掛了
```

### 手動安裝

```bash
cp bin/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

在 `~/.claude/settings.json` 加入：

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

### 移除

```bash
node bin/install.js --uninstall
```

若安裝前有原本的 statusline，會自動還原。

### 隱私說明

- OAuth token 從本機 Keychain 或 `~/.claude/.credentials.json` 讀取，與 Claude Code 本身使用的是同一個 token
- Token **僅傳送給** `api.anthropic.com`（Anthropic 官方 API）以查詢用量，不會傳到任何第三方
- 查詢結果快取於 `/tmp/claude-hearts/usage.json`，僅包含用量百分比，無個人資料，60 秒後更新
- 目錄名稱與 git 分支只在本機顯示，不會傳出

### 注意事項

- 5h / 7d 用量限制僅 **Claude.ai Pro / Max 訂閱者**可用
- 無訂閱者仍會顯示第一行（Model、Context、費用）
- 重置倒數時間以 **UTC 時間戳**計算，與系統時區無關，所有地區結果一致

---

## English

A cute multi-theme statusline for [Claude Code](https://claude.ai/code) — displays usage limits, context window usage, and session cost.

![](.github/demo.png)

Colours indicate usage level:
- 💚 Green — under 50%
- 💜 Purple — 50–69%
- 💛 Yellow — 70–89%
- ❤️ Red — 90%+

### Install

```bash
git clone https://github.com/tseng7510/claude_code_plugin.git
cd claude_code_plugin/claude-hearts
node bin/install.js
```

Backs up any existing statusline and configures Claude Code automatically.

**Requirements**

- `node` — for JSON parsing
- `curl` — for fetching usage data
- `git` — for branch info (optional)

### Themes

Set the `CLAUDE_HEARTS_THEME` environment variable to choose a theme. Default: `hearts`.

![](.github/themes.png)

| Theme | Filled | Empty | Description |
|-------|--------|-------|-------------|
| `hearts` | ♥ | ♡ | Hearts (default) |
| `stars` | ★ | ☆ | Stars |
| `dots` | ● | ○ | Dots |
| `blocks` | █ | ░ | Blocks |
| `flowers` | ✿ | ❀ | Flowers |
| `diamonds` | ◆ | ◇ | Diamonds |
| `sparks` | ✦ | ✧ | Sparks |
| `pawprints` | 🐾 | · | Paw prints (emoji, shape-only distinction) |
| `bears` | ᴥ | ᴥ | Bear nose, with bear face expression after % |
| `triangles` | ▲ | △ | Triangles |
| `snowflakes` | ❄ | ❅ | Snowflakes |
| `music` | ♪ | ♩ | Music notes |
| `sakura` | ✾ | ✽ | Sakura |
| `arrows` | ❯ | › | Arrows |

Set your theme in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "CLAUDE_HEARTS_THEME=bears ~/.claude/statusline.sh"
  }
}
```

**bears theme**

A bear face expression appears after the percentage and changes with usage:

```
34% ʕ•ᴥ•ʔ  — green, all good
62% ʕ-ᴥ-ʔ  — purple, a bit tired
78% ʕ；ᴥ；ʔ — yellow, struggling
95% ʕ×ᴥ×ʔ  — red, lights out
```

### Manual install

```bash
cp bin/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
```

### Uninstall

```bash
node bin/install.js --uninstall
```

Restores your previous statusline if one existed.

### Privacy

- Your OAuth token is read from your local Keychain or `~/.claude/.credentials.json` — the same token Claude Code already uses
- The token is sent **only** to `api.anthropic.com` (Anthropic's own API) to fetch your usage data — never to any third party
- Usage data is cached locally at `/tmp/claude-hearts/usage.json` for 60 seconds; it contains only usage percentages, no personal information
- Directory name and git branch are displayed locally only and never transmitted anywhere

### Notes

- 5h / 7d rate limit data is only available for **Claude.ai Pro / Max subscribers**
- Without a subscription, the first line (model, context, cost) is still shown
- Reset countdowns are calculated from **UTC timestamps** and are unaffected by the local system timezone — results are consistent for users in any timezone

## License

MIT
