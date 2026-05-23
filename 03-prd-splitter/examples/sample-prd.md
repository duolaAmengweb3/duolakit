# BookmarkBird — Product Requirements (v0.1)

**Owner:** Sam (PM)
**Last updated:** 2026-05-23
**Target launch:** 2026-Q3

---

## 1 · The problem

Engineers at small SaaS startups (5-50 people) collect 200-2000 bookmarks across browsers, Slack threads, Notion pages, and personal docs. They want to find what they saved 6 months ago — and they can't, because the bookmarks are scattered across 6 different tools none of which talk to each other.

Existing solutions either:
- Want to be a second brain (Notion, Obsidian) — too heavy for "I just want to find that one React performance article from Q1"
- Are too lightweight (browser bookmarks) — no full-text search, no shared library, lost when device dies

## 2 · The target user

- Senior IC engineer or staff engineer at a tech-forward company
- Saves 5-50 bookmarks per week
- Owns at least 2 devices (laptop + phone)
- Trusts a paid tool more than a free one (so monetization works)

Not for: enterprise teams of 500+ (different needs), casual users with < 5 bookmarks/week (won't pay).

## 3 · Core user stories

### As a user, I want to capture a bookmark from anywhere

- Browser extension on Chrome / Firefox / Safari — one click captures URL + title + selection + my note
- iOS share sheet extension — capture from any app
- Email-to-bookmark — forward a link to `save@bookmarkbird.app`, it appears in my library
- Slack slash command `/save <url>` — capture without leaving Slack
- Capture should work offline; sync when back online

### As a user, I want to find what I saved

- Full-text search across title, description, my notes, and (when available) the article body
- Filter by date, tag, source (browser / email / slack), domain
- Search should return results in < 200ms for libraries up to 10k bookmarks
- "Saved 6 months ago about React performance" should work as a natural-language query (semantic search)

### As a user, I want to organize without overhead

- Auto-tagging based on URL + title + content (e.g., URLs from github.com get a `code` tag)
- I can override or add my own tags
- Folders are optional (most users do fine with tags alone)
- Bulk operations: select multiple, retag, archive, export

### As a user, I want privacy

- All my data is encrypted at rest
- I can export everything as JSON / CSV anytime
- I can delete my account and all data within 24 hours
- No selling of data to third parties (state this in marketing)

### As a user, I want to share specific bookmarks

- One-click share to a public URL with optional expiry (24h / 7d / never)
- Share a tagged collection ("things I've read about distributed systems") as a public page
- View counts on shares — see if the link I sent got opened
- Sharing should not require the recipient to sign up

## 4 · Pricing

- **Free**: 200 bookmarks lifetime, web app only
- **Pro $7/mo or $60/year**: unlimited bookmarks, all integrations, semantic search, sharing
- **Team $15/user/mo**: Pro features + shared team library + admin controls

## 5 · Cross-cutting requirements

- Sub-100ms server response time for 95th percentile
- Web app accessible per WCAG 2.1 AA
- GDPR + CCPA compliant
- Deployable to a single $20/mo VPS for the first 1000 users (no AWS lock-in)
- Crash analytics (Sentry) + product analytics (PostHog) wired up before launch
- Public status page (Statuspage.io or similar) for paying users

## 6 · Out of scope for v1

- Team features (defer to v1.1)
- Slack integration (defer to v1.2)
- AI summaries of saved articles (defer to v1.3 — we'll evaluate cost vs willingness-to-pay)
- Self-hosted edition (defer to v2 if at all)

## 7 · Open questions (Sam to answer before split)

- Do we ship Safari extension at launch or only Chrome/Firefox? (Safari is harder to publish on, ~2 weeks extra work)
- Is the semantic search MVP "vector search on titles only" or "vector search on full body"? (cost: ~10x more storage for body)
- Do we want Stripe or Lemon Squeezy for billing? (Lemon = easier for international, Stripe = better dispute handling)
