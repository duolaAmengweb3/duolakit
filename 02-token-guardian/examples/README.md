# token-guardian · smoke-test fixture

A reproducible end-to-end test for the PreToolUse hook. Confirms that:

1. Each tool call appends one record to `~/.duolakit/token-log.jsonl`
2. Crossing the warn threshold (default 80%) emits one stderr message
3. Crossing the stop threshold (default 95%) emits one stderr message
4. Repeat calls at the same level are silent (dedupe via `~/.duolakit/state.json`)
5. Log entries older than 5 hours are excluded from the window sum
6. Custom budget config in `~/.duolakit/token-guardian.json` is honored

## Run

```bash
bash examples/smoke-test.sh
```

Expected: `passed: 10    failed: 0`.

## Warning

The test **wipes `~/.duolakit/` at start**. If you're already using token-guardian for real budget tracking, back up `~/.duolakit/` first:

```bash
cp -r ~/.duolakit ~/.duolakit.backup
bash examples/smoke-test.sh
rm -rf ~/.duolakit && mv ~/.duolakit.backup ~/.duolakit
```

## What's NOT tested here

- The slash commands themselves (`/token-budget`, `/token-status`, `/token-route`) — those are markdown instructions to Claude, not executable code, so they're validated by trying them inside a real Claude Code session.
- The Pro routing sub-agent (`agents/router.md`) — same reason.
- The `/cost` calibration flow — needs a human to paste Claude Code's `/cost` output, can't be automated.

The hook is the only piece of executable code in this plugin. Once the smoke test passes, the rest is "does Claude follow the markdown" — verify by installation.
