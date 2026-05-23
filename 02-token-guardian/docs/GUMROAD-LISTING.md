# Gumroad 上架资产 · token-guardian

> 上架时直接 copy-paste。所有写法按转化最优做了。

---

## 商品基本信息

| 字段 | 值 |
|---|---|
| **Name** | `Token Guardian for Claude Code` |
| **URL slug** | `token-guardian`（最终：`https://duolakit.gumroad.com/l/token-guardian`） |
| **Price** | `$9` (fixed) |
| **Currency** | USD |
| **Category** | Software & Apps |
| **Tags** | `claude-code`, `token`, `budget`, `monitoring`, `openrouter`, `developer-tools` |

---

## Cover image

文件已生成：`docs/cover.png`（1280×720，紫粉渐变 + 用量进度条 + ETA 行 + ∞ logo）。直接上传到 Gumroad。

---

## 商品描述（Gumroad 商品页正文，直接 copy）

```markdown
# Token Guardian for Claude Code

**Stop blowing through your 5h window without warning.**

3 hours into a refactor. Suddenly `rate_limit_exceeded`. You wait 90 minutes,
lose context, miss the deploy window. This is the meme of 2026 Q1 — and it
keeps happening because Claude Code doesn't tell you how close you are.

**Token Guardian tracks every tool call, warns you ~30 minutes before you hit
the wall, and (Pro) recommends an OpenRouter fallback with the cost/quality
trade-off explicit.**

---

## What you get

- ✓ Lifetime license key for `token-guardian` Pro
- ✓ Plugin installable via `/plugin install token-guardian@duolakit`
- ✓ `/token-route` — Pro routing recommendation for OpenRouter (Claude / DeepSeek / Gemini / o1-mini)
- ✓ `/token-calibrate` persistent across sessions + rolling 7-day history
- ✓ `prd-router`-style sub-agent for context-aware routing decisions
- ✓ Email support within 48h
- ✓ All future Pro updates, forever

---

## Free vs Pro

| Feature | Free | Pro |
|---|---|---|
| Activity logging (every tool call) | ✓ | ✓ |
| 5h-window budget tracking + threshold warning | ✓ | ✓ |
| Pace + ETA extrapolation | ✓ | ✓ |
| `/token-calibrate` against `/cost` | one-shot per session | **persistent + 7-day rolling history** |
| `/token-route` multi-provider routing | basic generic tip | **full decision matrix + sub-agent** |
| Settings.json / env snippet generation | — | **✓** |
| Email support | community | **48h SLA** |
| Updates | forever | **forever** |
| Price | Free | **$9 one-time** |

Free tier is genuinely free forever. No rug-pull. Pro adds the routing matrix + persistent calibration + support.

---

## How honest is the estimate?

Anthropic doesn't expose precise token counts to plugins. Token Guardian
uses a heuristic (`input_size / 4 + per-tool baseline`) which is typically
30-50% under Claude Code's own `/cost`. Pro `/token-calibrate` closes the
gap — paste `/cost` once and Pro re-tunes for your real workflow.

If you need precise per-second numbers, use Claude Code's built-in `/cost`.
Token Guardian is an alarm clock, not a stopwatch.

---

## How it works (30 seconds)

1. Install: `/plugin marketplace add duolaAmengweb3/duolakit`
2. Install: `/plugin install token-guardian@duolakit`
3. Activate Pro: `/token-activate <your-license-key>`
4. Use Claude Code normally. The PreToolUse hook logs every call.
5. When you cross the warn threshold (80% default), one stderr message:
   `[token-guardian] ⚠ Heads up: 180,400 / 220,000 tokens (~82%) in last 5h`
6. Run `/token-status` for pace + ETA. Or `/token-route` for the Pro fallback recommendation.

---

## Why this exists

Built by [@hunterweb303](https://x.com/hunterweb303), a Claude Code Max
power user who got tired of half-refactors dying to `rate_limit_exceeded`
on a Friday afternoon.

Same author maintains [mimo-tui](https://mimo-tui.pages.dev) (the native
MiMo terminal agent) and the other duolakit plugins.

This is plugin #2 in the [duolakit](https://duolakit.pages.dev) matrix —
production-grade tools for Claude Code power users.

---

## Refund policy

14-day no-questions-asked. Email `noreply@duolakit.pages.dev` or DM
[@hunterweb303](https://x.com/hunterweb303) on X.

---

## FAQ

**Q: Does this work offline?**
A: Yes. Everything runs locally inside Claude Code. No telemetry, no
   calls home (except the optional `/token-activate` Gumroad verification).

**Q: Will it slow down Claude Code?**
A: No. The PreToolUse hook is < 50ms per call. Even at 1000 tool calls per
   session, that's < 1 minute total overhead, distributed.

**Q: Does it know my exact token usage?**
A: No, and the README is honest about this. It estimates. For precise
   numbers use Claude Code's `/cost`. Pro `/token-calibrate` makes the
   estimate ~10% accurate by calibrating against your `/cost` output.

**Q: What providers does Pro routing support?**
A: OpenRouter as the unified gateway. Recommended models include Anthropic
   Claude 3.5 Sonnet (via proxy), OpenAI GPT-4.1 / o1-mini, Google Gemini
   2.0 Flash / 2.5 Pro, DeepSeek-chat. The matrix is updated each release.

**Q: Will Pro auto-switch my model?**
A: No. Switching always requires your explicit confirmation. Anti-feature
   by design — you should never be surprised which model just answered.

**Q: How is the license key delivered?**
A: Immediately after purchase, by email. Inside Claude Code, run
   `/token-activate <key>` once per machine. License is tied to your
   email, works on unlimited personal devices.

**Q: What's different from `ccusage` / `ccmonitor` / etc?**
A: Those are read-only dashboards over Anthropic's billing API. Token
   Guardian runs in-session in Claude Code itself — it warns you BEFORE
   you cross the limit, while you're still typing. And Pro gives you a
   one-command path off Claude when the wall is imminent.

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
- [x] **Custom delivery email** — "Thanks! Your license: {{license_key}}. Activate with /token-activate <key> inside Claude Code."

---

## Demo 视频脚本（30 秒）

### Frame 1 · Hook（0-5s）
**画面**：终端右下角 Claude Code 在工作，左侧屏幕上 `/cost` 显示用量已到 78%
**字幕**：`3 hours in. 78% of your 5h window gone. No warning until now.`

### Frame 2 · 痛点回放（5-10s）
**画面**：屏幕红色闪烁，`rate_limit_exceeded` 错误信息弹出
**字幕**：`Then it just stops. 90 minutes of waiting.`

### Frame 3 · 工具登场（10-16s）
**画面**：装上 token-guardian，过几秒后 stderr 弹出 `[token-guardian] ⚠ Heads up: 180,400 / 220,000 tokens (~82%)`
**字幕**：`token-guardian warns you ~30 min early.`

### Frame 4 · /token-status 输出（16-22s）
**画面**：跑 `/token-status`，显示进度条 + Pace + ETA 表格
**字幕**：`/token-status`

### Frame 5 · Pro 路由（22-27s）
**画面**：跑 `/token-route`，显示推荐切到 `openrouter/anthropic/claude-3.5-sonnet`，成本 + 质量摊开
**字幕**：`/token-route → fallback ready in 1 command.`

### Frame 6 · CTA（27-30s）
**画面**：duolakit.pages.dev + Gumroad 商品页
**字幕**：`duolakit.pages.dev · $9 lifetime`

---

## 上架后立即做的 3 件事

1. plugin README 顶部加 Gumroad 链接（已在 README 里）
2. landing 02 卡片改成 link 到 Gumroad
3. 发首条 X 长推（见 `docs/X-LAUNCH-POST.md`）

---

## License Key 验证机制（已实装 v1.0）

`bin/license.sh` 调 Gumroad `/v2/licenses/verify` 真校验。流程：

```bash
# User in Claude Code:
/token-activate ABCD-1234-EFGH-5678

# Internally:
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh activate ABCD-1234-EFGH-5678
# → POST https://api.gumroad.com/v2/licenses/verify
#     product_id=<TOKEN_GUARDIAN_PRODUCT_ID>
#     license_key=ABCD-1234-EFGH-5678
# → On success: write ~/.duolakit/licenses.json slot "token-guardian"
# → Pro commands (route, calibrate persistent) call license.sh check before doing anything
```

**上架后唯一要做的代码改动**：把 `bin/license.sh` 里的
`GUMROAD_PRODUCT_ID="PLACEHOLDER_REPLACE_AT_GUMROAD_LAUNCH"` 换成 Gumroad 给的真 ID。
