#!/bin/bash
# One-time script: seeds 34 labeled GitHub Issues on JPGBMR/repo-bootstrap.
# Each issue body is a JSON object with project metadata that the Actions workflow parses.
#
# Usage: GH_TOKEN=your_token bash scripts/create-issues.sh

set -e

# Fail fast if GH_TOKEN is not set — no silent failures
GH_TOKEN=${GH_TOKEN:?'GH_TOKEN is required. Run: GH_TOKEN=your_token bash scripts/create-issues.sh'}
export GH_TOKEN

REPO="JPGBMR/repo-bootstrap"

# All descriptions verified to contain no single-quotes (heredoc-safe) and no double-quotes (JSON-safe)
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

# Stack per project — must match the stacks generate-files.sh and set-topics.sh expect
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

# Create the label if it does not already exist — idempotent, safe to re-run
echo "Ensuring publish-project label exists on $REPO..."
gh label create "publish-project" \
  --color "0075ca" \
  --description "Triggers the project publisher workflow" \
  --repo "$REPO" \
  2>/dev/null || true

TOTAL=${#DESCRIPTIONS[@]}
COUNT=0

echo "Creating $TOTAL issues on $REPO..."
echo ""

for project in "${!DESCRIPTIONS[@]}"; do
  DESC="${DESCRIPTIONS[$project]}"
  STACK="${STACKS[$project]}"

  # Build the JSON issue body — the Actions workflow will parse these three fields
  BODY=$(cat <<EOF
{
  "name": "$project",
  "stack": "$STACK",
  "description": "$DESC"
}
EOF
)

  COUNT=$((COUNT + 1))
  echo "[$COUNT/$TOTAL] $project ($STACK)"

  gh issue create \
    --repo "$REPO" \
    --title "[publish] $project" \
    --body "$BODY" \
    --label "publish-project"

  # 3s delay between API calls — safely under GitHub secondary rate limits for issue creation
  sleep 3
done

echo ""
echo "Done. $COUNT issues created."
echo "Monitor workflows : https://github.com/$REPO/actions"
echo "View issues       : https://github.com/$REPO/issues"
