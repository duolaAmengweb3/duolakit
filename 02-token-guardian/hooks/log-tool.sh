#!/usr/bin/env bash
# token-guardian · PreToolUse hook
# Responsibilities:
#   1. Append one JSON record per tool call to ~/.duolakit/token-log.jsonl
#   2. Sum the last 5h of activity
#   3. Compare against ~/.duolakit/token-guardian.json budget thresholds
#   4. Emit a one-time stderr warning when a threshold is crossed
#
# Safety contract:
#   - ALWAYS exit 0 — non-zero would block the user's tool call.
#   - Bug/exception output from node goes to /dev/null; only the intended
#     warning string (written to node's stdout) is forwarded to stderr.
#   - Threshold warnings deduped via ~/.duolakit/state.json so a single
#     crossing fires once per window, not on every tool call.

set -u

DUOLAKIT_DIR="${HOME}/.duolakit"
LOG_FILE="${DUOLAKIT_DIR}/token-log.jsonl"
CONFIG_FILE="${DUOLAKIT_DIR}/token-guardian.json"
STATE_FILE="${DUOLAKIT_DIR}/state.json"

mkdir -p "${DUOLAKIT_DIR}" 2>/dev/null || exit 0

payload=$(cat 2>/dev/null) || exit 0
[ -z "${payload}" ] && exit 0

command -v node >/dev/null 2>&1 || exit 0

# node writes the user-visible warning (if any) to stdout.
# Real node errors / exceptions go to /dev/null so we never spam the user.
warning=$(
  node -e '
const fs = require("fs");
const [payloadRaw, logFile, configFile, stateFile] = process.argv.slice(1);

function safeReadJson(p, fallback) {
  try { return JSON.parse(fs.readFileSync(p, "utf8")); } catch (_) { return fallback; }
}
function safeWriteJson(p, obj) {
  try { fs.writeFileSync(p, JSON.stringify(obj, null, 2)); } catch (_) {}
}

// ---- 1. parse + estimate ----
let tool = "unknown", input = {}, input_size = 0;
try {
  const p = JSON.parse(payloadRaw || "{}");
  tool = p.tool_name || "unknown";
  input = p.tool_input || {};
  input_size = JSON.stringify(input).length;
} catch (_) {}

const baselines = { Read: 200, Edit: 400, Write: 600, Bash: 300, Glob: 150, Grep: 150 };
const baseline = baselines[tool] || 250;
const estimated_tokens = Math.round(baseline + input_size / 4);
const now = new Date();
const ts = now.toISOString();

// ---- 2. append log ----
try { fs.appendFileSync(logFile, JSON.stringify({ ts, tool, input_size, estimated_tokens }) + "\n"); }
catch (_) { process.exit(0); }

// ---- 3. config + threshold check ----
const cfg = safeReadJson(configFile, {
  five_hour_window_tokens: 220000,
  warn_at_percent: 80,
  hard_stop_at_percent: 95,
  calibration_multiplier: 1.0
});
const cal = Number(cfg.calibration_multiplier) || 1.0;
const budget = Number(cfg.five_hour_window_tokens) || 220000;
const warnPct = Number(cfg.warn_at_percent) || 80;
const stopPct = Number(cfg.hard_stop_at_percent) || 95;

// ---- 4. sum 5h window ----
const windowStart = now.getTime() - 5 * 60 * 60 * 1000;
let windowSum = 0;
try {
  const lines = fs.readFileSync(logFile, "utf8").split("\n");
  for (const line of lines) {
    if (!line) continue;
    try {
      const r = JSON.parse(line);
      const t = Date.parse(r.ts);
      if (Number.isFinite(t) && t >= windowStart) {
        windowSum += Number(r.estimated_tokens) || 0;
      }
    } catch (_) {}
  }
} catch (_) { process.exit(0); }

const effectiveSum = Math.round(windowSum * cal);
const pct = (effectiveSum / budget) * 100;

let level = "ok";
if (pct >= stopPct) level = "stop";
else if (pct >= warnPct) level = "warn";

const levelOrder = { ok: 0, warn: 1, stop: 2 };
const state = safeReadJson(stateFile, { last_warn_level: "ok", last_warn_ts: null });

// Only emit when bumping UP a level. When window ages out and pct drops back, reset.
if (levelOrder[level] > levelOrder[state.last_warn_level]) {
  const human = effectiveSum.toLocaleString();
  const budgetHuman = budget.toLocaleString();
  const pctStr = pct.toFixed(1);
  if (level === "warn") {
    process.stdout.write(
      "\n[token-guardian] ⚠  Heads up: " + human + " / " + budgetHuman +
      " tokens (~" + pctStr + "%) in the last 5h. Warn threshold (" + warnPct + "%) crossed.\n" +
      "  Run /token-status for pace + ETA. /token-route (Pro) suggests a fallback.\n\n"
    );
  } else if (level === "stop") {
    process.stdout.write(
      "\n[token-guardian] ⛔ Approaching limit: " + human + " / " + budgetHuman +
      " tokens (~" + pctStr + "%). Hard-stop threshold (" + stopPct + "%) crossed.\n" +
      "  Stop using tools for ~30 min so old activity ages out of the 5h window,\n" +
      "  or switch via /token-route (Pro).\n\n"
    );
  }
  safeWriteJson(stateFile, { last_warn_level: level, last_warn_ts: ts });
} else if (levelOrder[level] < levelOrder[state.last_warn_level]) {
  safeWriteJson(stateFile, { last_warn_level: level, last_warn_ts: ts });
}
' "${payload}" "${LOG_FILE}" "${CONFIG_FILE}" "${STATE_FILE}" 2>/dev/null
)

# Forward the warning (if any) to stderr — that's what Claude Code shows users.
if [ -n "${warning}" ]; then
  printf '%s' "${warning}" >&2
fi

exit 0
