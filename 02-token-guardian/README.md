# token-guardian · duolakit

> **Stop blowing past your Claude Code 5h window without warning.**
> Heuristic budget guard that logs every tool call, estimates your usage, and (Pro) routes you to OpenRouter when Claude is exhausted.

[![License](https://img.shields.io/badge/license-MIT-EC4899)](../LICENSE)
[![duolakit](https://img.shields.io/badge/duolakit-marketplace-6366F1)](https://duolakit.pages.dev)

[English](#english) · [中文](#中文)

---

## English

### The problem

You're 3 hours into a refactor. Suddenly Claude Code stops with `rate_limit_exceeded`. You wait 90 minutes. You lose context. You miss the deploy window.

This happened to enough people (V2EX, HN, r/ClaudeAI throughout 2026 Q1) that "Claude ran out and now I'm cooked" became a meme.

**token-guardian gives you a 30-minute warning before you hit the wall**, with a clear pace estimate and (Pro) a one-command escape hatch to OpenRouter.

### What's honest about this

Anthropic does NOT expose precise token counts to plugins. Everything token-guardian reports is a heuristic:

- `input_size / 4 + per-tool baseline ≈ estimated_tokens`
- Estimates are typically 30-50% lower than Claude Code's own `/cost`
- We accept this and offer calibration: paste `/cost` output, we'll recalibrate

This is honest "budget alarm clock" software, not a precise meter. If you need precision, use Claude Code's built-in `/cost`.

### Install

```bash
/plugin marketplace add duolaAmengweb3/duolakit
/plugin install token-guardian@duolakit
```

### Commands

| Command | What it does | Tier |
|---|---|---|
| `/token-budget show` | Show current 5h / daily budget thresholds | Free |
| `/token-budget set 5h 220000` | Set the 5h window cap | Free |
| `/token-status` | Show estimated usage, pace, time until threshold | Free |
| `/token-calibrate` | Paste Claude Code's `/cost`, fix the heuristic multiplier | Free (session) / **Pro $9** (persistent + 7-day history) |
| `/token-route` | Recommend OpenRouter fallback for the next task | **Pro $9** |
| `/token-activate <key>` | Verify Gumroad license, unlock Pro features | n/a |

### How it works

1. **PreToolUse hook** appends one line to `~/.duolakit/token-log.jsonl` per tool call.
2. **`/token-status`** reads the last 5h of log, sums estimates, extrapolates.
3. **`/token-route`** (Pro) reads the status + your current conversation context and picks an OpenRouter model with explicit cost/quality trade-off.

Nothing leaves your machine. No telemetry. No API key required.

### Free vs Pro

| Feature | Free | Pro $9 |
|---|---|---|
| Activity logging | ✓ | ✓ |
| 5h window budget tracking | ✓ | ✓ |
| Pace + ETA extrapolation | ✓ | ✓ |
| `/cost` calibration | one-shot per session | rolling 7-day |
| Multi-provider routing recommendations | basic generic tip | full matrix + sub-agent |
| OpenRouter env / settings snippet generation | ❌ | ✓ |
| Historical reports (daily/weekly) | ❌ | ✓ |
| Email support | community | 48h SLA |

[**Buy Pro on Gumroad →**](https://duolakit.gumroad.com/l/token-guardian) *(coming soon)*

### Anti-features

- ❌ No SaaS — runs locally inside Claude Code.
- ❌ No telemetry — `~/.duolakit/token-log.jsonl` never leaves your machine.
- ❌ No API key handling — we never see or store your Anthropic key.
- ❌ No auto-switching — every model switch needs your explicit confirmation.
- ❌ No usage-based fees — Pro is $9 one-time, that's it.

### What's in v1.0 (today)

- PreToolUse hook logs every tool call to `~/.duolakit/token-log.jsonl`
- Hook actively warns at warn/stop thresholds (deduped via `~/.duolakit/state.json`)
- `/token-budget` show/set 5h + daily caps + warn/stop %
- `/token-status` shows estimated usage, pace, ETA to thresholds
- `/token-calibrate` accepts Claude Code's `/cost` to fix the heuristic (Free: session, Pro: persistent + 7-day history)
- `/token-route` (Pro): multi-provider routing recommendation with cost/quality trade-offs explicit
- `token-router` sub-agent for context-aware routing decisions
- `/token-activate <license-key>` actually verifies against Gumroad

### What's next (not in v1.0)

- Slack / Discord webhook alerts when nearing budget
- Multi-account support (track Claude Code + Cursor + Aider separately)
- Historical export (CSV/JSON) for personal analytics
- Auto-switch (with explicit confirm) when Pro routing fires

### License

[MIT](../LICENSE) for the plugin source. Pro features verified via Gumroad license key.

---

## 中文

### 解决什么问题

你重构到一半，Claude Code 突然 `rate_limit_exceeded`。等 90 分钟，丢失上下文，错过 deploy 窗口。

2026 Q1 这个场景在 V2EX / HN / r/ClaudeAI 反复出现，"Claude 用完了我又得回家洗澡"成了梗。

**token-guardian 在你撞墙前 30 分钟给你警告**，带清晰的速率预估和（Pro）一键切到 OpenRouter 的逃生通道。

### 老实说

Anthropic **不**给插件暴露精确的 token 数。token-guardian 全是启发式估算：

- `input_size / 4 + 每工具基线 ≈ estimated_tokens`
- 估算通常比 Claude Code 自己的 `/cost` 低 30-50%
- 我们承认这个误差，并提供校准：你把 `/cost` 粘过来，我们重新算

这是一个**老实的"预算闹钟"**，不是精确度量仪。要精确就用 Claude Code 自带的 `/cost`。

### 安装

```bash
/plugin marketplace add duolaAmengweb3/duolakit
/plugin install token-guardian@duolakit
```

### 命令

| 命令 | 作用 | 等级 |
|---|---|---|
| `/token-budget show` | 显示当前 5h / 日预算阈值 | 免费 |
| `/token-budget set 5h 220000` | 设置 5h 窗口上限 | 免费 |
| `/token-status` | 显示估算用量、速率、距阈值时间 | 免费 |
| `/token-calibrate` | 粘 `/cost` 输出修正启发式 multiplier | 免费会话 / **Pro $9** 持久 + 7 天历史 |
| `/token-route` | 给下一个任务推荐 OpenRouter 替代模型 | **Pro $9** |
| `/token-activate <key>` | 校验 Gumroad license，解锁 Pro | — |

### 工作原理

1. **PreToolUse hook** 每次工具调用追加一行到 `~/.duolakit/token-log.jsonl`。
2. **`/token-status`** 读最近 5 小时的日志，汇总估算，外推。
3. **`/token-route`**（Pro）读 status + 当前对话上下文，挑一个 OpenRouter 模型，把成本/质量 trade-off 摊开给你。

数据不出本机。无遥测。不需要 API key。

### 免费版 vs Pro

| 功能 | 免费 | Pro $9 |
|---|---|---|
| 活动日志 | ✓ | ✓ |
| 5h 窗口预算追踪 | ✓ | ✓ |
| 速率 + ETA 外推 | ✓ | ✓ |
| `/cost` 校准 | 每会话 1 次 | 滚动 7 天 |
| 多供应商路由推荐 | 通用提示 | 完整决策矩阵 + 子 agent |
| OpenRouter env/settings 片段生成 | ❌ | ✓ |
| 历史报表（日/周） | ❌ | ✓ |
| 邮件支持 | 社区 | 48h SLA |

[**Gumroad 买 Pro →**](https://duolakit.gumroad.com/l/token-guardian) *（即将上架）*

### 不会做的事

- ❌ 不做 SaaS — 全部本地跑在 Claude Code 里。
- ❌ 不上报数据 — `~/.duolakit/token-log.jsonl` 不出本机。
- ❌ 不碰 API key — 我们看不见也不存你的 Anthropic key。
- ❌ 不自动切换 — 每次切模型都得你明确确认。
- ❌ 不收用量费 — Pro 一次 $9，仅此。

### v1.0 已经发的（今天）

- PreToolUse hook 把每次工具调用记到 `~/.duolakit/token-log.jsonl`
- Hook 主动告警跨阈值（用 `~/.duolakit/state.json` 去重）
- `/token-budget` 看/设 5h + 日预算 + warn/stop 百分比
- `/token-status` 显示估算用量、速率、距阈值时间
- `/token-calibrate` 用 Claude Code 的 `/cost` 校准启发式（免费会话级、Pro 持久 + 7 天历史）
- `/token-route`（Pro）：多供应商路由推荐，成本/质量明摊
- `token-router` 上下文感知的子 agent
- `/token-activate <license-key>` 真调 Gumroad 校验

### 下一步（不在 v1.0）

- Slack / Discord webhook 告警
- 多账户支持（Claude Code + Cursor + Aider 分开追踪）
- 历史导出（CSV/JSON）个人分析
- Pro 路由触发后自动切换（带显式确认）

### 联系

- X · [@hunterweb303](https://x.com/hunterweb303)
- Telegram · [t.me/dsa885](https://t.me/dsa885)
- Issues · [github.com/duolaAmengweb3/duolakit/issues](https://github.com/duolaAmengweb3/duolakit/issues)

### License

[MIT](../LICENSE)（plugin 源码）+ Pro 功能通过 Gumroad license key 校验。
