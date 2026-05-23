---
name: token-calibrate
description: Paste Claude Code's /cost output to recalibrate the heuristic estimator. Free = session-only. Pro = persistent across sessions.
argument-hint: "(no args — paste /cost output when prompted)"
---

# /token-calibrate

You are running the `token-calibrate` command from the `token-guardian` plugin.

Your task: improve the accuracy of `/token-status` by comparing the plugin's heuristic estimate against Claude Code's ground-truth `/cost` output, computing a calibration multiplier, and persisting it.

## Why this exists

The heuristic in `hooks/log-tool.sh` is `input_chars / 4 + per-tool baseline`. It under- or over-estimates by 30-50% depending on the user's workflow. `/cost` knows the real numbers — this command bridges them.

## Procedure

1. **Check the log exists.** Read `~/.duolakit/token-log.jsonl`. If empty or missing, tell the user:

   ```
   No activity logged yet. Use Claude Code for a bit first, then re-run.
   ```

   Stop.

2. **Compute the current 5h window estimate.** Sum `estimated_tokens` for entries in the last 5h. Call this `est`.

3. **Ask the user for /cost.** Prompt:

   ```
   Paste Claude Code's /cost output (just the lines about this 5h window).
   I'll compute the calibration multiplier.

   Tip: in Claude Code, run /cost — it shows session token usage. Look for
   the line with the rolling-window total in tokens.
   ```

   Wait for the user to paste. Accept any of these formats Claude Code has used:
   ```
   Total: 158,432 tokens
   Session: ~160K tokens
   5h window: 158432
   ```

   Extract the number (commas, decimals, K/M suffixes all OK). Call this `actual`.

4. **Sanity-check.**
   - If `actual < 100`: probably parsed wrong. Ask the user to re-paste or give the number directly.
   - If `actual / est > 10` or `actual / est < 0.1`: out-of-range — probably the user's pasted number is from a different window. Ask to confirm.

5. **Compute multiplier.**

   ```
   multiplier = actual / est
   ```

   Round to 2 decimal places. Typical values: 1.2 to 2.0 (the heuristic underestimates).

6. **Decide where to persist** — license-gated:

   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh check
   ```

   Exit `0` (Pro) → persist to `~/.duolakit/token-guardian.json` under `calibration_multiplier`. Survives sessions. The hook reads it every call.

   Exit `1` (Free) → write to `~/.duolakit/calibration-session.json` instead (session-only). When the user runs Claude Code from a new shell, it's gone. Tell them so:

   ```
   ✓ Calibration applied for this session only (Free tier).
     multiplier: 1.43
     next session will reset to 1.0

   Pro persists calibration across sessions and gives you 7-day rolling
   re-calibration. Buy: https://duolakit.gumroad.com/l/token-guardian
   ```

7. **Confirm + report.**

   ```
   ✓ Calibration multiplier set to 1.43
     Your heuristic was estimating 110,580 tokens.
     /cost said 158,030.
     Future /token-status reports will multiply estimates by 1.43.

   Persistence:  Pro · ~/.duolakit/token-guardian.json
                 (or Free · ~/.duolakit/calibration-session.json)
   ```

## What you must NOT do

- Don't apply a multiplier outside [0.3, 3.0] without an explicit "yes I really mean it" from the user. Anything beyond that range is probably a parse error.
- Don't store /cost output verbatim (could contain session metadata). Only store the extracted number + the timestamp.
- Don't claim Pro persistence on Free tier — be honest about session-only.
- Don't compute multiplier from a window with < 10 log entries — sample too small. Tell user "use Claude Code more first, then re-calibrate."

## Pro extras (calibration history)

For Pro users, also append a row to `~/.duolakit/calibration-history.jsonl`:

```json
{"ts":"2026-05-23T...","actual":158030,"est":110580,"multiplier":1.43}
```

Use this for the v1.1 "rolling 7-day average multiplier" feature. Free tier doesn't write this file.
