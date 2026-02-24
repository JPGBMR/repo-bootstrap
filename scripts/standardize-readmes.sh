#!/bin/bash
# standardize-readmes.sh
# Audits and upgrades README.md on all 34 JPGBMR repos.
# Appends missing sections only — never overwrites existing content.
# Tracks progress in pipeline-state.json — safe to re-run.
#
# Required sections (per stack):
#   all:      stack badge, Getting Started, portfolio footer
#   html:     live demo badge (prepended after H1)
#   seo-intel: Flask-specific Getting Started (detected via app.py presence)
#
# Usage: bash scripts/standardize-readmes.sh  (run from repo-bootstrap root)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/../pipeline-state.json"
TMPDIR_BASE=$(mktemp -d)
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
UPDATED=0
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
  CHANGED=0

  echo ""
  echo "[$COUNT/$TOTAL] $project ($STACK)"

  # pipeline-state.json idempotency
  if grep -q "\"repo\":\"$project\".*\"step\":\"standardize-readme\".*\"status\":\"ok\"" "$STATE_FILE" 2>/dev/null; then
    echo "  [SKIP] pipeline-state.json: standardize-readme already ok"
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  git clone --quiet --depth 1 --branch main \
    "https://x-access-token:${TOKEN}@github.com/JPGBMR/${project}.git" \
    "$WDIR"

  cd "$WDIR"
  git config user.name "JPGBMR Bot"
  git config user.email "bot@jpgbmr.dev"

  README="./README.md"

  # Create minimal README if missing
  if [ ! -f "$README" ]; then
    printf "# %s\n\n" "$project" > "$README"
    CHANGED=1
  fi

  README_CONTENT=$(cat "$README")

  # --- Live demo badge (HTML only) ---
  if [ "$STACK" = "html" ]; then
    if ! echo "$README_CONTENT" | grep -q "jpgbmr.github.io"; then
      DEMO_BADGE="[![Live Demo](https://img.shields.io/badge/Live%20Demo-jpgbmr.github.io-58a6ff?style=flat-square)](https://jpgbmr.github.io/${project}/)"
      # Insert after first H1 line
      awk -v badge="$DEMO_BADGE" '
        /^# / && !done { print; print ""; print badge; done=1; next }
        { print }
      ' "$README" > "$README.tmp" && mv "$README.tmp" "$README"
      echo "  → added live demo badge"
      CHANGED=1
    fi
  fi

  # --- Stack badge ---
  if ! grep -q "shields.io" "$README"; then
    case "$STACK" in
      html)
        STACK_BADGE='[![HTML](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white)](https://github.com/JPGBMR/'"$project"')'
        ;;
      python)
        STACK_BADGE='[![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)](https://github.com/JPGBMR/'"$project"')'
        ;;
      powershell)
        STACK_BADGE='[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white)](https://github.com/JPGBMR/'"$project"')'
        ;;
    esac
    # Append after first blank line following H1
    awk -v badge="$STACK_BADGE" '
      /^# / && !h1done { h1done=1 }
      h1done && /^$/ && !done { print; print badge; done=1; next }
      { print }
    ' "$README" > "$README.tmp" && mv "$README.tmp" "$README"
    echo "  → added stack badge"
    CHANGED=1
  fi

  # --- Getting Started ---
  if ! grep -q "## Getting Started" "$README"; then
    # seo-intel is Flask — detected by app.py presence, not stack label
    if [ -f "./app.py" ]; then
      GETTING_STARTED="## Getting Started

\`\`\`bash
pip install -r requirements.txt
python app.py
\`\`\`

Open [http://localhost:5000](http://localhost:5000) in your browser."
    else
      case "$STACK" in
        html)
          GETTING_STARTED="## Getting Started

Open \`index.html\` in your browser. No install required."
          ;;
        python)
          GETTING_STARTED="## Getting Started

\`\`\`bash
pip install -r requirements.txt
python main.py
\`\`\`"
          ;;
        powershell)
          GETTING_STARTED="## Getting Started

Run the main script in PowerShell:

\`\`\`powershell
.\\run.ps1
\`\`\`"
          ;;
      esac
    fi
    printf "\n%s\n" "$GETTING_STARTED" >> "$README"
    echo "  → added Getting Started"
    CHANGED=1
  fi

  # --- Portfolio footer ---
  # Check last 3 lines for JPGBMR mention
  if ! tail -3 "$README" | grep -q "JPGBMR"; then
    printf "\n---\n*Part of the [JPGBMR](https://github.com/JPGBMR) open-source portfolio.*\n" >> "$README"
    echo "  → added portfolio footer"
    CHANGED=1
  fi

  # Commit only if changes were made
  if [ "$CHANGED" -eq 1 ]; then
    git add README.md
    # Only commit if there are staged changes
    if ! git diff --cached --quiet; then
      git commit -q -m "docs: standardize README to company template"
      git push -q origin HEAD:main
      echo "  → pushed to main"
    fi
    state_append "$project" "standardize-readme" "ok" "sections added"
    UPDATED=$((UPDATED + 1))
  else
    echo "  [SKIP] README already complete"
    state_append "$project" "standardize-readme" "ok" "already complete"
    SKIPPED=$((SKIPPED + 1))
  fi

  cd "$TMPDIR_BASE"
  rm -rf "$WDIR"
  sleep 1
done

echo ""
echo "════════════════════════════════════"
echo "  standardize-readmes complete"
echo "  Updated  : $UPDATED"
echo "  Skipped  : $SKIPPED"
echo "  Total    : $TOTAL"
echo "════════════════════════════════════"
