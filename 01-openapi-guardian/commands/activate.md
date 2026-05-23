---
name: openapi-activate
description: Activate the Pro tier for openapi-guardian using your Gumroad license key. Stored locally at ~/.duolakit/licenses.json. No telemetry.
argument-hint: "<license-key>  (from Gumroad receipt email)"
---

# /openapi-activate

You are running the `openapi-activate` command from the `openapi-guardian` plugin.

Your task: take the license key the user gave you, verify it against Gumroad's License API by shelling out to `${CLAUDE_PLUGIN_ROOT}/bin/license.sh`, and report success or failure.

## Procedure

1. **Parse the key.**
   - The key is the first argument. Expected shape: 4 groups of 4 alphanumeric chars separated by `-`, e.g. `ABCD-1234-EFGH-5678`. Be lenient — Gumroad has changed the format historically.
   - If no key was passed, print:
     ```
     usage: /openapi-activate <license-key>

     The key arrives in your Gumroad receipt email after purchase.
     Buy: https://duolakit.gumroad.com/l/openapi-guardian
     ```
     and stop.

2. **Verify.** Run:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh activate <key>
   ```

3. **Interpret the exit code.**
   - `0` → success. The key was accepted and `~/.duolakit/licenses.json` now has a slot for `openapi-guardian` with `valid: true`. Print:
     ```
     ✓ Pro activated for openapi-guardian.

     You now have:
       - Multi-spec registry (multiple openapi.yaml in one repo)
       - Reviewer sub-agent on diffs > 50 lines
       - 48h email support: noreply@duolakit.pages.dev

     The activation is local to this machine. Re-run /openapi-activate <key>
     on each device you use. The key works on unlimited personal devices.
     ```
   - `3` → Gumroad rejected the key. Print the error message the script returned. Common cases:
     - "That license does not exist for the product" → key typo or wrong product
     - "Product not yet listed on Gumroad" → we haven't shipped the listing yet
     - "license refunded / chargebacked / disputed" → tell user to contact support
   - `2` → script usage error. Shouldn't happen if step 1 validated, but if it does, print the script's stderr.

4. **Privacy note** (always print at the end of a successful activation):

   > Stored at `~/.duolakit/licenses.json`. This file contains your license key
   > and the email address Gumroad has on file. It never leaves your machine
   > except when the plugin re-verifies with Gumroad (re-verification triggers
   > automatically every 30 days during normal use).

## How to deactivate

```bash
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh deactivate
```

This removes only the `openapi-guardian` slot from `~/.duolakit/licenses.json`. Other duolakit plugin licenses are untouched.

## What you must NOT do

- Don't echo the license key after activation — the user already has it in their email.
- Don't try to verify the key against any URL other than `api.gumroad.com`.
- Don't store the key in any file outside `~/.duolakit/`.
- Don't pretend Pro is active if the script returned non-zero.

## Mock modes (for testing)

Internally, `bin/license.sh` supports:
- `--mock-success activate <key>` → pretends Gumroad said valid
- `--mock-failure activate <key>` → pretends Gumroad said invalid

These are for `examples/smoke-test.sh` and never invoked by this slash command.
