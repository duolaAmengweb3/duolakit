# duolakit-license · Cloudflare Worker

Real-time Gumroad webhook receiver + license verification proxy.

## Why this exists

Gumroad's UI (as of 2026-05) doesn't expose a per-product "Generate license keys" toggle on standard digital products. So we built our own:

```
Buyer → Gumroad checkout → Gumroad pings this Worker → Worker writes email to KV
                                                          ↑
Buyer runs /<plugin>-activate <email> ────────────────────┘
                                                          ↓
                                  Worker reads KV → returns {valid: true}
                                                          ↓
                                  Plugin writes ~/.duolakit/licenses.json
```

Refunds, disputes, and chargebacks fire the same Ping with `refunded/dispute_won/chargebacked = true` — the Worker auto-deletes the KV entry. Within seconds of a refund, the email stops working.

## Endpoints

| Method · path | Purpose |
|---|---|
| `GET /` or `/health` | Liveness check (returns timestamp) |
| `POST /ping?secret=<PING_SECRET>` | Gumroad webhook receiver |
| `GET /verify?plugin=<slug>&email=<email>` | Plugin asks "is this email a buyer?" → returns `{valid: bool}` |

Accepted plugin slugs (anything else is silently ignored on `/ping`, 400-rejected on `/verify`):
- `openapi-guardian`
- `token-guardian`
- `prd-splitter`

## Production URL

```
https://duolakit-license.hxu92521.workers.dev
```

KV namespace: `LICENSES` (id `4342b826953b4576b1a71860aa1e5d66`)
Secret: `PING_SECRET` (32-byte hex, set via `wrangler secret put`)

## Gumroad setup (one-time, per product)

In Gumroad → Settings → Advanced → Ping URL (or per-product webhook), set:

```
https://duolakit-license.hxu92521.workers.dev/ping?secret=<PING_SECRET>
```

The PING_SECRET is whatever you set in step 1 of "Deploy from scratch" below. Save the value — you'll need it both to set the Gumroad URL AND to invoke `/ping` for testing.

## Deploy

```bash
cd worker
npm install
npx wrangler deploy
```

## Deploy from scratch (if you ever need to recreate)

```bash
cd worker
npm install
# 1. Generate a random secret
PING_SECRET=$(openssl rand -hex 32)
echo "$PING_SECRET"  # save this!
# 2. Upload as Worker secret
echo "$PING_SECRET" | npx wrangler secret put PING_SECRET
# 3. Create KV namespace
npx wrangler kv namespace create LICENSES
# Copy the printed id into wrangler.toml's [[kv_namespaces]] id
# 4. Deploy
npx wrangler deploy
# 5. Update plugin bin/license.sh files if the Worker URL changes
```

## Test against deployed Worker

```bash
WORKER=https://duolakit-license.hxu92521.workers.dev
SECRET="<your ping secret>"

# Health
curl -s "${WORKER}/" | jq

# Simulate a purchase
curl -X POST "${WORKER}/ping?secret=${SECRET}" \
  -d "email=test@example.com" \
  -d "product_permalink=openapi-guardian" \
  -d "sale_id=TEST-1"

# Verify it's there
curl -s "${WORKER}/verify?plugin=openapi-guardian&email=test@example.com" | jq

# Simulate a refund
curl -X POST "${WORKER}/ping?secret=${SECRET}" \
  -d "email=test@example.com" \
  -d "product_permalink=openapi-guardian" \
  -d "refunded=true"

# Verify it's gone
curl -s "${WORKER}/verify?plugin=openapi-guardian&email=test@example.com" | jq
```

## Local dev

```bash
npx wrangler dev    # runs at http://localhost:8787
```

Plugins can be pointed at the local dev Worker via env var:

```bash
DUOLAKIT_VERIFY_URL=http://localhost:8787/verify \
  bash ../01-openapi-guardian/bin/license.sh activate test@example.com
```

## Cost

Free tier covers:
- 100,000 Worker requests/day (we'll see < 100/day even at 1000 sales)
- 100,000 KV reads/day, 1,000 writes/day
- 1 GB KV storage

If we exceed (~1k sales/day), Workers Paid is $5/month for 10M reqs.
