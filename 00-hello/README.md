# hello · duolakit

> Sanity-check plugin. Verifies that the duolakit marketplace + install pipeline work end-to-end.

## Install

```bash
# In Claude Code:
/plugin marketplace add duolaAmengweb3/duolakit
/plugin install hello@duolakit
```

## Usage

```
/duolakit-hello
/duolakit-hello Alice
```

Output:

```
∞ Hello from duolakit!

You installed plugin: hello@duolakit (v0.1.0)
This is the sanity-check plugin — the install pipeline works.

Next: try /plugin install openapi-guardian@duolakit when it ships.

Made by @hunterweb303 · https://duolakit.pages.dev
```

## What this plugin does

Nothing useful. It exists so we can verify:

1. Marketplace JSON parses ✓
2. Plugin install pipeline works ✓
3. Slash command registration works ✓
4. Frontmatter is valid ✓

When you see this greeting, the rest of duolakit's SKUs (`openapi-guardian`, `token-guardian`, `prd-splitter`, ...) are ready to ship into the same pipeline.

## License

MIT
