# awesome-claude-code 提交指南 · openapi-guardian

> **重要**：awesome-claude-code 不接受 PR，必须用 Issue Form 提交。仓库主明确写过：
> "ALL RECOMMENDATIONS MUST BE MADE USING THE WEB UI ISSUE FORM TEMPLATE, OR YOU RISK BEING BANNED."
> 且建议"即使你有一整个 marketplace，也请只提交一个最聚焦的 plugin"。
>
> 所以策略：**只提交 openapi-guardian 这一个**，不提交 duolakit marketplace 本身。等它被收录、有用户反馈后再单独提 token-guardian。

---

## 提交入口

打开（必须登录 GitHub，必须用 Web UI，不能用 gh CLI）：

https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml

---

## 表单字段（逐字段照填）

### display_name
```
openapi-guardian
```

### primary_link
```
https://github.com/duolaAmengweb3/duolakit/tree/main/01-openapi-guardian
```

### author_name
```
duola
```

### author_link
```
https://github.com/duolaAmengweb3
```

### category（下拉）
**选**：`Agent Skills`

> 理由：本插件的核心是一个 auto-loaded skill (`skills/openapi-expert.md`)。虽然也带 3 个 slash command，但 skill 是它的灵魂——slash command 是入口，skill 是大脑。
>
> 备选：如果觉得 Agent Skills 不合适，可换 `Slash-Commands` + subcategory `Slash-Commands: Miscellaneous`。

### subcategory（下拉）
**选**：`General`

> Agent Skills 下没有更细的分类。

### license（下拉）
**选**：`MIT`

### description（1-3 句，不带 emoji）
```
Detect and auto-fix drift between an OpenAPI spec, Express route handlers, TypeScript types, and SDK clients — all inside a Claude Code session. Ships three slash commands (/openapi-check, /openapi-sync, /openapi-init), an OpenAPI-expert skill that auto-loads, a PreToolUse hook that warns when the spec is edited, and a reviewer sub-agent for diffs over 50 lines. Includes a runnable Express demo with intentional drift so new users can validate end-to-end in 5 minutes.
```

### validate_claims（怎么让 maintainer 5 分钟内验证你说的没吹）
```
git clone https://github.com/duolaAmengweb3/duolakit.git
cd duolakit/01-openapi-guardian/examples/express-demo
npm install
# Then in Claude Code with the plugin installed:
/openapi-check
# Expected: drift table showing one ✗ for DELETE /users/{id} (intentionally missing).
```

### validate_claim_part_2（具体演示任务）
```
Run /openapi-sync in the demo project. The plugin proposes adding the missing
DELETE /users/{id} handler in routes/users.ts, asks for confirmation before
writing, then runs `tsc --noEmit` to verify the types still compile.
```

### validate_claims_part_3（用户可直接复制的 prompt）
```
/openapi-check
```

### additional_comments（可选 — 我建议填这段，加可信度）
```
Plugin author also maintains mimo-tui (https://mimo-tui.pages.dev), the
native MiMo terminal agent. openapi-guardian is plugin #1 in the duolakit
matrix — a curated set of focused tools for Claude Code power users.

Free tier (MIT) is genuinely free forever: Express + single spec + all three
commands. Optional Pro adds Fastify/Hono/NestJS support — but the free tier
is fully functional on its own and is what this submission is about.

No telemetry, no SaaS, no calls home. Everything runs locally inside the
Claude Code session.
```

### 五个 checkbox
全部勾上：
- [x] 资源对此 list 是新的（没人提过 openapi-guardian）
- [x] 资源已存在 ≥ 7 天（首次 commit 2026-05-21，提交时确保 ≥ 7 天，否则等到 2026-05-28 之后再交）
- [x] 链接可访问
- [x] 没有重复提交
- [x] 人类验证

---

## 提交时机

**最早 2026-05-28 之后再交**（满足 7 天 cooldown）。

在此之前可以做：
1. 在 X 发首条推文（拿一些 stars 让 maintainer 提交时更愿意收）
2. 让朋友试用 demo，至少 1 个外部 reply / star
3. 把 Gumroad 链接也上好（这样 awesome 收录后流量直接能转化）

---

## 被收录后的二次行动

1. 在 README 顶部加 awesome-claude-code 徽章：
   ```markdown
   [![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/hesreallyhim/awesome-claude-code)
   ```
2. 把"awesome-claude-code 收录"作为推文素材发一次
3. 等 1-2 周后再提 token-guardian (但前提是 token-guardian 也 ≥ 7 天且有真实用户)

---

## 如果被拒了

可能原因 + 应对：

| 拒因 | 怎么改 |
|---|---|
| "category 不合适" | 改提 `Slash-Commands: Miscellaneous` |
| "描述太营销" | 删掉所有形容词，只留 What + How |
| "没真实用户验证" | 等 X 推文带来 ≥ 5 star 再交 |
| "free tier 太单薄" | 加一句 "free tier 1 spec 没有限速" 强化 |
