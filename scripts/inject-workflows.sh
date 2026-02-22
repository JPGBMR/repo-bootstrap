#!/bin/bash
# inject-workflows.sh
# Clones each JPGBMR repo, injects CI (and CD for HTML) workflow files.
# Pushes to main AND any open feature branches (C-003 Rule 1).
# Enables GitHub Pages for all HTML repos via the API.
# Tracks progress in pipeline-state.json — safe to re-run.
#
# Usage: bash scripts/inject-workflows.sh  (run from repo-bootstrap root)

set -euo pipefail

# D-01 fix: --force overwrites ci.yml even if it already exists.
# Default (no flag): skip repos that already have ci.yml (idempotent re-run).
FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
STATE_FILE="$SCRIPT_DIR/../pipeline-state.json"
TMPDIR_BASE=$(mktemp -d)
TOKEN=$(gh auth token --hostname github.com)

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

touch "$STATE_FILE"

COUNT=0
TOTAL=${#PROJECTS[@]}
INJECTED=0
SKIPPED=0

state_append() {
  local repo="$1" step="$2" status="$3" notes="$4"
  printf '{"repo":"%s","step":"%s","status":"%s","ts":"%s","notes":"%s"}\n' \
    "$repo" "$step" "$status" "$(date -u +%FT%TZ)" "$notes" >> "$STATE_FILE"
}

cleanup() {
  rm -rf "$TMPDIR_BASE"
}
trap cleanup EXIT

for project in "${PROJECTS[@]}"; do
  COUNT=$((COUNT + 1))
  STACK="${STACKS[$project]}"
  WDIR="$TMPDIR_BASE/$project"

  echo ""
  echo "[$COUNT/$TOTAL] $project ($STACK)"

  # pipeline-state.json idempotency — skip if this step already succeeded
  if grep -q "\"repo\":\"$project\".*\"step\":\"inject-workflows\".*\"status\":\"ok\"" "$STATE_FILE" 2>/dev/null; then
    echo "  [SKIP] pipeline-state.json: inject-workflows already ok"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Shallow clone — explicitly target main to avoid landing on master (BLK-01)
  git clone --quiet --depth 1 --branch main \
    "https://x-access-token:${TOKEN}@github.com/JPGBMR/${project}.git" \
    "$WDIR"

  cd "$WDIR"
  git config user.name "JPGBMR Bot"
  git config user.email "bot@jpgbmr.dev"

  # ci.yml idempotency guard — skip if CI workflow already present on main.
  # --force bypasses this check to propagate updated templates.
  if [ -f ".github/workflows/ci.yml" ] && [ "$FORCE" = "false" ]; then
    echo "  [SKIP] .github/workflows/ci.yml already exists (use --force to overwrite)"
    state_append "$project" "inject-workflows" "skip" "ci.yml already on main"
    SKIPPED=$((SKIPPED + 1))
    cd "$TMPDIR_BASE"
    rm -rf "$WDIR"
    sleep 2
    continue
  fi

  # Inject stack-appropriate CI workflow
  mkdir -p .github/workflows
  case "$STACK" in
    python)     cp "$TEMPLATES_DIR/ci-python.yml"     .github/workflows/ci.yml ;;
    html)       cp "$TEMPLATES_DIR/ci-html.yml"       .github/workflows/ci.yml ;;
    powershell) cp "$TEMPLATES_DIR/ci-powershell.yml" .github/workflows/ci.yml ;;
  esac
  echo "  → ci.yml injected ($STACK)"

  # Inject Pages CD workflow for HTML repos only
  if [ "$STACK" = "html" ]; then
    cp "$TEMPLATES_DIR/cd-pages.yml" .github/workflows/cd-pages.yml
    echo "  → cd-pages.yml injected"
  fi

  # Commit
  git add .github/
  git commit -q -m "ci: inject CI/CD workflows"

  # Push to main (HEAD:main works regardless of local branch name — BLK-01)
  git push -q origin HEAD:main
  echo "  → pushed to main"

  # C-003 Rule 1 — push ci.yml to any open feature branches
  OPEN_BRANCHES=$(gh pr list --repo "JPGBMR/$project" --json headRefName \
    --jq '.[].headRefName' 2>/dev/null || echo "")
  for branch in $OPEN_BRANCHES; do
    git push -q origin "HEAD:$branch" 2>/dev/null \
      && echo "  → pushed to feature branch: $branch" \
      || echo "  → WARN: push to $branch failed (protected or diverged)"
  done

  # Enable GitHub Pages for HTML repos (source: root of main branch)
  if [ "$STACK" = "html" ]; then
    printf '{"source":{"branch":"main","path":"/"}}' | \
      gh api "repos/JPGBMR/$project/pages" -X POST --input - \
      2>/dev/null \
      && echo "  → Pages enabled" \
      || echo "  → Pages already enabled (skipped)"
  fi

  state_append "$project" "inject-workflows" "ok" ""
  INJECTED=$((INJECTED + 1))
  cd "$TMPDIR_BASE"
  rm -rf "$WDIR"

  # Rate limit safety — 2s between repos
  sleep 2
done

echo ""
echo "════════════════════════════════════"
echo "  inject-workflows complete"
echo "  Injected : $INJECTED"
echo "  Skipped  : $SKIPPED"
echo "  Total    : $TOTAL"
echo "════════════════════════════════════"
