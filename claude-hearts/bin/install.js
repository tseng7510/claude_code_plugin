#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");

const SCRIPT_NAME = "statusline.sh";
const CLAUDE_DIR = path.join(os.homedir(), ".claude");
const DEST = path.join(CLAUDE_DIR, SCRIPT_NAME);
const BACKUP = path.join(CLAUDE_DIR, `${SCRIPT_NAME}.backup`);
const SETTINGS = path.join(CLAUDE_DIR, "settings.json");

const VALID_THEMES = [
  "hearts", "stars", "dots", "blocks", "flowers", "diamonds", "sparks",
  "pawprints", "bears", "triangles", "snowflakes", "music", "sakura", "arrows",
];

const args = process.argv.slice(2);
const isUninstall = args.includes("--uninstall");

const themeArg = args.find((a) => a.startsWith("--theme"));
let theme = null;
if (themeArg) {
  if (themeArg.includes("=")) {
    theme = themeArg.split("=")[1];
  } else {
    const idx = args.indexOf(themeArg);
    theme = args[idx + 1] ?? null;
  }
}

if (theme && !VALID_THEMES.includes(theme)) {
  console.error(`✗ Unknown theme: "${theme}"`);
  console.error(`  Available: ${VALID_THEMES.join(", ")}`);
  process.exit(1);
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function readSettings() {
  try {
    return JSON.parse(fs.readFileSync(SETTINGS, "utf8"));
  } catch {
    return {};
  }
}

function writeSettings(obj) {
  ensureDir(CLAUDE_DIR);
  fs.writeFileSync(SETTINGS, JSON.stringify(obj, null, 2) + "\n");
}

// ── Uninstall ─────────────────────────────────────────────
if (isUninstall) {
  console.log("Uninstalling claude-hearts statusline...");

  if (fs.existsSync(BACKUP)) {
    fs.copyFileSync(BACKUP, DEST);
    fs.unlinkSync(BACKUP);
    console.log("✓ Restored previous statusline from backup");
  } else if (fs.existsSync(DEST)) {
    fs.unlinkSync(DEST);
    console.log("✓ Removed statusline script");
  }

  const settings = readSettings();
  const sl = settings.statusLine;
  if (sl && sl.command && sl.command.includes(SCRIPT_NAME)) {
    delete settings.statusLine;
    writeSettings(settings);
    console.log("✓ Removed statusLine from settings.json");
  }

  console.log("Done! Restart Claude Code to apply changes.");
  process.exit(0);
}

// ── Install ───────────────────────────────────────────────
const themeLabel = theme ? ` (theme: ${theme})` : "";
console.log(`Installing claude-hearts statusline${themeLabel}...`);
ensureDir(CLAUDE_DIR);

if (fs.existsSync(DEST)) {
  fs.copyFileSync(DEST, BACKUP);
  console.log("✓ Backed up existing statusline to statusline.sh.backup");
}

const src = path.join(__dirname, SCRIPT_NAME);
fs.copyFileSync(src, DEST);
fs.chmodSync(DEST, 0o755);
console.log(`✓ Copied statusline script to ${DEST}`);

const command = theme
  ? `CLAUDE_HEARTS_THEME=${theme} ${DEST}`
  : DEST;

const settings = readSettings();
settings.statusLine = { type: "command", command };
writeSettings(settings);
console.log(`✓ Updated ${SETTINGS}`);

const selectedTheme = theme ?? "hearts";
console.log(`\nDone! Restart Claude Code to see your ✦ ${selectedTheme} statusline.`);
console.log("\nTo change theme: npx claude-hearts --theme <name>");
console.log(`Available themes: ${VALID_THEMES.join(", ")}`);
console.log("\nTo uninstall: npx claude-hearts --uninstall");
