#!/bin/bash
# preflight.sh
# Read-only gate — validates all 34 repos are ready for CI injection.
#
# EXIT 1 (hard blockers — nothing downstream should run):
#   - Repo missing on JPGBMR
#   - Default branch is not 'main'
#   - Required CI template files missing from repo-bootstrap/templates/
#
# WARN + exit 0 (logged, not blocking):
#   - Open PRs on any repo (inject-workflows.sh handles them via C-003 Rule 1)
#
# Usage: bash scripts/preflight.sh  (run from repo-bootstrap root)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
REPORT="/tmp/preflight-report.txt"
: > "$REPORT"

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

COUNT=0
TOTAL=${#PROJECTS[@]}
PASS=0
FAIL=0
WARN=0
FAILURES=()
WARNINGS=()

# --- Check required template files (EXIT 1 if missing) ---
REQUIRED_TEMPLATES=(ci-html.yml ci-python.yml ci-powershell.yml cd-pages.yml)
TEMPLATE_FAIL=false
for tmpl in "${REQUIRED_TEMPLATES[@]}"; do
  if [ ! -f "$TEMPLATES_DIR/$tmpl" ]; then
    echo "[TEMPLATE MISSING] $TEMPLATES_DIR/$tmpl"
    FAILURES+=("TEMPLATE: $tmpl not found in templates/")
    TEMPLATE_FAIL=true
  fi
done
if [ "$TEMPLATE_FAIL" = "true" ]; then
  echo "ERROR: Required templates missing — fix before running inject-workflows.sh"
  exit 1
fi

# --- Per-repo checks ---
for p in "${PROJECTS[@]}"; do
  COUNT=$((COUNT + 1))
  STATUS="PASS"
  ISSUES=()
  WARN_ISSUES=()

  # (1) Repo exists — hard blocker
  REPO_NAME=$(gh repo view "JPGBMR/$p" --json name --jq '.name' 2>/dev/null || echo "")
  if [ -z "$REPO_NAME" ]; then
    ISSUES+=("MISSING: repo not found on JPGBMR")
    STATUS="FAIL"
  else
    # (2) Default branch is main — hard blocker
    DEFAULT_BRANCH=$(gh api "repos/JPGBMR/$p" --jq '.default_branch' 2>/dev/null || echo "unknown")
    if [ "$DEFAULT_BRANCH" != "main" ]; then
      ISSUES+=("BRANCH_WRONG: default_branch='$DEFAULT_BRANCH' (expected 'main')")
      STATUS="FAIL"
    fi

    # (3) Open PRs — WARN only (inject-workflows handles them via C-003 Rule 1)
    OPEN_PRS=$(gh pr list --repo "JPGBMR/$p" --json number --jq 'length' 2>/dev/null || echo 0)
    if [ "$OPEN_PRS" -gt 0 ]; then
      PR_HEADS=$(gh pr list --repo "JPGBMR/$p" --json number,headRefName \
        --jq '[.[] | "#\(.number) \(.headRefName)"] | join(", ")' 2>/dev/null || echo "?")
      WARN_ISSUES+=("OPEN_PR: $OPEN_PRS open PR(s) — $PR_HEADS")
    fi
  fi

  # Print status line
  if [ "$STATUS" = "FAIL" ]; then
    printf "[$COUNT/$TOTAL] %-28s FAIL — %s\n" "$p" "${ISSUES[*]}"
    FAIL=$((FAIL + 1))
    FAILURES+=("$p: ${ISSUES[*]}")
    echo "[FAIL] $p — ${ISSUES[*]}" >> "$REPORT"
  elif [ "${#WARN_ISSUES[@]}" -gt 0 ]; then
    printf "[$COUNT/$TOTAL] %-28s WARN — %s\n" "$p" "${WARN_ISSUES[*]}"
    WARN=$((WARN + 1))
    WARNINGS+=("$p: ${WARN_ISSUES[*]}")
    echo "[WARN] $p — ${WARN_ISSUES[*]}" >> "$REPORT"
    PASS=$((PASS + 1))  # WARN is not a failure
  else
    printf "[$COUNT/$TOTAL] %-28s PASS\n" "$p"
    PASS=$((PASS + 1))
    echo "[PASS] $p — ok" >> "$REPORT"
  fi
done

echo ""
echo "════════════════════════════════════"
echo "  preflight complete"
echo "  PASS : $PASS / $TOTAL  (includes WARNs)"
echo "  FAIL : $FAIL / $TOTAL"
echo "  WARN : $WARN / $TOTAL  (open PRs — non-blocking)"
if [ "$WARN" -gt 0 ]; then
  echo ""
  echo "  Warnings (open PRs — inject-workflows.sh handles them):"
  for w in "${WARNINGS[@]}"; do echo "    ~ $w"; done
fi
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "  Failures (must fix before proceeding):"
  for f in "${FAILURES[@]}"; do echo "    ✗ $f"; done
fi
echo "════════════════════════════════════"
echo "  Full report: $REPORT"
echo "════════════════════════════════════"

[ "$FAIL" -eq 0 ]
