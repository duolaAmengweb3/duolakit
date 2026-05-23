# openapi-guardian · duolakit

> **OpenAPI spec ↔ route handlers ↔ TypeScript types ↔ SDK clients — all in lockstep, inside Claude Code.**
> Change one place, four others update. No more schema drift bugs at 11pm.

[![License](https://img.shields.io/badge/license-MIT-EC4899)](../LICENSE)
[![duolakit](https://img.shields.io/badge/duolakit-marketplace-6366F1)](https://duolakit.pages.dev)

[English](#english) · [中文](#中文)

---

## English

### The problem

You change one line in `openapi.yaml`. Four other places need updates:

1. Route handler in `src/routes/users.ts`
2. TypeScript types in `src/types/api.d.ts`
3. SDK client in `packages/sdk/index.ts`
4. Test fixtures in `tests/fixtures/`

Forget one and prod breaks. Remember all four and waste 30 minutes per change.

**openapi-guardian watches the spec and auto-syncs all four**, inside your Claude Code session.

### Install

```bash
# Add the duolakit marketplace once
/plugin marketplace add duolaAmengweb3/duolakit

# Install this plugin
/plugin install openapi-guardian@duolakit
```

### Commands

| Command | What it does | Tier |
|---|---|---|
| `/openapi-check` | Detect drift between spec / routes / types / SDK | Free |
| `/openapi-sync`  | Bring all 4 into agreement (asks before each write) | Free (Express) / Pro (Fastify+Hono+NestJS) |
| `/openapi-init`  | Bootstrap a new project (Express + OpenAPI scaffolding) | Free |
| `/openapi-activate <key>` | Verify Gumroad license, unlock Pro framework + multi-service | n/a |

### Try the demo in 5 minutes

```bash
cd examples/express-demo
npm install
npm run dev      # server on :3000
```

In Claude Code:

```
/openapi-check
```

You'll see one row with `✗` because the demo project ships with intentional drift (`DELETE /users/{id}` missing). Then:

```
/openapi-sync
```

It will offer to fix the drift. Confirm, and the handler is added in the same style as your existing code.

### How it works

This plugin is **pure markdown + JSON + an OpenAPI-expert skill**. It does not bundle any heavy runtime — instead, it gives Claude Code clear instructions on how to:

1. Read your spec file (`openapi.yaml`)
2. Discover route handlers, types, and SDK files via `glob`
3. Compare them
4. Generate / edit files using `edit_file` / `write_file`
5. Run `tsc --noEmit` to verify

A sub-agent (`reviewer`) is invoked for any change > 50 lines to give a second opinion before write.

A PreToolUse hook fires when you edit `openapi.yaml` to remind you to run `/openapi-sync`.

### Free vs Pro

| | Free | Pro $19 |
|---|---|---|
| Spec files watched | 1 | Unlimited |
| Frameworks | Express | Express, Fastify, Hono, NestJS |
| Multi-service registry | ❌ | ✓ |
| Team schema registry | ❌ | ✓ |
| Email support | Community | 48h SLA |
| Updates | Forever | Lifetime |

**Free is genuinely free forever.** Pro adds breadth (more frameworks + multi-service) and support. No rug-pull, no usage caps.

[**Buy Pro on Gumroad →**](https://duolakit.gumroad.com/l/openapi-guardian) *(coming soon)*

### Refund

14-day no-questions-asked refund. Email `noreply@duolakit.pages.dev` or DM [@hunterweb303](https://x.com/hunterweb303).

### What's in v1.0 (today)

- `/openapi-check`, `/openapi-sync`, `/openapi-init` (Free + Pro behavior gated by `bin/license.sh`)
- Express + Fastify framework support shipping (Hono + NestJS use the same code paths — Claude follows your framework's conventions via the skill)
- Multi-service registry (Pro): scan multiple `openapi.yaml` files in one repo
- `prd-reviewer` style second-opinion sub-agent for diffs > 50 lines
- PreToolUse hook nudge when editing the spec
- Express + Fastify runnable demo projects with intentional drift
- `/openapi-activate <license-key>` actually verifies against Gumroad

### What's next (not in v1.0)

- Hono + NestJS dedicated demos (the code paths already work — these add reference projects)
- Watch mode (auto-trigger `/openapi-sync` on spec save)
- CI integration (GitHub Action wrapper for headless drift detection)
- Reverse mode: code-to-spec with hand-curated diff approval

### Anti-features (things this plugin will NOT do)

- ❌ No SaaS — everything runs locally inside Claude Code.
- ❌ No telemetry — no calls home, no analytics.
- ❌ No lock-in — your code stays in your repo; uninstall any time.
- ❌ No "AI hallucinations into prod" — every write is confirmed by the user.

### License

[MIT](../LICENSE) for the plugin source. Pro features (where applicable) use a separate commercial license enforced via license key.

---

## 中文

### 解决什么问题

你改了一行 `openapi.yaml`。下面 4 处都得跟着改：

1. `src/routes/users.ts` 里的路由 handler
2. `src/types/api.d.ts` 里的 TypeScript 类型
3. `packages/sdk/index.ts` 里的 SDK 客户端
4. `tests/fixtures/` 里的测试 fixture

忘了一个 → 生产环境炸。全都记得 → 每次改 schema 浪费 30 分钟。

**openapi-guardian 监控 spec 文件，自动同步这 4 处**，全程在你的 Claude Code 会话里完成。

### 安装

```bash
# 添加 duolakit marketplace（只用做一次）
/plugin marketplace add duolaAmengweb3/duolakit

# 安装本插件
/plugin install openapi-guardian@duolakit
```

### 命令

| 命令 | 作用 | 等级 |
|---|---|---|
| `/openapi-check` | 检测 spec / routes / types / SDK 之间的漂移 | 免费 |
| `/openapi-sync`  | 同步 4 处（每次写文件前会问你确认） | 免费 Express / Pro 多框架 |
| `/openapi-init`  | 在新项目里初始化 Express + OpenAPI 脚手架 | 免费 |
| `/openapi-activate <key>` | 校验 Gumroad license，解锁 Pro 多框架 + 多服务 | — |

### 5 分钟试 demo

```bash
cd examples/express-demo
npm install
npm run dev      # 启动服务 :3000
```

在 Claude Code 里：

```
/openapi-check
```

你会看到一行 `✗` —— demo 项目特意留了一个漂移（`DELETE /users/{id}` 在 spec 里有但 handler 没写）。然后：

```
/openapi-sync
```

它会提议修复这个漂移。你确认后，handler 会按你现有代码的风格写进 `routes/users.ts`。

### 工作原理

本插件是**纯 markdown + JSON + 一个 OpenAPI 专家 skill**。不打包任何重型运行时——而是给 Claude Code 清晰的指令，告诉它如何：

1. 读你的 spec 文件（`openapi.yaml`）
2. 通过 `glob` 找出 routes / types / SDK 文件
3. 对比
4. 用 `edit_file` / `write_file` 改/写文件
5. 跑 `tsc --noEmit` 验证

任何超过 50 行的改动都会调起子 agent (`reviewer`) 给第二意见。

编辑 `openapi.yaml` 时会触发 PreToolUse hook，提醒你"改完记得跑 /openapi-sync"。

### 免费版 vs Pro

| 维度 | 免费版 | Pro $19 |
|---|---|---|
| spec 文件数 | 1 | 无限 |
| 框架 | Express | Express / Fastify / Hono / NestJS |
| 多服务 registry | ❌ | ✓ |
| 团队 schema registry | ❌ | ✓ |
| 邮件支持 | 社区 | 48 小时 SLA |
| 更新 | 永久 | 永久 |

**免费版永久免费，不会被砍掉**。Pro 加的是广度（更多框架 + 多服务）和支持。无套路，无用量上限。

[**Gumroad 买 Pro →**](https://duolakit.gumroad.com/l/openapi-guardian) *（即将上架）*

### 退款

14 天无理由退款。邮件 `noreply@duolakit.pages.dev` 或私信 [@hunterweb303](https://x.com/hunterweb303)。

### v1.0 已经发的（今天）

- `/openapi-check`、`/openapi-sync`、`/openapi-init`（免费 + Pro 行为由 `bin/license.sh` 真硬门控）
- Express + Fastify 框架支持已上（Hono + NestJS 走同一套代码路径——skill 让 Claude 跟你框架的惯例走）
- 多服务 registry（Pro）：扫一个 repo 里多个 `openapi.yaml`
- diff > 50 行自动调起 `prd-reviewer` 风格的第二意见子 agent
- 编辑 spec 时 PreToolUse hook 弹提醒
- Express + Fastify 双 demo 项目，都带故意漂移
- `/openapi-activate <license-key>` 真调 Gumroad 校验

### 下一步（不在 v1.0）

- Hono + NestJS 的专属 demo 项目（代码路径已通，这是补参考工程）
- Watch 模式（spec 保存时自动触发 `/openapi-sync`）
- CI 集成（GitHub Action 包装的无人值守漂移检测）
- 反向模式：code-to-spec，人工核对 diff 再批

### 不会做的事

- ❌ 不做 SaaS — 全部本地跑在你的 Claude Code 里。
- ❌ 不上报数据 — 不联网回传任何信息。
- ❌ 不锁定 — 你的代码就在你的 repo，随时卸载。
- ❌ 不允许 AI 幻觉直接进 prod — 每次写文件都得你确认。

### 联系

- X · [@hunterweb303](https://x.com/hunterweb303)
- Telegram · [t.me/dsa885](https://t.me/dsa885)
- Issues · [github.com/duolaAmengweb3/duolakit/issues](https://github.com/duolaAmengweb3/duolakit/issues)

### License

[MIT](../LICENSE)（plugin 源码）+ Pro 功能用独立商业 license（通过 license key 校验）。
