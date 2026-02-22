# repo-bootstrap

Automated project publisher for the JPGBMR open-source portfolio.

This repo is the **orchestration layer only** — it contains no project code. Its sole purpose is to automate the creation and publication of all 34 portfolio projects to JPGBMR using GitHub Actions triggered by GitHub Issues.

---

## How It Works

1. Run `scripts/create-issues.sh` — creates one labeled Issue per project on this repo
2. Each issue is labeled `publish-project`, which triggers the Actions workflow
3. The workflow pulls source from Catalitium, injects any missing README/`.gitignore`, creates the public repo on JPGBMR, pushes the code, and sets topics
4. The issue is automatically closed with a link to the published repo

Every repo creation has a linked closed issue here as an audit trail.

---

## Setup

### 1. Create a Personal Access Token

Create a **Classic PAT** on the JPGBMR account with scopes: `repo`, `workflow`

> Classic PAT is recommended over Fine-grained PAT — fine-grained tokens can have trouble with repo creation across account boundaries.

### 2. Add the Token as a Repository Secret

`JPGBMR/repo-bootstrap → Settings → Secrets and variables → Actions → New repository secret`

- **Name:** `GH_TOKEN`
- **Value:** your Classic PAT

### 3. Verify Catalitium Repos Are Public

All 34 source repos on Catalitium must be public. A private repo returns a 404 during the checkout step (not a 401), making it hard to diagnose. Check visibility before running.

### 4. Run the Issue Seeder

```bash
GH_TOKEN=your_token bash scripts/create-issues.sh
```

This creates 34 labeled issues with a 3-second delay between each. Each issue triggers one workflow run. Monitor progress under the [Actions tab](https://github.com/JPGBMR/repo-bootstrap/actions).

---

## Re-triggering a Failed Run

If a workflow run fails, re-trigger it by removing and re-adding the `publish-project` label on the failed issue:

```bash
# Replace <number> with the issue number shown in the failed run
gh issue edit <number> --repo JPGBMR/repo-bootstrap --remove-label "publish-project"
sleep 5
gh issue edit <number> --repo JPGBMR/repo-bootstrap --add-label "publish-project"
```

---

## Projects Published (34)

| Project | Stack |
|---|---|
| ascii-art | Python |
| aspect-ratio | HTML/JS |
| auto-prompter | Python |
| base64 | HTML/JS |
| binary-converter | HTML/JS |
| bmi-calculator | HTML/JS |
| cache-cleaner | Python |
| contract-generator | HTML/JS |
| conway-game | Python |
| countdown-timer | HTML/JS |
| cpu-benchmark | PowerShell |
| cron-builder | HTML/JS |
| css-minifier | HTML/JS |
| euro-castles | HTML/JS |
| hash-generator | HTML/JS |
| hex-palette | HTML/JS |
| invoice-generator | HTML/JS |
| json-formatter | HTML/JS |
| lorem-generator | HTML/JS |
| maze-master | Python |
| morse-translator | HTML/JS |
| pixel-art-editor | HTML/JS |
| qr-generator | Python |
| reading-estimator | HTML/JS |
| regex-tester | HTML/JS |
| secure-vault | Python |
| seo-intel | Python |
| social-card | HTML/JS |
| system-health | PowerShell |
| text-summarizer | Python |
| timezone-converter | HTML/JS |
| tip-calculator | HTML/JS |
| typing-test | Python |
| word-counter | HTML/JS |

---

## Audit Trail

Every repo creation has a corresponding closed issue on this repo. An open issue means that publish either failed or has not yet run. All 34 issues closed with success comments = complete deployment.
