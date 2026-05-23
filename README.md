# ∞ duolakit

> **Independent tools for Claude Code power users.**
> Real workflows, not framework wrappers. MIT core, optional Pro for advanced features.

[![Marketplace](https://img.shields.io/badge/Claude%20Code-marketplace-6366F1)](https://duolakit.pages.dev)
[![License](https://img.shields.io/badge/license-MIT-EC4899)](./LICENSE)
[![X](https://img.shields.io/badge/X-@hunterweb303-000000)](https://x.com/hunterweb303)

---

## Install

```bash
# In Claude Code, add the duolakit marketplace once:
/plugin marketplace add duolaAmengweb3/duolakit

# Then install any plugin:
/plugin install hello@duolakit
/plugin install openapi-guardian@duolakit
```

---

## Available plugins

| # | Plugin | Status | What it does | Pro |
|---|---|---|---|---|
| 00 | [hello](./00-hello) | ✅ Live | Sanity check that the install pipeline works | — |
| 01 | [openapi-guardian](./01-openapi-guardian) | ✅ Live | OpenAPI ↔ routes ↔ types ↔ SDK 4-way sync | $19 |
| 02 | [token-guardian](./02-token-guardian) | ✅ Live | Heuristic 5h-window budget guard + OpenRouter routing (Pro) | $9 |
| 03 | [prd-splitter](./03-prd-splitter) | ✅ Live | PRD → epic/story/task tree with Fibonacci estimates + Linear push (Pro) | $19 |

---

## Why duolakit

Claude Code has 9,000+ plugins. About 100 are production-ready. **duolakit only ships plugins that meet 5 standards:**

- ✅ Unit tests + 30s demo video
- ✅ Bilingual README (中文 + English)
- ✅ Free-forever MIT core
- ✅ Clear Pro license boundary (if any)
- ✅ Monthly release cadence, issues answered within 30 days

Built by [duola](https://x.com/hunterweb303). Same author as [mimo-tui](https://mimo-tui.pages.dev).

---

## Status

`v1.0` — three production-grade plugins, full test suite, real-time license verification via Cloudflare Worker. Pro tiers are hard-gated by `bin/license.sh` in each plugin (not soft markdown promises). Pro purchase is DM-based: ping [@hunterweb303 on X](https://x.com/hunterweb303) or [t.me/dsa885](https://t.me/dsa885) — any payment method, any currency, no payment processor signup required.

## Verify everything works

```bash
bash tests/run-all.sh
```

Validates every plugin in the marketplace:
- JSON / markdown frontmatter / shell syntax
- SKU-01 Express demo (npm install, tsc, server boot, GET / POST / GET-by-id / DELETE-intentional-404)
- SKU-02 hook smoke test (logging, threshold warnings, dedupe, window aging, custom budget)
- SKU-03 PRD/tree validity + Linear push helper (mock mode, error paths, API-key masking)

---

## License

[MIT](./LICENSE) for plugin source code. Pro features (where applicable) have their own commercial license — see each plugin's `LICENSE.commercial` file.
