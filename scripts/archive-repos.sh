#!/bin/bash
# archive-repos.sh — C-010-01
# Archives 4 legacy orphan repos on JPGBMR. Idempotent.
# Usage: bash scripts/archive-repos.sh  (run from repo-bootstrap root)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/../pipeline-state.json"
touch "$STATE_FILE"

REPOS=(CodigoLimpio Python-Automation-Intro Python-Enviroment-Setup matrix-rain)

# Hard safety guard — never archive these regardless of any input
PROTECTED=(JPGBMR repo-bootstrap jpgbmr.github.io pomodoro-timer)

state_append() {
  printf '{"repo":"%s","step":"archive","status":"%s","ts":"%s","notes":"%s"}\n' \
    "$1" "$2" "$(date -u +%FT%TZ)" "$3" >> "$STATE_FILE"
}

is_protected() {
  local name="$1"
  for p in "${PROTECTED[@]}"; do
    [[ "$name" == "$p" ]] && return 0
  done
  return 1
}

ARCHIVED=0
SKIPPED=0

for repo in "${REPOS[@]}"; do
  echo ""
  echo "→ $repo"

  if is_protected "$repo"; then
    echo "  [ABORT] $repo is in PROTECTED list — refusing to archive"
    exit 1
  fi

  ALREADY=$(gh api "repos/JPGBMR/$repo" --jq '.archived' 2>/dev/null || echo "not_found")

  if [[ "$ALREADY" == "true" ]]; then
    echo "  [SKIP] already archived"
    state_append "$repo" "ok" "already archived"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  if [[ "$ALREADY" == "not_found" ]]; then
    echo "  [SKIP] repo not found on JPGBMR — skipping"
    state_append "$repo" "skip" "repo not found"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  gh repo archive "JPGBMR/$repo" --yes
  echo "  [DONE] archived"
  state_append "$repo" "ok" "archived now"
  ARCHIVED=$((ARCHIVED + 1))
done

echo ""
echo "════════════════════════════════════"
echo "  archive-repos complete"
echo "  Archived : $ARCHIVED"
echo "  Skipped  : $SKIPPED"
echo "════════════════════════════════════"
