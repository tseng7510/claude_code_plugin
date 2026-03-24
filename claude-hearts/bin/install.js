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

const VALID_DIRECTIONS = ["fill", "deplete"];

const args = process.argv.slice(2);
const isUninstall = args.includes("--uninstall");

function getArgValue(name) {
  const arg = args.find((a) => a.startsWith(`--${name}`));
  if (!arg) return null;
  if (arg.includes("=")) return arg.split("=")[1];
  const idx = args.indexOf(arg);
  return args[idx + 1] ?? null;
}

const theme = getArgValue("theme");
const direction = getArgValue("direction");

if (theme && !VALID_THEMES.includes(theme)) {
  console.error(`✗ Unknown theme: "${theme}"`);
  console.error(`  Available: ${VALID_THEMES.join(", ")}`);
  process.exit(1);
}

if (direction && !VALID_DIRECTIONS.includes(direction)) {
  console.error(`✗ Unknown direction: "${direction}"`);
  console.error(`  Available: fill, deplete`);
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

const envParts = [];
if (theme) envParts.push(`CLAUDE_HEARTS_THEME=${theme}`);
if (direction) envParts.push(`CLAUDE_HEARTS_DIRECTION=${direction}`);
const command = envParts.length > 0 ? `${envParts.join(" ")} ${DEST}` : DEST;

const settings = readSettings();
settings.statusLine = { type: "command", command };
writeSettings(settings);
console.log(`✓ Updated ${SETTINGS}`);

const selectedTheme = theme ?? "hearts";
const selectedDirection = direction ?? "fill";
console.log(`\nDone! Restart Claude Code to see your ✦ ${selectedTheme} statusline (${selectedDirection} mode).`);
console.log("\nOptions:");
console.log("  --theme <name>       Available: " + VALID_THEMES.join(", "));
console.log("  --direction <mode>   fill (default) or deplete");
console.log("\nTo uninstall: node bin/install.js --uninstall");
