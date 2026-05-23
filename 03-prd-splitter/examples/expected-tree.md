# BookmarkBird — work breakdown

> Source: sample-prd.md
> Split on: 2026-05-23
> Epics: 5  ·  Stories: 16  ·  Tasks: 11
>
> NOTE: This is a *reference* output shape for the sample PRD. The real
> `/prd-split` command produces a similar tree from any PRD; exact wording
> and story count will vary because the skill exercises judgment.

## Epic 1 · Capture

User can save a bookmark from any of their tools, with notes and offline support.

### Story 1.1 · User can save from Chrome / Firefox with one click  · **`5 pts`**

A browser extension that, when clicked, captures the current URL, page title, any selected text, and lets the user type a quick note before saving.

**Acceptance criteria:**
- [ ] Extension installs from each store without errors
- [ ] One-click save captures URL + title + selection + optional note
- [ ] Save works offline; queued items sync when back online
- [ ] Visible confirmation toast after save

**Tasks:**
- [ ] Chrome extension manifest v3
- [ ] Firefox extension manifest
- [ ] Local IndexedDB queue
- [ ] Sync worker

### Story 1.2 · User can save via iOS share sheet  · **`5 pts`**

iOS share sheet extension allowing capture from any app on iPhone/iPad.

**Acceptance criteria:**
- [ ] Share sheet extension installed via the main app
- [ ] Captures URL + title + selection
- [ ] Captures even when main app isn't running
- [ ] Sync to cloud within 5s of capture (online)

### Story 1.3 · User can save by emailing save@bookmarkbird.app  · **`3 pts`**

User forwards / sends a link to a dedicated address; it lands in their library tied to their account email.

**Acceptance criteria:**
- [ ] Inbound email parsed for URLs in body and subject
- [ ] First URL becomes the bookmark; rest get notes
- [ ] Spam filtering rejects bulk emails
- [ ] Confirmation email sent on first successful save

### Story 1.4 · Safari extension at launch  · **`5 pts`**  *(open question — Sam to decide)*

**Open question:** Sam to decide whether Safari ships at launch or v1.1.

## Epic 2 · Find

Search across the user's library by full text, filter, and semantic intent.

### Story 2.1 · Full-text search by title / description / note  · **`5 pts`**

**Acceptance criteria:**
- [ ] Search box in main UI, returns results as user types (debounced)
- [ ] Results returned in < 200ms for libraries up to 10k bookmarks
- [ ] Highlights matched terms in result snippets
- [ ] Empty-state handling for no matches

**Tasks:**
- [ ] Postgres FTS / Meilisearch evaluation
- [ ] Index on save / update
- [ ] Highlight rendering

### Story 2.2 · Filter by tag, date, source, domain  · **`3 pts`**

**Acceptance criteria:**
- [ ] Filter chips above results
- [ ] Multi-select within a dimension (e.g., 2 tags)
- [ ] URL encodes current filter state (shareable filtered view)

### Story 2.3 · Semantic search ("React performance article from Q1")  · **`8 pts`**  *(flagged for re-split candidate — see below)*

**Acceptance criteria:**
- [ ] Embeddings generated on save (title + description; body optional per cost decision)
- [ ] Search supports natural-language query
- [ ] Falls back gracefully when no vector match (use FTS)
- [ ] Cost per 1k stored bookmarks documented

## Epic 3 · Organize

Auto-tag, tag manually, bulk operations.

### Story 3.1 · Auto-tag on save based on URL + title  · **`3 pts`**

**Acceptance criteria:**
- [ ] Rule-based tagger (github.com → `code`, youtube.com → `video`, etc.)
- [ ] User can override any auto-tag
- [ ] Tagger doesn't run on items captured offline (runs on sync instead)

### Story 3.2 · User-managed tags  · **`2 pts`**

**Acceptance criteria:**
- [ ] User can add / remove tags from a bookmark
- [ ] Tag list in side panel shows all user tags
- [ ] Renaming a tag updates all bookmarks using it

### Story 3.3 · Bulk operations (select many, retag / archive)  · **`3 pts`**

**Acceptance criteria:**
- [ ] Checkbox on each bookmark row
- [ ] Bulk actions menu: archive, retag, export, delete
- [ ] Operations on 1000+ items complete in < 5s (background job)

## Epic 4 · Share

Public links, public collections, view counts.

### Story 4.1 · Share a single bookmark via public URL  · **`3 pts`**

**Acceptance criteria:**
- [ ] One-click share generates a public URL
- [ ] Expiry options: 24h / 7d / never
- [ ] Recipient sees a clean page without requiring signup
- [ ] Page is responsive (mobile + desktop)

### Story 4.2 · Share a tagged collection as a public page  · **`5 pts`**

**Acceptance criteria:**
- [ ] User picks a tag; toggle "make public"
- [ ] Public page shows all bookmarks for that tag
- [ ] Updates to the tag (new bookmarks) appear within 1 min
- [ ] User can unpublish

### Story 4.3 · View counts on shared links  · **`2 pts`**

**Acceptance criteria:**
- [ ] Each shared URL tracks unique IP views (deduped per day)
- [ ] Owner sees the count on their dashboard
- [ ] Privacy: no IP stored, only counters

## Epic 5 · Billing

Free / Pro / Team tiers, payment integration, gating.

### Story 5.1 · User upgrades from Free to Pro  · **`5 pts`**

**Acceptance criteria:**
- [ ] Pricing page lists tiers
- [ ] Checkout flow via chosen processor (Stripe vs Lemon — open question)
- [ ] Successful payment unlocks Pro features immediately
- [ ] Receipts sent by email

**Tasks:**
- [ ] Stripe / Lemon evaluation (open question)
- [ ] Webhook handler
- [ ] Subscription state in DB
- [ ] Gating middleware

### Story 5.2 · 200-bookmark hard cap on Free tier  · **`2 pts`**

**Acceptance criteria:**
- [ ] Saving the 201st bookmark shows upgrade prompt instead
- [ ] Existing bookmarks remain readable / searchable
- [ ] Upgrade prompt is dismissable (user can stay on free, lose new-save ability)

## Cross-cutting

### Story X.1 · GDPR + CCPA compliance + data export  · **`5 pts`**

**Acceptance criteria:**
- [ ] User can export all data as JSON or CSV from settings
- [ ] User can delete account; data purged within 24h
- [ ] Privacy policy page with all required disclosures
- [ ] Cookie consent banner (EU only via geo-IP)

### Story X.2 · Sentry + PostHog wired before launch  · **`3 pts`**

**Acceptance criteria:**
- [ ] Sentry catches and reports unhandled errors in web + extensions
- [ ] PostHog tracks key events (signup, save, search, upgrade)
- [ ] No PII in either system (URLs are not PII for our purposes; notes are scrubbed)

### Story X.3 · Status page  · **`2 pts`**

**Acceptance criteria:**
- [ ] Status page at status.bookmarkbird.app
- [ ] Auto-updated from uptime monitor (Better Stack / equivalent)
- [ ] Subscribe-to-incidents email

---

## Estimation summary

- Total points: 73
- Distribution: 1pt × 0 · 2pt × 4 · 3pt × 6 · 5pt × 6 · 8pt × 1 · 13pt × 0
- Stories flagged for re-split (8+ pts): 1 — Story 2.3 (semantic search)
- At ~1 pt/half-day this is roughly: **37 dev-days** (~7-8 weeks for 1 senior IC; ~4 weeks for 2)

## Re-split candidates

### Story 2.3 · Semantic search (8 pts) — proposed split

The 8 collapses two distinct concerns: embedding pipeline vs query/UX. They have different unknowns.

1. **Story 2.3a · Embedding pipeline on save** (~5 pts) — pick embedding model, store vectors, backfill existing bookmarks
2. **Story 2.3b · Natural-language search UI + fallback to FTS** (~3 pts) — UI affordance, query → embedding, ranking, fallback

Both ship independently — the pipeline is useful even before the UI exists (powers future "related bookmarks" feature).

---

## Open questions (carried from PRD)

- Safari at launch vs v1.1? (affects scope by ~1 story / ~5 pts)
- Semantic search on titles only vs full body? (cost gap ~10x)
- Stripe vs Lemon Squeezy? (affects scope by ~0 pts but affects launch timeline)
