---
name: prd-split
description: Read a PRD (Markdown / plain text) and produce a structured epic → story → task tree with acceptance criteria. Writes to ./PRD-tree.md by default.
argument-hint: "[optional: path to PRD file, defaults to ./PRD.md or ./prd.md]"
---

# /prd-split

You are running the `prd-split` command from the `prd-splitter` plugin.

Your task: read a PRD, identify the units of work hidden inside it, and emit a clean three-level tree (epic → story → task) with acceptance criteria attached at the story level. **Do not estimate points yet** — that's the next command (`/prd-estimate`).

## Procedure

1. **Locate the PRD.**
   - If user passed an argument, use that path.
   - Otherwise check (in order): `./PRD.md`, `./prd.md`, `./docs/PRD.md`, `./PRD.txt`. If multiple exist, ask the user which one.
   - If none exist, ask: "Paste the PRD inline, or give me a file path."

2. **Parse the PRD into raw chunks.** Read the file. Identify natural sections by:
   - Markdown headings (`#` / `##` / `###`)
   - Numbered lists with significant text under each item
   - "Requirements" / "User stories" / "Features" sections if explicitly labelled

3. **Cluster into epics.** An epic = a coherent chunk of value delivered together, ~2-6 weeks of work for a single dev. Most real PRDs have 2-7 epics. **Resist the urge to split into more than 7** — fewer, fatter epics scale better than many thin ones.

4. **Decompose each epic into stories.** A story = something a single dev can complete in 1-5 days. Each story MUST have:
   - A short title in user-language ("As a [user], I can [action] so that [value]" is fine but not required)
   - A description (2-4 sentences)
   - Acceptance criteria (3-7 bullets, each individually verifiable)

5. **Decompose stories into tasks** (only when useful). A task = 1-4 hours of work. Add tasks only when the story is complex enough that a checklist genuinely helps. **Many stories should have ZERO tasks** — that's a feature, not a bug. Over-decomposition is the #1 way PRD-splitter outputs become useless noise.

6. **Output format.** Write to `./PRD-tree.md` (ask first if it exists). The shape MUST be:

   ```markdown
   # <PRD title> — work breakdown

   > Source: <PRD path>
   > Split on: <ISO date>
   > Epics: <N>  ·  Stories: <N>  ·  Tasks: <N>

   ## Epic 1 · <Epic title>

   <One-sentence description of what shipping this epic means.>

   ### Story 1.1 · <Story title>

   <2-4 sentence description.>

   **Acceptance criteria:**
   - [ ] <criterion 1>
   - [ ] <criterion 2>
   - [ ] <criterion 3>

   **Tasks:** (optional, only if helpful)
   - [ ] <task 1>
   - [ ] <task 2>

   ### Story 1.2 · <Story title>
   ...

   ## Epic 2 · ...
   ```

7. **Cross-cutting concerns.** Add a final section called `## Cross-cutting` for things that don't belong to any single epic (auth, logging, deployment, accessibility audit). Treat each as a story.

8. **Summary at top.** After writing, summarize in the chat:
   - "I split this into N epics, M stories, K tasks. The biggest epic is X (Y stories). The most uncertain story I'd flag is Z — needs a clarifying conversation before estimating."

## Style rules

- **Story titles user-language, NOT implementation-language.** "User can reset password" not "Add /reset-password route".
- **Acceptance criteria are observable.** "Password reset email arrives within 60s" not "Use Postmark API correctly".
- **No estimates yet.** If the PRD already has estimates, IGNORE them — `/prd-estimate` re-derives them from the tree.
- **No assignees.** This is breakdown, not planning.

## When the PRD is bad

If the PRD has:
- < 200 words → too thin to split, ask user to flesh out first
- No clear user / value → ask "who is this for and what changes for them"
- > 30 pages → ask user to pre-trim by section, then split those sections one at a time
- Contradictions or undefined terms → list them in chat under "Open questions" — don't fabricate answers

## What you must NOT do

- Don't generate code samples — that's the implementer's job downstream.
- Don't invent acceptance criteria the PRD doesn't imply. If a criterion is unclear, mark it `- [ ] (unclear: <what's missing>)`.
- Don't write `PRD-tree.md` without confirming with the user first if it already exists — they may have edited it manually.
- Don't claim certainty on stories you genuinely don't understand. Flag them.

## Free vs Pro

- Free: full split, output to `PRD-tree.md`.
- Pro: includes the `prd-reviewer` sub-agent that gives a second opinion on any story with > 7 acceptance criteria or > 4 tasks (likely too big, should be split).
