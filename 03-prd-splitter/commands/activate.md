---
name: prd-activate
description: Activate the Pro tier for prd-splitter using the email you gave when you DM'd to buy Pro. Verified in real-time against the duolakit-license Worker. Stored locally at ~/.duolakit/licenses.json. No telemetry.
argument-hint: "<your-purchase-email>"
---

# /prd-activate

You are running the `prd-activate` command from the `prd-splitter` plugin.

Your task: take the email the user gave you, verify against the duolakit-license Cloudflare Worker (which the operator updates in real-time when a buyer pays), and report success or failure.

## How activation works (so you can explain if asked)

1. Buyer DMs [@hunterweb303 on X](https://x.com/hunterweb303) or [t.me/dsa885](https://t.me/dsa885) to buy Pro ($19, any payment method).
2. After payment is confirmed, the operator runs `bash bin/admin.sh grant <plugin> <email>` which POSTs the email to the duolakit-license Worker.
3. The Worker writes the buyer's email to Cloudflare KV.
4. The buyer runs `/prd-activate <their-email>`.
5. This script GETs `/verify?plugin=prd-splitter&email=<email>`.
6. If the email is in KV → success → write `~/.duolakit/licenses.json` and unlock Pro.

End-to-end latency from operator grant to buyer activation: < 5 seconds.

## Procedure

1. **Parse the email.** First argument. If missing, print usage:
   ```
   usage: /prd-activate <your-purchase-email>

   Use the email you gave when you DM'd to buy Pro.
   Buy: DM [@hunterweb303 on X](https://x.com/hunterweb303) or [t.me/dsa885](https://t.me/dsa885) — $19 lifetime
   ```
   and stop.

2. **Verify via the Worker.** Run:
   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/bin/license.sh activate <email>
   ```

3. **Interpret the exit code.**
   - `0` → success. Print:
     ```
     ✓ Pro activated for prd-splitter (<email>)

     You now have:
       - /prd-push linear (direct GraphQL push, no CSV detour)
       - prd-reviewer second-opinion on 8+ point stories
       - Persistent per-project estimation calibration
       - 48h email support: noreply@duolakit.pages.dev

     Activation is local to this machine. Re-run /prd-activate <email>
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

Removes only the `prd-splitter` slot from `~/.duolakit/licenses.json`. Other duolakit plugin licenses are untouched. Refunds are handled manually: when the operator agrees to refund, they run `bash bin/admin.sh revoke <plugin> <email>` which removes the email from KV. Subsequent `check` calls fail within seconds.

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
