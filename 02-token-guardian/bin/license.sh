#!/usr/bin/env bash
# duolakit · license helper for token-guardian
#
# Activation model: REAL-TIME EMAIL VERIFICATION via duolakit-license Worker.
#
#   1. Buyer purchases on Gumroad.
#   2. Within seconds, Gumroad pings our Cloudflare Worker, which writes
#      the buyer's email to KV.
#   3. Buyer runs /openapi-activate <their-purchase-email>.
#   4. This script GETs the Worker's /verify endpoint.
#   5. If the email is in KV → write ~/.duolakit/licenses.json and unlock Pro.
#
# Why this model: as of 2026-05, Gumroad's UI did not expose a per-product
# "Generate license keys" toggle on standard digital products, so we built
# our own real-time verification on top of the Gumroad Ping webhook.
#
# Usage:
#   license.sh check                        → exit 0 if Pro is active, 1 if not
#   license.sh activate <email>             → call Worker /verify, write licenses.json
#   license.sh deactivate                   → remove this plugin's slot
#   license.sh status                       → print ~/.duolakit/licenses.json
#
# Testing (skips network):
#   license.sh --mock-success activate <email>   → pretend Worker said valid
#   license.sh --mock-failure activate <email>   → pretend Worker said invalid
#   DUOLAKIT_VERIFY_URL=http://localhost:8787/verify license.sh activate <email>
#                                                → override the Worker URL
#
# State file: ~/.duolakit/licenses.json (shared across all duolakit plugins)

set -u

PLUGIN_NAME="token-guardian"
DEFAULT_VERIFY_URL="https://duolakit-license.hxu92521.workers.dev/verify"

DUOLAKIT_DIR="${HOME}/.duolakit"
LICENSES_FILE="${DUOLAKIT_DIR}/licenses.json"

MOCK_MODE=""
if [ "${1:-}" = "--mock-success" ]; then MOCK_MODE="success"; shift; fi
if [ "${1:-}" = "--mock-failure" ]; then MOCK_MODE="failure"; shift; fi

OP="${1:-}"
shift || true

mkdir -p "${DUOLAKIT_DIR}" 2>/dev/null || true

VERIFY_URL="${DUOLAKIT_VERIFY_URL:-${DEFAULT_VERIFY_URL}}"

# ─── helpers ──────────────────────────────────────────────────────────
normalize_email() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

valid_email() {
  echo "$1" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
}

write_slot() {
  local email="$1" valid="$2"
  python3 - "${LICENSES_FILE}" "${PLUGIN_NAME}" "${email}" "${valid}" <<'PYEOF'
import sys, json, os
from datetime import datetime, timezone

path, plugin, email, valid_str = sys.argv[1:5]
valid = valid_str.lower() == "true"

if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except json.JSONDecodeError:
        data = {"version": 1, "licenses": {}}
else:
    data = {"version": 1, "licenses": {}}

data.setdefault("licenses", {})
data["licenses"][plugin] = {
    "email": email,
    "verified_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
    "valid": valid
}
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PYEOF
}

remove_slot() {
  python3 - "${LICENSES_FILE}" "${PLUGIN_NAME}" <<'PYEOF'
import sys, json, os
path, plugin = sys.argv[1:3]
if not os.path.exists(path):
    sys.exit(0)
try:
    with open(path) as f:
        data = json.load(f)
except json.JSONDecodeError:
    sys.exit(0)
if "licenses" in data and plugin in data["licenses"]:
    del data["licenses"][plugin]
with open(path, "w") as f:
    json.dump(data, f, indent=2)
PYEOF
}

slot_valid() {
  python3 - "${LICENSES_FILE}" "${PLUGIN_NAME}" <<'PYEOF'
import sys, json, os
path, plugin = sys.argv[1:3]
if not os.path.exists(path):
    sys.exit(1)
try:
    with open(path) as f:
        data = json.load(f)
except json.JSONDecodeError:
    sys.exit(1)
slot = data.get("licenses", {}).get(plugin)
if slot and slot.get("valid") is True:
    sys.exit(0)
sys.exit(1)
PYEOF
}

verify_via_worker() {
  local email="$1"
  if [ "${MOCK_MODE}" = "success" ]; then
    echo '{"valid":true,"plugin":"'"${PLUGIN_NAME}"'","email":"'"${email}"'"}'
    return 0
  fi
  if [ "${MOCK_MODE}" = "failure" ]; then
    echo '{"valid":false,"plugin":"'"${PLUGIN_NAME}"'","email":"'"${email}"'"}'
    return 0
  fi
  # URL-encode the email by letting curl do it via --data-urlencode then -G.
  curl -sS --max-time 15 -G "${VERIFY_URL}" \
    --data-urlencode "plugin=${PLUGIN_NAME}" \
    --data-urlencode "email=${email}" \
    2>/dev/null || echo '{"valid":false,"error":"network"}'
}

# ─── operations ───────────────────────────────────────────────────────
case "${OP}" in
  check)
    if slot_valid; then
      exit 0
    fi
    exit 1
    ;;

  activate)
    EMAIL_RAW="${1:-}"
    if [ -z "${EMAIL_RAW}" ]; then
      echo "usage: license.sh activate <email-you-used-at-gumroad-checkout>" >&2
      exit 2
    fi
    EMAIL=$(normalize_email "${EMAIL_RAW}")
    if ! valid_email "${EMAIL}"; then
      echo "activation failed: '${EMAIL_RAW}' is not a valid email format" >&2
      exit 4
    fi

    RESP=$(verify_via_worker "${EMAIL}")
    VALID=$(echo "${RESP}" | python3 -c "import sys,json
try: d=json.load(sys.stdin)
except: print('false'); sys.exit()
print('true' if d.get('valid') else 'false')" 2>/dev/null || echo "false")

    if [ "${VALID}" = "true" ]; then
      write_slot "${EMAIL}" "true"
      echo "✓ Pro activated for ${PLUGIN_NAME} (${EMAIL})"
      exit 0
    else
      ERR=$(echo "${RESP}" | python3 -c "import sys,json
try: d=json.load(sys.stdin); print(d.get('reason') or d.get('error') or '')
except: print('')" 2>/dev/null || echo "")
      if [ "${ERR}" = "network" ]; then
        echo "activation failed: could not reach license server (${VERIFY_URL})" >&2
        echo "  Check your internet connection and try again." >&2
        exit 5
      fi
      echo "activation failed: ${EMAIL} is not on the ${PLUGIN_NAME} buyers list." >&2
      echo "  - If you bought < 60 seconds ago, the Gumroad webhook may still be in flight. Wait and retry." >&2
      echo "  - The email must exactly match the one you used at Gumroad checkout." >&2
      echo "  - Refunded / disputed purchases are automatically removed." >&2
      echo "  - Contact noreply@duolakit.pages.dev with your Gumroad order ID if this persists." >&2
      exit 3
    fi
    ;;

  deactivate)
    remove_slot
    echo "deactivated: ${PLUGIN_NAME}"
    exit 0
    ;;

  status)
    if [ -f "${LICENSES_FILE}" ]; then
      cat "${LICENSES_FILE}"
    else
      echo '{"version":1,"licenses":{}}'
    fi
    ;;

  *)
    cat >&2 <<EOF
usage: license.sh <op> [args]
  check                          Exit 0 if Pro is active, 1 if not.
  activate <email>               Verify email against Worker, store locally.
  deactivate                     Remove this plugin's license slot.
  status                         Print ~/.duolakit/licenses.json

Testing helpers:
  --mock-success activate <email>   Treat verify call as success.
  --mock-failure activate <email>   Treat verify call as invalid.
  DUOLAKIT_VERIFY_URL=...           Override the Worker URL.
EOF
    exit 2
    ;;
esac
