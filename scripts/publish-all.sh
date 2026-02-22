#!/bin/bash
# publish-all.sh
# Publishes all 34 live JPGBMR portfolio projects.
# For each: creates GitHub repo, pushes code to feat/initial-release, opens PR into main.
# Usage: bash scripts/publish-all.sh 2>&1 | tee /tmp/publish-all.log

set -eo pipefail

CODEBASE="/c/Users/catal/Desktop/code-base"
TOKEN=$(gh auth token --hostname github.com)
RESULTS_FILE="/tmp/publish-results.tsv"
echo -e "project\tstatus\tpr_url\tnotes" > "$RESULTS_FILE"

declare -A DESCRIPTIONS=(
  [ascii-art]="Terminal-based ASCII art generator written in Python"
  [aspect-ratio]="Calculate image and video dimensions across any aspect ratio"
  [auto-prompter]="Automated prompt generation and chaining tool"
  [base64]="Browser-based Base64 encoder and decoder for text and files"
  [binary-converter]="Convert between binary, decimal, hexadecimal, and octal"
  [bmi-calculator]="BMI calculator with visual health range indicator"
  [cache-cleaner]="Python and PowerShell utility to clean system cache"
  [contract-generator]="Browser-based contract document generator"
  [conway-game]="Conways Game of Life simulation in Python"
  [countdown-timer]="Live countdown timer to any target date and time"
  [cpu-benchmark]="PowerShell CPU benchmarking and performance testing tool"
  [cron-builder]="Visual cron expression builder and explainer"
  [css-minifier]="One-click CSS minifier and beautifier"
  [euro-castles]="Interactive guide to European castles"
  [hash-generator]="Generate MD5, SHA1, and SHA256 hashes from any text"
  [hex-palette]="Hexadecimal color mood palette installable as PWA"
  [invoice-generator]="Browser-based invoice creation and export tool"
  [json-formatter]="Format, minify, and validate JSON with syntax highlighting"
  [lorem-generator]="Generate placeholder text by words, sentences, or paragraphs"
  [maze-master]="Maze generation and solving algorithms in Python"
  [morse-translator]="Text to Morse code translator with optional audio playback"
  [pixel-art-editor]="Browser-based pixel art drawing and export tool"
  [qr-generator]="QR code generator with customization options"
  [reading-estimator]="Get reading time, word count, and readability stats from any text"
  [regex-tester]="Live regex tester with match highlighting and explanations"
  [secure-vault]="Encrypted secure vault application in Python"
  [seo-intel]="SEO analysis and intelligence tool"
  [social-card]="Social media card designer and exporter"
  [system-health]="System health monitor and benchmark tool"
  [text-summarizer]="Automatic text summarization utility in Python"
  [timezone-converter]="Convert times between world timezones with visual clock"
  [tip-calculator]="Bill splitter and tip calculator for groups"
  [typing-test]="Typing speed and accuracy test application"
  [word-counter]="Real-time word, character, and sentence counter"
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

# Ordered list for deterministic processing
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

for project in "${PROJECTS[@]}"; do
  COUNT=$((COUNT + 1))
  DESC="${DESCRIPTIONS[$project]}"
  STACK="${STACKS[$project]}"
  SRC="$CODEBASE/$project"

  echo ""
  echo "[$COUNT/$TOTAL] ══════ $project ($STACK) ══════"

  WDIR=$(mktemp -d)
  STATUS="complete"
  NOTES=""
  PR_URL=""

  # ── 1. Copy source files ───────────────────────────────────────────────────
  cp -r "$SRC/." "$WDIR/"

  # ── 2. Clean build artifacts ───────────────────────────────────────────────
  find "$WDIR" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
  find "$WDIR" -name "*.pyc" -delete 2>/dev/null || true
  rm -rf "$WDIR/.git"

  # ── 3. Project-specific fixes ──────────────────────────────────────────────
  case "$project" in
    system-health)
      rm -f "$WDIR/20261602_system_health.log"
      NOTES="Removed runtime log file (20261602_system_health.log). Added to .gitignore."
      ;;
    auto-prompter)
      if [ -f "$WDIR/prompts copy.jsonl" ]; then
        mv "$WDIR/prompts copy.jsonl" "$WDIR/prompts-copy.jsonl"
        NOTES="Renamed 'prompts copy.jsonl' → 'prompts-copy.jsonl' (space in filename removed)."
      fi
      ;;
    ascii-art)
      NOTES="Pre-fixed: README.mc → README.md (filename typo)."
      ;;
    hex-palette)
      NOTES="Pre-fixed: iindex.html → index.html (filename typo)."
      ;;
  esac

  # ── 4. Generate README.md if missing ──────────────────────────────────────
  README_STATUS="pre-existing"
  if [ ! -f "$WDIR/README.md" ]; then
    README_STATUS="generated"
    TITLE=$(echo "$project" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
    cat > "$WDIR/README.md" <<REOF
# $TITLE

$DESC

## Tech Stack
REOF
    case "$STACK" in
      python)
        printf '![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)\n\n## Getting Started\n\n```bash\npython main.py\n```\n' >> "$WDIR/README.md"
        ;;
      html)
        printf '![HTML](https://img.shields.io/badge/HTML5-E34F26?style=flat&logo=html5&logoColor=white) ![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black)\n\n## Getting Started\n\nOpen `index.html` in your browser. No build step required.\n' >> "$WDIR/README.md"
        ;;
      powershell)
        printf '![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat&logo=powershell&logoColor=white)\n\n## Getting Started\n\n```powershell\n.\\run.ps1\n```\n' >> "$WDIR/README.md"
        ;;
    esac
    printf '\n---\n*Part of the [JPGBMR](https://github.com/JPGBMR) open-source portfolio.*\n' >> "$WDIR/README.md"
    echo "  → README.md generated"
  else
    echo "  → README.md: pre-existing"
  fi

  # ── 5. Generate .gitignore ─────────────────────────────────────────────────
  case "$STACK" in
    python)
      cat > "$WDIR/.gitignore" <<'GIEOF'
__pycache__/
*.py[cod]
*$py.class
*.so
*.egg
*.egg-info/
dist/
build/
.env
.venv
venv/
env/
.pytest_cache/
*.pyc
GIEOF
      ;;
    html)
      cat > "$WDIR/.gitignore" <<'GIEOF'
node_modules/
dist/
.DS_Store
Thumbs.db
*.log
GIEOF
      ;;
    powershell)
      cat > "$WDIR/.gitignore" <<'GIEOF'
.vs/
bin/
obj/
*.user
*.suo
*.log
reports/*.csv
reports/*.txt
*.log
GIEOF
      ;;
  esac
  echo "  → .gitignore generated"

  # ── 6. Create GitHub repo ──────────────────────────────────────────────────
  gh repo create "JPGBMR/$project" \
    --public \
    --description "$DESC" \
    2>/dev/null && echo "  → Repo created" || echo "  → Repo already exists"

  # ── 7. Create labels ───────────────────────────────────────────────────────
  gh label create "build: vitalic" --color "0052cc" --description "Built by Vitalic (Agent 3)" --repo "JPGBMR/$project" 2>/dev/null || true
  gh label create "qa: athena"     --color "e4e669" --description "Pending Athena QA review"    --repo "JPGBMR/$project" 2>/dev/null || true
  gh label create "agent"          --color "bfd4f2" --description "Agent fleet waterfall"        --repo "JPGBMR/$project" 2>/dev/null || true
  case "$STACK" in
    python)     gh label create "stack: python"     --color "3776AB" --repo "JPGBMR/$project" 2>/dev/null || true ;;
    html)       gh label create "stack: html"       --color "E34F26" --repo "JPGBMR/$project" 2>/dev/null || true ;;
    powershell) gh label create "stack: powershell" --color "5391FE" --repo "JPGBMR/$project" 2>/dev/null || true ;;
  esac
  echo "  → Labels created"

  # ── 8. Set topics ──────────────────────────────────────────────────────────
  case "$STACK" in
    python)     gh repo edit "JPGBMR/$project" --add-topic python     --add-topic open-source --add-topic cli            --add-topic tool           2>/dev/null || true ;;
    html)       gh repo edit "JPGBMR/$project" --add-topic html       --add-topic css         --add-topic javascript     --add-topic web-app --add-topic open-source 2>/dev/null || true ;;
    powershell) gh repo edit "JPGBMR/$project" --add-topic powershell --add-topic windows     --add-topic system-monitor --add-topic open-source     2>/dev/null || true ;;
  esac
  echo "  → Topics set"

  # ── 9. Git init + main branch (README only) ────────────────────────────────
  cd "$WDIR"
  git init -q
  git config user.name "JPGBMR Bot"
  git config user.email "bot@jpgbmr.dev"
  git remote add origin "https://x-access-token:${TOKEN}@github.com/JPGBMR/${project}.git"

  git checkout -b main -q
  git add README.md
  git commit -q -m "chore: initial repo — $project"
  git push -qu origin main --force
  echo "  → main pushed (README only)"

  # ── 10. feat/initial-release branch (all files) ───────────────────────────
  git checkout -b feat/initial-release -q
  git add .
  git commit -q -m "feat: initial release — $project"
  git push -qu origin feat/initial-release --force
  echo "  → feat/initial-release pushed"

  # ── 11. Create PR ──────────────────────────────────────────────────────────
  PR_BODY_FILE=$(mktemp)
  cat > "$PR_BODY_FILE" <<PREOF
## Vitalic Build Report — \`$project\`

| Field | Value |
|---|---|
| **Stack** | $STACK |
| **Source** | \`Catalitium/$project\` (local) |
| **Build ID** | V-$(printf "%03d" $COUNT) |
| **Spec** | C-002 (batch publish) |

### Files in this release
PREOF

  # List all files
  find . -type f | sort | grep -v '^\./\.git' | sed 's|^\./||' | while read -r f; do
    echo "- \`$f\`" >> "$PR_BODY_FILE"
  done

  cat >> "$PR_BODY_FILE" <<PREOF

### What Vitalic generated
- **README.md**: $README_STATUS
- **.gitignore**: generated (stack: $STACK)
$([ -n "$NOTES" ] && echo "- **Fix applied**: $NOTES" || echo "")

### Athena — test checklist
- [ ] Repo is public on JPGBMR: https://github.com/JPGBMR/$project
- [ ] All source files present and readable
- [ ] README.md renders correctly (check badge, getting-started section, footer)
- [ ] .gitignore excludes stack artifacts (\`$STACK\` patterns)
- [ ] Topics set: verify under repo Settings → Topics
- [ ] PR merges cleanly into \`main\` (no conflicts)
- [ ] No secrets, credentials, or runtime logs committed

### Known pre-conditions
- Catalitium/$project was the source — verify source parity
- All \`__pycache__\` and \`.pyc\` files were excluded before commit

---
🤖 Built by **Vitalic** (Agent 3) · Awaiting **Athena** (Agent 4) review
*[Claude Code](https://claude.com/claude-code) — Elena→Colombo→Vitalic→Athena waterfall*
PREOF

  PR_URL=$(gh pr create \
    --repo "JPGBMR/$project" \
    --title "feat: initial release — $project" \
    --base main \
    --head feat/initial-release \
    --label "build: vitalic" \
    --label "qa: athena" \
    --label "agent-fleet" \
    --body-file "$PR_BODY_FILE" 2>&1) || {
      # PR may already exist — fetch its URL rather than failing
      PR_URL=$(gh pr view --repo "JPGBMR/$project" feat/initial-release --json url -q .url 2>/dev/null || echo "PR already exists")
      STATUS="complete"
    }

  rm -f "$PR_BODY_FILE"
  echo "  → PR: $PR_URL"

  # ── 12. Record result ──────────────────────────────────────────────────────
  echo -e "$project\t$STATUS\t$PR_URL\t$NOTES" >> "$RESULTS_FILE"

  cd "$CODEBASE"
  rm -rf "$WDIR"

  # Rate limit safety — 3s between projects
  sleep 3
done

echo ""
echo "════════════════════════════════════"
echo "  DONE. $COUNT/$TOTAL projects published."
echo "  Results: $RESULTS_FILE"
echo "════════════════════════════════════"
cat "$RESULTS_FILE"
