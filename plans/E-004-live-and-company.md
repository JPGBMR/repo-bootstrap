# ELENA — Task Plan E-004
## Make All 34 Repos Fully Live + 5 Company-Grade Deliverables

---

```
[CONTEXT]
All 34 non-wip repos are published on JPGBMR with code on main.
All PRs merged except 1 (to be resolved in E-004-01).
0/34 repos have CI workflows. 0/34 have GitHub Pages. 0/34 have branch protection.
The inventory phase is done. The infrastructure phase has not started.
```

```
[ENHANCEMENT]
"Ensure all non-wip folders are live" means more than repos existing.
A repo is not live until: CI is green, Pages is deployed (HTML), and main is protected.
Expanding definition of "live" to that standard. Proceeding.
```

```
[ASSUMPTION]
"5 tasks for our software company" = 5 Colombo-ready specs that build a
professional company presence on top of the portfolio foundation.
These are strategic, not just maintenance. Ordered by dependency.
```

---

```json
{
  "agent": "elena",
  "type": "task_plan",
  "plan_id": "E-004",
  "timestamp": "2026-02-22T00:00:00Z",
  "operator_request": "Make exhaustive plan to ensure all non-wip folders are live. 5 tasks for Colombo for our software company.",
  "interpreted_intent": "Complete the infrastructure pipeline (CI + Pages + branch protection) so all 34 repos are genuinely live. Then establish 5 company-grade deliverables that turn the portfolio into a professional software company presence.",
  "priority": "p1",
  "target_account": "JPGBMR",

  "tasks": [

    {
      "task_id": "E-004-01",
      "title": "Complete CI/CD pipeline — inject workflows into all 34 repos",
      "description": "Create the 4 CI/CD template files (ci-html.yml, cd-pages.yml, ci-python.yml, ci-powershell.yml) in repo-bootstrap/templates/. Write inject-workflows.sh that clones each repo, drops in the correct template(s), and pushes to main. HTML repos get both ci-html.yml and cd-pages.yml. Idempotent — skips repos that already have .github/workflows/ci.yml. Logs progress to pipeline-state.json.",
      "stack": "yaml + bash",
      "scope": "all 34 — 22 html, 10 python, 2 powershell",
      "action_type": "create + run",
      "acceptance_criteria": "Every JPGBMR project repo has a green CI checkmark on main. Every HTML repo has a live GitHub Pages URL: https://jpgbmr.github.io/<project>/",
      "depends_on": [],
      "estimated_effort": "large",
      "files_affected": [
        "templates/ci-html.yml",
        "templates/cd-pages.yml",
        "templates/ci-python.yml",
        "templates/ci-powershell.yml",
        "scripts/inject-workflows.sh",
        "pipeline-state.json"
      ],
      "pre_flight_fixes": [
        "Close or merge the 1 remaining open PR (feat/initial-release) before injecting CI — identify which repo via: gh pr list --repo JPGBMR/<each> 2>/dev/null"
      ],
      "risks": [
        "GitHub Pages must be enabled via API after first ci.yml push — use gh api POST /repos/JPGBMR/{repo}/pages",
        "Lighthouse CI on Pages requires a deployed URL — use continue-on-error:true on first run",
        "seo-intel is Flask — ruff passes but no server; note in pipeline-state.json",
        "Rate limits: sleep 2 between every API call in inject-workflows.sh"
      ],
      "out_of_scope": ["Branch protection (E-004-02), merging PRs, modifying any project source code"]
    },

    {
      "task_id": "E-004-02",
      "title": "Lock main — branch protection on all 34 repos",
      "description": "Write branch-protection.sh. For each repo: apply branch protection to main requiring the repo's CI status check to pass before any merge. No required reviewers (solo + Flavio workflow). Script reads the correct status check context name per stack (CI / lint, CI / lint-and-test, CI / analyze). Idempotent — safe to re-run. Logs to pipeline-state.json.",
      "stack": "bash",
      "scope": "all 34",
      "action_type": "create + run",
      "acceptance_criteria": "gh api repos/JPGBMR/word-counter/branches/main/protection returns 200. Attempting a direct push to main on any repo is rejected.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "small",
      "files_affected": ["scripts/branch-protection.sh"],
      "pre_flight_fixes": [],
      "risks": [
        "Branch protection context names must exactly match CI job names — Colombo must align these in the templates",
        "Apply LAST — never before CI is confirmed green on main"
      ],
      "out_of_scope": ["Required reviewers, org-level protection, CODEOWNERS"]
    },

    {
      "task_id": "E-004-03",
      "title": "COMPANY TASK 1 — JPGBMR profile README (company card)",
      "description": "Create the JPGBMR/JPGBMR repo (GitHub profile repo). Write a professional README.md that serves as the company homepage on GitHub. Contents: company tagline, stack badges (Python / HTML / JS / PowerShell), categorized project table with live Pages links and one-line descriptions for all 34 projects, and a section for upcoming wip- projects. Clean, minimal, no emoji overload. Mobile-readable.",
      "stack": "html (markdown)",
      "scope": "JPGBMR/JPGBMR (profile repo)",
      "action_type": "create",
      "acceptance_criteria": "https://github.com/JPGBMR displays the profile README. All 34 project links resolve. Pages links work for all 22 HTML tools.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "medium",
      "files_affected": ["README.md (in JPGBMR/JPGBMR repo)"],
      "pre_flight_fixes": [],
      "risks": [
        "Pages URLs must be confirmed live before embedding in profile README — run after E-004-01 is complete"
      ],
      "out_of_scope": ["Custom domain, org description, social links (those are manual GitHub settings)"]
    },

    {
      "task_id": "E-004-04",
      "title": "COMPANY TASK 2 — Portfolio landing page (jpgbmr.github.io)",
      "description": "Build a single-page HTML/CSS/JS company portfolio site deployed to GitHub Pages from a new repo: JPGBMR/jpgbmr.github.io. The site lists all 34 live projects in a filterable card grid (filter by stack: all / html / python / powershell). Each card: project name, one-line description, stack badge, and a 'Launch' button linking to the live Pages URL or GitHub repo. Dark theme. Zero dependencies — no frameworks, no npm. One index.html + one style.css + one app.js. Mobile-first responsive.",
      "stack": "html",
      "scope": "JPGBMR/jpgbmr.github.io (new repo)",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io loads, displays all 34 project cards, filter buttons work, Launch buttons open correct URLs. Lighthouse score ≥ 90 performance, ≥ 95 accessibility.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "large",
      "files_affected": [
        "index.html",
        "style.css",
        "app.js",
        ".github/workflows/cd-pages.yml"
      ],
      "pre_flight_fixes": [],
      "risks": [
        "Pages URL for this repo is the root JPGBMR domain (jpgbmr.github.io) — only one repo can own this URL",
        "All 22 HTML project Pages URLs must be confirmed before hardcoding in app.js",
        "No build step — Vitalik must not reach for a bundler"
      ],
      "out_of_scope": ["Custom domain, analytics, contact form, blog, auth of any kind"]
    },

    {
      "task_id": "E-004-05",
      "title": "COMPANY TASK 3 — README standard across all 34 repos",
      "description": "Write a script (scripts/standardize-readmes.sh) that audits and upgrades every project README. For each repo: check if README has (a) a live demo badge linking to Pages URL (HTML only), (b) a stack badge, (c) a Getting Started section, (d) the portfolio footer. If any are missing, inject them. Commit message: 'docs: standardize README to company template'. Idempotent — checks for each element before inserting. Does NOT overwrite existing custom content — appends or inserts missing sections only.",
      "stack": "bash",
      "scope": "all 34",
      "action_type": "create + run",
      "acceptance_criteria": "Every JPGBMR project README renders with a stack badge, Getting Started section, and portfolio footer. HTML repos also have a live demo badge. Spot-check: word-counter, seo-intel, cpu-benchmark.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "medium",
      "files_affected": ["scripts/standardize-readmes.sh"],
      "pre_flight_fixes": [],
      "risks": [
        "seo-intel Getting Started is Flask-specific — script must detect stack and use correct template",
        "cpu-benchmark Getting Started is PowerShell-specific — same",
        "Do not overwrite READMEs that already have rich content — check for existing sections before inserting"
      ],
      "out_of_scope": ["Screenshots, GIFs, demo videos, changelog, contributors section"]
    },

    {
      "task_id": "E-004-06",
      "title": "COMPANY TASK 4 — GitHub Projects roadmap board",
      "description": "Create a GitHub Projects (v2) board on the JPGBMR account named 'Portfolio Roadmap'. Columns: Backlog / In Progress / Review / Live. Populate with: all 38 wip- projects as Backlog cards (with stack label and spec status). Add the 34 live projects as Live cards (linked to their repos). Board is public. Write a script (scripts/setup-roadmap.sh) that automates card creation via the GitHub GraphQL API.",
      "stack": "bash + graphql",
      "scope": "JPGBMR account (Projects v2)",
      "action_type": "create",
      "acceptance_criteria": "https://github.com/users/JPGBMR/projects shows the Portfolio Roadmap board. 38 wip- items visible in Backlog. 34 live projects visible in Live column.",
      "depends_on": [],
      "estimated_effort": "medium",
      "files_affected": ["scripts/setup-roadmap.sh"],
      "pre_flight_fixes": [],
      "risks": [
        "GitHub Projects v2 uses GraphQL, not REST — Colombo must spec the correct mutation schema",
        "Token must have 'project' scope — check gh auth token scopes before running",
        "38 wip- card creation is batch — must handle rate limits (sleep between mutations)"
      ],
      "out_of_scope": ["Sprint planning, milestones, assignees, estimated dates"]
    },

    {
      "task_id": "E-004-07",
      "title": "COMPANY TASK 5 — First wip- project: full Elena→Colombo→Vitalik→Athena delivery",
      "description": "Run the complete agent pipeline on the first wip- project build. Recommended: wip-password-generator (simplest spec, zero dependencies, pure HTML/JS, high user value). Elena scopes it → Colombo blueprints it → Vitalik builds it → Athena verifies it → PR opened → merged → Pages live. This is the template run for all future wip- deliveries. Document what the pipeline produced, what needed adjustment, and what Colombo's standing rules need to update.",
      "stack": "html",
      "scope": "wip-password-generator → becomes password-generator",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/password-generator/ is live. CI is green. Lighthouse ≥ 90. PR was opened, reviewed, and merged through the standard pipeline. wip-password-generator folder removed from local disk after publish.",
      "depends_on": ["E-004-01", "E-004-02"],
      "estimated_effort": "medium",
      "files_affected": [
        "password-generator/index.html",
        "password-generator/style.css",
        "password-generator/app.js",
        "password-generator/.gitignore",
        "password-generator/README.md",
        "password-generator/.github/workflows/ci.yml",
        "password-generator/.github/workflows/cd-pages.yml"
      ],
      "pre_flight_fixes": [
        "Read wip-password-generator/README.md spec before Colombo blueprints — spec is the source of truth"
      ],
      "risks": [
        "This is the pipeline's first real product delivery — slow down, document everything",
        "If the spec is incomplete, Elena gaps-fills and notes it — do not block Vitalik for a missing detail"
      ],
      "out_of_scope": ["Backend password strength API, user accounts, password storage of any kind"]
    }

  ],

  "build_sequence": "E-004-01 (CI inject) → E-004-02 (branch protect) → E-004-03 + E-004-05 + E-004-06 in parallel → E-004-04 (portfolio site, needs Pages URLs from 01) → E-004-07 (first wip- delivery, needs 01 + 02)",

  "done_when": "All 34 repos green CI on main. All 22 HTML repos live on Pages. All main branches protected. JPGBMR profile README live. jpgbmr.github.io portfolio site live. All 34 READMEs standardized. Roadmap board live with 72 cards. password-generator delivered and live.",

  "elena_notes": "Colombo: E-004-01 is the blocker for most of this plan — prioritize it. The correct execution order for the full pipeline is in C-003: preflight → publish (done) → inject CI → wait for green → merge PRs → branch protect. Do not skip steps. E-004-07 is the most important long-term deliverable — it proves the pipeline works end-to-end on a new build, not just a publish. Every lesson from E-004-07 feeds back into COLOMBO.md as a standing rule."
}
```
