#!/bin/bash
# branch-protection.sh
# Applies branch protection rules to main on all 34 JPGBMR repos.
# Required CI status check context is set per stack to match the exact job id.
# Tracks progress in pipeline-state.json — safe to re-run.
#
# CRITICAL: context strings must match CI job names exactly.
# A mismatch permanently blocks all PRs with an unsatisfiable status check.
#
# Contexts:
#   html       → "CI / lint"           (workflow name: CI, job id: lint)
#   python     → "CI / lint-and-test"  (workflow name: CI, job id: lint-and-test)
#   powershell → "CI / analyze"        (workflow name: CI, job id: analyze)
#
# Run LAST — only after CI is confirmed green on main for all 34 repos.
#
# Usage: bash scripts/branch-protection.sh  (run from repo-bootstrap root)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/../pipeline-state.json"
TOKEN=$(gh auth token --hostname github.com)

touch "$STATE_FILE"

PROJECTS=(
  ascii-art auto-prompter cache-cleaner conway-game maze-master qr-generator
  secure-vault seo-intel text-summarizer typing-test
  cpu-benchmark system-health
  aspect-ratio base64 binary-converter bmi-calculator contract-generator
  countdown-timer cron-builder css-minifier euro-castles hash-generator
  hex-palette invoice-generator json-formatter lorem-generator morse-translator
  pixel-art-editor reading-estimator regex-tester social-card timezone-converter
  tip-calculator word-counter
)

declare -A STACKS=(
  [ascii-art]=python       [auto-prompter]=python    [cache-cleaner]=python
  [conway-game]=python     [maze-master]=python      [qr-generator]=python
  [secure-vault]=python    [seo-intel]=python        [text-summarizer]=python
  [typing-test]=python
  [cpu-benchmark]=powershell  [system-health]=powershell
  [aspect-ratio]=html      [base64]=html             [binary-converter]=html
  [bmi-calculator]=html    [contract-generator]=html [countdown-timer]=html
  [cron-builder]=html      [css-minifier]=html       [euro-castles]=html
  [hash-generator]=html    [hex-palette]=html        [invoice-generator]=html
  [json-formatter]=html    [lorem-generator]=html    [morse-translator]=html
  [pixel-art-editor]=html  [reading-estimator]=html  [regex-tester]=html
  [social-card]=html       [timezone-converter]=html [tip-calculator]=html
  [word-counter]=html
)

COUNT=0
TOTAL=${#PROJECTS[@]}
SUCCESS=0
FAILED=0
FAILED_REPOS=()

state_append() {
  local repo="$1" step="$2" status="$3" notes="$4"
  printf '{"repo":"%s","step":"%s","status":"%s","ts":"%s","notes":"%s"}\n' \
    "$repo" "$step" "$status" "$(date -u +%FT%TZ)" "$notes" >> "$STATE_FILE"
}

for project in "${PROJECTS[@]}"; do
  COUNT=$((COUNT + 1))
  STACK="${STACKS[$project]}"

  # Context string must match the CI workflow job id exactly — case and space sensitive
  case "$STACK" in
    html)       CONTEXT="CI / lint" ;;
    python)     CONTEXT="CI / lint-and-test" ;;
    powershell) CONTEXT="CI / analyze" ;;
  esac

  echo "[$COUNT/$TOTAL] $project — context: '$CONTEXT'"

  # pipeline-state.json idempotency — skip if already succeeded
  if grep -q "\"repo\":\"$project\".*\"step\":\"branch-protection\".*\"status\":\"ok\"" "$STATE_FILE" 2>/dev/null; then
    echo "  [SKIP] pipeline-state.json: branch-protection already ok"
    SUCCESS=$((SUCCESS + 1))
    continue
  fi

  PROTECTION_JSON=$(printf '{
  "required_status_checks": {
    "strict": true,
    "contexts": ["%s"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}' "$CONTEXT")

  if printf '%s' "$PROTECTION_JSON" | \
      gh api "repos/JPGBMR/$project/branches/main/protection" \
        -X PUT \
        -H "Accept: application/vnd.github+json" \
        --input - > /dev/null 2>&1; then
    echo "  → Protected ✓"
    state_append "$project" "branch-protection" "ok" "$CONTEXT"
    SUCCESS=$((SUCCESS + 1))
  else
    echo "  → FAILED"
    state_append "$project" "branch-protection" "fail" "$CONTEXT"
    FAILED=$((FAILED + 1))
    FAILED_REPOS+=("$project")
  fi

  # 1s delay — branch protection API has tighter rate limits
  sleep 1
done

echo ""
echo "════════════════════════════════════"
echo "  branch-protection complete"
echo "  Protected : $SUCCESS"
echo "  Failed    : $FAILED"
if [ "$FAILED" -gt 0 ]; then
  echo "  Failed repos:"
  for r in "${FAILED_REPOS[@]}"; do echo "    - $r"; done
fi
echo "════════════════════════════════════"
