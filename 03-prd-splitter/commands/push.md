---
name: prd-push
description: "[Pro] Push stories from PRD-tree.md directly to Linear via API. No CSV detour. Always dry-runs first."
argument-hint: "linear  [--dry-run | --no-dry-run] [--team <team-key>]"
---

# /prd-push

You are running the `prd-push` command from the `prd-splitter` plugin. **This is a Pro feature.**

Your task: read `PRD-tree.md`, transform stories into Linear issues, and create them via the Linear API. **Always show a dry-run first** unless the user explicitly passed `--no-dry-run`.

## Free vs Pro detection — hard-gated

**Before doing any work**, shell out to:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh check
```

Exit `1` → Pro is NOT active. Refuse the command and print:

```
/prd-push is a Pro feature ($19 lifetime).

Free tier alternative: /prd-export linear  (produces a CSV you drop into Linear).

Buy Pro:    DM @hunterweb303 (X) or t.me/dsa885 — $19 lifetime
Activate:   /prd-activate <your-purchase-email>
```

Exit `0` → Pro is active. Proceed with the procedure below.

**This is enforced**, not soft-gated. Free users cannot push to Linear from this plugin — `/prd-export linear` + manual import is the documented path.

## Inputs

- `./PRD-tree.md` (required)
- `LINEAR_API_KEY` env var (Linear personal API key — get at https://linear.app/settings/api)
- Argument: `linear` (Jira CSV is available via `/prd-export jira` + manual import)
- Optional `--team <team-key>` — Linear team to push into. If absent, list user's teams and ask.
- Optional `--dry-run` — print what WOULD be created without making API calls (default behavior anyway).
- Optional `--no-dry-run` — required to actually create issues.

## Procedure

1. **Verify Pro status** (see above).

2. **Verify env.** If `LINEAR_API_KEY` is not set:
   ```
   LINEAR_API_KEY not found. Set it with:
     export LINEAR_API_KEY=lin_api_xxxxx

   Get a key at: https://linear.app/settings/api
   ```
   Stop.

3. **Read PRD-tree.md.** Parse into epics → stories. If empty or malformed, stop and tell user.

4. **Resolve team.** Use the helper script `examples/push-linear.sh` (or its equivalent inline curl) to list teams:
   ```bash
   bash examples/push-linear.sh list-teams
   ```
   Pick the one matching `--team` or ask the user to choose. Remember the team-id.

5. **Dry-run.** Show the user a table:
   ```
   Plan: 12 stories to create in team "Engineering" (id: eng-xxx)
   ─────────────────────────────────────────────────────────────
   #  Epic        Story                              Estimate
   ─────────────────────────────────────────────────────────────
   1  Auth        User can sign up via email          3
   2  Auth        User can reset password             5
   3  Auth        Account lockout after 5 fails       3
   ...
   ─────────────────────────────────────────────────────────────
   Run with --no-dry-run to actually create these.
   ```

   If the user passed `--no-dry-run`, proceed; otherwise stop here.

6. **Actually push.** Use the Linear GraphQL API via `examples/push-linear.sh create`. For each story:
   - title: `[<Epic>] <Story title>`
   - description: same shape as `/prd-export linear`
   - teamId: from step 4
   - estimate: the Fibonacci number
   - labelIds: lookup-or-create `epic-<lowercased-epic-name>`

   Rate limit: max 1 request / second. If Linear returns 429, back off 30s and retry once.

7. **Report.**
   ```
   Created 12 issues in Linear (team: Engineering)
   ───────────────────────────────────────────────
   ✓ ENG-241  [Auth] User can sign up via email
   ✓ ENG-242  [Auth] User can reset password
   ...
   ───────────────────────────────────────────────
   View: https://linear.app/<workspace>/team/eng
   ```

   For each created issue, save the mapping to `~/.duolakit/prd-splitter-mapping.json` so subsequent runs can detect "already pushed" and update instead of re-create:

   ```json
   {
     "PRD-tree.md": {
       "Auth/User can reset password": {"linear_id": "ENG-242", "pushed_at": "2026-05-23T..."}
     }
   }
   ```

## Idempotency

If a story's `<epic>/<title>` key is already in the mapping for this PRD, **update** the existing issue (estimate, description) instead of creating a new one. Confirm the update with the user first.

If the mapping says ENG-242 but ENG-242 doesn't exist anymore in Linear (deleted), warn but allow re-create.

## What you must NOT do

- Never push without dry-run unless `--no-dry-run` is passed.
- Never store the API key in any file under the repo or `~/.duolakit/`. Read from env every time.
- Never push more than 50 issues in one call without a second confirmation ("Really push 73 issues? y/N").
- Never delete Linear issues from this plugin. Pushing is one-way.
- Never echo the API key in logs or messages.

## Roadmap

- Today (v1.0) · Linear push, dry-run default, idempotent update, license-key verification
- Next · Jira push (today: CSV via `/prd-export jira` + manual import works), Notion source, reverse sync (pull updated estimates from Linear back into PRD-tree.md)
