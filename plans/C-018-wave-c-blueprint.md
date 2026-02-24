# C-018 Wave C Blueprint Pack

Source plan: `E-018`
Target account: `JPGBMR`

## Global Constraints

- Apply pre-flight renames from `wip-*` to final project names before implementation.
- Enforce clamped parameters and capped defaults for all visual specs.
- Exclude out-of-scope features: CAS/symbolic algebra, unbounded rendering, physics-accurate orbital simulation, backend compute.
- QA gate threshold: minimum score `85`, no critical/high findings for ship.

## C-018-01 graphing-calculator

- Sequence: `1`
- Depends on: none
- Scope files:
  - `graphing-calculator/index.html`
  - `graphing-calculator/style.css`
  - `graphing-calculator/script.js`
  - `graphing-calculator/README.md`
- Acceptance criteria:
  - Deterministic expression parsing for supported grammar.
  - Plot updates correctly with zoom/pan and discontinuity handling.
  - Root approximation is bounded and reproducible for supported inputs.
- QA hook: `QH-018-01`
  - Verify deterministic parse/plot behavior and bounded root output.
  - Invalid expressions must fail with explicit errors.

## QA Routing

- `85-100` and no critical/high findings: ship.
- `60-84` or any high finding: rework to Vitalik with narrowed retest scope.
- `0-59` or blocked dependency: escalate to Colombo/Elena per routing rules.

## C-018-02 matrix-calculator

- Sequence: `2`
- Depends on: `C-018-01`
- Scope files:
  - `matrix-calculator/index.html`
  - `matrix-calculator/style.css`
  - `matrix-calculator/script.js`
  - `matrix-calculator/README.md`
- Acceptance criteria:
  - Add/subtract/multiply/transpose/determinant/inverse operate correctly within size caps.
  - Deterministic validation precedence is enforced.
  - Invalid states fail with explicit error messages.
- QA hook: `QH-018-02`
  - Verify operation correctness for supported dimensions.
  - Verify rejection ordering: malformed input > dimension mismatch > singular inverse > unsupported operation.

## C-018-03 particle-galaxy

- Sequence: `3`
- Depends on: `C-018-02`
- Scope files:
  - `particle-galaxy/index.html`
  - `particle-galaxy/style.css`
  - `particle-galaxy/script.js`
  - `particle-galaxy/README.md`
- Acceptance criteria:
  - Capped defaults and hard max caps for interactive parameters.
  - Deterministic regeneration by seed.
  - Graceful degraded mode on sustained frame instability.
- QA hook: `QH-018-03` (shared)
  - Validate no unbounded particle growth and stable default controls.

## C-018-04 solar-system

- Sequence: `4`
- Depends on: `C-018-03`
- Scope files:
  - `solar-system/index.html`
  - `solar-system/style.css`
  - `solar-system/script.js`
  - `solar-system/README.md`
- Acceptance criteria:
  - Planets animate with bounded time controls.
  - Pause/resume and selection behave deterministically.
  - Interaction remains stable under repeated selection and mobile touch fallback.
- QA hook: `QH-018-03` (shared)
  - Confirm stable default rendering and bounded controls.

## C-018-05 terrain-generator

- Sequence: `5`
- Depends on: `C-018-04`
- Scope files:
  - `terrain-generator/index.html`
  - `terrain-generator/style.css`
  - `terrain-generator/script.js`
  - `terrain-generator/README.md`
- Acceptance criteria:
  - Deterministic regeneration by seed.
  - Parameter clamps enforced within documented ranges.
  - Stable render with bounded grid defaults and explicit recovery path.
- QA hook: `QH-018-04`
  - Validate seed determinism, clamp behavior, and responsiveness under capped limits.

## Build Sequence

`C-018-01 -> C-018-02 -> C-018-03 -> C-018-04 -> C-018-05`

## Athena Routing Bands

- Ship: score `85-100` and no critical/high findings.
- Rework: score `60-84` or any high finding.
- Escalate: score `0-59` or blocked/ambiguous dependency.
