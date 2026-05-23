# Gumroad 上架资产 · prd-splitter

> 上架时直接 copy-paste。所有写法按转化最优做了。

---

## 商品基本信息

| 字段 | 值 |
|---|---|
| **Name** | `PRD Splitter for Claude Code` |
| **URL slug** | `prd-splitter`（最终：`https://duolakit.gumroad.com/l/prd-splitter`） |
| **Price** | `$19` (fixed) |
| **Currency** | USD |
| **Category** | Software & Apps |
| **Tags** | `claude-code`, `prd`, `linear`, `jira`, `agile`, `task-breakdown`, `developer-tools` |

---

## Cover image

`docs/cover.png`（1280×720，紫粉渐变 + 流程图 `PRD.md → 5 epics → 16 stories → Linear` + Fibonacci 主张行 + ∞ logo）。

---

## 商品描述（Gumroad 商品页正文，直接 copy）

```markdown
# PRD Splitter for Claude Code

**Your PRD is 6 pages. Your tracker wants 80 tickets. Half the team
over-decomposes into 120 noise items. The other half handwaves and forgets
cross-cutting work. That gap is where projects die.**

PRD Splitter is opinionated about the right size: **3-7 epics, 5-15 stories
per epic, mostly zero tasks per story.** Fibonacci-only estimates (no 4, no
6, no 7 — false precision suppressed by design). Cross-cutting epic is
always there. Acceptance criteria must be observable. Open questions get
tracked, never hallucinated over.

The result: a tree your team can actually estimate, schedule, and ship.

---

## What you get

- ✓ Lifetime license key for `prd-splitter` Pro
- ✓ Plugin installable via `/plugin install prd-splitter@duolakit`
- ✓ `/prd-push linear` — direct GraphQL push to Linear, dry-run default,
   idempotent on re-run (won't duplicate issues)
- ✓ `prd-reviewer` Pro sub-agent that second-opinions 8+ point stories:
   confirm, downgrade, or propose a clean split
- ✓ Persistent per-project estimation calibration
- ✓ Email support within 48h
- ✓ All future Pro updates, forever

---

## Free vs Pro

| Feature | Free | Pro |
|---|---|---|
| `/prd-split` (PRD → epic/story tree) | ✓ | ✓ |
| `/prd-estimate` (Fibonacci, 13+ flagging) | ✓ | ✓ |
| `/prd-export linear` / `jira` / `markdown` (CSV) | ✓ | ✓ |
| `prd-reviewer` sub-agent on 8+ stories | — | **✓** |
| `/prd-push linear` direct GraphQL push | — | **✓** |
| Per-project calibration | session-only | **persistent** |
| Email support | community | **48h SLA** |
| Updates | forever | **forever** |
| Price | Free | **$19 one-time** |

Free tier is genuinely free forever. No rug-pull. Pro adds the API push
(skip CSV detour), the reviewer agent (catch over-sized stories before
ticketing), and persistent calibration.

---

## What makes the output usable

Most "PRD → tickets" tools fail because they mechanically turn every bullet
into an issue. PRD Splitter is opinionated:

- **Refuses > 50 stories per PRD pass.** Big PRDs get split section-at-a-time.
- **No 4 / 6 / 7 points.** Forces Fibonacci. Estimates feel more honest because they're less precise.
- **Cross-cutting epic always present.** Auth, observability, compliance, deploy — none get forgotten.
- **Open questions tracked, not hallucinated.** Plugin lists them under `## Open questions` rather than making things up.
- **Reviewer agent challenges 8+ stories** (Pro). Second opinion: confirm, downgrade, propose split.

---

## How it works (30 seconds)

1. Install: `/plugin marketplace add duolaAmengweb3/duolakit`
2. Install: `/plugin install prd-splitter@duolakit`
3. Activate Pro: `/prd-activate <your-license-key>`
4. In a project with `PRD.md`:
   ```
   /prd-split
   /prd-estimate
   /prd-push linear         # dry-run shows the plan
   /prd-push linear --no-dry-run    # actually creates issues
   ```
5. Done. 16 issues in Linear, idempotent (re-runs update, don't duplicate).

---

## Why this exists

Built by [@hunterweb303](https://x.com/hunterweb303), a Claude Code power
user who spent too many Monday mornings translating PMs' Notion pages into
Linear backlogs by hand. After the third "wait this story is really 13
points" mid-implementation, the rules baked into this plugin were born.

Same author maintains [mimo-tui](https://mimo-tui.pages.dev) and the
other duolakit plugins.

This is plugin #3 in the [duolakit](https://duolakit.pages.dev) matrix —
production-grade tools for Claude Code power users.

---

## Refund policy

14-day no-questions-asked. Email `noreply@duolakit.pages.dev` or DM
[@hunterweb303](https://x.com/hunterweb303) on X.

---

## FAQ

**Q: Does it support Jira?**
A: Free `/prd-export jira` produces a CSV you can import. Direct GraphQL
   push to Jira is not in v1.0 — Linear-only for the Pro `/prd-push`.

**Q: Does it support Confluence / Notion as input?**
A: Pasted Markdown works (paste into the PRD.md file). Direct Notion DB
   sync is in the roadmap; not in v1.0.

**Q: What if I disagree with an estimate?**
A: Tell the plugin in chat. It accepts your correction and recalibrates
   similar-shape stories in the same project. Pro persists calibration
   to `~/.duolakit/prd-splitter-calibration.json`; Free is session-only.

**Q: Will it push to Linear without my permission?**
A: No. `/prd-push linear` always dry-runs first. You must add
   `--no-dry-run` to actually create issues. After that, the plugin asks
   "Really push N issues? y/N" when N > 50.

**Q: What if I push, then split the PRD differently next week?**
A: Plugin tracks `~/.duolakit/prd-splitter-mapping.json`. Re-running
   `/prd-push linear` for the same PRD updates existing issues
   (estimate, description) rather than creating new ones. You're asked
   to confirm any update.

**Q: Does it store my Linear API key?**
A: Never. `LINEAR_API_KEY` is read from env on every call. Plugin
   refuses to write it to any file. In mock mode (for testing), the key
   is auto-masked in output (`lin_...34`, never the full key).

**Q: How is the license delivered?**
A: Immediately after purchase. Email arrives within 5 minutes. Inside
   Claude Code, run `/prd-activate <key>` once per machine.

---

## Made by duola

- X: [@hunterweb303](https://x.com/hunterweb303)
- GitHub: [duolaAmengweb3/duolakit](https://github.com/duolaAmengweb3/duolakit)
- Telegram: [t.me/dsa885](https://t.me/dsa885)
```

---

## Gumroad 设置开关

- [x] **Generate license keys** — 必勾
- [x] **Allow ratings & reviews** — 勾
- [x] **Allow refunds within 14 days** — 默认
- [ ] **Send tip prompt** — **不勾**
- [x] **Custom delivery email** — "Thanks! Your license: {{license_key}}. Activate with /prd-activate <key> inside Claude Code."

---

## Demo 视频脚本（30 秒）

### Frame 1 · Hook（0-5s）
**画面**：编辑器打开 `BookmarkBird-PRD.md`，6 页 Markdown 滚动展示
**字幕**：`PRD 6 pages. Tracker wants 80 tickets. Where's the right split?`

### Frame 2 · 一行命令（5-10s）
**画面**：Claude Code 窗口跑 `/prd-split sample-prd.md`
**字幕**：`/prd-split`

### Frame 3 · 结果（10-16s）
**画面**：生成的 `PRD-tree.md` 文件，5 个 epic + 16 个 story 展开
**字幕**：`5 epics. 16 stories. Cross-cutting auto-detected.`

### Frame 4 · 估算（16-22s）
**画面**：跑 `/prd-estimate`，每个 story 打上 Fibonacci 点数，summary footer 显示 73 points / 37 dev-days
**字幕**：`/prd-estimate — Fibonacci only. 73 pts. 13+ flagged for re-split.`

### Frame 5 · Pro 推送（22-27s）
**画面**：跑 `/prd-push linear`，dry-run 表格 → 用户按 y → 16 行 ✓ ENG-241..256
**字幕**：`/prd-push linear → 16 issues in Linear, idempotent.`

### Frame 6 · CTA（27-30s）
**画面**：duolakit.pages.dev + Gumroad 商品页
**字幕**：`duolakit.pages.dev · $19 lifetime`

---

## 上架后立即做的 3 件事

1. plugin README 顶部加 Gumroad 链接
2. landing 03 卡片改成 link 到 Gumroad
3. 发首条 X 长推（见 `docs/X-LAUNCH-POST.md`）

---

## License Key 验证机制（已实装 v1.0）

同 SKU-01 / SKU-02：`bin/license.sh` 调 Gumroad `/v2/licenses/verify`，写
`~/.duolakit/licenses.json` 的 `prd-splitter` slot。Pro 命令（`/prd-push`、
`/prd-estimate` 的 reviewer agent）都先 `bash bin/license.sh check`，
退出 1 直接拒绝。

**上架后唯一改动**：把 `bin/license.sh` 里的
`GUMROAD_PRODUCT_ID="PLACEHOLDER_REPLACE_AT_GUMROAD_LAUNCH"` 换成 Gumroad 给的真 ID。
