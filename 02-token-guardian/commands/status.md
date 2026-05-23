---
name: token-status
description: Show estimated token usage in the current rolling 5h window vs your budget, with extrapolation to "when you'll hit the wall".
---

# /token-status

You are running the `token-status` command from the `token-guardian` plugin.

Your task: read the activity log + budget config, estimate current 5h-window usage, and print a status table with an extrapolation.

## Inputs

- `~/.duolakit/token-guardian.json` — budget config (see /token-budget)
- `~/.duolakit/token-log.jsonl` — per-tool-call log written by the PreToolUse hook
- Claude Code's own `/cost` output if the user pastes it (most accurate signal)

## Log format

Each line is a JSON object written by `hooks/log-tool.sh`:

```json
{"ts": "2026-05-23T16:42:01Z", "tool": "Read", "input_size": 1840, "estimated_tokens": 460}
```

`estimated_tokens` uses a rough heuristic: input chars ÷ 4 + a per-tool baseline (Read: 200, Edit: 400, Write: 600, Bash: 300, Glob/Grep: 150). This is an estimate, not ground truth.

## Procedure

1. **Read budget config.** Default values if file missing (see /token-budget).
2. **Read activity log.** Tail the last 5 hours' entries (filter by `ts`). If log doesn't exist or is empty, print "No activity logged yet — make sure the plugin's hook is registered."
3. **Sum estimated tokens** in the window.
4. **Compute extrapolation.**
   - Tokens-per-minute = sum / (minutes elapsed since first entry in window)
   - Tokens remaining = budget - sum
   - Minutes until threshold:
     - to `warn_at_percent` = (budget * warn/100 - sum) / tokens-per-minute
     - to `hard_stop_at_percent` = (budget * stop/100 - sum) / tokens-per-minute

5. **Render status.**

   ```
   token-guardian status · 5h rolling window
   ─────────────────────────────────────────────────────────────
   Window:       16:42 → 21:42 (active for 1h 12m)
   Budget:       220,000 tokens
   Used (est):   78,400 tokens  ███████░░░░░░░░░░░░░░  35.6%
   Pace:         1,090 tok/min  (avg over last hour)
   ─────────────────────────────────────────────────────────────
   ⚠  Warn at 176,000 (80%)   →  ETA ~1h 30m
   ⛔ Stop at 209,000 (95%)   →  ETA ~2h 00m
   ─────────────────────────────────────────────────────────────
   Top tools this window:
     Edit       42 calls   ~24,000 tok
     Read       28 calls   ~14,000 tok
     Bash       18 calls   ~6,400 tok
     Grep       12 calls   ~2,800 tok
   ─────────────────────────────────────────────────────────────
   ```

6. **Add advice line.**
   - If usage < warn: "On track. Carry on."
   - If usage ≥ warn but < stop: "Slow down — you'll hit the wall in ~X min at this pace. Try /token-route (Pro) to suggest a fallback model for the next tasks."
   - If usage ≥ stop: "Stop. You're past your safety threshold. Either wait for the 5h window to reset or switch providers manually."

7. **Honesty footer.**

   > Estimates are heuristic. For ground truth, run Claude Code's `/cost` and paste it back; I'll calibrate. Anthropic doesn't yet expose token meta to plugins.

## Pro feature: /cost calibration

If the user pastes Claude Code's `/cost` output, recalibrate the heuristic constant so future estimates are tighter. Save calibration multiplier to `~/.duolakit/token-guardian.json` under `calibration_multiplier`. Free tier accepts the paste once per session; Pro keeps a rolling 7-day calibration.

## What you must NOT do

- Don't fabricate numbers. If the log is empty, say so.
- Don't claim precision the heuristic can't deliver. Always show the disclaimer.
- Don't suggest "buy more tokens" — that's not how the Max plan works, and it would be dishonest.
