#!/bin/bash
# setup-roadmap.sh
# Creates the JPGBMR Portfolio Roadmap board on GitHub Projects v2 via GraphQL.
# 34 Live cards + 38 Backlog cards = 72 total. Board is set to public.
#
# PRE-FLIGHT REQUIRED: token must have 'project' scope.
# Check with: gh auth status
# If missing: gh auth login --with-token (use PAT with project scope)
#
# Usage: bash scripts/setup-roadmap.sh  (run from repo-bootstrap root)

set -euo pipefail

# Verify 'project' scope before spending GraphQL quota
SCOPES=$(gh auth status 2>&1 | grep "Token scopes" | head -1)
if ! echo "$SCOPES" | grep -q "project"; then
  echo "ERROR: 'project' scope not found on current token."
  echo "Current scopes: $SCOPES"
  echo ""
  echo "Regenerate your PAT at https://github.com/settings/tokens"
  echo "Required scopes: repo, workflow, delete_repo, project"
  echo "Then re-authenticate: gh auth login --with-token"
  exit 1
fi

echo "Token scope check: OK (project scope present)"

# GraphQL helper
gql() {
  gh api graphql -f query="$1"
}

# --- Phase 1: Get JPGBMR user node ID ---
echo ""
echo "Phase 1: Fetching JPGBMR user ID..."
USER_ID=$(gql '{ user(login: "JPGBMR") { id } }' --jq '.data.user.id')
echo "  USER_ID: $USER_ID"

# --- Phase 2: Create project ---
echo ""
echo "Phase 2: Creating Portfolio Roadmap project..."
PROJECT_ID=$(gql "mutation {
  createProjectV2(input: {
    ownerId: \"$USER_ID\"
    title: \"Portfolio Roadmap\"
  }) {
    projectV2 { id }
  }
}" --jq '.data.createProjectV2.projectV2.id')
echo "  PROJECT_ID: $PROJECT_ID"

# --- Phase 3: Set Status field options ---
# Get the Status field ID (created automatically with new projects)
echo ""
echo "Phase 3: Configuring Status field..."
STATUS_FIELD_ID=$(gql "{
  node(id: \"$PROJECT_ID\") {
    ... on ProjectV2 {
      fields(first: 10) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
          }
        }
      }
    }
  }
}" --jq '.data.node.fields.nodes[] | select(.name == "Status") | .id')
echo "  STATUS_FIELD_ID: $STATUS_FIELD_ID"

# Get option IDs for Backlog and Live — they may exist as Todo/Done in defaults
# We'll create cards first, then set status after getting option IDs
OPTION_IDS=$(gql "{
  node(id: \"$PROJECT_ID\") {
    ... on ProjectV2 {
      fields(first: 10) {
        nodes {
          ... on ProjectV2SingleSelectField {
            id
            name
            options { id name }
          }
        }
      }
    }
  }
}" --jq '.data.node.fields.nodes[] | select(.name == "Status") | .options')
echo "  Status options: $OPTION_IDS"

# Extract first option (Todo/Backlog equivalent) and last (Done/Live equivalent)
BACKLOG_OPT=$(echo "$OPTION_IDS" | jq -r '.[0].id')
LIVE_OPT=$(echo "$OPTION_IDS" | jq -r '.[-1].id')
echo "  Backlog option: $BACKLOG_OPT"
echo "  Live option: $LIVE_OPT"

# --- Phase 4: Add 34 Live items ---
echo ""
echo "Phase 4: Adding 34 Live project cards..."

add_card() {
  local title="$1"
  local body="$2"
  local status_opt="$3"

  ITEM_ID=$(gql "mutation {
    addProjectV2DraftIssue(input: {
      projectId: \"$PROJECT_ID\"
      title: \"$title\"
      body: \"$body\"
    }) {
      projectItem { id }
    }
  }" --jq '.data.addProjectV2DraftIssue.projectItem.id')

  # Set status field
  gql "mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: \"$PROJECT_ID\"
      itemId: \"$ITEM_ID\"
      fieldId: \"$STATUS_FIELD_ID\"
      value: { singleSelectOptionId: \"$status_opt\" }
    }) { projectV2Item { id } }
  }" > /dev/null

  sleep 0.5
}

# Live projects (34)
add_card "ascii-art"            "ASCII art generator (Python)"                            "$LIVE_OPT"
add_card "auto-prompter"        "Auto prompt chaining tool (Python)"                      "$LIVE_OPT"
add_card "cache-cleaner"        "Cache cleaning utility — Python + PowerShell"            "$LIVE_OPT"
add_card "conway-game"          "Conway's Game of Life (Python)"                          "$LIVE_OPT"
add_card "maze-master"          "Maze generation and solving (Python)"                    "$LIVE_OPT"
add_card "qr-generator"         "QR code generator (Python)"                              "$LIVE_OPT"
add_card "secure-vault"         "Encrypted secure vault (Python)"                         "$LIVE_OPT"
add_card "seo-intel"            "SEO intelligence tool — Flask app (Python)"              "$LIVE_OPT"
add_card "text-summarizer"      "Text summarization utility (Python)"                     "$LIVE_OPT"
add_card "typing-test"          "Typing speed test (Python)"                              "$LIVE_OPT"
add_card "cpu-benchmark"        "CPU benchmarking tool (PowerShell)"                      "$LIVE_OPT"
add_card "system-health"        "System health monitor and benchmark (PowerShell)"        "$LIVE_OPT"
add_card "aspect-ratio"         "Image/video dimension calculator (HTML)"                 "$LIVE_OPT"
add_card "base64"               "Base64 encoder/decoder (HTML)"                           "$LIVE_OPT"
add_card "binary-converter"     "Binary, decimal, hex, octal converter (HTML)"            "$LIVE_OPT"
add_card "bmi-calculator"       "BMI calculator with health range visualization (HTML)"   "$LIVE_OPT"
add_card "contract-generator"   "Contract document generator (HTML)"                      "$LIVE_OPT"
add_card "countdown-timer"      "Live countdown to any target date/time (HTML)"           "$LIVE_OPT"
add_card "cron-builder"         "Visual cron expression builder (HTML)"                   "$LIVE_OPT"
add_card "css-minifier"         "CSS minifier and beautifier (HTML)"                      "$LIVE_OPT"
add_card "euro-castles"         "European castles interactive guide (HTML)"               "$LIVE_OPT"
add_card "hash-generator"       "MD5/SHA1/SHA256 hash generator (HTML)"                   "$LIVE_OPT"
add_card "hex-palette"          "Hex color mood palette — PWA (HTML)"                     "$LIVE_OPT"
add_card "invoice-generator"    "Invoice creation and export (HTML)"                      "$LIVE_OPT"
add_card "json-formatter"       "JSON formatter, minifier, validator (HTML)"              "$LIVE_OPT"
add_card "lorem-generator"      "Placeholder text generator (HTML)"                       "$LIVE_OPT"
add_card "morse-translator"     "Morse code translator with audio (HTML)"                 "$LIVE_OPT"
add_card "pixel-art-editor"     "Pixel art drawing tool (HTML)"                           "$LIVE_OPT"
add_card "reading-estimator"    "Reading time, word count, readability stats (HTML)"      "$LIVE_OPT"
add_card "regex-tester"         "Live regex tester with match highlighting (HTML)"        "$LIVE_OPT"
add_card "social-card"          "Social media card designer (HTML)"                       "$LIVE_OPT"
add_card "timezone-converter"   "World timezone converter with visual clock (HTML)"       "$LIVE_OPT"
add_card "tip-calculator"       "Bill splitter and tip calculator (HTML)"                 "$LIVE_OPT"
add_card "word-counter"         "Real-time word/character/sentence counter (HTML)"        "$LIVE_OPT"

echo "  → 34 Live cards added"

# --- Phase 5: Add 38 Backlog (wip-) items ---
echo ""
echo "Phase 5: Adding 38 Backlog wip- cards..."

# Simple utilities
add_card "wip-color-scheme"       "Color palette generator (HTML)"                        "$BACKLOG_OPT"
add_card "wip-dice-roller"        "Virtual dice roller for tabletop gaming (HTML)"         "$BACKLOG_OPT"
add_card "wip-gradient-generator" "Visual CSS gradient creator (HTML)"                    "$BACKLOG_OPT"
add_card "wip-markdown-preview"   "Live markdown editor with preview (HTML)"              "$BACKLOG_OPT"
add_card "wip-password-generator" "Secure password generator (HTML)"                      "$BACKLOG_OPT"
add_card "wip-pomodoro-timer"     "Productivity timer — 25/5 min cycles (HTML)"           "$BACKLOG_OPT"
add_card "wip-unit-converter"     "Multi-category unit conversion (HTML)"                 "$BACKLOG_OPT"

# Developer & AI tools
add_card "wip-case-converter"     "camelCase ↔ snake_case ↔ kebab-case ↔ PascalCase (HTML)"      "$BACKLOG_OPT"
add_card "wip-context-packer"     "Compress long text for LLM context windows (HTML)"     "$BACKLOG_OPT"
add_card "wip-data-converter"     "CSV ↔ JSON ↔ YAML bidirectional converter (HTML)"      "$BACKLOG_OPT"
add_card "wip-token-counter"      "Token count + API cost estimator (HTML)"               "$BACKLOG_OPT"
add_card "wip-url-parser"         "URL decomposer — scheme, host, path, params (HTML)"    "$BACKLOG_OPT"

# Games
add_card "wip-simon-says"         "Audio + color memory sequences (HTML)"                 "$BACKLOG_OPT"
add_card "wip-snake-game"         "Classic Snake on HTML canvas (HTML)"                   "$BACKLOG_OPT"

# Three.js / WebGL animations
add_card "wip-audio-visualizer"   "Mic-driven 3D frequency bars (Three.js)"              "$BACKLOG_OPT"
add_card "wip-dna-helix"          "Rotating double helix with base pair labels (Three.js)" "$BACKLOG_OPT"
add_card "wip-fluid-sim"          "2D Navier-Stokes fluid simulation (Three.js)"          "$BACKLOG_OPT"
add_card "wip-fractal-tree"       "Generative 3D trees from L-System grammar (Three.js)"  "$BACKLOG_OPT"
add_card "wip-gravity-sim"        "N-body gravitational simulation (Three.js)"            "$BACKLOG_OPT"
add_card "wip-lorenz-attractor"   "Real-time 3D strange attractor (Three.js)"            "$BACKLOG_OPT"
add_card "wip-matrix-rain"        "Matrix digital rain in 3D (Three.js)"                 "$BACKLOG_OPT"
add_card "wip-particle-galaxy"    "50k+ particle spiral galaxy (Three.js)"               "$BACKLOG_OPT"
add_card "wip-solar-system"       "8 planets with real orbital period ratios (Three.js)" "$BACKLOG_OPT"
add_card "wip-terrain-generator"  "Perlin noise heightmap with flythrough camera (Three.js)" "$BACKLOG_OPT"

# Serious math tools
add_card "wip-complex-plane"      "Argand plane, roots of unity, Julia sets (HTML)"      "$BACKLOG_OPT"
add_card "wip-fourier-visualizer" "Draw a wave → FFT decomposition + epicycles (HTML)"   "$BACKLOG_OPT"
add_card "wip-graphing-calculator" "Multi-function plotter with zoom/pan, root finder (HTML)" "$BACKLOG_OPT"
add_card "wip-laplace-visualizer" "Pole-zero plot, step response, Bode plot (HTML)"      "$BACKLOG_OPT"
add_card "wip-linear-solver"      "Gaussian elimination with geometric visualization (HTML)" "$BACKLOG_OPT"
add_card "wip-matrix-calculator"  "NxN matrix operations with step-by-step solutions (HTML)" "$BACKLOG_OPT"

# Million-dollar SaaS
add_card "wip-api-builder"        "Visual API creation platform (SaaS)"                  "$BACKLOG_OPT"
add_card "wip-compliance-auto"    "GDPR/CCPA automation (SaaS)"                          "$BACKLOG_OPT"
add_card "wip-email-warmup"       "Email deliverability and sender reputation (SaaS)"    "$BACKLOG_OPT"
add_card "wip-niche-job-board"    "Vertical-specific job marketplace (SaaS)"             "$BACKLOG_OPT"
add_card "wip-screenshot-docs"    "AI-powered docs from screenshots (SaaS)"              "$BACKLOG_OPT"
add_card "wip-waitlist-platform"  "Complete product launch toolkit (SaaS)"               "$BACKLOG_OPT"

echo "  → 38 Backlog cards added"

# --- Phase 6: Set project public ---
echo ""
echo "Phase 6: Setting project to public..."
gql "mutation {
  updateProjectV2(input: {
    projectId: \"$PROJECT_ID\"
    public: true
  }) {
    projectV2 { id public }
  }
}" > /dev/null
echo "  → Board is now public"

echo ""
echo "════════════════════════════════════"
echo "  setup-roadmap complete"
echo "  Board: https://github.com/users/JPGBMR/projects/"
echo "  72 cards total (34 Live + 38 Backlog)"
echo "════════════════════════════════════"
