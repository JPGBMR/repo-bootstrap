#!/bin/bash
# merge-prs.sh
# Squash-merges feat/initial-release PRs on all 34 JPGBMR repos if CI is passing.
# Skips repos with no open PR, pending CI, or failed CI.
# Logs all non-merged outcomes to /tmp/merge-failures.tsv for Athena.
#
# Usage: bash scripts/merge-prs.sh  (run from repo-bootstrap root)
# Run AFTER CI has had time to complete (allow ~10 min after inject-workflows.sh)

set -eo pipefail

FAILURES_FILE="/tmp/merge-failures.tsv"
echo -e "project\tpr_number\tci_status\treason" > "$FAILURES_FILE"

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
MERGED=0
SKIPPED=0
PENDING=0
FAILED_CI=0

for project in "${PROJECTS[@]}"; do
  COUNT=$((COUNT + 1))
  echo ""
  echo "[$COUNT/$TOTAL] $project"

  # Get PR number for feat/initial-release (empty string if no PR)
  PR_NUMBER=$(gh pr list \
    --repo "JPGBMR/$project" \
    --head feat/initial-release \
    --json number \
    --jq '.[0].number // empty' 2>/dev/null)

  if [ -z "$PR_NUMBER" ]; then
    echo "  [NO PR] — skipping"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  echo "  PR #$PR_NUMBER found"

  # Check CI status via statusCheckRollup
  # Handles both commit statuses (.state) and check runs (.conclusion)
  CI_STATE=$(gh pr view "$PR_NUMBER" \
    --repo "JPGBMR/$project" \
    --json statusCheckRollup \
    --jq '
      .statusCheckRollup |
      if length == 0 then "success"
      elif any(.[]; .state == "FAILURE" or .conclusion == "failure" or .state == "ERROR" or .conclusion == "error") then "failure"
      elif all(.[]; .state == "SUCCESS" or .conclusion == "success") then "success"
      else "pending"
      end
    ' 2>/dev/null || echo "pending")

  echo "  CI status: $CI_STATE"

  case "$CI_STATE" in
    success)
      # Squash merge — conventional commit subject, delete branch after merge
      gh pr merge "$PR_NUMBER" \
        --repo "JPGBMR/$project" \
        --squash \
        --subject "feat: initial release of $project" \
        --delete-branch
      echo "  → Merged ✓"
      MERGED=$((MERGED + 1))
      ;;
    failure)
      echo "  → SKIPPED (CI failed)"
      echo -e "$project\t$PR_NUMBER\tfailure\tCI checks failed — investigate before merging" >> "$FAILURES_FILE"
      FAILED_CI=$((FAILED_CI + 1))
      ;;
    pending)
      echo "  → SKIPPED (CI pending — re-run this script after CI completes)"
      echo -e "$project\t$PR_NUMBER\tpending\tCI checks still running" >> "$FAILURES_FILE"
      PENDING=$((PENDING + 1))
      ;;
  esac
done

echo ""
echo "════════════════════════════════════"
echo "  merge-prs complete"
echo "  Merged      : $MERGED"
echo "  No PR found : $SKIPPED"
echo "  CI pending  : $PENDING"
echo "  CI failed   : $FAILED_CI"
if [ $((PENDING + FAILED_CI)) -gt 0 ]; then
  echo ""
  echo "  Re-run required for $((PENDING + FAILED_CI)) repos:"
  echo "  Failures log: $FAILURES_FILE"
  echo ""
  column -t -s $'\t' "$FAILURES_FILE"
fi
echo "════════════════════════════════════"
