#!/bin/bash
# Injects README.md and .gitignore into a checked-out Catalitium project if either is missing.
# Called by the Actions workflow after the source checkout step.
#
# Args: $1=PROJECT  $2=STACK  $3=DESC  $4=DIR

set -e

PROJECT="$1"
STACK="$2"
DESC="$3"
DIR="$4"

# Convert kebab-case project name to Title Case for the README heading.
# python3 .title() is used over sed \u — more portable and handles edge cases cleanly.
NAME_TITLE=$(echo "$PROJECT" | sed 's/-/ /g' | python3 -c "import sys; print(sys.stdin.read().strip().title())")

# ─── README.md ───────────────────────────────────────────────────────────────

if [ ! -f "$DIR/README.md" ]; then
  echo "Generating README.md for $PROJECT..."

  # Write the opening block — uses unquoted heredoc so $NAME_TITLE and $DESC expand
  cat > "$DIR/README.md" <<EOF
# $NAME_TITLE

$DESC

## Tech Stack
EOF

  # Append stack-specific badge and getting-started section.
  # Quoted heredoc (<<'SECTION') prevents backtick and dollar-sign interpretation.
  case "$STACK" in
    python)
      printf '![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)\n' \
        >> "$DIR/README.md"
      cat >> "$DIR/README.md" <<'SECTION'

## Getting Started

```bash
python main.py
```
SECTION
      ;;

    html)
      printf '![HTML](https://img.shields.io/badge/HTML5-E34F26?style=flat&logo=html5&logoColor=white) ![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat&logo=javascript&logoColor=black)\n' \
        >> "$DIR/README.md"
      cat >> "$DIR/README.md" <<'SECTION'

## Getting Started

Open `index.html` in your browser. No build step required.
SECTION
      ;;

    powershell)
      printf '![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat&logo=powershell&logoColor=white)\n' \
        >> "$DIR/README.md"
      cat >> "$DIR/README.md" <<'SECTION'

## Getting Started

```powershell
.\run.ps1
```
SECTION
      ;;
  esac

  # Append the shared portfolio footer
  cat >> "$DIR/README.md" <<'FOOTER'

---
*Part of the [JPGBMR](https://github.com/JPGBMR) open-source portfolio.*
FOOTER

  echo "README.md generated for $PROJECT"
else
  echo "README.md already exists for $PROJECT — skipping"
fi

# ─── .gitignore ──────────────────────────────────────────────────────────────

if [ ! -f "$DIR/.gitignore" ]; then
  echo "Generating .gitignore for $PROJECT ($STACK)..."

  case "$STACK" in
    python)
      # Fetch the official GitHub Python gitignore template
      curl -fsSL https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore \
        -o "$DIR/.gitignore"
      ;;

    html)
      # Node.gitignore covers npm build artifacts common to HTML/JS projects
      curl -fsSL https://raw.githubusercontent.com/github/gitignore/main/Node.gitignore \
        -o "$DIR/.gitignore"
      # Append OS and editor artifacts not covered by the Node template
      cat >> "$DIR/.gitignore" <<'GITIGNORE'

# OS and editor artifacts
.DS_Store
Thumbs.db
*.log
GITIGNORE
      ;;

    powershell)
      # VisualStudio.gitignore is the standard for PowerShell / Windows projects
      curl -fsSL https://raw.githubusercontent.com/github/gitignore/main/VisualStudio.gitignore \
        -o "$DIR/.gitignore"
      ;;
  esac

  echo ".gitignore generated for $PROJECT"
else
  echo ".gitignore already exists for $PROJECT — skipping"
fi
