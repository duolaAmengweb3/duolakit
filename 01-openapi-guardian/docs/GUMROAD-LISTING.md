# Gumroad 上架资产 · openapi-guardian

> 上架 Gumroad 时直接 copy-paste 这些字段。所有写法已经按转化最优做了。

---

## 商品基本信息

| 字段 | 值 |
|---|---|
| **Name** | `OpenAPI Guardian for Claude Code` |
| **URL slug** | `openapi-guardian`（最终链接：`https://duolakit.gumroad.com/l/openapi-guardian`） |
| **Price** | `$19` (fixed) |
| **Currency** | USD |
| **Category** | Software & Apps |
| **Tags** | `claude-code`, `openapi`, `typescript`, `developer-tools`, `productivity` |

---

## Cover image 规格

| 维度 | 值 |
|---|---|
| 尺寸 | 1280 × 720 px |
| 格式 | PNG |
| 内容 | 大字 "**OpenAPI Guardian**" + 副标 "Claude Code plugin · $19" + 紫粉渐变背景 + ∞ logo |
| 模板位置 | 用 Figma / Canva 拼，10 分钟 |

参考视觉：跟 duolakit.pages.dev hero 同色调（紫粉渐变 + JetBrains Mono 字体）

---

## 商品描述（Gumroad 商品页正文，直接 copy）

```markdown
# OpenAPI Guardian for Claude Code

**Stop chasing schema drift across your codebase.**

Every time you change an OpenAPI spec, four other places need updates:

- Route handlers
- TypeScript types
- SDK clients  
- Test fixtures

Forget one and prod breaks. Remember all four and waste 30 minutes per change.

**OpenAPI Guardian watches your spec and auto-syncs all four**, inside your Claude Code session.

---

## What you get

- ✓ Lifetime license key for `openapi-guardian` Pro
- ✓ Plugin installable via `/plugin install openapi-guardian@duolakit`
- ✓ Unlimited services (vs free = 1 spec file)
- ✓ Fastify + Hono + NestJS support (vs free = Express only)
- ✓ Team schema registry (sync schemas across repos)
- ✓ Email support within 48h
- ✓ All future Pro updates, forever

---

## Free vs Pro

| Feature | Free | Pro |
|---|---|---|
| Spec files watched | 1 | **Unlimited** |
| Frameworks | Express | **Express + Fastify + Hono + NestJS** |
| Multi-service registry | — | **✓** |
| Team schema registry | — | **✓** |
| Support | Community | **Email 48h SLA** |
| Updates | Forever | **Forever** |
| Price | Free | **$19 one-time** |

Free tier is genuinely free forever. No rug-pull. Pro adds breadth + support.

---

## How it works (30 seconds)

1. Install: `/plugin marketplace add duolaAmengweb3/duolakit`
2. Install: `/plugin install openapi-guardian@duolakit`  
3. In your project, run `/openapi-check` — see drift in seconds.
4. Run `/openapi-sync` — fix it. Every write is confirmed by you.

Demo video: [link to YouTube]

---

## Why this exists

Built by [@hunterweb303](https://x.com/hunterweb303), a Claude Code power user who got tired of fixing schema drift bugs at 11pm.

Same author maintains [mimo-tui](https://mimo-tui.pages.dev) — the native MiMo terminal agent.

This is plugin #1 in the [duolakit](https://duolakit.pages.dev) matrix — production-grade tools for Claude Code power users.

---

## Refund policy

14-day no-questions-asked refund. Email `noreply@duolakit.pages.dev` or DM [@hunterweb303](https://x.com/hunterweb303) on X.

---

## FAQ

**Q: Does this work without internet?**  
A: Yes. Plugin runs 100% locally inside Claude Code. No SaaS, no telemetry, no calls home.

**Q: What if I'm not using Express?**  
A: The plugin still installs and reads your spec. Free tier only writes Express handlers. Pro unlocks Fastify, Hono, NestJS auto-write.

**Q: Does it lock me in?**  
A: No. Your code lives in your repo. Uninstall any time — your files don't change.

**Q: How is the license key delivered?**  
A: Immediately after purchase. Gumroad emails it to you. Inside Claude Code, run `/duolakit-activate <key>` to unlock Pro features. (Activation command ships in next version of the `hello` plugin — for now Pro detection is automatic via Gumroad license API.)

**Q: Will the license work across multiple computers?**  
A: Yes — tied to your email, not your machine. Personal use across all your devices.

**Q: What's the difference between this and `swagger-codegen` / `openapi-typescript` / etc?**  
A: Those generate code one-way (spec → types). OpenAPI Guardian also detects drift the other direction (code → spec mismatch), runs inside your Claude Code session, and uses an OpenAPI-expert skill so changes feel idiomatic for your specific framework.

**Q: I'm a solo developer — is this worth $19?**  
A: If you fix 1 schema-drift production bug per year because of this, you've already saved 5-10× the price (1 hour of triage + fix + deploy ≈ $100+). Multiply by team size.

---

## Made by duola

- X: [@hunterweb303](https://x.com/hunterweb303)
- GitHub: [duolaAmengweb3/duolakit](https://github.com/duolaAmengweb3/duolakit)
- Telegram: [t.me/dsa885](https://t.me/dsa885)
```

---

## Gumroad 设置开关（在商品发布页面找）

- [x] **Generate license keys** — 必勾，每个买家拿到唯一 key
- [x] **Allow ratings & reviews** — 勾，社会证明
- [x] **Allow refunds within 14 days** — 默认勾，保留
- [ ] **Send tip prompt** — **不勾**（降低转化）
- [ ] **Custom delivery email** — 可选，写一句 "Thanks for buying! Your license: {{license_key}}"

---

## Demo 视频脚本（30 秒，你自己录）

逐帧分镜，每帧 5-6 秒：

### Frame 1 · Hook（0-5s）
**画面**：终端里 `vim openapi.yaml`，光标在某行 schema 上
**字幕**：`Change one OpenAPI line. Four places must update.`
**旁白**：无（让画面说话）

### Frame 2 · 痛点（5-10s）
**画面**：分屏显示 4 个文件 — `openapi.yaml` / `routes/users.ts` / `types/api.d.ts` / `sdk/index.ts`，每个文件都有黄色 highlight 标记 "must change"
**字幕**：`Routes. Types. SDK. Tests. 30 min/change. 11pm bugs.`

### Frame 3 · 工具登场（10-15s）
**画面**：在 Claude Code 里跑 `/openapi-check`，drift 表格出来
**字幕**：`/openapi-check`
**旁白**（可选）：`Drift detected in 5 seconds.`

### Frame 4 · 自动修复（15-22s）
**画面**：跑 `/openapi-sync`，agent 提议 3 个改动，用户按 `y` 确认，文件一个个被更新（屏幕快速滚动 diff）
**字幕**：`/openapi-sync → fixed.`

### Frame 5 · 价值锚（22-27s）
**画面**：截图显示 `tsc --noEmit` 通过 ✓ + git diff 干净
**字幕**：`Saved: 30 min / change.`

### Frame 6 · CTA（27-30s）
**画面**：duolakit.pages.dev landing 截图 + Gumroad 商品页 URL
**字幕**：`duolakit.pages.dev · $19 lifetime`

---

## 上架后立即做的 3 件事

1. **plugin README 顶部加 Gumroad 链接**
   ```markdown
   > **Pro $19 → [Buy on Gumroad](https://duolakit.gumroad.com/l/openapi-guardian)**
   ```
2. **duolakit.pages.dev landing 把 01 卡片改成 link 到 Gumroad**
3. **发首条 X 长推**（参考 `docs/X-LAUNCH-POST.md`）

---

## License Key 验证机制（实现细节）

Gumroad 给每个买家生成 license key（如 `A1B2-C3D4-E5F6-G7H8`）。

**plugin 怎么验证**：

调 Gumroad License API：

```bash
curl -X POST https://api.gumroad.com/v2/licenses/verify \
  -d "product_id=YOUR_GUMROAD_PRODUCT_ID" \
  -d "license_key=A1B2-C3D4-E5F6-G7H8"
```

返回 JSON 含 `success: true` + 用户邮箱 → 写入 `~/.duolakit/license.json` 缓存（不需要每次都调网络）。

**实现方式**（v1.0 已实装）：

- 每个 plugin 自带 `/<plugin>-activate <key>` slash command（`/openapi-activate` / `/token-activate` / `/prd-activate`）
- `bin/license.sh` 调 Gumroad `/v2/licenses/verify` 真校验
- 写入 `~/.duolakit/licenses.json`（一个文件管多个 plugin 的 slot）
- Pro command 启动时调 `bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh check` 真硬门控，非 0 直接拒绝
- API key 自动 mask（`lin_...34`），从不出现在任何日志
- 上架后只需把 `GUMROAD_PRODUCT_ID="PLACEHOLDER_REPLACE_AT_GUMROAD_LAUNCH"` 替换成 Gumroad 给的真实 id 即可
