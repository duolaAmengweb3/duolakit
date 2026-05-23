# awesome-claude-code 提交指南 · token-guardian

> 同 SKU-01：awesome-claude-code 不接受 PR，必须用 Issue Form。
> 仓库主明确说"即使是 marketplace 也只提交一个最聚焦的 plugin"。
>
> 策略：等 SKU-01 (openapi-guardian) 被收录后过 2-3 周再提交本 SKU，避免被认为"刷条目"。

---

## 提交入口

https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml

---

## 表单字段（逐字段照填）

### display_name
```
token-guardian
```

### primary_link
```
https://github.com/duolaAmengweb3/duolakit/tree/main/02-token-guardian
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
**选**：`Hooks`

> 理由：本插件的核心是一个 PreToolUse hook（`hooks/log-tool.sh`）做主动告警。Skill + commands 是入口和报表，hook 是引擎。
>
> 备选：如果 maintainer 觉得 Hooks 不合适，可换 `Tooling` + subcategory `Tooling: Usage Monitors`（这个 subcategory 几乎就是为这种插件准备的）。

### subcategory（下拉）
**选**：`General`（Hooks 类目下没有更细分）

> 如果改 category 为 Tooling，subcategory 选 `Tooling: Usage Monitors`。

### license（下拉）
**选**：`MIT`

### description（1-3 句，不带 emoji）
```
A PreToolUse hook that logs every Claude Code tool call, sums the rolling 5h window against a configurable budget, and emits a deduplicated stderr warning ~30 minutes before you hit the rate limit. Ships four slash commands (/token-budget, /token-status, /token-calibrate, /token-route), a token-expert skill that auto-loads, and an optional Pro tier that recommends OpenRouter / DeepSeek / Gemini fallbacks with cost/quality trade-offs explicit. Heuristic estimate (input chars ÷ 4 + per-tool baseline) is honest about its ±30% accuracy; the /token-calibrate command pastes Claude Code's own /cost output to recalibrate.
```

### validate_claims（怎么 5 分钟内验证）
```
git clone https://github.com/duolaAmengweb3/duolakit.git
cd duolakit/02-token-guardian
bash examples/smoke-test.sh
# Expected: passed: 10    failed: 0
# Exercises: log writes, threshold warnings at 80% and 95%, dedupe,
# 5h window aging, custom budget config.
```

### validate_claim_part_2（具体演示任务）
```
Install in Claude Code:
  /plugin marketplace add duolaAmengweb3/duolakit
  /plugin install token-guardian@duolakit

Use Claude Code normally. After ~30-50 tool calls, run:
  /token-status

Expected: a usage table + pace + ETA to threshold, plus an honesty
footer noting estimates are heuristic.
```

### validate_claims_part_3（用户可直接复制的 prompt）
```
/token-status
```

### additional_comments（建议填）
```
This is plugin #2 in the duolakit marketplace (the first was
openapi-guardian, also recently submitted). The author maintains
mimo-tui (https://mimo-tui.pages.dev), the native MiMo terminal agent.

Free tier (MIT) is fully functional: activity logging + threshold
warnings + budget config + session calibration + status reporting.
Optional Pro ($9 one-time) adds multi-provider routing recommendations
and persistent calibration. This submission is about the free tier.

No telemetry, no SaaS, no calls home (except optional Gumroad license
verification during /token-activate). Runs entirely inside the Claude
Code session.

Particularly relevant to users on Claude Code Max ($200/mo) who have
hit the 5h rolling window mid-task — a common complaint in 2026 Q1.
```

### 五个 checkbox
全部勾上：
- [x] 资源对此 list 是新的
- [x] 资源已存在 ≥ 7 天（首次 commit 2026-05-23，提交时确保 ≥ 7 天，即 2026-05-30 之后）
- [x] 链接可访问
- [x] 没有重复提交
- [x] 人类验证

---

## 提交时机

**最早 2026-05-30 之后**（满足 7 天 cooldown）。

最好等 SKU-01 (openapi-guardian) 已经被收录、且有 ≥ 1-2 周间隔后再提，避免被 maintainer 认为是"刷条目"。

在此之前可以做：
1. 发首条 X 推文（参考 docs/X-LAUNCH-POST.md）
2. 上 Gumroad（参考 docs/GUMROAD-LISTING.md）
3. 让 1-2 个朋友试用 + star，提升真实度

---

## 被收录后

1. 在 README 顶部加 awesome-claude-code 徽章
2. 推一条 "token-guardian 被 awesome-claude-code 收录" 的 X 推
3. 收录后第一周流量会有小峰值 —— 准备好回复 issues
