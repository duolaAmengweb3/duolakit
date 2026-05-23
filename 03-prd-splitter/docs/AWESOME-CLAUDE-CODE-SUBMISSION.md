# awesome-claude-code 提交指南 · prd-splitter

> 同 SKU-01/02：用 Issue Form，不接受 PR。
> 提交策略：等 SKU-01 + SKU-02 都已被收录后再提，避免被认为是刷条目（最早建议 2026-06 中下旬）。

---

## 提交入口

https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml

---

## 表单字段（逐字段照填）

### display_name
```
prd-splitter
```

### primary_link
```
https://github.com/duolaAmengweb3/duolakit/tree/main/03-prd-splitter
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
**选**：`Slash-Commands`

> 理由：本插件主要由 4 个 slash command 驱动（`/prd-split`、`/prd-estimate`、`/prd-export`、`/prd-push`），用户的入口是命令而非 hook 或 skill。
>
> 备选：如果觉得 Slash-Commands 不合适，可换 `Agent Skills`（因为 prd-expert skill 是大脑），subcategory `General`。

### subcategory（下拉）
**选**：`Slash-Commands: Project & Task Management`

> 这个 subcategory 几乎就是为 PRD/ticket 工具准备的。

### license（下拉）
**选**：`MIT`

### description（1-3 句，不带 emoji）
```
Reads a PRD (Markdown / text), produces an opinionated epic → story → task tree (3-7 epics, 5-15 stories per epic, mostly zero tasks) with Fibonacci-only estimates and observable acceptance criteria. Refuses over-decomposition (caps at 50 stories per pass), always adds a Cross-cutting epic, tracks Open questions instead of fabricating answers. Free tier exports to Markdown / Linear-CSV / Jira-CSV; optional Pro tier adds direct GraphQL push to Linear (always dry-runs first, idempotent on re-run) plus a reviewer sub-agent that second-opinions 8+ point stories.
```

### validate_claims（5 分钟验证）
```
git clone https://github.com/duolaAmengweb3/duolakit.git
cd duolakit/03-prd-splitter
bash examples/smoke-test.sh
# Expected: passed: 20    failed: 0
# Exercises: sample PRD validity, expected tree shape, Fibonacci-only
# check, Linear push helper in mock mode (handles list-teams + create,
# rejects missing fields, refuses without API key, masks the API key
# in mock output to prevent leakage).
```

### validate_claim_part_2（具体演示任务）
```
In Claude Code (after install), inside the cloned repo:
  cd 03-prd-splitter/examples
  claude

  /prd-split sample-prd.md
  # Reads BookmarkBird PRD (~600 words), writes PRD-tree.md
  /prd-estimate
  # Adds Fibonacci points, summary footer (~73 total, ~37 dev-days)
  /prd-export linear
  # Produces PRD-tree.linear.csv ready to drag into Linear
```

### validate_claims_part_3（用户可直接复制的 prompt）
```
/prd-split sample-prd.md
```

### additional_comments
```
This is plugin #3 in the duolakit marketplace (after openapi-guardian and
token-guardian). Same author maintains mimo-tui (https://mimo-tui.pages.dev).

The plugin is opinionated about what "good" looks like — explicitly refuses
to use 4 / 6 / 7 point estimates (suppresses false precision), refuses to
produce > 50 stories per PRD pass, always adds a Cross-cutting epic so auth /
observability / compliance don't get forgotten. These opinions are baked into
the prd-expert skill, not hidden in code, so users can read why each rule
exists in skills/prd-expert.md.

Free tier (MIT) is genuinely free forever and fully functional: split,
estimate, and 3-format export. Optional Pro ($19 one-time) adds the
reviewer sub-agent and direct Linear API push. This submission focuses on
the free tier.

No telemetry, no SaaS, no calls home (except optional /prd-activate which
hits Gumroad's license verify). The Linear API key is read from env every
call, never written to disk, and auto-masked in mock-mode output to
prevent accidental leak in logs.
```

### 五个 checkbox
全部勾上：
- [x] 资源对此 list 是新的
- [x] 资源已存在 ≥ 7 天（首次 commit 2026-05-23，提交时确保 ≥ 7 天）
- [x] 链接可访问
- [x] 没有重复提交
- [x] 人类验证

---

## 提交时机

**最早 2026-05-30**，但**强烈建议等 SKU-01 + SKU-02 都被收录后再提**（约 2026-06 中下旬）。三个连续提交会让 maintainer 把你打成"刷条目"。

可以在等待期做：
1. 发首条 X 推（参考 docs/X-LAUNCH-POST.md）
2. 上 Gumroad
3. 发到 PM/agile 社群（r/projectmanagement, r/agile, LinkedIn）
4. 让几个 PM 朋友试用 + 反馈

---

## 被收录后

1. README 顶部加 awesome-claude-code 徽章
2. 推 "duolakit 三件套全部进 awesome-claude-code" 的总结推 —— 矩阵叙事达到顶点
3. 此时可以考虑总结一篇 "How I built 3 Claude Code plugins in 4 weeks" 的长文，去 dev.to / HN
