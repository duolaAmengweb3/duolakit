#!/usr/bin/env bash
# token-guardian · end-to-end smoke test
#
# Exercises the PreToolUse hook against simulated tool-call payloads and
# verifies all four functional contracts:
#   1. Each call appends one record to ~/.duolakit/token-log.jsonl
#   2. Crossing the warn threshold emits ONE warning to stderr
#   3. Crossing the stop threshold emits ONE warning to stderr
#   4. Repeat calls at the same level do NOT re-warn (dedupe)
#   5. Activity older than 5 hours is excluded from the window sum
#
# Run from this directory:   bash smoke-test.sh
# Or from anywhere:           bash <plugin-root>/examples/smoke-test.sh
#
# Side effects: WIPES ~/.duolakit/ at start. Don't run this on a machine
# where you already use token-guardian for real budget tracking unless
# you back up ~/.duolakit/ first.

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK="${HERE}/../hooks/log-tool.sh"

if [ ! -f "${HOOK}" ]; then
  echo "FAIL: cannot find hook at ${HOOK}"
  exit 1
fi

DUOLAKIT_DIR="${HOME}/.duolakit"
LOG_FILE="${DUOLAKIT_DIR}/token-log.jsonl"
STATE_FILE="${DUOLAKIT_DIR}/state.json"
CONFIG_FILE="${DUOLAKIT_DIR}/token-guardian.json"

pass=0
fail=0

assert() {
  local label="$1"
  local actual="$2"
  local expected="$3"
  if [ "${actual}" = "${expected}" ]; then
    echo "  ✓ ${label}"
    pass=$((pass + 1))
  else
    echo "  ✗ ${label}"
    echo "      expected: ${expected}"
    echo "      actual:   ${actual}"
    fail=$((fail + 1))
  fi
}

assert_match() {
  local label="$1"
  local actual="$2"
  local pattern="$3"
  if echo "${actual}" | grep -q "${pattern}"; then
    echo "  ✓ ${label}"
    pass=$((pass + 1))
  else
    echo "  ✗ ${label}"
    echo "      pattern:   ${pattern}"
    echo "      actual:    ${actual}"
    fail=$((fail + 1))
  fi
}

reset() {
  rm -rf "${DUOLAKIT_DIR}"
  mkdir -p "${DUOLAKIT_DIR}"
}

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 1 · single small call → log written, no warning"
# ─────────────────────────────────────────────────────────────────────
reset
err=$(echo '{"tool_name":"Read","tool_input":{"file_path":"/tmp/x"}}' | bash "${HOOK}" 2>&1)
assert "no stderr output"      "${err}"            ""
assert "log has 1 line"        "$(wc -l < "${LOG_FILE}" | tr -d ' ')"  "1"
assert "no state file yet"     "$([ -f "${STATE_FILE}" ] && echo yes || echo no)"  "no"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 2 · flood to >80% → exactly ONE warn-level message"
# ─────────────────────────────────────────────────────────────────────
reset
warn_count=0
stop_count=0
# Each Read call with 4000-char input = 200 baseline + 1000 input = 1200 tok.
# 220k * 0.81 / 1200 ≈ 149 calls to cross 80% but not 95%.
all_err=""
for i in $(seq 1 150); do
  one_err=$(echo '{"tool_name":"Read","tool_input":{"data":"'"$(printf 'x%.0s' $(seq 1 4000))"'"}}' | bash "${HOOK}" 2>&1)
  all_err+="${one_err}"
done
warn_count=$(echo "${all_err}" | grep -c "Heads up" || true)
stop_count=$(echo "${all_err}" | grep -c "Approaching limit" || true)
assert "exactly 1 warn message"  "${warn_count}"  "1"
assert "exactly 0 stop messages" "${stop_count}"  "0"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 3 · continue flooding to >95% → exactly ONE stop-level message"
# ─────────────────────────────────────────────────────────────────────
# We're already past 80% from test 2. Add ~40 more 1200-tok calls = ~48k → push past 95%.
all_err=""
for i in $(seq 1 40); do
  one_err=$(echo '{"tool_name":"Read","tool_input":{"data":"'"$(printf 'x%.0s' $(seq 1 4000))"'"}}' | bash "${HOOK}" 2>&1)
  all_err+="${one_err}"
done
warn_count=$(echo "${all_err}" | grep -c "Heads up" || true)
stop_count=$(echo "${all_err}" | grep -c "Approaching limit" || true)
assert "no further warn message"  "${warn_count}"  "0"
assert "exactly 1 stop message"   "${stop_count}"  "1"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 4 · further calls at stop level → silent (dedupe)"
# ─────────────────────────────────────────────────────────────────────
all_err=""
for i in 1 2 3 4 5; do
  one_err=$(echo '{"tool_name":"Read","tool_input":{"file_path":"/tmp/x"}}' | bash "${HOOK}" 2>&1)
  all_err+="${one_err}"
done
assert "no further warnings"  "${all_err}"  ""

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 5 · old (>5h) entries are excluded from window sum"
# ─────────────────────────────────────────────────────────────────────
reset
old_ts=$(node -e 'console.log(new Date(Date.now() - (5*60+1)*60*1000).toISOString())')
for i in $(seq 1 200); do
  echo "{\"ts\":\"${old_ts}\",\"tool\":\"Read\",\"input_size\":4000,\"estimated_tokens\":1200}" >> "${LOG_FILE}"
done
# Now make ONE fresh call. Total fresh contribution: ~1200 tok = ~0.5% of budget.
# No warning should fire even though log has 200 entries totaling 240k tokens.
err=$(echo '{"tool_name":"Read","tool_input":{"file_path":"/tmp/x"}}' | bash "${HOOK}" 2>&1)
assert "no warning despite 240k of OLD activity"  "${err}"  ""

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 6 · custom budget config respected"
# ─────────────────────────────────────────────────────────────────────
reset
# Set a tiny 10k budget so even one moderate call crosses 80%.
cat > "${CONFIG_FILE}" <<'EOF'
{
  "five_hour_window_tokens": 10000,
  "warn_at_percent": 80,
  "hard_stop_at_percent": 95,
  "calibration_multiplier": 1.0
}
EOF
# One 32000-char Read = ~8200 tok → 82% of 10k budget → warn
err=$(echo '{"tool_name":"Read","tool_input":{"data":"'"$(printf 'x%.0s' $(seq 1 32000))"'"}}' | bash "${HOOK}" 2>&1)
assert_match "warn fires under custom budget" "${err}" "Heads up"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────"
echo "  passed: ${pass}    failed: ${fail}"
echo "─────────────────────────────────────────────"
if [ ${fail} -gt 0 ]; then
  exit 1
fi
exit 0
