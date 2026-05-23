/**
 * duolakit-license · Cloudflare Worker
 *
 * Two endpoints:
 *   POST /ping?secret=<PING_SECRET>
 *     - Body: application/x-www-form-urlencoded (Gumroad ping format)
 *     - Reads: email, product_permalink, sale_id, refunded, dispute_won, chargebacked
 *     - Refund/dispute/chargeback → delete the KV slot
 *     - Otherwise                 → put the KV slot
 *     - Always returns 200 (so Gumroad doesn't retry storm)
 *
 *   GET /verify?plugin=<slug>&email=<email>
 *     - Returns 200 { valid: boolean, plugin, email }
 *     - No auth — readonly lookup that requires the exact email
 *
 * KV schema:
 *   key:    lic:<plugin>:<email_lowercased>
 *   value:  JSON { email, plugin, purchased_at, sale_id }
 *
 * Plugin slugs accepted (rejects anything else to avoid garbage in KV):
 *   openapi-guardian | token-guardian | prd-splitter
 *
 * Gumroad ping setup:
 *   In Gumroad → Settings → Advanced → Ping URL:
 *     https://duolakit-license.<your>.workers.dev/ping?secret=<PING_SECRET>
 */

export interface Env {
  LICENSES: KVNamespace;
  PING_SECRET: string;
}

const ALLOWED_PLUGINS = new Set([
  "openapi-guardian",
  "token-guardian",
  "prd-splitter",
]);

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function normalizeEmail(raw: string | null | undefined): string {
  return (raw ?? "").trim().toLowerCase();
}

async function handlePing(req: Request, env: Env): Promise<Response> {
  const url = new URL(req.url);
  if (url.searchParams.get("secret") !== env.PING_SECRET) {
    return json({ error: "unauthorized" }, 401);
  }
  if (req.method !== "POST") {
    return json({ error: "method_not_allowed" }, 405);
  }

  const formText = await req.text();
  const form = new URLSearchParams(formText);

  const plugin = (form.get("product_permalink") ?? "").trim();
  const email = normalizeEmail(form.get("email"));
  const sale_id = form.get("sale_id") ?? form.get("id") ?? "";

  if (!ALLOWED_PLUGINS.has(plugin)) {
    // Not one of our plugins — accept silently so Gumroad doesn't retry.
    return json({ ok: true, ignored: true, reason: "unknown plugin", plugin });
  }
  if (!email) {
    return json({ ok: true, ignored: true, reason: "no email" });
  }

  const refunded = ["true", "1"].includes(
    (form.get("refunded") ?? "").toLowerCase(),
  );
  const disputeWon = ["true", "1"].includes(
    (form.get("dispute_won") ?? "").toLowerCase(),
  );
  const chargebacked = ["true", "1"].includes(
    (form.get("chargebacked") ?? "").toLowerCase(),
  );

  const key = `lic:${plugin}:${email}`;

  if (refunded || disputeWon || chargebacked) {
    await env.LICENSES.delete(key);
    return json({
      ok: true,
      action: "revoked",
      plugin,
      email,
      reason: refunded ? "refunded" : disputeWon ? "dispute_won" : "chargebacked",
    });
  }

  const slot = {
    email,
    plugin,
    purchased_at: new Date().toISOString(),
    sale_id,
  };
  await env.LICENSES.put(key, JSON.stringify(slot));
  return json({ ok: true, action: "granted", plugin, email });
}

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
