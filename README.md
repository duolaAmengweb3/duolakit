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
| 01 | [openapi-guardian](./01-openapi-guardian) | 🚧 Building | OpenAPI ↔ routes ↔ types ↔ SDK 4-way sync | $19 |
| 02 | [token-guardian](./02-token-guardian) | 📅 Planned | Real-time token budget alerts + multi-provider fallback | $9 |
| 03 | [prd-splitter](./03-prd-splitter) | 📅 Planned | PRD → Linear/Jira ticket breakdown + estimation | $19 |

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

`v0.1` — bootstrapping. Repo public on day 1 to keep myself honest.

---

## License

[MIT](./LICENSE) for plugin source code. Pro features (where applicable) have their own commercial license — see each plugin's `LICENSE.commercial` file.
