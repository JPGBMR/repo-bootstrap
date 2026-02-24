#!/bin/bash
# update-profile-readme.sh — C-010-02
# Rewrites JPGBMR/JPGBMR README.md via GitHub API (no clone required).
# Usage: bash scripts/update-profile-readme.sh  (run from repo-bootstrap root)

set -euo pipefail

TOKEN=$(gh auth token --hostname github.com)
REPO="JPGBMR/JPGBMR"
BRANCH="main"
FILE_PATH="README.md"
API="https://api.github.com/repos/${REPO}/contents/${FILE_PATH}"

# Fetch current SHA — always live, never cached (prevents SHA mismatch on PUT)
echo "→ Fetching current SHA..."
SHA=$(curl -sf -H "Authorization: token $TOKEN" "$API" | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")
echo "  SHA: $SHA"

# Build README content
README=$(cat <<'HEREDOC'
# JPGBMR

Open-source tools — 41 live projects across Python, JavaScript, and PowerShell.

[![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)](#python-tools)
[![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat-square&logo=javascript&logoColor=black)](#web-tools)
[![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white)](#web-tools)
[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white)](#system-tools)
[![MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

---

## Web Tools (29)

| Project | Description | Live |
|---------|-------------|------|
| [aspect-ratio](https://github.com/JPGBMR/aspect-ratio) | Calculate image and video dimensions across any aspect ratio | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/aspect-ratio/) |
| [base64](https://github.com/JPGBMR/base64) | Browser-based Base64 encoder and decoder | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/base64/) |
| [binary-converter](https://github.com/JPGBMR/binary-converter) | Convert between binary, decimal, hexadecimal, and octal | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/binary-converter/) |
| [bmi-calculator](https://github.com/JPGBMR/bmi-calculator) | BMI calculator with visual health range indicator | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/bmi-calculator/) |
| [color-from-image](https://github.com/JPGBMR/color-from-image) | Extract dominant colours from any image — CSS/JSON/PNG export | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/color-from-image/) |
| [contract-generator](https://github.com/JPGBMR/contract-generator) | Browser-based contract document generator | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/contract-generator/) |
| [countdown-timer](https://github.com/JPGBMR/countdown-timer) | Live countdown timer to any target date and time | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/countdown-timer/) |
| [cron-builder](https://github.com/JPGBMR/cron-builder) | Visual cron expression builder and explainer | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/cron-builder/) |
| [css-minifier](https://github.com/JPGBMR/css-minifier) | One-click CSS minifier and beautifier | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/css-minifier/) |
| [euro-castles](https://github.com/JPGBMR/euro-castles) | Interactive guide to European castles | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/euro-castles/) |
| [fake-data-gen](https://github.com/JPGBMR/fake-data-gen) | Fake data generator with 15 types, JSON/CSV/list export | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/fake-data-gen/) |
| [hash-generator](https://github.com/JPGBMR/hash-generator) | Generate MD5, SHA1, and SHA256 hashes from any text | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/hash-generator/) |
| [hex-palette](https://github.com/JPGBMR/hex-palette) | Hexadecimal color mood palette installable as PWA | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/hex-palette/) |
| [image-compressor](https://github.com/JPGBMR/image-compressor) | Browser-side image compressor with split-view preview | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/image-compressor/) |
| [invoice-generator](https://github.com/JPGBMR/invoice-generator) | Browser-based invoice creation and export tool | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/invoice-generator/) |
| [json-formatter](https://github.com/JPGBMR/json-formatter) | Format, minify, and validate JSON with syntax highlighting | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/json-formatter/) |
| [lorem-generator](https://github.com/JPGBMR/lorem-generator) | Generate placeholder text by words, sentences, or paragraphs | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/lorem-generator/) |
| [morse-translator](https://github.com/JPGBMR/morse-translator) | Morse code translator with audio playback | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/morse-translator/) |
| [password-generator](https://github.com/JPGBMR/password-generator) | Secure password generator using crypto.getRandomValues | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/password-generator/) |
| [pixel-art-editor](https://github.com/JPGBMR/pixel-art-editor) | Browser-based pixel art drawing and export tool | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/pixel-art-editor/) |
| [reading-estimator](https://github.com/JPGBMR/reading-estimator) | Reading time, word count, and readability stats | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/reading-estimator/) |
| [regex-tester](https://github.com/JPGBMR/regex-tester) | Live regex tester with match highlighting | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/regex-tester/) |
| [sleep-calculator](https://github.com/JPGBMR/sleep-calculator) | Optimal bedtimes and wake times based on 90-min sleep cycles | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/sleep-calculator/) |
| [social-card](https://github.com/JPGBMR/social-card) | Social media card designer and exporter | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/social-card/) |
| [tip-calculator](https://github.com/JPGBMR/tip-calculator) | Bill splitter and tip calculator for groups | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/tip-calculator/) |
| [timezone-converter](https://github.com/JPGBMR/timezone-converter) | Convert times between world timezones with visual clock | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/timezone-converter/) |
| [unit-converter](https://github.com/JPGBMR/unit-converter) | Multi-category unit converter with 80+ units | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/unit-converter/) |
| [url-shortener](https://github.com/JPGBMR/url-shortener) | URL shortener with QR code and history | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/url-shortener/) |
| [word-counter](https://github.com/JPGBMR/word-counter) | Real-time word, character, and sentence counter | [![Live](https://img.shields.io/badge/Live-58a6ff?style=flat-square)](https://jpgbmr.github.io/word-counter/) |

---

## Python Tools (10)

| Project | Description |
|---------|-------------|
| [ascii-art](https://github.com/JPGBMR/ascii-art) | Terminal-based ASCII art generator |
| [auto-prompter](https://github.com/JPGBMR/auto-prompter) | Automated prompt generation and chaining tool |
| [cache-cleaner](https://github.com/JPGBMR/cache-cleaner) | Python and PowerShell utility to clean system cache |
| [conway-game](https://github.com/JPGBMR/conway-game) | Conway's Game of Life simulation |
| [maze-master](https://github.com/JPGBMR/maze-master) | Maze generation and solving algorithms |
| [qr-generator](https://github.com/JPGBMR/qr-generator) | QR code generator with customization options |
| [secure-vault](https://github.com/JPGBMR/secure-vault) | Encrypted secure vault application |
| [seo-intel](https://github.com/JPGBMR/seo-intel) | SEO analysis and intelligence tool (Flask) |
| [text-summarizer](https://github.com/JPGBMR/text-summarizer) | Automatic text summarization utility |
| [typing-test](https://github.com/JPGBMR/typing-test) | Typing speed and accuracy test |

---

## System Tools (2)

| Project | Description |
|---------|-------------|
| [cpu-benchmark](https://github.com/JPGBMR/cpu-benchmark) | PowerShell CPU benchmarking and performance testing |
| [system-health](https://github.com/JPGBMR/system-health) | System health monitor and benchmark tool |

---

*Built with the Elena → Colombo → Vitalik → Athena pipeline.*
HEREDOC
)

# Base64 encode (cross-platform: python3)
CONTENT_B64=$(echo "$README" | python3 -c "import sys, base64; print(base64.b64encode(sys.stdin.buffer.read()).decode())")

echo "→ Committing to $REPO/$FILE_PATH ..."

RESPONSE=$(curl -sf -X PUT "$API" \
  -H "Authorization: token $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$(python3 -c "
import json, sys
print(json.dumps({
  'message': 'docs: update profile README — 41 projects, fix Web Tools table',
  'content': sys.argv[1],
  'sha': sys.argv[2],
  'branch': 'main'
}))" "$CONTENT_B64" "$SHA"
)")

COMMIT=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['commit']['sha'][:7])" 2>/dev/null || echo "unknown")
echo "  [DONE] commit $COMMIT"
echo ""
echo "════════════════════════════════════"
echo "  update-profile-readme complete"
echo "  Commit: $COMMIT"
echo "════════════════════════════════════"
