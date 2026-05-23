# X 发布长推 · token-guardian

---

## 完整长推（直接 copy，调整链接后发）

```
你上次半夜 3 点被 Claude Code 的 rate_limit_exceeded 击落是什么时候？

我做了个 plugin 让它别再发生。

Claude Code Max 5h 窗口约 220K tokens —— Anthropic 从不主动告诉你
你跑到 78% 了。一头扎进去，撞墙时已经晚了 90 分钟。

所以我写了 token-guardian。

╔═════════════════════════════════════════════════════╗
║   PreToolUse hook 每次工具调用都记 + 算窗口用量     ║
║   80% 时 stderr 弹一次告警（去重，不刷屏）         ║
║   95% 时再弹一次最后通牒                            ║
║   /token-status 看 ETA 和速率                       ║
║   /token-route (Pro) 一条命令切 OpenRouter 路由     ║
╚═════════════════════════════════════════════════════╝

老实说：估算是启发式的（input_size/4 + 每工具基线），
通常比 /cost 低 30-50%。
Pro /token-calibrate 让你粘一次 /cost，从此误差 ~10%。

—— 关于 duolakit 矩阵

duolakit 不是单个 plugin，是一组：
01. openapi-guardian — schema ↔ routes ↔ types ↔ sdk 四向同步
02. token-guardian   ← 今天上线
03. prd-splitter     — PRD → Linear ticket 拆分 + Fibonacci 估算

共同标准：
· 每个 plugin 单元测试 + 30 秒 demo
· 中英双语 README
· 免费 MIT core 永久免费，绝不 rug-pull
· Pro 版独立明示价格

—— 怎么用

```bash
/plugin marketplace add duolaAmengweb3/duolakit
/plugin install token-guardian@duolakit
```

免费版：完整活动追踪 + 预算告警 + 单会话校准
Pro $9 一次性：多供应商路由矩阵 + 持久校准 + 7 天历史 + 邮件支持

→ duolakit.pages.dev
→ github.com/duolaAmengweb3/duolakit
→ duolakit.gumroad.com/l/token-guardian

made by @hunterweb303
其他 SKU：openapi-guardian（也是 duolakit）+ mimo-tui（同作者）

—— 留言告诉我

你最近一次 Claude Code 撞墙是在做什么？我想拿你的痛点验证下个 SKU 的方向。
```

---

## 钩子拆解

- **共情型开头**："半夜 3 点" / "击落" —— 立刻召唤"我也经历过"的读者
- **悬念第二行**："我做了个让它别再发生" —— 逼读者展开
- **数据**：220K tokens 是公开观察值（V2EX 上有原文），可信
- **老实**：明说估算是启发式 —— 反差感强，建立信任（多数 SaaS 都吹精度）
- **CTA 三选一**：landing / GitHub / Gumroad
- **互动结尾**："留言"触发评论 —— X 算法重权评论

---

## 发布时机

- **美西时间周二/周三早上 9-11 点**
- 国内：**周二/周三晚 11 点 - 凌晨 1 点**

---

## 配图（4 张）

1. **/token-status 截图**：进度条 + ETA 表格，1280×720（用 docs/cover.png 也行）
2. **stderr 告警截图**：终端里红色 `⚠ Heads up: 180,400 / 220,000` 那一刻
3. **/token-route 输出截图**：决策矩阵 + 推荐 + 成本对比
4. **duolakit 矩阵图**：landing hero 截图（3 张 Live 卡片）

---

## 转发战略

1. **Reply 自己**：补一条 `/token-route` 的 demo 视频链接
2. **回评论**：1 小时内全部回（X 重权互动密度）
3. **dev.to 长文**：标题 "Why Claude Code's silent rate limit cost me a deploy window — and the plugin I built to fix it"
4. **HN Show HN**：`Show HN: A Claude Code plugin that warns you ~30 min before you hit the 5h rate limit`
5. **V2EX**："Claude Code 5h 窗口预算告警插件，10 行配置接入" —— V2EX 中文社区已经吐槽过这个问题
6. **r/ClaudeAI**：同 V2EX 但英文版

---

## A/B 测试备用钩子

### 钩子 A（损失厌恶型）
```
$200/月 Claude Code Max。
跑到一半 rate_limit。等 90 分钟。
那 90 分钟的会员费按比例 $0.92。
但损失的开发上下文按比例：不可挽回。

我写了个插件治这个。
```

### 钩子 B（数据型）
```
Claude Code Max 5h 窗口大约 220,000 tokens。
你正常用 4 小时 = 大约 175,000。
剩下 1 小时，你不知道还有多少预算。

token-guardian 让你知道。
```

### 钩子 C（叙事型）
```
我做了 openapi-guardian 之后，
被同一个用户问了同一个问题三次：
"你能不能再做一个，让我别再被 Claude Code rate limit 打断？"

第二次没听。第三次写了。
```

48 小时内挑一个不同情绪锚点的换。
