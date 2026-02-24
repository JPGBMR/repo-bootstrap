# COLOMBO BLUEPRINT — C-003
## CI/CD + Testing Pipeline — JPGBMR Portfolio

**Agent:** Colombo | **Priority:** P1 | **Effort:** Large
**State entering this plan:** 11/34 repos published, 0 CI workflows injected, 0 tests running

---

## MISSION
Finish publishing all 34 repos. Inject standardized CI + GitHub Pages into every project.
Every push must be linted and tested. Every HTML project must deploy to Pages automatically.
No manual steps after this runs.

---

## TOP 5 DELIVERABLES (Elena's picks)

| # | Deliverable | Done when |
|---|---|---|
| 1 | All 34 repos published on JPGBMR | `gh repo list JPGBMR --limit 50` shows 35 repos |
| 2 | CI workflow live on every repo | Green checkmark on every main branch |
| 3 | HTML projects on GitHub Pages | `https://jpgbmr.github.io/<project>` loads |
| 4 | Branch protection on all repos | PRs require CI pass before merge |
| 5 | All 34 open PRs merged into main | No open `feat/initial-release` PRs remain |

---

## SPECS

### C-003-01 — Finish publish (remaining 23 repos)
**Action:** Run `publish-all.sh` in full.
**What Vitalic does:**
```bash
bash scripts/publish-all.sh 2>&1 | tee /tmp/publish-all.log
```
The script is idempotent — safe to run over the 11 already-published repos.
**Acceptance:** `gh repo list JPGBMR --limit 50` returns 35 entries.

---

### C-003-02 — CI template: HTML (`templates/ci-html.yml`)
**Create file:** `repo-bootstrap/templates/ci-html.yml`

```yaml
name: CI

on:
  push:
    branches: [main, 'feat/**']
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: HTMLHint
        run: npx --yes htmlhint "**/*.html" --ignore "node_modules/**"
      - name: Lighthouse CI
        uses: treosh/lighthouse-ci-action@v11
        with:
          urls: |
            https://jpgbmr.github.io/${{ github.event.repository.name }}/
          uploadArtifacts: true
          temporaryPublicStorage: true
        continue-on-error: true
```

**Decision (Colombo):** `continue-on-error: true` on Lighthouse — Lighthouse failures flag, not block. Portfolio projects are UI tools; a score <90 should not kill a PR.

---

### C-003-03 — CD template: GitHub Pages (`templates/cd-pages.yml`)
**Create file:** `repo-bootstrap/templates/cd-pages.yml`

```yaml
name: Deploy to Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: '.'
      - uses: actions/deploy-pages@v4
        id: deployment
```

---

### C-003-04 — CI template: Python (`templates/ci-python.yml`)
**Create file:** `repo-bootstrap/templates/ci-python.yml`

```yaml
name: CI

on:
  push:
    branches: [main, 'feat/**']
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install deps
        run: |
          pip install ruff
          [ -f requirements.txt ] && pip install -r requirements.txt || true
      - name: Ruff lint
        run: ruff check .
      - name: Tests
        run: |
          if [ -d tests ]; then
            pip install pytest
            pytest tests/ -v
          else
            echo "No tests/ directory — skipping pytest"
          fi
```

---

### C-003-05 — CI template: PowerShell (`templates/ci-powershell.yml`)
**Create file:** `repo-bootstrap/templates/ci-powershell.yml`

```yaml
name: CI

on:
  push:
    branches: [main, 'feat/**']
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: PSScriptAnalyzer
        shell: pwsh
        run: |
          Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
          $results = Invoke-ScriptAnalyzer -Path . -Recurse -Severity Warning,Error
          $results | Format-Table
          if ($results | Where-Object Severity -eq 'Error') { exit 1 }
```

---

### C-003-06 — inject-workflows.sh
**Create file:** `repo-bootstrap/scripts/inject-workflows.sh`

Logic per project:
1. Clone `JPGBMR/<project>` to tmp dir
2. `mkdir -p .github/workflows`
3. Copy stack-appropriate CI template → `.github/workflows/ci.yml`
4. If stack=html: also copy `cd-pages.yml` → `.github/workflows/cd-pages.yml`
5. `git add .github/ && git commit -m "ci: inject CI/CD workflows"`
6. `git push origin main`
7. Enable GitHub Pages via API: `gh api repos/JPGBMR/<project>/pages -X POST -f source[branch]=main -f source[path]=/`

Key flags:
- Skip if `.github/workflows/ci.yml` already exists (idempotent)
- `2>/dev/null || true` on Pages enable (fails gracefully if already enabled or not HTML)
- `sleep 2` between repos (rate limit safety)

---

### C-003-07 — branch-protection.sh
**Create file:** `repo-bootstrap/scripts/branch-protection.sh`

For every JPGBMR project repo, apply via API:
```bash
gh api repos/JPGBMR/$project/branches/main/protection \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["CI / lint-and-test", "CI / lint", "CI / analyze"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 0,
    "dismiss_stale_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

**Decision (Colombo):** `required_approving_review_count: 0` — solo dev workflow. CI must pass; human review not required. Flip to 1 when Flavio is active.

---

### C-003-08 — merge-prs.sh
**Create file:** `repo-bootstrap/scripts/merge-prs.sh`

For each project:
1. Check if PR `feat/initial-release → main` is open
2. If CI status = success → auto-merge: `gh pr merge --squash --auto`
3. If CI status = failure → log to `/tmp/merge-failures.tsv`, skip
4. Print final summary

---

## EXECUTION ORDER (Vitalic runs in this sequence)

```
1. C-003-01  bash scripts/publish-all.sh          # finish inventory
2. C-003-02  create templates/ci-html.yml
3. C-003-03  create templates/cd-pages.yml
4. C-003-04  create templates/ci-python.yml
5. C-003-05  create templates/ci-powershell.yml
6. C-003-06  create scripts/inject-workflows.sh
7. C-003-07  create scripts/branch-protection.sh
8. C-003-08  create scripts/merge-prs.sh
9.           bash scripts/inject-workflows.sh      # runs workflows on all 34
10.          bash scripts/branch-protection.sh     # locks main on all 34
11.          bash scripts/merge-prs.sh             # closes all open PRs
```

Steps 2–8 are pure file creation — fast. Steps 9–11 touch GitHub API — run sequentially.

---

## TESTING STANDARDS (simple, non-negotiable)

| Stack | Lint | Test | Deploy |
|---|---|---|---|
| html | HTMLHint (block) + Lighthouse (warn) | none | GitHub Pages auto |
| python | ruff (block) | pytest if tests/ exists | none |
| powershell | PSScriptAnalyzer Error=block, Warning=warn | none | none |

**Rule:** If there is no `tests/` folder in a Python project, CI does not fail — it logs "No tests — skipping". Adding tests is `[DEBT]`, not a blocker.

---

## ISSUES COLOMBO RAISES ON repo-bootstrap

```
[SPEC] all — inject CI/CD workflows into 34 repos          priority:p1 vitalic:ready
[SPEC] all — enable branch protection on main              priority:p1 vitalic:ready
[SPEC] all — merge feat/initial-release PRs after CI pass  priority:p2 vitalic:ready
[DEBT] python — no tests/ in any of the 10 Python projects priority:p3
[DECISION] lighthouse — continue-on-error:true chosen      type:decision
```

---

## RISKS & NOTES

- **GitHub Pages + free account:** Pages works on public repos with free accounts. All 34 are public. No issue.
- **Lighthouse on Pages:** First run will fail if Pages isn't deployed yet. `continue-on-error: true` handles this.
- **seo-intel is a Flask app** — `ruff check .` will pass but there's no server to lint templates. Flag as `[DEBT]`.
- **branch protection requires CI contexts to match exactly** — context strings in `branch-protection.sh` must match job names in CI templates. Colombo has aligned them: `CI / lint-and-test` (python), `CI / lint` (html), `CI / analyze` (powershell).
- **merge-prs.sh:** Squash merge keeps main history clean. Each project main ends up with 2 commits: `chore: initial repo` + `feat: initial release`.

---

## MESSAGE TO VITALIC

```
BUILD ORDER:
1. publish-all.sh — run it first, get all 34 repos live
2. templates/ — create all 4 yml files exactly as specced
3. inject-workflows.sh — clone each repo, drop in templates, push to main
4. branch-protection.sh — lock main on all 34 after CI is wired
5. merge-prs.sh — auto-merge all open PRs once CI is green

WATCH OUT FOR:
- inject-workflows.sh must be idempotent — skip if ci.yml already exists
- Pages API call: POST not PUT, fails if already enabled, use || true
- branch protection contexts must match CI job names exactly (see spec)
- seo-intel has a Flask structure — ruff still works, just note it
- sleep 2 between every API-touching loop iteration, no exceptions

DO NOT:
- Do not hardcode the token — always use $(gh auth token)
- Do not enable Pages on python or powershell repos — html only
- Do not block on Lighthouse score — continue-on-error:true always
- Do not add tests/ to Python projects — that is Athena's [DEBT] ticket

DONE WHEN:
- gh repo list JPGBMR --limit 50 → 35 repos
- Every repo has .github/workflows/ci.yml on main
- Every HTML repo has .github/workflows/cd-pages.yml on main
- Every HTML repo has a green Pages URL: https://jpgbmr.github.io/<project>/
- No open feat/initial-release PRs remain
- gh api repos/JPGBMR/word-counter/branches/main/protection → 200 OK
```
