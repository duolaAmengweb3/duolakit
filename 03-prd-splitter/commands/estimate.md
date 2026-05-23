---
name: prd-estimate
description: Assign Fibonacci story points (1, 2, 3, 5, 8, 13) to each story in PRD-tree.md. Stories rated 13+ trigger a re-split suggestion.
argument-hint: "[optional: path to PRD-tree.md, defaults to ./PRD-tree.md]"
---

# /prd-estimate

You are running the `prd-estimate` command from the `prd-splitter` plugin.

Your task: read `PRD-tree.md`, add a Fibonacci story-point estimate to every story, and flag any story that estimates 13+ as a candidate for re-splitting.

## Fibonacci scale (the only scale this plugin uses)

| Points | What it means | Typical solo-dev time |
|---|---|---|
| 1  | Trivial — a 1-line config change, a typo fix | < 1 hour |
| 2  | Small — a clear, contained change with obvious approach | 1-4 hours |
| 3  | Standard — one component or one endpoint, well-understood | 0.5-1 day |
| 5  | Medium — multi-file, some integration | 1-2 days |
| 8  | Large — cross-cutting, real complexity, some unknowns | 3-5 days |
| 13 | **Too big** — should be split. If estimating 13, suggest splits. | 1-2 weeks |
| 20+ | Refuse to estimate. Force a re-split first. | — |

**Never** use 4, 6, 7, 9, 10, 11, 12. The whole point of Fibonacci is that you can't pretend to be precise between 3 and 5.

## Procedure

1. **Read PRD-tree.md.** If it doesn't exist, tell the user to run `/prd-split` first.

2. **For each story**, estimate based on:
   - Number of acceptance criteria (5+ criteria typically → 5 or 8 pts)
   - Whether tasks are listed and how many (4+ tasks → likely 5 or 8)
   - Mentions of "integration", "migration", "new framework" → bump up
   - Mentions of "existing pattern", "similar to X" → bump down

3. **Write the estimate inline** by editing PRD-tree.md. Format:

   ```markdown
   ### Story 1.1 · User can reset password  · **`5 pts`**

   <existing description>
   ```

   Insert the ``` · **`N pts`** ``` suffix at the end of the H3 title line. Don't reformat anything else.

4. **Add a summary footer to the file.**

   ```markdown
   ---
   ## Estimation summary

   - Total points: 47
   - Distribution: 1pt × 0 · 2pt × 3 · 3pt × 5 · 5pt × 4 · 8pt × 1 · 13pt × 0
   - Stories flagged for re-split (13+ pts): 0
   - At ~1 pt/half-day this is roughly: **24 dev-days** (5 weeks for 1 person, 2-3 weeks for 2)
   ```

   Always include the "rough days" sentence — it's the most useful single number for the PM reading this.

5. **Flag big stories.** Any story estimated 13 → at end of the file under `## Re-split candidates`, list them and propose 2-3 ways to break them. **Don't auto-split** — that's a user decision.

6. **In chat, summarize**: "Estimated N stories. Total: X points (~Y dev-days). Flagged Z for re-split."

## Calibration

When the user pushes back ("that's way too much", "no this is just a 2"), accept the correction and recalibrate similar stories in the same tree. Save the calibration to `~/.duolakit/prd-splitter-calibration.json`:

```json
{
  "stories": [
    {"title": "User can reset password", "your_estimate": 5, "user_estimate": 3}
  ]
}
```

Use this to bias future estimates for similar-shape stories in the SAME project. Don't share across projects (the user's velocity varies).

## What you must NOT do

- Don't estimate with non-Fibonacci numbers.
- Don't estimate a tree you didn't just read — always re-read PRD-tree.md fresh (it may have been edited since /prd-split).
- Don't add estimates to tasks. Only stories get estimated. Tasks are checklist items.
- Don't overwrite the file without confirming with the user.

## Free vs Pro — license check before invoking the reviewer

Before invoking the `prd-reviewer` sub-agent on any 8+ point story, shell out to:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh check
```

Exit `0` (Pro) → call the reviewer agent automatically for each 8+ story. Include its verdict block in the chat output AND attach a brief annotation to the story in PRD-tree.md (`*(reviewer: confirmed)*` or `*(reviewer: suggested downgrade to 5)*`).

Exit `1` (Free) → skip the reviewer entirely. Note in the final summary:

```
ℹ  3 stories estimated 8+ pts (potentially over-sized). Pro tier invokes
   the prd-reviewer sub-agent to second-opinion each one. Activate with
   /prd-activate <license-key> or see https://duolakit.gumroad.com/l/prd-splitter
```

| Capability | Free | Pro |
|---|---|---|
| Estimate every story with Fibonacci | ✓ | ✓ |
| Summary footer with totals | ✓ | ✓ |
| 13+ stories flagged for re-split | ✓ | ✓ |
| `prd-reviewer` second opinion on 8+ stories | — | ✓ |
| Per-project calibration persistence | session-only | persistent |
