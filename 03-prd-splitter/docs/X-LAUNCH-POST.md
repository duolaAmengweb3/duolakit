# X 发布长推 · prd-splitter

---

## 完整长推（直接 copy）

```
PRD 6 页，tracker 想要 80 张票。
中间这段断层是项目搞砸的地方。

一半团队过度拆分到 120 张噪音票，
另一半挥手而过，把 auth / 部署 / 监控 全部忘光。

我做了一个 plugin 治这个。

╔═════════════════════════════════════════════════════╗
║   /prd-split    — PRD → 3-7 epic + 5-15 story       ║
║   /prd-estimate — Fibonacci only（4/6/7 禁用）      ║
║   /prd-export   — Linear/Jira/Markdown CSV          ║
║   /prd-push     — 直推 Linear (Pro)                 ║
╚═════════════════════════════════════════════════════╝

主见硬编码进去的几条：
· 单次 PRD 超过 50 个 story 直接拒绝
· 「Cross-cutting」epic 永远会有（auth / 监控 / 部署 / 合规）
· 验收标准必须可观察（QA 能写测试）
· Open questions 被追踪，不被脑补
· 8+ 分的 story 自动调起 reviewer 子 agent 二次审查（Pro）

—— 关于矩阵

duolakit 三个 plugin：
01. openapi-guardian — schema ↔ 4 处自动同步
02. token-guardian   — 撞墙前 30 min 告警
03. prd-splitter     ← 今天上线

共同标准：
· 单元测试 + 30 秒 demo
· 中英双语 README
· 免费 MIT core 永久免费，绝不 rug-pull
· Pro 独立明示价格
· 月度发版，issue 30 天必回

—— 怎么用

```bash
/plugin marketplace add duolaAmengweb3/duolakit
/plugin install prd-splitter@duolakit

# In project with PRD.md:
/prd-split
/prd-estimate
/prd-export linear   # 免费 CSV 导出
# OR (Pro):
/prd-push linear     # 直推，默认 dry-run
```

免费版：split + estimate + 3-format export（Linear/Jira CSV + Markdown）
Pro $19 一次性：reviewer agent + 直推 Linear（idempotent）+ 持久校准

→ duolakit.pages.dev
→ github.com/duolaAmengweb3/duolakit
→ DM @hunterweb303 (X) / t.me/dsa885（$19 买 Pro，任意付款方式）

made by @hunterweb303

—— 留言

PRD → tickets 这件事你现在用什么工具/流程？最痛的环节是什么？
```

---

## 钩子拆解

- **第一行画反差**：6 页 vs 80 票 —— 立刻视觉化"断层"
- **二三行讲两种失败模式**：过度拆 vs 拍脑袋 —— 任何做过 PM 的都能对号入座
- **「我做了 plugin 治这个」**：建立信任，逼读者展开
- **5 条主见列表**：是这个工具的真区分点，不是其他 PRD 工具能给的
- **CTA 三选一**：landing / GitHub / DM @hunterweb303 直接买 Pro
- **互动结尾**：触发 PM / Tech Lead 圈层的评论

---

## 发布时机

- **美西时间周二/周三早上 9-11 点**
- 国内：**周二/周三晚 11 点 - 凌晨 1 点**
- PM / agile 圈层活跃时段，避开周五（人都在收尾）

---

## 配图（4 张）

1. **拆分前 vs 后**：左边 6 页 PRD，右边 5 epic + 16 story 的 tree（用 expected-tree.md 截图）
2. **/prd-estimate 输出**：每个 story 带 Fibonacci 点 + summary footer
3. **/prd-push dry-run 表**：12 条 story 预览 → Linear
4. **Linear 截图**：16 个新建 issue 的列表

---

## 转发战略

1. **Reply 自己**：补一条"为什么不准用 4 / 6 / 7"的小推
2. **回评论**：1 小时内全部回
3. **dev.to 长文**：标题 "How a 'no 4, no 6, no 7' rule kept our estimates honest"
4. **HN Show HN**：`Show HN: A Claude Code plugin that turns PRDs into Linear issues — but refuses to over-decompose`
5. **r/projectmanagement / r/agile**：PM/agile 社群对"少而精的拆分"会有强共鸣
6. **LinkedIn**：本品的 PM 受众更多在 LinkedIn 而非 X，复用同一文案

---

## A/B 测试备用钩子

### 钩子 A（叙事型）
```
做了 3 个 sprint 后我意识到：
我们 backlog 里 70% 的票，是 PM 把 PRD 一个 bullet 一个 bullet 写过来的。

谁能把这些"碎屑"重新聚合成 epic？

我把这个工作放进 Claude Code。
```

### 钩子 B（原则型）
```
Fibonacci estimate 的整个意义就是：
你分不清 6 和 7。

但我们用的 Linear / Jira 大多数模板默认 1-10 任意点数。
团队估出来 6 和 7，然后假装它们不一样。

我写了一个工具强制 Fibonacci。它拒绝输出 4、6、7。
```

### 钩子 C（损失厌恶）
```
上 sprint 估了 13 个 story 总 60 点。
实际跑完 96 点。

差的 36 点 = 9 天 = 一个工程师两周白干。

PRD 拆得不对，后面所有规划都跑偏。
我做了个 Claude Code plugin 治这个根。
```

48 小时内挑一个换。
