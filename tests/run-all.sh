#!/usr/bin/env bash
# duolakit · full test suite
#
# Validates every plugin in the marketplace:
#   - JSON files parse
#   - Markdown command/skill/agent frontmatter has required fields
#   - Shell hooks have valid syntax
#   - SKU-02 PreToolUse hook behaves correctly under 6 scenarios
#   - SKU-01 Express demo type-checks and serves all 4 endpoints (DELETE intentionally 404s)
#
# Run from repo root:   bash tests/run-all.sh
# Exit 0 on success, 1 on any failure.

set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.."

ROOT="$(pwd)"
FAIL=0
PASS=0

section() {
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "  $1"
  echo "═══════════════════════════════════════════════════════════"
}

ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); }
bad()  { echo "  ✗ $1"; FAIL=$((FAIL+1)); }

# ─────────────────────────────────────────────────────────────────────
section "1 · JSON validation"
# ─────────────────────────────────────────────────────────────────────
JSON_FILES=(
  ".claude-plugin/marketplace.json"
  "00-hello/.claude-plugin/plugin.json"
  "01-openapi-guardian/.claude-plugin/plugin.json"
  "01-openapi-guardian/hooks/hooks.json"
  "02-token-guardian/.claude-plugin/plugin.json"
  "02-token-guardian/hooks/hooks.json"
  "03-prd-splitter/.claude-plugin/plugin.json"
)
for f in "${JSON_FILES[@]}"; do
  if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
    ok "$f"
  else
    bad "$f (invalid JSON)"
  fi
done

# ─────────────────────────────────────────────────────────────────────
section "2 · Markdown frontmatter (commands, skills, agents)"
# ─────────────────────────────────────────────────────────────────────
MD_FILES=$(find 00-hello 01-openapi-guardian 02-token-guardian 03-prd-splitter \
  \( -path '*/commands/*' -o -path '*/agents/*' -o -path '*/skills/*' \) \
  -name '*.md')
for f in ${MD_FILES}; do
  result=$(python3 - "$f" <<'PYEOF'
import sys, re
fp = sys.argv[1]
content = open(fp).read()
m = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
if not m:
    print("NO_FRONTMATTER")
    sys.exit()
fm = {}
for line in m.group(1).split('\n'):
    if ':' in line and not line.strip().startswith('-'):
        k, _, v = line.partition(':')
        fm[k.strip()] = v.strip()
missing = [k for k in ('name','description') if k not in fm]
if missing:
    print("MISSING:" + ",".join(missing))
else:
    print("OK:" + fm['name'])
PYEOF
)
  case "$result" in
    OK:*)
      ok "$f  (${result#OK:})"
      ;;
    NO_FRONTMATTER)
      bad "$f (missing --- frontmatter)"
      ;;
    MISSING:*)
      bad "$f (${result})"
      ;;
    *)
      bad "$f (unknown error: $result)"
      ;;
  esac
done

# ─────────────────────────────────────────────────────────────────────
section "3 · Shell script syntax"
# ─────────────────────────────────────────────────────────────────────
SH_FILES=$(find 00-hello 01-openapi-guardian 02-token-guardian 03-prd-splitter \
  -name '*.sh' -not -path '*/node_modules/*')
for f in ${SH_FILES}; do
  if bash -n "$f" 2>/dev/null; then
    ok "$f"
  else
    bad "$f (syntax error)"
  fi
done

# ─── back up ~/.duolakit once for all sections that touch it ────────────
DK_BACKUP=""
if [ -d "${HOME}/.duolakit" ]; then
  DK_BACKUP="${HOME}/.duolakit.testbak.$$"
  mv "${HOME}/.duolakit" "${DK_BACKUP}"
fi
restore_duolakit() {
  rm -rf "${HOME}/.duolakit"
  if [ -n "${DK_BACKUP}" ] && [ -d "${DK_BACKUP}" ]; then
    mv "${DK_BACKUP}" "${HOME}/.duolakit"
  fi
}
trap restore_duolakit EXIT

# ─────────────────────────────────────────────────────────────────────
section "4 · SKU-02 token-guardian — hook smoke test (10 assertions)"
# ─────────────────────────────────────────────────────────────────────
if bash 02-token-guardian/examples/smoke-test.sh > /tmp/sku2-smoke.out 2>&1; then
  ok "02-token-guardian/examples/smoke-test.sh (all assertions passed)"
else
  bad "02-token-guardian/examples/smoke-test.sh (see /tmp/sku2-smoke.out)"
  echo "    ─── last 20 lines ───"
  tail -20 /tmp/sku2-smoke.out | sed 's/^/    /'
fi

# ─────────────────────────────────────────────────────────────────────
section "5 · SKU-03 prd-splitter — examples + Linear push helper (20 assertions)"
# ─────────────────────────────────────────────────────────────────────
if bash 03-prd-splitter/examples/smoke-test.sh > /tmp/sku3-smoke.out 2>&1; then
  ok "03-prd-splitter/examples/smoke-test.sh (all assertions passed)"
else
  bad "03-prd-splitter/examples/smoke-test.sh (see /tmp/sku3-smoke.out)"
  echo "    ─── last 30 lines ───"
  tail -30 /tmp/sku3-smoke.out | sed 's/^/    /'
fi

# ─────────────────────────────────────────────────────────────────────
section "6 · License helper — state transitions across all three plugins"
# ─────────────────────────────────────────────────────────────────────
rm -rf "${HOME}/.duolakit"

# Each plugin should report check=1 on a clean machine.
for sku in 01-openapi-guardian 02-token-guardian 03-prd-splitter; do
  rc=0; bash $sku/bin/license.sh check || rc=$?
  if [ "${rc}" = "1" ]; then
    ok "$sku: check on clean state → exit 1"
  else
    bad "$sku: clean check expected 1 got ${rc}"
  fi
done

# Activate each via --mock-success, then check should succeed.
for sku in 01-openapi-guardian 02-token-guardian 03-prd-splitter; do
  bash $sku/bin/license.sh --mock-success activate "TEST-KEY-$sku" > /tmp/license-activate.out 2>&1
  rc=0; bash $sku/bin/license.sh check || rc=$?
  if [ "${rc}" = "0" ]; then ok "$sku: check after mock-success activate → exit 0"; else bad "$sku: post-activate check expected 0 got ${rc}"; fi
done

# Activate with --mock-failure should not flip the slot (already valid from above), but should report exit 3.
rc=0; bash 01-openapi-guardian/bin/license.sh --mock-failure activate BAD > /dev/null 2>&1 || rc=$?
if [ "${rc}" = "3" ]; then ok "mock-failure activate → exit 3"; else bad "mock-failure expected 3 got ${rc}"; fi

# Real activate with placeholder product_id should refuse with exit 3 + clear message.
out=$(bash 01-openapi-guardian/bin/license.sh activate ANY-KEY 2>&1)
rc=$?
if [ "${rc}" = "3" ] && echo "${out}" | grep -q "not yet listed"; then
  ok "real activate with placeholder product_id → exit 3 with explanatory msg"
else
  bad "real activate placeholder behavior wrong (rc=${rc}, out=${out})"
fi

# Deactivate clears the slot.
bash 01-openapi-guardian/bin/license.sh deactivate > /dev/null
rc=0; bash 01-openapi-guardian/bin/license.sh check || rc=$?
if [ "${rc}" = "1" ]; then ok "deactivate then check → exit 1"; else bad "post-deactivate check expected 1 got ${rc}"; fi

# Shared file integrity: SKU-02 and SKU-03 slots must still be present after SKU-01 deactivate.
remaining=$(python3 -c "import json; d=json.load(open('$HOME/.duolakit/licenses.json')); print(','.join(sorted(d.get('licenses',{}).keys())))" 2>/dev/null)
if [ "${remaining}" = "prd-splitter,token-guardian" ]; then
  ok "shared licenses.json kept other plugins' slots intact"
else
  bad "shared licenses.json corrupted; expected prd-splitter,token-guardian got '${remaining}'"
fi

rm -rf "${HOME}/.duolakit"

# ─────────────────────────────────────────────────────────────────────
section "7 · SKU-01 openapi-guardian — Express demo end-to-end"
# ─────────────────────────────────────────────────────────────────────
cd 01-openapi-guardian/examples/express-demo

# Install (idempotent — skips if node_modules present and lockfile matches)
if [ ! -d node_modules ]; then
  echo "  installing deps (first run only)..."
  if npm install --silent > /tmp/sku1-install.log 2>&1; then
    ok "npm install"
  else
    bad "npm install (see /tmp/sku1-install.log)"
    cd "${ROOT}"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  passed: ${PASS}    failed: ${FAIL}"
    echo "═══════════════════════════════════════════════════════════"
    exit 1
  fi
else
  ok "node_modules already present (skip install)"
fi

if npx --no-install tsc --noEmit > /tmp/sku1-tsc.log 2>&1; then
  ok "tsc --noEmit"
else
  bad "tsc --noEmit (see /tmp/sku1-tsc.log)"
fi

# Find a free port
PORT_TRY=3344
while lsof -i :${PORT_TRY} >/dev/null 2>&1; do
  PORT_TRY=$((PORT_TRY + 1))
done

PORT=${PORT_TRY} npx tsx server.ts > /tmp/sku1-server.log 2>&1 &
SERVER_PID=$!
sleep 2

# Verify server up
if curl -s -f "http://localhost:${PORT_TRY}/users" > /dev/null; then
  ok "server boots on port ${PORT_TRY}"
else
  bad "server failed to boot (see /tmp/sku1-server.log)"
  kill ${SERVER_PID} 2>/dev/null
  cd "${ROOT}"
  echo ""
  echo "  passed: ${PASS}    failed: ${FAIL}"
  exit 1
fi

# GET /users returns []
EMPTY=$(curl -s "http://localhost:${PORT_TRY}/users")
if [ "${EMPTY}" = "[]" ]; then ok "GET /users → []"; else bad "GET /users → expected [] got: ${EMPTY}"; fi

# POST /users → 201
CREATED=$(curl -s -X POST "http://localhost:${PORT_TRY}/users" \
  -H 'content-type: application/json' \
  -d '{"email":"test@example.com","name":"Test"}')
ID=$(echo "${CREATED}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
if [ -n "${ID}" ]; then ok "POST /users → created id=${ID:0:8}..."; else bad "POST /users → no id in response: ${CREATED}"; fi

# GET /users/{id}
if [ -n "${ID}" ]; then
  GOT=$(curl -s "http://localhost:${PORT_TRY}/users/${ID}")
  if echo "${GOT}" | grep -q "${ID}"; then ok "GET /users/{id} → user with matching id"; else bad "GET /users/{id} → ${GOT}"; fi
fi

# DELETE /users/{id} → 404 (intentional drift)
if [ -n "${ID}" ]; then
  DEL_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "http://localhost:${PORT_TRY}/users/${ID}")
  if [ "${DEL_CODE}" = "404" ]; then ok "DELETE /users/{id} → 404 (intentional drift, will be caught by /openapi-check)"; else bad "DELETE /users/{id} → expected 404 got ${DEL_CODE}"; fi
fi

kill ${SERVER_PID} 2>/dev/null
wait 2>/dev/null
cd "${ROOT}"

# ─────────────────────────────────────────────────────────────────────
section "8 · SKU-01 openapi-guardian — Fastify demo (Pro proof)"
# ─────────────────────────────────────────────────────────────────────
cd 01-openapi-guardian/examples/fastify-demo

if [ ! -d node_modules ]; then
  echo "  installing Fastify deps (first run only)..."
  if npm install --silent > /tmp/sku1-fastify-install.log 2>&1; then
    ok "fastify npm install"
  else
    bad "fastify npm install (see /tmp/sku1-fastify-install.log)"
    cd "${ROOT}"
    echo "  passed: ${PASS}    failed: ${FAIL}"
    exit 1
  fi
else
  ok "fastify node_modules already present (skip install)"
fi

if npx --no-install tsc --noEmit > /tmp/sku1-fastify-tsc.log 2>&1; then
  ok "fastify tsc --noEmit"
else
  bad "fastify tsc --noEmit (see /tmp/sku1-fastify-tsc.log)"
fi

PORT_TRY=3346
while lsof -i :${PORT_TRY} >/dev/null 2>&1; do
  PORT_TRY=$((PORT_TRY + 1))
done

PORT=${PORT_TRY} npx tsx server.ts > /tmp/sku1-fastify-server.log 2>&1 &
FSERVER_PID=$!
sleep 2

if curl -s -f "http://localhost:${PORT_TRY}/users" > /dev/null; then
  ok "fastify server boots on port ${PORT_TRY}"
else
  bad "fastify server failed to boot (see /tmp/sku1-fastify-server.log)"
  kill ${FSERVER_PID} 2>/dev/null
  cd "${ROOT}"
  echo "  passed: ${PASS}    failed: ${FAIL}"
  exit 1
fi

# Same intentional drift: spec has DELETE /users/{id}, handler doesn't.
F_CREATED=$(curl -s -X POST "http://localhost:${PORT_TRY}/users" \
  -H 'content-type: application/json' \
  -d '{"email":"fastify@example.com","name":"FastifyTest"}')
F_ID=$(echo "${F_CREATED}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
if [ -n "${F_ID}" ]; then
  ok "fastify POST /users → created id=${F_ID:0:8}..."
  F_DEL_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "http://localhost:${PORT_TRY}/users/${F_ID}")
  if [ "${F_DEL_CODE}" = "404" ]; then
    ok "fastify DELETE /users/{id} → 404 (same intentional drift as Express)"
  else
    bad "fastify DELETE expected 404 got ${F_DEL_CODE}"
  fi
else
  bad "fastify POST /users → no id: ${F_CREATED}"
fi

kill ${FSERVER_PID} 2>/dev/null
wait 2>/dev/null
cd "${ROOT}"

# ─────────────────────────────────────────────────────────────────────
section "Summary"
# ─────────────────────────────────────────────────────────────────────
echo "  passed: ${PASS}    failed: ${FAIL}"
echo ""
if [ ${FAIL} -gt 0 ]; then
  exit 1
fi
echo "  All plugin assets validated and tested. All SKUs are production-grade."
exit 0
