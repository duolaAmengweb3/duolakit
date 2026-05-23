---
name: openapi-check
description: Detect drift between your OpenAPI spec, route handlers, TypeScript types, and SDK clients. Read-only — never modifies files.
argument-hint: "[optional: path to spec file, defaults to ./openapi.yaml]"
---

# /openapi-check

You are running the `openapi-check` command from the `openapi-guardian` plugin.

Your task: detect drift between the 4 components (spec / routes / types / SDK) and report what's out of sync. **Do not modify any files.** This is a read-only diagnostic.

## Procedure

1. **Locate the spec file.**
   - If the user passed an argument (e.g. `/openapi-check api/spec.yaml`), use that path.
   - Otherwise check for `openapi.yaml`, `openapi.json`, `schemas/openapi.yaml`, or `api/openapi.yaml` in this order.
   - If none found, ask the user where the spec lives.

2. **Discover handlers.**
   - Use `glob` to find route files: `src/routes/**/*.{ts,js}`, `src/controllers/**/*.{ts,js}`, `routes/**/*.{ts,js}`, `app/api/**/route.{ts,js}` (Next.js).
   - Read each file and extract: HTTP method + path + handler location (file:line).

3. **Discover types.**
   - Check for `src/types/api.d.ts`, `src/types/api.ts`, `types/api.d.ts`, `generated/api.d.ts`.
   - List all exported schema types.

4. **Discover SDK (optional).**
   - Check for `src/sdk/**`, `packages/sdk/**`, or `node_modules/@<scope>/sdk` if used.

5. **Compare and report.**

   For each operation in the spec, build a table:

   ```
   ┌────────────────────────────────────┬──────┬──────┬──────┬──────┐
   │ Operation                          │ Spec │ Route│ Types│ SDK  │
   ├────────────────────────────────────┼──────┼──────┼──────┼──────┤
   │ POST /users (createUser)           │  ✓   │  ✓   │  ✓   │  ✗   │
   │ GET /users/{id} (getUser)          │  ✓   │  ✓   │  ✓   │  ✓   │
   │ DELETE /users/{id} (deleteUser)    │  ✓   │  ✗   │  ✓   │  ✗   │
   │ GET /products (listProducts)       │  ✗   │  ✓   │  ✗   │  ✗   │
   └────────────────────────────────────┴──────┴──────┴──────┴──────┘
   ```

   Then for each row with at least one `✗`, give a one-line explanation of what's missing and which file to edit:

   ```
   ✗ DELETE /users/{id}
     - Missing handler. Add to src/routes/users.ts
     - Missing in SDK. Will be auto-generated when you run /openapi-sync
   
   ✗ GET /products
     - Handler exists at src/routes/products.ts:18 but not in spec
     - Either add to openapi.yaml or remove the handler if it's dead code
   ```

6. **Summarize.**

   End with a 3-line summary:

   ```
   Operations in sync:        12 / 15
   Drift detected:            3
   Most critical:             DELETE /users/{id} (missing handler — clients will 404)
   ```

7. **Suggest next step.** Tell the user they can run `/openapi-sync` to fix automatically, or fix manually based on the report.

## What you must NOT do

- Don't modify any files. This is `check`, not `sync`.
- Don't run shell commands (no `openapi-typescript`, no `prettier`). Just read.
- Don't guess if a file doesn't exist — ask the user.
- Don't report drift for `examples/` or `tests/` files (those are intentional).

## Free vs Pro — enforced via license check

**Before scanning multiple spec files OR non-Express frameworks**, shell out to:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh check
```

Exit `0` → Pro active, scan everything.
Exit `1` → Free, restrict to one spec + Express handlers.

| Tier | What `/openapi-check` scans |
|---|---|
| Free | First spec file found + Express routes only |
| Pro  | All spec files (multi-service) + Express / Fastify / Hono / NestJS routes |

When skipping a non-Express handler on Free, note it in the output:

```
⚠ Skipped: src/services/auth/openapi.yaml (Pro only — multi-service)
⚠ Skipped: src/routes/fastify-auth.ts  (Pro only — non-Express framework)

  Pro: https://duolakit.gumroad.com/l/openapi-guardian
  Activate: /openapi-activate <license-key>
```
