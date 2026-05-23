---
name: token-budget
description: Set or show your Claude Code token budget for the rolling 5-hour window (Max plan) or daily cap. Writes to ~/.duolakit/token-guardian.json.
argument-hint: "[set 5h <tokens> | set daily <tokens> | show]"
---

# /token-budget

You are running the `token-budget` command from the `token-guardian` plugin.

Your task: read or write the user's token budget config at `~/.duolakit/token-guardian.json`.

## Config schema

```json
{
  "five_hour_window_tokens": 220000,
  "daily_tokens": 1000000,
  "warn_at_percent": 80,
  "hard_stop_at_percent": 95,
  "updated_at": "2026-05-23T16:00:00Z"
}
```

Defaults (used if file missing) are based on Claude Code Max plan publicly observed limits as of 2026 Q1:
- `five_hour_window_tokens`: 220000
- `daily_tokens`: 1000000
- `warn_at_percent`: 80
- `hard_stop_at_percent`: 95

These are best-guess defaults — Anthropic does not officially publish per-plan limits and they change. Tell the user to adjust based on their own observation.

## Procedure

1. **Parse the argument.**
   - `set 5h <N>` → update `five_hour_window_tokens`
   - `set daily <N>` → update `daily_tokens`
   - `set warn <P>` → update `warn_at_percent`
   - `set stop <P>` → update `hard_stop_at_percent`
   - `show` or no argument → print the current config in a table
   - Anything else → print usage help

2. **Read existing config.**
   - If `~/.duolakit/token-guardian.json` exists, load it.
   - If not, materialize with the defaults above (without writing yet).

3. **Apply change** (if `set`).
   - Validate: tokens must be > 0 and < 10_000_000; percent must be 1-99.
   - Update `updated_at` to current ISO timestamp.
   - Write the file. Create `~/.duolakit/` if missing. **Confirm with the user before writing.**

4. **Print result.**

   ```
   token-guardian budget
   ─────────────────────────────────────────
   5h rolling window     220,000 tokens
   daily cap           1,000,000 tokens
   warn at                    80% of budget
   hard stop at               95% of budget
   ─────────────────────────────────────────
   config:  ~/.duolakit/token-guardian.json
   ```

## Honesty disclaimer

End every `show` output with:

> Note: Claude Code does not expose precise token counts to plugins. token-guardian uses a heuristic estimate based on tool-call activity logged in `~/.duolakit/token-log.jsonl`. Use Claude Code's built-in `/cost` for ground truth. Budget thresholds here are advisory.

## What you must NOT do

- Don't write to the config without confirming the value with the user.
- Don't pretend you can read actual token counts from Anthropic's API — the plugin runs locally with no API key.
- Don't suggest the user "upgrade" to fix budget issues — the right answer is /token-route (Pro) or being more frugal.
