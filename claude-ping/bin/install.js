#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");

const SCRIPT_NAME = "ping.sh";
const CLAUDE_DIR = path.join(os.homedir(), ".claude");
const DEST = path.join(CLAUDE_DIR, SCRIPT_NAME);
const SETTINGS = path.join(CLAUDE_DIR, "settings.json");

const HOOK_STOP = {
  matcher: "",
  hooks: [{ type: "command", command: `${DEST} finished` }],
};
const HOOK_NOTIFICATION = {
  matcher: "",
  hooks: [{ type: "command", command: `${DEST} input` }],
};

const args = process.argv.slice(2);
const isUninstall = args.includes("--uninstall");

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

function addHook(settings, event, hookEntry) {
  if (!settings.hooks) settings.hooks = {};
  if (!settings.hooks[event]) settings.hooks[event] = [];
  const cmd = hookEntry.hooks[0].command;
  const exists = settings.hooks[event].some(
    (h) => Array.isArray(h.hooks) && h.hooks.some((hh) => hh.command === cmd)
  );
  if (!exists) settings.hooks[event].push(hookEntry);
}

function removeHook(settings, event, command) {
  if (!settings.hooks?.[event]) return;
  settings.hooks[event] = settings.hooks[event].filter(
    (h) => !(Array.isArray(h.hooks) && h.hooks.some((hh) => hh.command === command))
  );
  if (settings.hooks[event].length === 0) delete settings.hooks[event];
  if (Object.keys(settings.hooks).length === 0) delete settings.hooks;
}

// ── Uninstall ──────────────────────────────────────────
if (isUninstall) {
  console.log("Uninstalling claude-ping...");

  if (fs.existsSync(DEST)) {
    fs.unlinkSync(DEST);
    console.log("✓ Removed bell script");
  }

  const settings = readSettings();
  removeHook(settings, "Stop", HOOK_STOP.command);
  removeHook(settings, "Notification", HOOK_NOTIFICATION.command);
  writeSettings(settings);
  console.log("✓ Removed hooks from settings.json");

  console.log("Done! Restart Claude Code to apply changes.");
  process.exit(0);
}

// ── Install ────────────────────────────────────────────
console.log("Installing claude-ping...");
ensureDir(CLAUDE_DIR);

const src = path.join(__dirname, SCRIPT_NAME);
fs.copyFileSync(src, DEST);
fs.chmodSync(DEST, 0o755);
console.log(`✓ Copied bell script to ${DEST}`);

const settings = readSettings();
addHook(settings, "Stop", HOOK_STOP);
addHook(settings, "Notification", HOOK_NOTIFICATION);
writeSettings(settings);
console.log("✓ Added hooks to settings.json");

console.log("\nDone! Restart Claude Code to enable notifications.");
console.log("  Stop hook       → notifies when Claude finishes");
console.log("  Notification hook → notifies when Claude needs your input");
console.log("\nTo uninstall: npx claude-ping --uninstall");
