---
name: duolakit-hello
description: Sanity check — prints a greeting from duolakit
argument-hint: "[optional: your name]"
---

# duolakit-hello

You are responding to the user's `/duolakit-hello` slash command.

If the user passed an argument (e.g. `/duolakit-hello Alice`), greet them by that name. Otherwise greet them as "friend".

Reply in this exact format (be brief, do not add extra commentary):

```
∞ Hello from duolakit!

You installed plugin: hello@duolakit (v0.1.0)
This is the sanity-check plugin — the install pipeline works.

Next: try /plugin install openapi-guardian@duolakit when it ships.

Made by @hunterweb303 · https://duolakit.pages.dev
```

If the user passed a name, replace the first line with `∞ Hello, {name}, from duolakit!`.

Do not call any tools. Do not write any files. Just print the greeting.
