#!/bin/bash
# Automated test suite for repo-bootstrap build artifacts.
# Run from the repo root: bash tests/test_build.sh

set -euo pipefail

PASS=0
FAIL=0
FAILURES=()

ok()   { echo "  PASS [$1] $2"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL [$1] $2 — $3"; FAIL=$((FAIL + 1)); FAILURES+=("[$1] $2: $3"); }

echo "=== repo-bootstrap test suite ==="
echo ""

# A-001: --confirm absent from non-comment workflow code
echo "[A-001] --confirm absent from non-comment workflow code..."
if grep -v '^[[:space:]]*#' .github/workflows/project-publisher.yml | grep -q '\-\-confirm'; then
  fail A-001 "--confirm flag" "found in executable workflow code"
else
  ok A-001 "--confirm absent from executable workflow code"
fi

# A-002: DESCRIPTIONS has exactly 34 entries
echo "[A-002] DESCRIPTIONS array entry count..."
COUNT=$(awk '/declare -A DESCRIPTIONS/,/^\)/' scripts/create-issues.sh | grep -oP '\[[a-z0-9-]+\]' | wc -l)
if [ "$COUNT" -eq 34 ]; then
  ok A-002 "DESCRIPTIONS has $COUNT entries"
else
  fail A-002 "DESCRIPTIONS count" "expected 34, got $COUNT"
fi

# A-003: STACKS has exactly 34 entries
echo "[A-003] STACKS array entry count..."
COUNT=$(awk '/declare -A STACKS/,/^\)/' scripts/create-issues.sh | grep -oP '\[[a-z0-9-]+\]' | wc -l)
if [ "$COUNT" -eq 34 ]; then
  ok A-003 "STACKS has $COUNT entries"
else
  fail A-003 "STACKS count" "expected 34, got $COUNT"
fi

# A-004: STACKS keys match DESCRIPTIONS keys exactly
echo "[A-004] STACKS keys match DESCRIPTIONS keys..."
awk '/declare -A STACKS/,/^\)/' scripts/create-issues.sh \
  | grep -oP '\[[a-z0-9-]+\]' | sed 's/[][]//g' | sort > /tmp/stacks_keys.txt
awk '/declare -A DESCRIPTIONS/,/^\)/' scripts/create-issues.sh \
  | grep -oP '\[[a-z0-9-]+\]' | sed 's/[][]//g' | sort > /tmp/desc_keys.txt
if diff -q /tmp/stacks_keys.txt /tmp/desc_keys.txt > /dev/null 2>&1; then
  ok A-004 "STACKS and DESCRIPTIONS keys are identical"
else
  DIFF=$(diff /tmp/stacks_keys.txt /tmp/desc_keys.txt)
  fail A-004 "STACKS/DESCRIPTIONS key mismatch" "$DIFF"
fi

# A-005: set-topics.sh — one topic per --add-topic flag
echo "[A-005] set-topics.sh one topic per --add-topic..."
MULTI=$(grep '\-\-add-topic' scripts/set-topics.sh \
  | grep -v '^[[:space:]]*#' \
  | grep -E '\-\-add-topic[[:space:]]+[^\\]+[[:space:]]+' || true)
if [ -z "$MULTI" ]; then
  ok A-005 "All --add-topic flags carry a single topic"
else
  fail A-005 "--add-topic" "multi-topic value detected: $MULTI"
fi

# A-006: printf pattern present for issue body write
echo "[A-006] Issue body write uses printf + env var pattern..."
if grep -qF "printf '%s' \"\$ISSUE_BODY\"" .github/workflows/project-publisher.yml; then
  ok A-006 "Safe printf write pattern confirmed in workflow"
else
  fail A-006 "issue body write" "printf pattern not found — may be using unsafe inline expansion"
fi

# A-007: GH_TOKEN unset causes immediate exit
echo "[A-007] GH_TOKEN unset causes immediate exit..."
OUTPUT=$(bash -c 'unset GH_TOKEN; bash scripts/create-issues.sh' 2>&1 || true)
if echo "$OUTPUT" | grep -q 'GH_TOKEN is required'; then
  ok A-007 "GH_TOKEN unset exits with clear error message"
else
  fail A-007 "GH_TOKEN guard" "expected 'GH_TOKEN is required', got: $OUTPUT"
fi

# A-008: generate-files.sh skips existing README.md
echo "[A-008] generate-files.sh skips existing README.md..."
TD=$(mktemp -d)
echo '# Pre-existing README' > "$TD/README.md"
touch "$TD/.gitignore"
BEFORE=$(cat "$TD/README.md")
bash scripts/generate-files.sh word-counter html 'Word counter tool' "$TD" > /dev/null
AFTER=$(cat "$TD/README.md")
if [ "$BEFORE" = "$AFTER" ]; then
  ok A-008 "Existing README.md was not overwritten"
else
  fail A-008 "README.md skip" "file was overwritten — content changed"
fi
rm -rf "$TD"

# A-009: generate-files.sh skips existing .gitignore
echo "[A-009] generate-files.sh skips existing .gitignore..."
TD=$(mktemp -d)
touch "$TD/README.md"
echo '# Pre-existing gitignore' > "$TD/.gitignore"
BEFORE=$(cat "$TD/.gitignore")
bash scripts/generate-files.sh word-counter html 'Word counter tool' "$TD" > /dev/null
AFTER=$(cat "$TD/.gitignore")
if [ "$BEFORE" = "$AFTER" ]; then
  ok A-009 "Existing .gitignore was not overwritten"
else
  fail A-009 ".gitignore skip" "file was overwritten — content changed"
fi
rm -rf "$TD"

# A-010: generate-files.sh produces correct README per stack
echo "[A-010] generate-files.sh README content per stack..."
for STACK in python html powershell; do
  TD=$(mktemp -d)
  touch "$TD/.gitignore"
  bash scripts/generate-files.sh test-project "$STACK" 'A test project' "$TD" > /dev/null
  if [ ! -f "$TD/README.md" ]; then
    fail "A-010/$STACK" "README.md generation" "file not created for stack=$STACK"
  elif ! grep -q 'Test Project' "$TD/README.md"; then
    fail "A-010/$STACK" "README.md title" "Title Case name not found for stack=$STACK"
  elif ! grep -q 'A test project' "$TD/README.md"; then
    fail "A-010/$STACK" "README.md description" "DESC not present for stack=$STACK"
  elif ! grep -q 'JPGBMR' "$TD/README.md"; then
    fail "A-010/$STACK" "README.md footer" "JPGBMR portfolio footer missing for stack=$STACK"
  else
    ok "A-010/$STACK" "README.md correct for stack=$STACK"
  fi
  rm -rf "$TD"
done

# A-011: printf correctly writes JSON body with special characters
echo "[A-011] Issue body printf handles special chars..."
TD=$(mktemp -d)
export ISSUE_BODY='{"name":"word-counter","stack":"html","description":"Handles $special \\backslash and backtick"}'
printf '%s' "$ISSUE_BODY" > "$TD/issue_body.json"
PARSED=$(python3 -c "import json; d=json.load(open('$TD/issue_body.json')); print(d['name'])")
if [ "$PARSED" = 'word-counter' ]; then
  ok A-011 "printf writes JSON with special chars; python3 parses correctly"
else
  fail A-011 "issue body write" "expected 'word-counter', got: $PARSED"
fi
rm -rf "$TD"

# Summary
echo ""
echo "=== Results ==="
echo "Passed : $PASS"
echo "Failed : $FAIL"
if [ ${#FAILURES[@]} -gt 0 ]; then
  echo ""
  echo "Failures:"
  for F in "${FAILURES[@]}"; do echo "  $F"; done
fi
echo ""
[ "$FAIL" -eq 0 ] && echo "ALL TESTS PASSED" || { echo "TESTS FAILED"; exit 1; }
