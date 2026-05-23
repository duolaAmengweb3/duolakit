---
name: openapi-sync
description: Auto-sync OpenAPI spec ↔ route handlers ↔ TypeScript types ↔ SDK clients. Generates/edits code to bring all four into agreement.
argument-hint: "[optional: --direction spec-to-code|code-to-spec, default spec-to-code]"
---

# /openapi-sync

You are running the `openapi-sync` command from the `openapi-guardian` plugin.

Your task: **bring the 4 components (spec / routes / types / SDK) into perfect sync**, writing or editing files where needed.

## Direction

The default direction is `spec-to-code` — the spec is the source of truth, code follows.

If user passes `--direction code-to-spec`, reverse: code is source of truth, update the spec.

If unclear, **ask the user explicitly** before any write:

> "Which direction this round?
> 1. Spec is the contract → I'll generate/update routes, types, SDK
> 2. Code is what's live → I'll update the spec to reflect what's actually shipping"

## Procedure (spec-to-code direction)

1. **Run `/openapi-check` first** silently to know what's out of sync.

2. **Group changes by category** and ask user to approve each batch:

   ```
   Plan to make 5 changes:
   
   [A] Add 1 route handler
       - DELETE /users/{id} → write to src/routes/users.ts
   
   [B] Update 2 type signatures
       - components["schemas"]["User"] add 'lastLoginAt: string?'
       - components["schemas"]["Order"] rename 'amount' → 'totalCents'
   
   [C] Add 2 SDK methods
       - sdk.deleteUser(id)
       - sdk.refundOrder(id, reason)
   
   Apply all? [y/n/which? e.g. A,C]
   ```

3. **For each approved change**, use:

   - `edit_file` for surgical changes (preferred).
   - `write_file` only when creating a new file.
   - **Never** delete a route handler without explicit user permission, even if the spec dropped that endpoint.

4. **If the change is large (> 50 lines)**, invoke the `reviewer` sub-agent to get a second opinion before writing.

5. **After writes**, run these checks via `shell`:

   - `npx tsc --noEmit` (type check)
   - If `package.json` has `lint` script, run it.
   - Report any errors back to the user and offer to fix.

6. **Commit suggestion**. If everything passes, suggest a commit message:

   ```
   Suggested commit:
   chore(api): sync handlers + types + sdk to openapi v0.4.2
     - Add DELETE /users/{id} handler
     - Update User schema (lastLoginAt nullable)
     - Rename Order.amount → Order.totalCents
   
   Run: git add -A && git commit -m "..."
   ```

## Procedure (code-to-spec direction)

Reverse — read all handlers, extract their `path + method`, build a spec, diff against the existing `openapi.yaml`, and propose updates. Same approval flow.

## Conflict handling

If you find a conflict (e.g. spec says `email: string`, handler validates `email: number`):

1. **Stop and ask**. Never auto-resolve.

   ```
   ⚠ Conflict on POST /users
     spec:    email: string (format: email)
     handler: zod.number().int() — src/routes/users.ts:23
   
   Which is correct?
   1. Spec wins — change handler to expect email string
   2. Handler wins — update spec to email: number (but that's probably wrong, ask why)
   3. Skip this one
   ```

2. Document the resolution in the commit message.

## Free vs Pro — enforced via license check

**Before doing any Pro-tier work** (writing handlers for Fastify/Hono/NestJS, or scanning multiple specs in a multi-service repo), shell out to:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh check
```

If exit code is `0` → Pro is active, all framework support available.
If exit code is `1` → Free tier, restrict to Express + single spec.

| Tier | Frameworks | Spec count |
|---|---|---|
| Free | Express only | 1 spec file |
| Pro  | Express + Fastify + Hono + NestJS | unlimited (multi-service registry) |

When you encounter a non-Express framework on Free tier, gracefully degrade:

```
⚠ openapi-guardian Free supports Express only.
  Detected Fastify in src/routes/*.ts — skipping these handlers.

  Pro unlocks Fastify + Hono + NestJS:
    Buy:      https://duolakit.gumroad.com/l/openapi-guardian  ($19 one-time)
    Activate: /openapi-activate <license-key>
```

Continue with Express files. Don't crash.

When the user has multiple `openapi.yaml` files (e.g., `services/auth/openapi.yaml`, `services/billing/openapi.yaml`), check the license. Free tier picks the first one and warns; Pro processes all of them.

## Safety rules

- **Never** modify `node_modules/`.
- **Never** modify `.git/` or git config.
- **Never** delete files. Only edit or create.
- **Always** ask before applying > 5 changes in one batch.
- **Never** push to remote. Only suggest the commit.
