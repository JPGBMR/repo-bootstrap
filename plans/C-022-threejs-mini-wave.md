# C-022 Three.js Mini Wave

Source plan: `E-022`
Target account: `JPGBMR`

## Wave Intent

Compact three-project wave with strict MVP boundaries:

- `fractal-tree`
- `gravity-sim`
- `matrix-rain-3d`

## Global Preconditions

- Pre-flight rename: `wip-fractal-tree -> fractal-tree`
- Pre-flight rename: `wip-gravity-sim -> gravity-sim`
- Slug resolution: `wip-matrix-rain -> matrix-rain-3d`
- Hard caps must be applied before exposing UI controls.

## Hard Cap Baselines

- Fractal recursion depth max: `10`
- Fractal branch angle range: `5..60`
- Fractal branch scale range: `0.45..0.82`
- Gravity body count max: `120`
- Gravity dt range: `0.002..0.03`
- Gravity velocity cap: `3.5`
- Matrix rain density max: `1800`
- Matrix rain speed range: `0.25..2.4`

## Acceptance Mapping

### C-022-01 Blueprint Pack

- Criterion: blueprint pack exists and is deterministic.
- Verification: this file declares exact file actions, bounds, and QA hooks.

### C-022-02 Fractal Tree

- Criterion: tree regenerates from controls and remains responsive under capped depth.
- Verification: enforce depth clamp and deterministic regeneration by seedless fixed branching equations.
- QA hook: `QH-022-FT`

### C-022-03 Gravity Sim

- Criterion: simulation stable under defaults with reset and anti-runaway caps.
- Verification: clamp dt, body count, and velocities; provide explicit reset.
- QA hook: `QH-022-GS`

### C-022-04 Matrix Rain 3D

- Criterion: slug resolved, capped defaults, degraded mode on low FPS.
- Verification: build under `matrix-rain-3d`, enforce density/speed caps, activate low-FPS fallback.
- QA hook: `QH-022-MR`

## QA Gate Routing

- Ship: `85-100` and no critical/high findings.
- Rework: `60-84` or any high finding.
- Escalate: `0-59` or blocked/ambiguous dependency.

## Required GitHub Evidence (Athena)

- Workflow status
- Required checks
- Artifact availability
- Claimed file-change alignment

## C-022-02 Fractal Tree

- Files:
  - `fractal-tree/index.html`
  - `fractal-tree/style.css`
  - `fractal-tree/script.js`
  - `fractal-tree/README.md`
- Acceptance:
  - Recursive generation with hard depth cap.
  - Deterministic regenerate/reset behavior.
  - Responsive controls under capped settings.
- QA hook: `QH-022-FT`

## C-022-03 Gravity Sim

- Files:
  - `gravity-sim/index.html`
  - `gravity-sim/style.css`
  - `gravity-sim/script.js`
  - `gravity-sim/README.md`
- Acceptance:
  - Stable defaults with start/pause/reset behavior.
  - dt/velocity/body-count clamps prevent runaway states.
- QA hook: `QH-022-GS`

## C-022-04 Matrix Rain 3D + Wave Route

- Files:
  - `matrix-rain-3d/index.html`
  - `matrix-rain-3d/style.css`
  - `matrix-rain-3d/script.js`
  - `matrix-rain-3d/README.md`
- Acceptance:
  - Slug conflict resolved to `matrix-rain-3d`.
  - Density/speed caps enforced with deterministic reset.
  - Low-FPS degraded mode with explicit warning state.
- QA hook: `QH-022-MR`

## Final Route Criteria

- Build outputs route to Athena for QA grading.
- Dashboard state files must reflect build + QA statuses for all wave specs.
