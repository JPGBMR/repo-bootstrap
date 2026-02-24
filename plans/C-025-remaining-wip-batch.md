# C-025 Remaining WIP Batch Blueprint

Source plan: `E-025`
Target account: `JPGBMR`

## Scope Lock

Target closure applies only to these five folders:

- `api-builder`
- `waitlist-platform`
- `compliance-auto`
- `screenshot-docs`
- `niche-job-board`

This wave does **not** require clearing every global `wip-*` directory.

## Anti-Overengineering Guardrails

- Local-first only.
- No backend infra, auth, billing, external DB, cloud OCR, or legal guarantees.
- Deterministic outputs from fixed templates and local data.
- Explicit validation and malformed-input handling.

## Brand Guidelines (Wave Default)

- Dark navy background family (`#0b1220` to `#121a2b`).
- Electric blue accent (`#2f81f7`) for primary actions.
- High contrast text and bordered cards/panels.
- Compact mobile-safe controls.

## Acceptance Mapping

### C-025-01 Pack

- Criterion: single deterministic blueprint artifact for all five projects.
- Verification: this file defines exact build sequence, bounds, and QA mapping.

### C-025-02 Wave A

- Projects: `api-builder`, `waitlist-platform`
- QA hook: `QH-025-A`
- Criterion: both core local flows run without placeholders.

### C-025-03 Wave B

- Projects: `compliance-auto`, `screenshot-docs`
- QA hook: `QH-025-B`
- Criterion: deterministic template outputs and explicit malformed-input handling.

### C-025-04 Wave C

- Project: `niche-job-board`
- QA hook: `QH-025-C`
- Criterion: create/list/filter/persist with deterministic validation.

### C-025-05 QA + Closure

- Files: inventory, grading, feed, and this plan.
- Criterion: state records reflect final route outcomes for the five-target set.

## QA Gate Bands

- Ship: `85-100` and no critical/high findings.
- Rework: `60-84` or any high finding.
- Escalate: `0-59` or blocked/ambiguous dependency.

## C-025-02 Wave A Foundations

- Projects: `api-builder`, `waitlist-platform`
- Files:
  - `api-builder/index.html`
  - `api-builder/style.css`
  - `api-builder/script.js`
  - `api-builder/README.md`
  - `waitlist-platform/index.html`
  - `waitlist-platform/style.css`
  - `waitlist-platform/script.js`
  - `waitlist-platform/README.md`
- Acceptance:
  - Deterministic local flow for endpoint schema mock generation.
  - Deterministic local waitlist validate/add/filter/export flow.
  - No placeholders or backend dependencies.
- QA hook: `QH-025-A`

## C-025-03 Wave B Operations

- Projects: `compliance-auto`, `screenshot-docs`
- Files:
  - `compliance-auto/index.html`
  - `compliance-auto/style.css`
  - `compliance-auto/script.js`
  - `compliance-auto/README.md`
  - `screenshot-docs/index.html`
  - `screenshot-docs/style.css`
  - `screenshot-docs/script.js`
  - `screenshot-docs/README.md`
- Acceptance:
  - Deterministic template output generation for compliance artifacts.
  - Deterministic screenshot-doc blocks from metadata + filenames.
  - Explicit malformed input handling.
- QA hook: `QH-025-B`

## C-025-04 Wave C Marketplace

- Project: `niche-job-board`
- Files:
  - `niche-job-board/index.html`
  - `niche-job-board/style.css`
  - `niche-job-board/script.js`
  - `niche-job-board/README.md`
- Acceptance:
  - Create/list/filter flows with local persistence.
  - Deterministic listing ID and duplicate prevention.
  - Clear validation for malformed salary/input states.
- QA hook: `QH-025-C`

## C-025-05 QA Gate + Target Closure

- State files updated for contexts `E-025-01` through `E-025-05`.
- Closure semantics applied to target-five folders only:
  - `api-builder`
  - `waitlist-platform`
  - `compliance-auto`
  - `screenshot-docs`
  - `niche-job-board`
- QA outcome in this environment:
  - Local build quality: pass for all five targets.
  - GitHub evidence gate: blocked/unavailable locally.
  - Route: rework/evidence pass required when GitHub checks are accessible.
