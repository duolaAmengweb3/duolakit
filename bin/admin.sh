#!/usr/bin/env bash
# duolakit · operator admin tool
#
# Concierge sales model: when a buyer DMs you and pays (any way you both agree),
# run this script to grant / revoke their access. The script writes to the same
# Cloudflare KV that the Gumroad-Ping endpoint would feed, so buyers can
# immediately activate via /<plugin>-activate <their-email>.
#
# Usage:
#   bin/admin.sh grant   <plugin> <email>     # grant access (writes KV)
#   bin/admin.sh revoke  <plugin> <email>     # revoke access (deletes KV)
#   bin/admin.sh check   <plugin> <email>     # is this email currently active?
#   bin/admin.sh list    <plugin>             # NOT supported — KV doesn't list
#                                              cheaply; see Cloudflare dashboard
#                                              KV browser instead.
#
# Plugins: openapi-guardian | token-guardian | prd-splitter
#
# Secret source (in order):
#   1. $DUOLAKIT_PING_SECRET env var
#   2. ~/.duolakit-admin/ping-secret file (mode 600)
#   3. exit 2 with instructions
#
# Worker URL:
#   DUOLAKIT_WORKER_URL env override or default below.

set -u

DEFAULT_WORKER_URL="https://duolakit-license.hxu92521.workers.dev"
WORKER_URL="${DUOLAKIT_WORKER_URL:-${DEFAULT_WORKER_URL}}"

ALLOWED_PLUGINS="openapi-guardian token-guardian prd-splitter"

# ─── secret resolution ──────────────────────────────────────────────
resolve_secret() {
  if [ -n "${DUOLAKIT_PING_SECRET:-}" ]; then
    echo "${DUOLAKIT_PING_SECRET}"
    return 0
  fi
  if [ -f "${HOME}/.duolakit-admin/ping-secret" ]; then
    cat "${HOME}/.duolakit-admin/ping-secret" | tr -d '\n'
    return 0
  fi
  cat >&2 <<EOF
error: PING_SECRET not found.

Set it via env:
  export DUOLAKIT_PING_SECRET=<your-secret>

Or store it at ~/.duolakit-admin/ping-secret (mode 600):
  mkdir -p ~/.duolakit-admin
  echo "<your-secret>" > ~/.duolakit-admin/ping-secret
  chmod 600 ~/.duolakit-admin/ping-secret
EOF
  exit 2
}

mask_secret() {
  local s="$1"
  local len=${#s}
  if [ "${len}" -gt 8 ]; then
    echo "${s:0:4}...${s: -2}"
  else
    echo "***"
  fi
}

# ─── arg parsing ────────────────────────────────────────────────────
OP="${1:-}"
PLUGIN="${2:-}"
EMAIL="${3:-}"

usage() {
  cat >&2 <<EOF
usage: bin/admin.sh <op> <plugin> [<email>]

ops:
  grant   <plugin> <email>     Grant Pro access (writes KV)
  revoke  <plugin> <email>     Revoke access (deletes KV)
  check   <plugin> <email>     Is this email active?
  health                       Check Worker /health

plugins: ${ALLOWED_PLUGINS// /, }

flags:
  --worker-url <url>           Override Worker URL (default: ${DEFAULT_WORKER_URL})

env:
  DUOLAKIT_PING_SECRET         If set, used instead of ~/.duolakit-admin/ping-secret
  DUOLAKIT_WORKER_URL          Override Worker URL
EOF
  exit 2
}

# Handle --worker-url anywhere
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --worker-url) WORKER_URL="$2"; shift 2 ;;
    --help|-h) usage ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]}"
OP="${1:-}"
PLUGIN="${2:-}"
EMAIL="${3:-}"

validate_plugin() {
  for p in ${ALLOWED_PLUGINS}; do
    [ "${PLUGIN}" = "${p}" ] && return 0
  done
  echo "error: unknown plugin '${PLUGIN}'. Allowed: ${ALLOWED_PLUGINS}" >&2
  exit 3
}

validate_email() {
  if ! echo "${EMAIL}" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
    echo "error: '${EMAIL}' is not a valid email" >&2
    exit 4
  fi
}

# ─── operations ─────────────────────────────────────────────────────
case "${OP}" in
  grant)
    [ -z "${PLUGIN}" ] || [ -z "${EMAIL}" ] && usage
    validate_plugin
    validate_email
    SECRET=$(resolve_secret)
    echo "→ granting ${PLUGIN} to ${EMAIL}"
    echo "  worker: ${WORKER_URL}"
    echo "  secret: $(mask_secret "${SECRET}")"
    RESP=$(curl -sS --max-time 15 -X POST "${WORKER_URL}/ping?secret=${SECRET}" \
      -H "content-type: application/x-www-form-urlencoded" \
      --data-urlencode "email=${EMAIL}" \
      --data-urlencode "product_permalink=${PLUGIN}" \
      --data-urlencode "sale_id=concierge-$(date +%s)" 2>&1) || {
      echo "✗ network error: ${RESP}" >&2
      exit 5
    }
    OK=$(echo "${RESP}" | python3 -c "import sys,json
try: d=json.load(sys.stdin); print('true' if d.get('ok') else 'false')
except: print('false')" 2>/dev/null)
    if [ "${OK}" = "true" ]; then
      ACTION=$(echo "${RESP}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','?'))" 2>/dev/null)
      # plugin "openapi-guardian" → command "/openapi-activate"
      # plugin "token-guardian"   → command "/token-activate"
      # plugin "prd-splitter"     → command "/prd-activate"
      ACTIVATE_CMD="/${PLUGIN%%-*}-activate"
      echo "✓ ${ACTION}: tell the buyer to run inside Claude Code:"
      echo "    ${ACTIVATE_CMD} ${EMAIL}"
      exit 0
    fi
    echo "✗ unexpected response:" >&2
    echo "${RESP}" >&2
    exit 6
    ;;

  revoke)
    [ -z "${PLUGIN}" ] || [ -z "${EMAIL}" ] && usage
    validate_plugin
    validate_email
    SECRET=$(resolve_secret)
    echo "→ revoking ${PLUGIN} for ${EMAIL}"
    RESP=$(curl -sS --max-time 15 -X POST "${WORKER_URL}/ping?secret=${SECRET}" \
      -H "content-type: application/x-www-form-urlencoded" \
      --data-urlencode "email=${EMAIL}" \
      --data-urlencode "product_permalink=${PLUGIN}" \
      --data-urlencode "refunded=true" 2>&1) || {
      echo "✗ network error: ${RESP}" >&2
      exit 5
    }
    ACTION=$(echo "${RESP}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('action','?'))" 2>/dev/null)
    if [ "${ACTION}" = "revoked" ]; then
      echo "✓ revoked. Buyer's /<plugin>-activate will start failing within seconds."
      exit 0
    fi
    echo "✗ unexpected response:" >&2
    echo "${RESP}" >&2
    exit 6
    ;;

  check)
    [ -z "${PLUGIN}" ] || [ -z "${EMAIL}" ] && usage
    validate_plugin
    validate_email
    RESP=$(curl -sS --max-time 15 -G "${WORKER_URL}/verify" \
      --data-urlencode "plugin=${PLUGIN}" \
      --data-urlencode "email=${EMAIL}" 2>&1)
    VALID=$(echo "${RESP}" | python3 -c "import sys,json
try: d=json.load(sys.stdin); print('true' if d.get('valid') else 'false')
except: print('false')" 2>/dev/null)
    if [ "${VALID}" = "true" ]; then
      echo "✓ ${EMAIL} is active for ${PLUGIN}"
    else
      echo "✗ ${EMAIL} is NOT active for ${PLUGIN}"
    fi
    ;;

  health)
    RESP=$(curl -sS --max-time 10 "${WORKER_URL}/" 2>&1) || {
      echo "✗ unreachable: ${WORKER_URL}" >&2
      exit 5
    }
    echo "${RESP}"
    ;;

  *)
    usage
    ;;
esac
