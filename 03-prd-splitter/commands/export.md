---
name: prd-export
description: Export PRD-tree.md to a downstream format — Linear CSV, Jira CSV, or plain Markdown.
argument-hint: "<format>  (one of: linear, jira, markdown)"
---

# /prd-export

You are running the `prd-export` command from the `prd-splitter` plugin.

Your task: convert the structured `PRD-tree.md` into a CSV (Linear or Jira) or cleaned-up Markdown, ready for import.

## Inputs

- `./PRD-tree.md` — produced by `/prd-split` and (optionally) `/prd-estimate`
- Argument: one of `linear`, `jira`, `markdown`

## Format spec — Linear CSV

Linear's CSV import expects this header (verify at https://linear.app/docs/import-csv-file):

```csv
Title,Description,Status,Priority,Estimate,Labels,Project
```

Mapping rules:
- One row per **story** (NOT per task — tasks become description checklist).
- `Title` = the story title, prefix with `[<Epic title>]` for grouping. Example: `[Auth] User can reset password`.
- `Description` = the story description + tasks rendered as a Markdown checklist:
  ```
  <description>

  **Acceptance criteria:**
  - [ ] criterion 1
  - [ ] criterion 2

  **Tasks:**
  - [ ] task 1
  ```
- `Status` = always `Backlog` (Linear's default for new imports).
- `Priority` = empty (leave for the team to set).
- `Estimate` = the story-point number (Linear interprets this as their estimate field).
- `Labels` = the epic name as a single label (e.g., `epic-auth`). Lowercase, dashed.
- `Project` = empty (user picks during import).

Write to `./PRD-tree.linear.csv`.

## Format spec — Jira CSV

Jira's CSV import is more flexible; we use this minimal header:

```csv
Issue Type,Summary,Description,Story Points,Labels,Epic Link
```

Mapping rules:
- One row per epic (Issue Type = `Epic`), then one row per story (Issue Type = `Story`).
- `Summary` = the title.
- `Description` = same shape as Linear description above.
- `Story Points` = the Fibonacci number.
- `Labels` = empty (Jira handles via Epic Link).
- `Epic Link` = the epic's `Summary` value, so Jira links stories to their epic on import.

Write to `./PRD-tree.jira.csv`.

## Format spec — Markdown

Just a cleaned re-emission of PRD-tree.md with:
- Acceptance criteria reformatted as a flat list (no [ ] checkboxes — assume reader is reading, not implementing)
- Tasks omitted (they're noise outside the tool that owns the story)
- Estimates kept inline
- A new H1 prefix `# Work breakdown — exportable Markdown`

Write to `./PRD-tree.export.md`.

## Procedure

1. **Validate argument.** Must be `linear`, `jira`, or `markdown`. Otherwise print usage:
   ```
   Usage: /prd-export <format>
     format:  linear   →  PRD-tree.linear.csv
              jira     →  PRD-tree.jira.csv
              markdown →  PRD-tree.export.md
   ```

2. **Read PRD-tree.md.** If missing, tell the user to run `/prd-split` first.

3. **Parse the tree** into a structured representation: a list of epics, each with a list of stories, each with title / description / acceptance criteria / tasks / estimate.

4. **Render to the chosen format.** Use the rules above.

5. **CSV escaping.** Wrap all fields in double quotes. Replace internal `"` with `""`. Multi-line description fields → keep newlines, CSV readers handle them.

6. **Confirm before writing.** Tell the user "Going to write PRD-tree.linear.csv (12 rows). OK?" then write on confirm.

7. **Print a one-line import instruction.**
   - Linear: "In Linear: ⌘K → Import → CSV → drop PRD-tree.linear.csv → confirm the column mapping → import."
   - Jira: "In Jira: Project settings → Import → CSV → upload PRD-tree.jira.csv → run the import wizard."
   - Markdown: "Output ready at PRD-tree.export.md — open and read or paste anywhere."

## What you must NOT do

- Don't push to Linear/Jira from this command — that's `/prd-push` (Pro). This is CSV only.
- Don't include tasks as separate rows. Tasks belong to stories; importing them as issues creates noise.
- Don't fabricate epics/stories that aren't in PRD-tree.md.
- Don't write CSV without confirming if the target file exists.

## Free vs Pro

- Free: all three formats fully supported.
- Pro: also runs `/prd-push linear` which uses the Linear API to create issues directly (no CSV intermediate).
