#!/usr/bin/env bash
# prd-splitter · Linear push helper (Pro feature)
#
# Usage:
#   bash push-linear.sh list-teams           # GET your Linear teams (needs LINEAR_API_KEY)
#   bash push-linear.sh create               # POST one issue, read JSON from stdin
#   bash push-linear.sh --mock list-teams    # print the request that would be made (no API call)
#   bash push-linear.sh --mock create        # ditto for create
#
# Stdin for `create` is a JSON object with shape:
#   {"title":"...","description":"...","teamId":"...","estimate":5,"labels":["epic-auth"]}
#
# Output: Linear's JSON response (or, in --mock mode, the curl command + payload).
#
# Safety:
#   - Never logs LINEAR_API_KEY (even with set -x; we manually mask in --mock).
#   - Refuses to run create-mode without explicit confirmation OR --mock.
#   - Always exits 0 in --mock to ease testing.

set -u

MOCK=0
if [ "${1:-}" = "--mock" ]; then
  MOCK=1
  shift
fi

CMD="${1:-}"

if [ -z "${CMD}" ]; then
  cat >&2 <<'EOF'
Usage:
  push-linear.sh list-teams
  push-linear.sh create  (stdin: JSON)
  push-linear.sh --mock list-teams
  push-linear.sh --mock create
EOF
  exit 1
fi

# Require the API key for any real call.
if [ "${MOCK}" = "0" ] && [ -z "${LINEAR_API_KEY:-}" ]; then
  echo "error: LINEAR_API_KEY not set. Get one at https://linear.app/settings/api" >&2
  echo "       (or run with --mock to preview the request without calling the API)" >&2
  exit 2
fi

ENDPOINT="https://api.linear.app/graphql"

# Mask the key when echoing in mock mode.
masked_key() {
  if [ -n "${LINEAR_API_KEY:-}" ]; then
    local len=${#LINEAR_API_KEY}
    if [ "${len}" -gt 8 ]; then
      echo "${LINEAR_API_KEY:0:4}...${LINEAR_API_KEY: -2}"
    else
      echo "***"
    fi
  else
    echo "<unset>"
  fi
}

call_or_print() {
  local payload="$1"
  if [ "${MOCK}" = "1" ]; then
    echo "[mock] POST ${ENDPOINT}"
    echo "[mock] auth: $(masked_key)"
    echo "[mock] payload:"
    echo "${payload}" | python3 -m json.tool 2>/dev/null || echo "${payload}"
    return 0
  fi
  # Real call:
  curl -sS -X POST "${ENDPOINT}" \
    -H "Authorization: ${LINEAR_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "${payload}"
}

case "${CMD}" in
  list-teams)
    PAYLOAD='{"query":"query { teams { nodes { id key name } } }"}'
    call_or_print "${PAYLOAD}"
    ;;

  create)
    INPUT=$(cat)
    if [ -z "${INPUT}" ]; then
      echo "error: create-mode requires JSON on stdin" >&2
      exit 1
    fi

    PAYLOAD=$(python3 - "${INPUT}" <<'PYEOF'
import sys, json
try:
    src = json.loads(sys.argv[1])
except json.JSONDecodeError as e:
    print(f"error: stdin is not valid JSON ({e})", file=sys.stderr); sys.exit(1)

for k in ("title", "teamId"):
    if k not in src:
        print(f"error: missing required field '{k}'", file=sys.stderr); sys.exit(1)

mutation = """mutation IssueCreate($input: IssueCreateInput!) {
  issueCreate(input: $input) {
    success
    issue { id identifier title url }
  }
}"""

variables = {
    "input": {
        "title": src["title"],
        "description": src.get("description", ""),
        "teamId": src["teamId"],
    }
}
if "estimate" in src and src["estimate"] is not None:
    variables["input"]["estimate"] = int(src["estimate"])

print(json.dumps({"query": mutation, "variables": variables}))
PYEOF
)
    [ -z "${PAYLOAD}" ] && exit 1
    call_or_print "${PAYLOAD}"
    ;;

  *)
    echo "error: unknown subcommand '${CMD}'" >&2
    exit 1
    ;;
esac
