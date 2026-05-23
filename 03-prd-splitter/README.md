# prd-splitter · duolakit

> **Turn a long PRD into a clean epic → story → task tree with Fibonacci estimates.**
> Export to Markdown, Linear-CSV, or Jira-CSV. Pro pushes straight to Linear via API.

[![License](https://img.shields.io/badge/license-MIT-EC4899)](../LICENSE)
[![duolakit](https://img.shields.io/badge/duolakit-marketplace-6366F1)](https://duolakit.pages.dev)

[English](#english) · [中文](#中文)

---

## English

### The problem

Your PRD is 6 pages. Your tracker wants 80 tickets. The gap between them is where projects die — half the team over-decomposes into 120 noise tickets, the other half handwaves and forgets cross-cutting work.

**prd-splitter is opinionated about the right size**: 3-7 epics, 5-15 stories per epic, mostly zero tasks. Fibonacci-only estimates. Cross-cutting concerns explicit. Acceptance criteria observable. Opinionated enough that the output is actually usable.

### Install

```bash
/plugin marketplace add duolaAmengweb3/duolakit
/plugin install prd-splitter@duolakit
```

### Commands

| Command | What it does | Tier |
|---|---|---|
| `/prd-split [file]` | Read a PRD, produce `PRD-tree.md` (epic → story → acceptance criteria) | Free |
| `/prd-estimate` | Assign Fibonacci points to each story; reviewer agent on 8+ stories | Free / **Pro $19** (reviewer) |
| `/prd-export linear\|jira\|markdown` | Emit `PRD-tree.linear.csv` / `.jira.csv` / `.export.md` | Free |
| `/prd-push linear [--dry-run]` | Push stories straight to Linear via API (always dry-runs first) | **Pro $19** |
| `/prd-activate <email>` | Verify your purchase email, unlock Pro features | n/a |

### How it works

1. **`/prd-split sample.md`** — Claude reads your PRD, identifies natural epics, breaks each into ~3-15 user-facing stories, attaches 3-7 observable acceptance criteria per story. Writes `PRD-tree.md`.
2. **`/prd-estimate`** — Claude reads the tree, assigns Fibonacci points (1, 2, 3, 5, 8, 13 — no 4, no 6, no 7). Stories rated 13 get a "you should split this" callout with concrete sub-story proposals.
3. **`/prd-export linear`** — Mechanical CSV conversion, one row per story, epic as label, estimate as the Estimate field. Drag-and-drop import into Linear.
4. **`/prd-push linear`** (Pro) — Skip the CSV detour. Reads `LINEAR_API_KEY` from env, dry-runs to show you the plan, then creates issues directly via GraphQL on confirmation.

### What makes the output usable (vs auto-split slop)

Most "PRD → tickets" tools fail because they mechanically turn every bullet into an issue. prd-splitter is opinionated:

- **Fewer fatter epics.** If you'd produce > 50 stories, the plugin refuses and asks you to point at one PRD section at a time.
- **No 4 / 6 / 7.** Fibonacci exists to suppress false precision. The plugin enforces it.
- **Cross-cutting epic is always there.** Auth, observability, compliance, deploy — the plugin adds a `## Cross-cutting` section so these don't get forgotten.
- **Open questions are tracked, not hallucinated over.** If the PRD has "TBD" or contradictions, the plugin lists them under `## Open questions` and refuses to fabricate answers.
- **The reviewer sub-agent challenges 8+ point stories.** Pro gets a second opinion: confirm, downgrade, or propose a clean split.

### Free vs Pro

| Feature | Free | Pro $19 |
|---|---|---|
| `/prd-split` | ✓ | ✓ |
| `/prd-estimate` | ✓ | ✓ |
| `/prd-export markdown / linear / jira` | ✓ | ✓ |
| `prd-reviewer` second-opinion sub-agent | ❌ | ✓ |
| `/prd-push linear` (direct API push) | ❌ | ✓ |
| Calibration memory (your estimates re-tune the plugin) | one session | persistent per project |
| Email support | community | 48h SLA |

**Get Pro · $19 lifetime** — DM [@hunterweb303 on X](https://x.com/hunterweb303) or [t.me/dsa885](https://t.me/dsa885). Any payment method works (Alipay, WeChat, Stripe link, PayPal, USDT, bank transfer — pick what fits you). You'll get activation within minutes.

### Try it in 5 minutes

```bash
cd examples
bash smoke-test.sh                    # validates 20 assertions
# Then in Claude Code:
/prd-split sample-prd.md
/prd-estimate
/prd-export linear
```

Compare your output to `examples/expected-tree.md` — yours will be similar but not identical (the skill exercises judgment).

### Anti-features

- ❌ No SaaS — runs locally inside Claude Code.
- ❌ No telemetry — no calls home, no PRD content leaves your machine (except Pro `/prd-push`, which is explicitly your call).
- ❌ No API key stored — `LINEAR_API_KEY` is read from env every call, never written to disk.
- ❌ No "auto-push" — every push to Linear dry-runs first and requires explicit `--no-dry-run`.
- ❌ No over-decomposition — the plugin refuses > 50 stories per PRD pass and asks you to chunk the input.

### What's in v1.0 (today)

- `/prd-split`, `/prd-estimate`, `/prd-export linear|jira|markdown` (all Free)
- `/prd-push linear` (Pro) — direct GraphQL push, always dry-runs first, idempotent on re-run
- `prd-reviewer` Pro sub-agent that gives a second opinion on 8+ point stories
- `prd-expert` skill with the "fewer fatter epics / Fibonacci only / never fabricate" judgment baked in
- `/prd-activate <purchase-email>` verifies against the duolakit license Worker in real-time
- Sample PRD ("BookmarkBird") + expected output for end-to-end demo

### What's next (not in v1.0)

- `/prd-push jira` direct GraphQL push (today: CSV via `/prd-export jira` works fine)
- Notion source (read PRDs from a Notion database)
- Reverse sync (pull updated estimates from Linear back into PRD-tree.md)
- Watch mode (auto-suggest re-estimate when PRD-tree.md changes)

### License

[MIT](../LICENSE) for the plugin source. Pro features (push, reviewer) verified via the duolakit license Worker (Cloudflare KV + your purchase email).

---

## 中文

### 解决什么问题

PRD 6 页，tracker 想要 80 张票，中间这段断层是项目搞砸的地方——一半团队过度拆分到 120 张噪音票，另一半挥手而过，把横切关注点忘光。

**prd-splitter 对"正确的颗粒度"很有主见**：3-7 个 epic、每个 epic 5-15 个 story、大部分 story 没有 task。强制 Fibonacci 估算。横切显式列出。验收标准必须可观察。这种"有主见"才是输出真正能用的原因。

### 安装

```bash
/plugin marketplace add duolaAmengweb3/duolakit
/plugin install prd-splitter@duolakit
```

### 命令

| 命令 | 作用 | 等级 |
|---|---|---|
| `/prd-split [file]` | 读 PRD，产出 `PRD-tree.md`（epic → story → 验收标准） | 免费 |
| `/prd-estimate` | 给 story 打 Fibonacci 点；8+ story 触发 reviewer 子 agent | 免费 / **Pro $19**（reviewer） |
| `/prd-export linear\|jira\|markdown` | 导出 `.linear.csv` / `.jira.csv` / `.export.md` | 免费 |
| `/prd-push linear [--dry-run]` | 直推 Linear（默认 dry-run，要确认） | **Pro $19** |
| `/prd-activate <email>` | 校验购买邮箱，解锁 Pro | — |

### 工作原理

1. **`/prd-split sample.md`** — Claude 读你的 PRD，识别 epic 边界，每个拆 ~3-15 个面向用户的 story，每个 story 配 3-7 条可观察的验收标准。写到 `PRD-tree.md`。
2. **`/prd-estimate`** — Claude 读 tree，打 Fibonacci 点（1, 2, 3, 5, 8, 13 —— 不准用 4、6、7）。13 分的会带"该拆"提示 + 拆分建议。
3. **`/prd-export linear`** — 机械转 CSV，一 row 一个 story，epic 当 label。拖进 Linear 就完事。
4. **`/prd-push linear`** (Pro) — 跳过 CSV。从 env 读 `LINEAR_API_KEY`，先 dry-run 展示计划，确认后直接 GraphQL 建 issue。

### 凭什么输出能用（不是机械拆分的垃圾）

大多数"PRD → 票"工具失败是因为它们把每个 bullet 都当成 issue。prd-splitter 有主见：

- **少而胖的 epic**。如果你一次性产出 > 50 story，插件会拒绝并让你按 section 分次拆。
- **不准 4 / 6 / 7**。Fibonacci 就是拿来压制假精度的。强制。
- **永远有 Cross-cutting epic**。auth / 观测 / 合规 / 部署不会被遗忘。
- **未决问题被追踪，不被脑补**。PRD 里"TBD"或者自相矛盾的地方会被列到 `## Open questions`，绝不编答案。
- **reviewer 子 agent 挑战 8+ 分的 story**。Pro 会拿到第二意见：确认 / 降级 / 拆。

### 免费版 vs Pro

| 功能 | 免费 | Pro $19 |
|---|---|---|
| `/prd-split` | ✓ | ✓ |
| `/prd-estimate` | ✓ | ✓ |
| `/prd-export markdown / linear / jira` | ✓ | ✓ |
| `prd-reviewer` 二次意见子 agent | ❌ | ✓ |
| `/prd-push linear` 直接 API 推送 | ❌ | ✓ |
| 校准记忆（你的修正会调教插件） | 单会话 | 项目级持久 |
| 邮件支持 | 社区 | 48h SLA |

**买 Pro · $19 永久** — DM [@hunterweb303 (X)](https://x.com/hunterweb303) 或 [t.me/dsa885](https://t.me/dsa885)。任意付款方式（支付宝 / 微信 / Stripe / PayPal / USDT / 银行转账 / etc.），几分钟内激活。

### 5 分钟试

```bash
cd examples
bash smoke-test.sh                    # 20 个断言全过
# 然后在 Claude Code:
/prd-split sample-prd.md
/prd-estimate
/prd-export linear
```

对比你的输出和 `examples/expected-tree.md` —— 会相似但不会一模一样（skill 是有判断力的）。

### 不会做的事

- ❌ 不做 SaaS — 全部本地跑在 Claude Code 里。
- ❌ 不上报数据 — 不联网（除了 Pro `/prd-push`，那是你明确触发的）。
- ❌ 不存 API key — `LINEAR_API_KEY` 每次从 env 读，绝不落盘。
- ❌ 不自动推送 — 每次推 Linear 都先 dry-run，要你加 `--no-dry-run`。
- ❌ 不过度拆分 — 单次 PRD pass 超过 50 个 story 直接拒绝，要你按 section 分批。

### 联系

- X · [@hunterweb303](https://x.com/hunterweb303)
- Telegram · [t.me/dsa885](https://t.me/dsa885)
- Issues · [github.com/duolaAmengweb3/duolakit/issues](https://github.com/duolaAmengweb3/duolakit/issues)

### License

[MIT](../LICENSE)（plugin 源码）+ Pro 功能通过 duolakit license Worker 校验（Cloudflare KV + 你的购买邮箱）。
