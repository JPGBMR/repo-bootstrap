# E-015 Shipping Cadence (Ship-First)

## Purpose
Increase shipping velocity without dropping QA discipline.

## Weekly Targets (Binary Pass/Fail)
- `builds_shipped_per_week >= 4` (must pass Athena gate).
- `same_day_handoff_rate >= 90%` for Elena -> Colombo -> Vitalik -> Athena.
- `qa_pass_rate >= 80%` on first Athena pass.
- `max_active_wip_batches = 2` at any time.
- `tech_debt_closure_ratio >= 0.8` (closed debt items / opened debt items per week).

Weekly result:
- `PASS` only if all five targets are met.
- `FAIL` if any target misses threshold.

## Tech Debt Budget (Mandatory)
- Reserve `20%` capacity per sprint/batch for debt work:
  - tests
  - lint/format
  - docs updates
  - cleanup/refactor of touched files
- Debt threshold: `max_open_debt_items = 12` across active scope.
- Enforcement:
  - If open debt > 12, no new WIP starts.
  - Only debt-reduction and critical bugfix work can proceed until <= 12.

## Same-Day Handoff Rule
- Every task started today must reach Athena handoff today unless blocked.
- If blocked, blocker must be logged with owner and unblock action.
- Unowned blockers are treated as process failure.

## Immediate Queue (Low-Hanging + One More Deliverable)
Pre-flight:
- Confirm non-overlap with in-flight E-010/E-011.
- Rename folder from `wip-*` to live slug before implementation.

Batch A (low-hanging fruits):
1. `wip-color-scheme` -> `color-scheme` (small)
2. `wip-dice-roller` -> `dice-roller` (small)
3. `wip-url-parser` -> `url-parser` (small)

Batch B (one additional deliverable):
4. `wip-context-packer` -> `context-packer` (medium)

## Required Outputs Per Project
- Runnable local project files (`index.html`, `style.css`, `script.js`, `README.md`).
- Vitalik `build_report` with acceptance trace and GitHub evidence refs.
- Athena `qa_report` + `grading_report`.

## Ownership
- Elena: queue and plan quality.
- Colombo: blueprint quality + QA gate fields.
- Vitalik: implementation + evidence-complete handoff.
- Athena: verification, grading, and release recommendation.
