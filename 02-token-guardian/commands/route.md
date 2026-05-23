---
name: token-route
description: "[Pro] Recommend a multi-provider fallback path when Claude is near or at its limit. Routes through OpenRouter to GPT/Gemini/DeepSeek with cost + quality trade-off shown."
argument-hint: "[task description, or omit to use the current conversation context]"
---

# /token-route

You are running the `token-route` command from the `token-guardian` plugin. **This is a Pro feature.**

Your task: given a task description, recommend which model to route to **for the next task** if Claude is at risk of hitting its budget. Surface the cost/quality trade-off explicitly so the user makes an informed switch.

## Free vs Pro

- **Free**: This command tells the user "Pro feature — DM @hunterweb303 (X) or t.me/dsa885 to buy" and shows ONE generic suggestion: "If Claude is at limit, try OpenRouter's `anthropic/claude-3.5-sonnet` proxy as a stopgap."
- **Pro**: Full routing analysis (see procedure below).

## How to detect Pro status

Shell out to the license helper:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh check
```

Exit `0` → Pro is active, full routing analysis follows.
Exit `1` → Free tier, run the abbreviated Free-tier flow described above.

Customers activate via `/token-activate <their-purchase-email>` after DM-ing to buy Pro and being granted access by the operator.

## Pro procedure

1. **Read context.**
   - Check `/token-status` first — confirm user is actually near budget. If they're at < 70% usage, ask "you're at X% — sure you want to route away from Claude now?"
   - Read the task description from the argument, or summarize the last 3-5 messages of the current conversation.

2. **Classify the task** into one of:
   - `simple-edit` (small file changes, < 100 lines diff)
   - `code-generation` (writing new feature, 100-500 lines)
   - `large-refactor` (cross-file, > 500 lines, tricky logic)
   - `research` (searching, summarizing, no code)
   - `debug` (need deep reasoning)

3. **Recommend** from this matrix (prices in USD per 1M tokens, blended I/O 1:3 ratio, 2026 Q1):

   | Task type | Top recommendation | Backup | Don't use |
   |---|---|---|---|
   | simple-edit | `openrouter/deepseek-chat` ($0.27) | `openrouter/gemini-2.0-flash` ($0.30) | claude-3-opus (overkill) |
   | code-generation | `openrouter/anthropic/claude-3.5-sonnet` ($3.0) | `openrouter/openai/gpt-4.1` ($4.0) | deepseek (quality drop on complex code) |
   | large-refactor | stay on Claude if any budget left, else `openrouter/openai/gpt-4.1` | `openrouter/gemini-2.5-pro` | deepseek, free-tier models |
   | research | `openrouter/gemini-2.0-flash` ($0.30, 1M context) | `openrouter/deepseek-chat` | claude-3-opus (cost waste) |
   | debug | `openrouter/anthropic/claude-3.5-sonnet` | `openrouter/openai/o1-mini` | deepseek-chat (weak reasoning) |

   **Update this table when prices/models change.** It's frozen at 2026-05. Tell the user "rates current as of 2026-05; check openrouter.ai/models for live pricing."

4. **Show the trade-off explicitly.**

   ```
   Recommended: openrouter/anthropic/claude-3.5-sonnet
     Quality:  ~95% of native Claude (same model via proxy)
     Cost:     $3.00/M tokens (vs $0 native Claude on Max plan, but you're out)
     Latency:  +200-400ms (OpenRouter hop)
     How:      Set OPENROUTER_API_KEY in env, then run
               `claude --provider openrouter --model anthropic/claude-3.5-sonnet`
               OR configure once in ~/.claude/settings.json
   ```

5. **Offer to write the env / config snippet.** Ask the user "Want me to write the snippet to ~/.claude/settings.json?" — confirm before writing.

## What you must NOT do

- Don't recommend providers you're not confident are stable in 2026 (no Mistral La Plateforme, no Cohere Command-R — they're undersupplied).
- Don't oversell — if the user is at 30% budget, tell them they don't need to route yet.
- Don't write env files or settings.json without explicit confirmation.
- Don't recommend free-tier models for non-trivial tasks (they hallucinate worse and waste retries).
