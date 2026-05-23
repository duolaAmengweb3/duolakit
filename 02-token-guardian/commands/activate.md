---
name: token-activate
description: Activate the Pro tier for token-guardian using the email you used at Gumroad checkout. Verified in real-time against the duolakit-license Worker. Stored locally at ~/.duolakit/licenses.json. No telemetry.
argument-hint: "<email-you-used-at-gumroad-checkout>"
---

# /token-activate

You are running the `token-activate` command from the `token-guardian` plugin.

Your task: take the email the user gave you, verify against the duolakit-license Cloudflare Worker (which is fed by Gumroad's purchase webhook in real-time), and report success or failure.

## How activation works (so you can explain if asked)

1. Buyer purchases on Gumroad (`hunterweb303.gumroad.com/l/token-guardian`).
2. Within seconds, Gumroad pings `duolakit-license.hxu92521.workers.dev/ping`.
3. The Worker writes the buyer's email to Cloudflare KV.
4. The buyer runs `/token-activate <their-email>`.
5. This script GETs `/verify?plugin=token-guardian&email=<email>`.
6. If the email is in KV → success → write `~/.duolakit/licenses.json` and unlock Pro.

End-to-end latency from purchase to activation: typically < 30 seconds.

## Procedure

1. **Parse the email.** First argument. If missing, print usage:
   ```
   usage: /token-activate <email-you-used-at-gumroad-checkout>

   The email is in your Gumroad receipt. It's the address you typed at checkout.
   Buy: https://hunterweb303.gumroad.com/l/token-guardian
   ```
   and stop.

2. **Verify via the Worker.** Run:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh activate <email>
   ```

3. **Interpret the exit code.**
   - `0` → success. Print:
     ```
     ✓ Pro activated for token-guardian (<email>)

     You now have:
       - /token-route multi-provider routing recommendations
       - /token-calibrate persistent /cost calibration + 7-day history
       - 48h email support: noreply@duolakit.pages.dev

     Activation is local to this machine. Re-run /token-activate <email>
     on each device. The email works on unlimited personal devices.
     ```
   - `3` → email not on the buyers list. Print the script's stderr verbatim — it already explains the common causes (recent purchase still in flight, email mismatch, refunded).
   - `4` → email format invalid. Tell user to double-check.
   - `5` → network error reaching the Worker. Suggest retry + checking internet.
   - `2` → script usage error. Shouldn't happen if step 1 validated.

4. **Privacy note** (always print at the end of a successful activation):

   > Stored at `~/.duolakit/licenses.json`. The file contains only your
   > email and a timestamp. It never leaves your machine. The Worker
   > knows you bought (it has to, to verify) but doesn't track your
   > usage of the plugin afterward.

## How to deactivate

```bash
bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh deactivate
```

Removes only the `token-guardian` slot from `~/.duolakit/licenses.json`. Other duolakit plugin licenses are untouched. Refunds and disputes are auto-handled by the Worker — within seconds of the Gumroad refund webhook, the email is removed from KV and subsequent `check` calls will fail.

## What you must NOT do

- Don't echo the email after activation — already in the user's receipt.
- Don't try to verify against any URL other than the configured `DUOLAKIT_VERIFY_URL` (or its default).
- Don't store anything outside `~/.duolakit/`.
- Don't pretend Pro is active if the script returned non-zero.

## Mock modes (for testing)

`bin/license.sh` supports:
- `--mock-success activate <email>` → pretends the Worker said valid
- `--mock-failure activate <email>` → pretends the Worker said invalid
- `DUOLAKIT_VERIFY_URL=http://localhost:8787/verify` → override Worker URL

These are for `tests/run-all.sh` and `examples/smoke-test.sh`. Never invoked by this slash command in normal use.
