# prd-splitter · examples + smoke test

What's here:

| File | Purpose |
|---|---|
| `sample-prd.md` | A realistic ~600-word PRD ("BookmarkBird") used as input for end-to-end demo |
| `expected-tree.md` | What `/prd-split` + `/prd-estimate` should approximately produce. Reference shape, not a strict target — Claude's wording varies |
| `push-linear.sh` | Pro: Linear GraphQL push helper. Supports `--mock` for testing without hitting the API |
| `smoke-test.sh` | 20 assertions across all the above |

## Run

```bash
bash smoke-test.sh
```

Expected: `passed: 20    failed: 0`.

## Try the full flow (in Claude Code)

```bash
cd examples
claude
```

Then:

```
/prd-split sample-prd.md
```

Claude reads the PRD and writes a `PRD-tree.md` next to it. Compare against `expected-tree.md` (yours will be similar but not identical — that's expected).

```
/prd-estimate
```

Fibonacci points get added to every story, with a re-split flag on Story 2.3 (semantic search, 8 pts).

```
/prd-export linear
```

Produces `PRD-tree.linear.csv` ready to import in Linear.

## Pro: push directly to Linear

Requires:
- A valid Pro license. Activate via `/prd-activate <license-key>` after buying on Gumroad — that writes a verified slot to `~/.duolakit/licenses.json`. For local testing without a real key, use `bash ../bin/license.sh --mock-success activate TEST-KEY`.
- `LINEAR_API_KEY` env var (get one at https://linear.app/settings/api)

Always dry-runs first:

```
/prd-push linear
```

Add `--no-dry-run` to actually create issues.

## Testing without a real Linear key

The push helper has a `--mock` mode that prints what it would send to Linear without making a network call:

```bash
bash push-linear.sh --mock list-teams
echo '{"title":"x","teamId":"t","estimate":3}' | bash push-linear.sh --mock create
```

Used by `smoke-test.sh` to keep the test suite hermetic.
