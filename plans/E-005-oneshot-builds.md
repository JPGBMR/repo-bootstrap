# ELENA — Task Plan E-005
## 5 Vitalik One-Shot Builds — Most Promising wip- Features

---

```
[CONTEXT]
38 wip- projects have READMEs with specs. Reviewed 8 candidates against
one-shot criteria: bounded scope, no design ambiguity left for Vitalik,
no backend, no auth, Vitalik knows the algorithm cold.

Eliminated:
- wip-fourier-visualizer: spec says Estimated Complexity = Complex.
  Three synchronized canvases + FFT + interactive spectrum = multi-session.
- wip-data-converter: CSV edge cases (quoted fields, multiline, escaped commas)
  are a rabbit hole. Column mapping UI adds a second hard problem. Not one-shot.
- wip-password-generator: too simple — 80 lines, no visual impact, low portfolio value.
- wip-gradient-generator: draggable color stops are deceptively tricky (pointer events,
  clamping, z-ordering). Colombo would need to spec "use range inputs only" to make
  it one-shot — demoted to honorable mention.
```

```
[ASSUMPTION]
"Most promising" = highest ratio of (visual impact + daily utility) / implementation risk.
"One-shot" = Vitalik builds it start-to-finish in one session without back-and-forth.
Colombo must provide the exact math, exact CDN URLs, and exact file structure —
zero design decisions left open for Vitalik.
```

---

```json
{
  "agent": "elena",
  "type": "task_plan",
  "plan_id": "E-005",
  "timestamp": "2026-02-22T00:00:00Z",
  "operator_request": "Plan the most promising features Vitalik can one-shot",
  "interpreted_intent": "Select 5 wip- projects with maximum portfolio impact that Vitalik can build completely in a single session. Colombo blueprints must close every design decision before Vitalik touches a file.",
  "priority": "p2",
  "target_account": "JPGBMR",

  "tasks": [

    {
      "task_id": "E-005-01",
      "title": "particle-galaxy — 50k-particle Three.js spiral galaxy",
      "description": "Build the particle galaxy. Single index.html. Three.js + OrbitControls from CDN. 50k particles in a BufferGeometry Points object arranged in a 2-arm logarithmic spiral. Inner core = white/yellow, arms = blue/purple, outer scatter = red/orange. Slow auto-rotation. Orbit controls. HTML range inputs (no dat.GUI — simpler) for: particle count, arm count, radius, arm tightness, scatter, rotation speed. Background starfield = second Points object with 5k random far-field points.",
      "stack": "html",
      "scope": "wip-particle-galaxy → particle-galaxy",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/particle-galaxy/ loads, renders 50k+ particles in a visible spiral galaxy, orbit drag works, all 6 sliders update the galaxy in real-time. Lighthouse performance ≥ 85 (Three.js scenes accepted lower than 90).",
      "depends_on": ["E-004-01"],
      "estimated_effort": "medium",
      "files_affected": ["index.html", "README.md", ".gitignore", ".github/workflows/ci.yml", ".github/workflows/cd-pages.yml"],
      "pre_flight_fixes": [],
      "risks": [
        "50k particles: must use BufferGeometry + Points, never individual Mesh objects — spec this explicitly",
        "Logarithmic spiral formula must be in the blueprint: r = radius * e^(spinFactor * θ), x = r*cos(θ + armIndex * 2π/armCount), z = r*sin(...)",
        "Color assignment: use THREE.Color with HSL — core hue=0.15 (yellow), arm hue=0.65 (blue), outer hue=0.0 (red)",
        "Vitalik must not reach for dat.GUI — specify plain HTML range inputs in the blueprint"
      ],
      "out_of_scope": ["Audio reactivity, multi-galaxy collision, motion blur, PNG export, WebXR"]
    },

    {
      "task_id": "E-005-02",
      "title": "lorenz-attractor — real-time 3D chaos theory visualizer",
      "description": "Build the Lorenz attractor. Single index.html. Three.js + OrbitControls from CDN. RK4 integration of the Lorenz system in real-time: dX/dt = σ(Y−X), dY/dt = X(ρ−Z)−Y, dZ/dt = XY−βZ. Render as a THREE.Line with a rolling buffer of the last N points. Color gradient along the trail: hue cycles with time (HSL mapped to elapsed t). Sliders: σ (1–20, default 10), ρ (1–50, default 28), β (0.1–5, default 2.67), trail length (100–5000), dt (0.001–0.02). Reset button. Pause/resume. Black background, neon trail (start cyan, end magenta). Optional: two simultaneous trajectories with slightly different starting points to demonstrate sensitive dependence.",
      "stack": "html",
      "scope": "wip-lorenz-attractor → lorenz-attractor",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/lorenz-attractor/ renders the butterfly attractor in real-time. Orbit drag works. All sliders update the system live. Reset spawns a new trajectory. Pause button halts integration.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "medium",
      "files_affected": ["index.html", "README.md", ".gitignore", ".github/workflows/ci.yml", ".github/workflows/cd-pages.yml"],
      "pre_flight_fixes": [],
      "risks": [
        "Rolling buffer: do NOT push/shift an array every frame — use a circular buffer with Float32Array and update BufferGeometry drawRange",
        "RK4 must be specced exactly in the blueprint — 4 lines of math, Vitalik copies it verbatim",
        "Scale the Lorenz output: raw values are ~(-20,20) — scale by 0.1 so it fits in Three.js viewport",
        "Color gradient: use a Float32Array colors attribute on the BufferGeometry, update in parallel with positions"
      ],
      "out_of_scope": ["Other attractors (Rössler, Chen), CSV export, parameter sweep animation, WebXR"]
    },

    {
      "task_id": "E-005-03",
      "title": "snake-game — classic canvas Snake with localStorage high score",
      "description": "Build Snake. Single index.html. HTML5 Canvas 2D, vanilla JS, zero dependencies. 400×400 canvas, 20×20 grid (20px cells). Dark background (#111), neon green snake (#39FF14), bright red food (#FF2400). Arrow keys + WASD. Speed starts at 150ms/tick, decreases by 5ms every 5 food eaten (min 60ms). Direction queue (handle fast inputs without 180° reversal). Collision: wall + self = game over. Game over overlay shows score and localStorage high score. Touch/swipe support for mobile. Pause on spacebar or blur. Brief flash on food pickup (cell turns white for 1 frame).",
      "stack": "html",
      "scope": "wip-snake-game → snake-game",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/snake-game/ plays Snake. Arrow keys + WASD move snake. Score increments on food. Speed visibly increases over time. Game over screen shows final score and high score. Mobile swipe works. High score persists on refresh.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "small",
      "files_affected": ["index.html", "README.md", ".gitignore", ".github/workflows/ci.yml", ".github/workflows/cd-pages.yml"],
      "pre_flight_fixes": [],
      "risks": [
        "Direction queue: must store pending directions and only dequeue on each tick — prevents 180° reversal on fast keypresses",
        "requestAnimationFrame with timestamp delta for tick throttling — not setInterval (pauses when tab is hidden)",
        "Food must never spawn on the snake — loop until empty cell found"
      ],
      "out_of_scope": ["Difficulty levels, multiplayer, obstacles, power-ups, online leaderboard"]
    },

    {
      "task_id": "E-005-04",
      "title": "markdown-preview — live split-pane editor with marked.js",
      "description": "Build the markdown previewer. Single index.html. marked.js + highlight.js from CDN. CSS Grid split-pane: left = raw textarea, right = rendered preview div. Live render on every keyup event (debounced 100ms). Toolbar: Clear, Copy HTML, Download .md, Toggle pane (collapses to one pane on mobile). Auto-save draft to localStorage on keyup. On load: restore from localStorage or show default markdown sample. Code blocks get highlight.js syntax coloring. GitHub-style prose CSS (dark background, readable line-height, styled tables/blockquotes).",
      "stack": "html",
      "scope": "wip-markdown-preview → markdown-preview",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/markdown-preview/ renders markdown live as user types. Code blocks have syntax highlighting. Content survives page refresh (localStorage). Copy HTML button copies rendered HTML. Download saves a .md file. Mobile stacks panes vertically.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "small",
      "files_affected": ["index.html", "README.md", ".gitignore", ".github/workflows/ci.yml", ".github/workflows/cd-pages.yml"],
      "pre_flight_fixes": [],
      "risks": [
        "marked.js must be configured with sanitize:false and use DOMPurify if embedding user HTML — spec this or explicitly scope out XSS concern (offline tool, user's own input only)",
        "Debounce the render call — direct keyup with large documents causes lag",
        "highlight.js init: call hljs.highlightAll() after each marked.parse() call inside the render function"
      ],
      "out_of_scope": ["Resizable divider (complex pointer logic), collaborative editing, image uploads, custom themes"]
    },

    {
      "task_id": "E-005-05",
      "title": "gravity-sim — N-body gravitational simulation, click to add planets",
      "description": "Build the gravity simulator. Single index.html. HTML5 Canvas 2D, vanilla JS. Start with 3–5 preset bodies (Sun + Earth + Moon scale masses). Click anywhere on canvas to add a new body with random mass (small asteroid to large planet — random radius 4–20px). Bodies exert gravitational force on each other: F = G*m1*m2/r². Verlet integration for stability. Velocity vectors shown as short arrows on hover. Bodies merge on collision (mass and momentum conserved). Trail rendering: each body leaves a fading dot trail (last 200 positions stored). Sliders: G constant (gravitational strength), time step (simulation speed), trail length. Reset button restores preset. Bodies draggable on mousedown to reposition and set initial velocity (drag and release = throw).",
      "stack": "html",
      "scope": "wip-gravity-sim → gravity-sim",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/gravity-sim/ shows orbiting bodies. Clicking canvas adds a new body. Bodies visibly attract each other. Collisions merge bodies. Trail fades behind each body. Sliders affect simulation. Drag-to-throw works.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "medium",
      "files_affected": ["index.html", "README.md", ".gitignore", ".github/workflows/ci.yml", ".github/workflows/cd-pages.yml"],
      "pre_flight_fixes": [],
      "risks": [
        "Verlet integration formula must be in blueprint: pos += vel*dt + 0.5*acc*dt², vel += 0.5*(acc_prev + acc_new)*dt",
        "Collision threshold: merge when distance < r1+r2. New radius = sqrt(r1²+r2²) (area-conserving)",
        "Softening factor to prevent division-by-zero at small distances: F = G*m1*m2 / (r² + ε²) where ε=5",
        "Trail: circular buffer of {x,y,alpha} per body — do NOT use canvas globalAlpha for entire scene",
        "Drag-to-throw: record mousedown position and body, on mouseup compute delta → set as initial velocity"
      ],
      "out_of_scope": ["3D rendering, relativistic effects, preset orbital mechanics scenarios, export/import"]
    }

  ],

  "build_sequence": "All 5 are independent — run in parallel after E-004-01 (CI injection) is complete. Recommended order if sequential: snake (warmup, simplest) → markdown-preview → gradient-generator → lorenz-attractor → particle-galaxy.",

  "done_when": "5 new repos live on JPGBMR. 5 GitHub Pages URLs return 200. CI green on all 5 main branches. Lighthouse ≥ 85 on all 5 (Three.js projects allowed lower performance score).",

  "elena_notes": "Colombo: for E-005-01 and E-005-02, the blueprint MUST include the exact math formulas — Vitalik should copy-paste them verbatim, not derive them. For E-005-03 and E-005-04, these are small-effort builds — Colombo can run both as a single Vitalik session. E-005-05 (gravity-sim) is the most algorithmically interesting — Colombo must spec the Verlet integrator, softening factor, and collision merge formula exactly or Vitalik will improvise a less stable approach. The one-shot guarantee depends entirely on Colombo's blueprint quality."
}
```

---

## One-Shot Score Card

| Project | Visual Impact | Daily Utility | One-Shot Confidence | Why it wins |
|---------|--------------|---------------|--------------------|-|
| particle-galaxy | ★★★★★ | ★★☆☆☆ | ★★★★☆ | Most stunning portfolio piece. Logarithmic spiral = 2 lines of math. |
| lorenz-attractor | ★★★★★ | ★★★☆☆ | ★★★★☆ | Beautiful AND educational. RK4 is textbook. Neon trail = instant wow. |
| snake-game | ★★★☆☆ | ★★★☆☆ | ★★★★★ | Vitalik can build this blind. Spec is watertight. Guaranteed ship. |
| markdown-preview | ★★★☆☆ | ★★★★★ | ★★★★★ | Opens every session. marked.js does the heavy lifting. ~120 lines JS. |
| gravity-sim | ★★★★☆ | ★★★☆☆ | ★★★★☆ | Interactive physics. Click-to-add-planets hook. Verlet = stable + simple. |

## What Colombo must lock down per project (non-negotiables)

**particle-galaxy** → Spiral math formula + HSL color mapping + "use range inputs NOT dat.GUI"
**lorenz-attractor** → RK4 equations verbatim + circular buffer for trail + scale factor (×0.1)
**snake-game** → Direction queue pattern + requestAnimationFrame with delta + food-spawn-safe-cell loop
**markdown-preview** → Debounce pattern + hljs.highlightAll() timing + localStorage key name
**gravity-sim** → Verlet integrator + softening factor ε=5 + collision merge formula + trail circular buffer

## Eliminated candidates and why

| Project | Eliminated because |
|---------|--------------------|
| wip-fourier-visualizer | Spec says Complex. Three synchronized canvases + FFT = multi-session. |
| wip-data-converter | CSV edge cases are a rabbit hole. Column mapping UI is a second hard problem. |
| wip-gradient-generator | Draggable color stops = deceptive complexity (pointer events, clamping). Demoted. |
| wip-password-generator | 80 lines, zero visual impact. Too simple to be "most promising." |
