#!/usr/bin/env bash
# prd-splitter · end-to-end smoke test
#
# Validates:
#   1. sample-prd.md is non-empty and Markdown-ish
#   2. expected-tree.md exists and references key sections (Epic, Story, Estimation summary)
#   3. push-linear.sh in --mock mode handles all subcommands correctly
#   4. push-linear.sh refuses non-mock create without LINEAR_API_KEY
#   5. push-linear.sh masks the API key when --mock prints it
#
# Run from this directory:   bash smoke-test.sh

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUSH="${HERE}/push-linear.sh"
PRD="${HERE}/sample-prd.md"
TREE="${HERE}/expected-tree.md"

pass=0
fail=0

assert() {
  local label="$1" actual="$2" expected="$3"
  if [ "${actual}" = "${expected}" ]; then
    echo "  ✓ ${label}"; pass=$((pass + 1))
  else
    echo "  ✗ ${label}"; echo "      expected: ${expected}"; echo "      actual:   ${actual}"
    fail=$((fail + 1))
  fi
}

assert_match() {
  local label="$1" actual="$2" pattern="$3"
  if echo "${actual}" | grep -q "${pattern}"; then
    echo "  ✓ ${label}"; pass=$((pass + 1))
  else
    echo "  ✗ ${label}"; echo "      pattern: ${pattern}"; echo "      actual:  ${actual}"
    fail=$((fail + 1))
  fi
}

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 1 · sample-prd.md exists and has body"
# ─────────────────────────────────────────────────────────────────────
if [ -f "${PRD}" ]; then
  size=$(wc -c < "${PRD}" | tr -d ' ')
  if [ "${size}" -gt 1000 ]; then
    echo "  ✓ sample-prd.md present (${size} bytes)"
    pass=$((pass + 1))
  else
    echo "  ✗ sample-prd.md too small (${size} bytes; expected > 1000)"
    fail=$((fail + 1))
  fi
else
  echo "  ✗ sample-prd.md missing"
  fail=$((fail + 1))
fi
assert_match "sample-prd.md has H1 title" "$(head -1 "${PRD}")" "^# "
assert_match "sample-prd.md has 'target user' section" "$(cat "${PRD}")" "target user"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 2 · expected-tree.md is well-formed"
# ─────────────────────────────────────────────────────────────────────
if [ -f "${TREE}" ]; then
  echo "  ✓ expected-tree.md present"; pass=$((pass + 1))
else
  echo "  ✗ expected-tree.md missing"; fail=$((fail + 1))
fi
assert_match "tree has at least one Epic"          "$(cat "${TREE}")" "^## Epic 1 · "
assert_match "tree has at least one Story"         "$(cat "${TREE}")" "^### Story 1\.1 · "
assert_match "tree has Estimation summary"         "$(cat "${TREE}")" "Estimation summary"
assert_match "tree has Cross-cutting section"      "$(cat "${TREE}")" "## Cross-cutting"
# Verify no non-Fibonacci point estimates appear. Fib = 1, 2, 3, 5, 8, 13.
non_fib=$(grep -oE '\*\*`[0-9]+ pts`\*\*' "${TREE}" | grep -oE '[0-9]+' | grep -vE '^(1|2|3|5|8|13)$' || true)
if [ -z "${non_fib}" ]; then
  echo "  ✓ tree uses only Fibonacci estimates"
  pass=$((pass + 1))
else
  echo "  ✗ non-Fibonacci estimates found: $(echo "${non_fib}" | tr '\n' ' ')"
  fail=$((fail + 1))
fi

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 3 · push-linear.sh --mock list-teams"
# ─────────────────────────────────────────────────────────────────────
out=$(bash "${PUSH}" --mock list-teams 2>&1)
assert_match "mock prints endpoint"           "${out}" "api.linear.app/graphql"
assert_match "mock prints teams query"        "${out}" "query { teams"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 4 · push-linear.sh --mock create with valid payload"
# ─────────────────────────────────────────────────────────────────────
payload='{"title":"Test","description":"d","teamId":"t1","estimate":5}'
out=$(echo "${payload}" | bash "${PUSH}" --mock create 2>&1)
assert_match "mock prints mutation"       "${out}" "issueCreate"
assert_match "mock includes title"        "${out}" "\"title\": \"Test\""
assert_match "mock includes estimate"     "${out}" "\"estimate\": 5"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 5 · push-linear.sh --mock create rejects missing teamId"
# ─────────────────────────────────────────────────────────────────────
out=$(echo '{"title":"x"}' | bash "${PUSH}" --mock create 2>&1)
rc=$?
assert "exits non-zero on missing teamId" "${rc}" "1"
assert_match "error names the missing field" "${out}" "missing required field 'teamId'"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 6 · non-mock create refuses without LINEAR_API_KEY"
# ─────────────────────────────────────────────────────────────────────
out=$(unset LINEAR_API_KEY; echo '{}' | bash "${PUSH}" create 2>&1)
rc=$?
assert "exits with code 2 when key missing" "${rc}" "2"
assert_match "error mentions LINEAR_API_KEY" "${out}" "LINEAR_API_KEY"

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "test 7 · API key is masked in mock output"
# ─────────────────────────────────────────────────────────────────────
out=$(LINEAR_API_KEY="lin_api_supersecret1234" bash "${PUSH}" --mock list-teams 2>&1)
assert_match "key appears masked" "${out}" "lin_\.\.\.34"
if echo "${out}" | grep -q "supersecret"; then
  echo "  ✗ FULL KEY LEAKED in mock output"
  fail=$((fail + 1))
else
  echo "  ✓ full key NOT present in mock output"
  pass=$((pass + 1))
fi

# ─────────────────────────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────"
echo "  passed: ${pass}    failed: ${fail}"
echo "─────────────────────────────────────────────"
[ ${fail} -gt 0 ] && exit 1
exit 0
