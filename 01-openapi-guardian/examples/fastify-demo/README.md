# fastify-demo · openapi-guardian (Pro)

The same spec + same intentional drift as `express-demo`, but with Fastify route handlers instead of Express. Use this to verify that **Pro tier actually works** for Fastify projects.

## What's the same vs express-demo

| | express-demo | fastify-demo |
|---|---|---|
| `openapi.yaml` | Identical | Identical |
| `types/api.d.ts` | Identical (generated from spec) | Identical |
| `routes/users.ts` | Express `Router` | Fastify plugin |
| Intentional drift | DELETE /users/{id} missing | DELETE /users/{id} missing |

The drift is the same — only the framework differs.

## Setup

```bash
cd examples/fastify-demo
npm install
npm run dev     # server on :3000 (override with PORT=...)
```

Smoke test:

```bash
curl http://localhost:3000/users                                          # → []
curl -X POST http://localhost:3000/users \
     -H 'content-type: application/json' \
     -d '{"email":"alice@example.com","name":"Alice"}'                     # → 201
curl -X DELETE http://localhost:3000/users/<id>                            # → 404 (intentional)
```

## Drive openapi-guardian against it

```bash
# Free tier (no license):
/openapi-check
# → "Skipped: Fastify routes are Pro only. Buy: ... / Activate: /openapi-activate <key>"

# After activation:
/openapi-activate <your-key>
/openapi-check
# → drift table including the DELETE row

/openapi-sync
# → writes the DELETE handler using Fastify's app.delete<{ Params: { id: string } }>(...) pattern
```

If you don't have a Pro license yet, you can simulate one for local testing:

```bash
bash ../../bin/license.sh --mock-success activate TEST-FASTIFY-KEY
/openapi-check         # now scans Fastify routes
bash ../../bin/license.sh deactivate    # remove the mock when done
```

## Why this demo exists

To prove the Pro promise is backed by working code, not just markdown. If a customer pays $19 for Fastify support, they get an immediately-runnable demo to verify against.
