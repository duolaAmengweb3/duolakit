#!/usr/bin/env bash
# duolakit · license helper for token-guardian
#
# Usage:
#   license.sh check                          → exit 0 if valid, 1 if missing/invalid
#   license.sh activate <license-key>         → verify with Gumroad, write licenses.json
#   license.sh deactivate                     → remove the plugin's slot
#   license.sh status                         → print current state (json)
#   license.sh --mock-success <op> [...]      → testing: pretend Gumroad said valid
#   license.sh --mock-failure <op> [...]      → testing: pretend Gumroad said invalid
#
# State file: ~/.duolakit/licenses.json  (shared across all duolakit plugins)
# Network:    POST https://api.gumroad.com/v2/licenses/verify

set -u

PLUGIN_NAME="token-guardian"
# Replace this with the real Gumroad product_id after the product is listed.
# Until then, the script refuses real verification with a clear message.
GUMROAD_PRODUCT_ID="PLACEHOLDER_REPLACE_AT_GUMROAD_LAUNCH"

DUOLAKIT_DIR="${HOME}/.duolakit"
LICENSES_FILE="${DUOLAKIT_DIR}/licenses.json"

MOCK_MODE=""
if [ "${1:-}" = "--mock-success" ]; then MOCK_MODE="success"; shift; fi
if [ "${1:-}" = "--mock-failure" ]; then MOCK_MODE="failure"; shift; fi

OP="${1:-}"
shift || true

mkdir -p "${DUOLAKIT_DIR}" 2>/dev/null || true

# ─── helpers ──────────────────────────────────────────────────────────
read_licenses() {
  if [ ! -f "${LICENSES_FILE}" ]; then
    echo '{"version":1,"licenses":{}}'
  else
    cat "${LICENSES_FILE}"
  fi
}

write_slot() {
  local key="$1" email="$2" valid="$3"
  python3 - "${LICENSES_FILE}" "${PLUGIN_NAME}" "${key}" "${email}" "${valid}" <<'PYEOF'
import sys, json, os
from datetime import datetime, timezone

path, plugin, key, email, valid_str = sys.argv[1:6]
valid = valid_str.lower() == "true"

if os.path.exists(path):
    with open(path) as f:
        data = json.load(f)
else:
    data = {"version": 1, "licenses": {}}

data.setdefault("licenses", {})
data["licenses"][plugin] = {
    "key": key,
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
with open(path) as f:
    data = json.load(f)
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

verify_with_gumroad() {
  local key="$1"
  # In MOCK_MODE, skip the network call.
  if [ "${MOCK_MODE}" = "success" ]; then
    echo '{"success":true,"purchase":{"email":"mock@example.com","refunded":false,"chargebacked":false,"disputed":false}}'
    return 0
  fi
  if [ "${MOCK_MODE}" = "failure" ]; then
    echo '{"success":false,"message":"That license does not exist for the product"}'
    return 0
  fi
  # Real call. Refuses if product_id is still the placeholder.
  if [ "${GUMROAD_PRODUCT_ID}" = "PLACEHOLDER_REPLACE_AT_GUMROAD_LAUNCH" ]; then
    echo '{"success":false,"message":"Product not yet listed on Gumroad. Pro purchase available soon."}'
    return 0
  fi
  curl -sS --max-time 15 -X POST "https://api.gumroad.com/v2/licenses/verify" \
    --data-urlencode "product_id=${GUMROAD_PRODUCT_ID}" \
    --data-urlencode "license_key=${key}" \
    --data-urlencode "increment_uses_count=false" \
    2>/dev/null || echo '{"success":false,"message":"network error"}'
}

# ─── operations ───────────────────────────────────────────────────────
case "${OP}" in
  check)
    if slot_valid; then
      exit 0
    else
      exit 1
    fi
    ;;

  activate)
    KEY="${1:-}"
    if [ -z "${KEY}" ]; then
      echo "usage: license.sh activate <license-key>" >&2
      exit 2
    fi
    RESP=$(verify_with_gumroad "${KEY}")
    SUCCESS=$(echo "${RESP}" | python3 -c "import sys,json; d=json.load(sys.stdin); print('true' if d.get('success') else 'false')" 2>/dev/null || echo "false")
    if [ "${SUCCESS}" = "true" ]; then
      EMAIL=$(echo "${RESP}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('purchase',{}).get('email','unknown'))" 2>/dev/null || echo "unknown")
      write_slot "${KEY}" "${EMAIL}" "true"
      echo "activated: ${PLUGIN_NAME} (${EMAIL})"
      exit 0
    else
      MSG=$(echo "${RESP}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','unknown error'))" 2>/dev/null || echo "unknown error")
      echo "activation failed: ${MSG}" >&2
      exit 3
    fi
    ;;

  deactivate)
    remove_slot
    echo "deactivated: ${PLUGIN_NAME}"
    exit 0
    ;;

  status)
    read_licenses
    ;;

  *)
    cat >&2 <<EOF
usage: license.sh <op> [args]
  check                          Exit 0 if Pro is active, 1 if not.
  activate <license-key>         Verify with Gumroad and store locally.
  deactivate                     Remove this plugin's license.
  status                         Print full licenses.json.

Test modes (skip Gumroad network call):
  --mock-success <op> [args]     Treat any verify call as success.
  --mock-failure <op> [args]     Treat any verify call as failure.
EOF
    exit 2
    ;;
esac
