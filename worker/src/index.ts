/**
 * duolakit-license · Cloudflare Worker
 *
 * Endpoints:
 *   POST /ping?secret=<PING_SECRET>          DM-mode manual grant (no payment processor)
 *     - Body: application/x-www-form-urlencoded
 *     - Reads: email, product_permalink, sale_id, refunded, dispute_won, chargebacked
 *     - Used by bin/admin.sh grant / revoke
 *
 *   POST /creem-ping                          Creem webhook receiver (Chrome ext / SaaS sales)
 *     - Body: application/json (Creem standard webhook)
 *     - Headers: creem-signature (HMAC-SHA256 of body using CREEM_WEBHOOK_SECRET)
 *     - Events handled: checkout.completed → grant; refund.created → revoke
 *     - Auto-maps Creem product_id → plugin slug via CREEM_PRODUCT_MAP
 *
 *   GET /verify?plugin=<slug>&email=<email>   Plugin activation check
 *     - Returns 200 { valid, plugin, email }
 *
 * KV schema:
 *   key:    lic:<plugin>:<email_lowercased>
 *   value:  JSON { email, plugin, purchased_at, sale_id, source }
 *
 * Plugin slugs accepted:
 *   - Claude Code marketplace: openapi-guardian | token-guardian | prd-splitter
 *   - Chrome extensions:       claude-folders | (more added per product)
 */

export interface Env {
  LICENSES: KVNamespace;
  PING_SECRET: string;
  CREEM_WEBHOOK_SECRET?: string;
}

const ALLOWED_PLUGINS = new Set([
  // Claude Code marketplace plugins
  "openapi-guardian",
  "token-guardian",
  "prd-splitter",
  // Chrome extensions
  "claude-folders",
]);

// Map Creem product IDs → our internal plugin slug. Update this when adding
// new products in Creem dashboard. The product_id appears in the test-product
// creation API response (`prod_xxxxxxxxxx`).
const CREEM_PRODUCT_MAP: Record<string, string> = {
  // Claude Folders Pro (test mode)
  "prod_6tjenEZwXkhBNgvZfkBiyt": "claude-folders",
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function normalizeEmail(raw: string | null | undefined): string {
  return (raw ?? "").trim().toLowerCase();
}

async function hmacSha256Hex(secret: string, body: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(body));
  const bytes = new Uint8Array(sig);
  return [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");
}

function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return result === 0;
}

async function grantSlot(
  env: Env,
  plugin: string,
  email: string,
  sale_id: string,
  source: string,
): Promise<void> {
  const slot = {
    email,
    plugin,
    purchased_at: new Date().toISOString(),
    sale_id,
    source,
  };
  await env.LICENSES.put(`lic:${plugin}:${email}`, JSON.stringify(slot));
}

async function revokeSlot(env: Env, plugin: string, email: string): Promise<void> {
  await env.LICENSES.delete(`lic:${plugin}:${email}`);
}

// ─── /ping (manual / DM mode, used by bin/admin.sh) ──────────────────
async function handlePing(req: Request, env: Env): Promise<Response> {
  const url = new URL(req.url);
  if (url.searchParams.get("secret") !== env.PING_SECRET) {
    return json({ error: "unauthorized" }, 401);
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const form = new URLSearchParams(await req.text());
  const plugin = (form.get("product_permalink") ?? "").trim();
  const email = normalizeEmail(form.get("email"));
  const sale_id = form.get("sale_id") ?? form.get("id") ?? "";

  if (!ALLOWED_PLUGINS.has(plugin)) {
    return json({ ok: true, ignored: true, reason: "unknown plugin", plugin });
  }
  if (!email) {
    return json({ ok: true, ignored: true, reason: "no email" });
  }

  const refunded = ["true", "1"].includes((form.get("refunded") ?? "").toLowerCase());
  const disputeWon = ["true", "1"].includes((form.get("dispute_won") ?? "").toLowerCase());
  const chargebacked = ["true", "1"].includes((form.get("chargebacked") ?? "").toLowerCase());

  if (refunded || disputeWon || chargebacked) {
    await revokeSlot(env, plugin, email);
    return json({
      ok: true,
      action: "revoked",
      plugin,
      email,
      reason: refunded ? "refunded" : disputeWon ? "dispute_won" : "chargebacked",
    });
  }

  await grantSlot(env, plugin, email, sale_id, "ping");
  return json({ ok: true, action: "granted", plugin, email });
}

// ─── /creem-ping (Creem webhook) ─────────────────────────────────────
async function handleCreemPing(req: Request, env: Env): Promise<Response> {
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const rawBody = await req.text();

  // Verify HMAC-SHA256 signature if secret is configured.
  // Skip verification if not configured (test mode) but log it.
  if (env.CREEM_WEBHOOK_SECRET) {
    const headerSig = req.headers.get("creem-signature") ?? "";
    const computed = await hmacSha256Hex(env.CREEM_WEBHOOK_SECRET, rawBody);
    if (!headerSig || !constantTimeEqual(headerSig.toLowerCase(), computed.toLowerCase())) {
      return json({ error: "bad_signature" }, 401);
    }
  }

  let payload: any;
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return json({ error: "bad_json" }, 400);
  }

  const eventType: string = payload.eventType ?? payload.event_type ?? "";
  const obj = payload.object ?? {};
  const email = normalizeEmail(obj.customer?.email);
  const productId: string = (obj.product?.id ?? "").trim();
  const orderId: string = (obj.order?.id ?? obj.id ?? "").trim();

  const plugin = CREEM_PRODUCT_MAP[productId];
  if (!plugin) {
    // Acknowledge so Creem stops retrying, but flag that the product is unknown.
    return json({ ok: true, ignored: true, reason: "unmapped product_id", productId });
  }
  if (!email) {
    return json({ ok: true, ignored: true, reason: "no email" });
  }

  if (eventType === "checkout.completed" || eventType === "subscription.active" || eventType === "subscription.paid") {
    await grantSlot(env, plugin, email, orderId, `creem:${eventType}`);
    return json({ ok: true, action: "granted", plugin, email, event: eventType });
  }

  if (
    eventType === "refund.created" ||
    eventType === "subscription.canceled" ||
    eventType === "subscription.expired" ||
    eventType === "dispute.created"
  ) {
    await revokeSlot(env, plugin, email);
    return json({ ok: true, action: "revoked", plugin, email, event: eventType });
  }

  // Acknowledge unhandled events silently.
  return json({ ok: true, ignored: true, reason: "event not handled", event: eventType });
}

// ─── /verify ─────────────────────────────────────────────────────────
async function handleVerify(req: Request, env: Env): Promise<Response> {
  const url = new URL(req.url);
  const plugin = (url.searchParams.get("plugin") ?? "").trim();
  const email = normalizeEmail(url.searchParams.get("email"));

  if (!ALLOWED_PLUGINS.has(plugin)) {
    return json({ valid: false, plugin, email, reason: "unknown_plugin" }, 400);
  }
  if (!email) {
    return json({ valid: false, plugin, email, reason: "no_email" }, 400);
  }

  const got = await env.LICENSES.get(`lic:${plugin}:${email}`);
  return json({ valid: got !== null, plugin, email });
}

async function handleHealth(): Promise<Response> {
  return json({ ok: true, service: "duolakit-license", time: new Date().toISOString() });
}

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);
    const path = url.pathname;
    try {
      if (path === "/" || path === "/health") return handleHealth();
      if (path === "/ping") return handlePing(req, env);
      if (path === "/creem-ping") return handleCreemPing(req, env);
      if (path === "/verify") return handleVerify(req, env);
      return json({ error: "not_found", path }, 404);
    } catch (err: unknown) {
      return json(
        { error: "internal", message: err instanceof Error ? err.message : String(err) },
        500,
      );
    }
  },
};
