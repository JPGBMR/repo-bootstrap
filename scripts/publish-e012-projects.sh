#!/bin/bash
set -euo pipefail

CODEBASE=/c/Users/catal/Desktop/code-base
TOKEN=$(gh auth token --hostname github.com)
RESULTS_FILE=/tmp/publish-e012-results.tsv
echo -e 'project\tstatus\tpr_url\tnotes' > "$RESULTS_FILE"

declare -A DESCRIPTIONS=(
  [dice-roller]='Virtual dice roller for tabletop gaming — d4 through d100, crypto-random, roll history'
  [url-parser]='URL decomposer — scheme, host, path, query params, fragment using the native URL API'
)

PROJECTS=(dice-roller url-parser)
COUNT=0
TOTAL=2

for project in "${PROJECTS[@]}"; do
  COUNT=$((COUNT + 1))
  DESC="${DESCRIPTIONS[$project]}"
  SRC="$CODEBASE/$project"
  WDIR=$(mktemp -d)
  STATUS=complete
  PR_URL=''

  echo ""
  echo "[$COUNT/$TOTAL] ══════ $project ══════"

  cp -r "$SRC/." "$WDIR/"
  find "$WDIR" -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
  find "$WDIR" -name '*.pyc' -delete 2>/dev/null || true
  rm -rf "$WDIR/.git"

  if [ ! -f "$WDIR/.gitignore" ]; then
    printf 'node_modules/\ndist/\n.DS_Store\nThumbs.db\n*.log\n' > "$WDIR/.gitignore"
  fi

  gh repo create "JPGBMR/$project" --public --description "$DESC" 2>/dev/null && echo '  -> repo created' || echo '  -> repo exists'

  gh repo edit "JPGBMR/$project" --add-topic html --add-topic javascript --add-topic web-app --add-topic open-source 2>/dev/null || true

  gh label create 'stack: html' --color 'E34F26' --repo "JPGBMR/$project" 2>/dev/null || true
  gh label create 'athena:review' --color '006B75' --repo "JPGBMR/$project" 2>/dev/null || true

  cd "$WDIR"
  git init -q
  git config user.name 'JPGBMR Bot'
  git config user.email 'bot@jpgbmr.dev'
  git remote add origin "https://x-access-token:${TOKEN}@github.com/JPGBMR/${project}.git"

  # main — README only
  git checkout -b main -q
  git add README.md
  git commit -q -m "chore: initial repo — $project"
  git push -qu origin main --force
  echo '  -> main pushed'

  # feat/initial-release — all files
  git checkout -b feat/initial-release -q
  git add .
  git commit -q -m "feat: initial release — $project"
  git push -qu origin feat/initial-release --force
  echo '  -> feat/initial-release pushed'

  # Open PR
  PR_URL=$(gh pr create \
    --repo "JPGBMR/$project" \
    --title "feat: initial release — $project" \
    --base main \
    --head feat/initial-release \
    --body "Initial release of $project. Stack: HTML/CSS/JS. No dependencies. Athena: verify no Math.random, no console.log, index.html renders, crypto RNG only." \
    2>&1) || PR_URL=$(gh pr view --repo "JPGBMR/$project" feat/initial-release --json url -q .url 2>/dev/null || echo 'PR exists')
  echo "  -> PR: $PR_URL"

  echo -e "$project\t$STATUS\t$PR_URL\t" >> "$RESULTS_FILE"

  cd "$CODEBASE"
  rm -rf "$WDIR"
  sleep 3
done

echo ''
echo '════════════════════════════════════'
echo "  DONE. $COUNT/$TOTAL projects published."
echo "  Results: $RESULTS_FILE"
echo '════════════════════════════════════'
cat "$RESULTS_FILE"
