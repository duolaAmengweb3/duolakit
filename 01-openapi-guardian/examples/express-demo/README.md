# express-demo · openapi-guardian

A tiny Express + OpenAPI project to demo `openapi-guardian` in 5 minutes.

It ships with **intentional drift**:
- Spec declares `DELETE /users/{id}` but the handler is missing.
- Run `/openapi-check` and watch it caught.
- Run `/openapi-sync` and watch it fixed.

## Setup

```bash
cd examples/express-demo
npm install
npm run dev
```

Server starts on `http://localhost:3000`. Set `PORT` to override:

```bash
PORT=3344 npm run dev
```

Smoke test it:

```bash
curl http://localhost:3000/users                                        # → []
curl -X POST http://localhost:3000/users -H 'content-type: application/json' \
     -d '{"email":"alice@example.com","name":"Alice"}'                   # → 201 with user
curl -X DELETE http://localhost:3000/users/<id>                          # → 404 (intentional drift)
```

## Try the drift detection (in Claude Code)

Open this folder in Claude Code (`cd examples/express-demo && claude`), then:

```
/openapi-check
```

Expected output (abbreviated):

```
┌────────────────────────────┬──────┬──────┬──────┐
│ Operation                  │ Spec │ Route│ Types│
├────────────────────────────┼──────┼──────┼──────┤
│ GET    /users              │  ✓   │  ✓   │  ✓   │
│ POST   /users              │  ✓   │  ✓   │  ✓   │
│ GET    /users/{id}         │  ✓   │  ✓   │  ✓   │
│ DELETE /users/{id}         │  ✓   │  ✗   │  ✓   │
└────────────────────────────┴──────┴──────┴──────┘

Drift: 1
Most critical: DELETE /users/{id} (missing handler — clients will 404)
```

## Try the auto-sync

```
/openapi-sync
```

It will:
1. Detect the missing `DELETE /users/{id}` handler.
2. Ask you to confirm.
3. Add a handler to `routes/users.ts` that follows the existing style.
4. Run `tsc --noEmit` to verify.

## Regenerate types manually

If you change `openapi.yaml`:

```bash
npm run api:types
```

Or just run `/openapi-sync` in Claude Code — it does that and more.
