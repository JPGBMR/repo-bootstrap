# COLOMBO BLUEPRINT — C-009
## sleep-calculator · color-from-image · fake-data-gen

**Agent:** Colombo | **Source:** E-009 | **Priority:** P1
**Date:** 2026-02-22

---

## PRE-FLIGHT: BUGS IN ELENA'S PLAN

Two bugs corrected before Vitalik touches any file. Both are in the spec as written —
not build bugs, spec bugs. The code logic in app.js would be wrong if Vitalik copied
verbatim without these corrections.

---

### [BUG-1] fake-data-gen — `Date` generator uses Math.random()

**File:** E-009 plan, fake-data-gen generators section.

Elena's `Date` generator explicitly uses `Math.random()`:
```js
// BUG — do not ship this line:
const d = new Date(start.getTime() + Math.random() * (end - start));
```

Elena's own spec says: **"Never Math.random(). Not once."**

**Colombo fix — use this instead:**
```js
'Date': () => {
  // Span 2000-01-01 to today in days, pick one crypto-randomly
  const START_YEAR = 2000;
  const totalDays = Math.floor((Date.now() - new Date(START_YEAR, 0, 1)) / 86400000);
  const offsetDays = crypto.getRandomValues(new Uint32Array(1))[0] % totalDays;
  const d = new Date(START_YEAR, 0, 1 + offsetDays);
  return d.toISOString().split('T')[0];
},
```

This is crypto-correct, simple, and avoids BigInt or float precision issues.

---

### [BUG-2] sleep-calculator — sleep-mode acceptance criteria has wrong input

**File:** E-009 plan, sleep-calculator acceptance criteria.

Elena writes:
> "Switch to sleep mode → input `11:00 PM` → wake times show `01:45 AM, 03:15 AM, 04:45 AM, 06:15 AM, 07:45 AM`"

**The code math is correct.** The acceptance criteria input is wrong. Verified:
- `11:00 PM` (1380 min) → produces `2:15 AM, 3:45 AM, 5:15 AM, 6:45 AM, 8:15 AM`
- `10:30 PM` (1350 min) → produces `1:45 AM, 3:15 AM, 4:45 AM, 6:15 AM, 7:45 AM` ✓

**Corrected acceptance criteria:** "Switch to sleep mode → input `10:30 PM` → wake times show `01:45 AM, 03:15 AM, 04:45 AM, 06:15 AM, 07:45 AM`"

The `calcWakeTimes` function as specced is correct. Do not change the code — fix the test input.

---

### [FIX] color-from-image — exportCSS function incomplete

**File:** E-009 plan, `exportCSS` function.

Elena's spec returns only the inner lines:
```js
function exportCSS(colours) {
  return colours.map((c, i) => `  --color-${i+1}: ${c.hex};`).join('\n');
  // comment says "wrapped in :root { ... }" but doesn't wrap
}
```

**Colombo fix — complete implementation:**
```js
function exportCSS(colours) {
  const vars = colours.map((c, i) => `  --color-${i+1}: ${c.hex};`).join('\n');
  return `:root {\n${vars}\n}`;
}
```

Clipboard output must be valid, paste-ready CSS. The `:root {}` wrapper is not optional.

---

### [DECISION] fake-data-gen — multi-column mode: toggle button, not long-press

**Elena's spec:** "UI: each type chip has a '+' indicator when in multi-select mode (toggle via long-press or dedicated button)."

Long-press has no standard web API. `contextmenu` event is touch-unreliable. Implementing custom long-press timers is out of scope for a 90-min build and creates accessibility debt.

**Colombo decision:** Multi-column mode via a single **"Multi" toggle button** next to the chip row. When active, tapping a chip adds it to the selection (up to 4); when inactive, tap = single select. State: `state.multiMode = false`.

This is unambiguous, accessible, and takes ~10 lines of JS.

---

## ARCHITECTURAL NOTES

### E-009 is an unusually complete Elena plan

Elena provided verbatim code for all critical paths: `medianCut()`, `generateLuhn()`,
the full `DATA` object, all 15 `generators{}` entries, export functions, state pattern,
drag-and-drop handlers, and both CI/CD YAML files. Vitalik's job is assembly + UI +
wiring — not algorithm design.

Colombo's role here is corrections (above), decisions (below), and routing.

### Three separate repos — no shared code

All three are independent. No shared vendor/, no monorepo. Each ships as its own
JPGBMR repo with its own CI/CD. No cross-linking required.

### No dependency changes from Elena's plan

| Project | Dependencies | Delivery |
|---|---|---|
| sleep-calculator | Google Fonts CDN (Inter) | 1 `<link>` tag |
| color-from-image | None | Zero CDN |
| fake-data-gen | None | Zero CDN |

Operator "lightweight local solutions" preference: Google Fonts for Inter is a single
DNS preconnect + stylesheet — negligible. The font CSS has `font-display: swap` so
it never blocks render. Acceptable. If Inter fails, `system-ui` covers it.

### Per-project design schemes stand (no operator override on E-009)

Elena's per-project palettes were not overridden by the operator. They ship as
specced: sleep-calculator (dark navy/indigo), color-from-image (warm off-white),
fake-data-gen (terminal dark). Each project has its own `:root` block — no shared
token file across projects.

---

## SPEC ADDENDA (what Elena left ambiguous — Colombo closes)

### sleep-calculator

**"Now" button format:** `new Date()` → format as `HH:MM` (24h, zero-padded).
The `input[type=time]` value attribute is always 24h format regardless of locale.
```js
document.getElementById('now-btn').addEventListener('click', () => {
  const now = new Date();
  const hh = String(now.getHours()).padStart(2, '0');
  const mm = String(now.getMinutes()).padStart(2, '0');
  state.inputTime = `${hh}:${mm}`;
  document.getElementById('time-input').value = state.inputTime;
  render();
});
```

**Best card highlight:** The 5-cycle card (index 3, 0-based) gets class `card--good best`.
Add `data-best="true"` attribute. CSS targets `[data-best]`:
```css
[data-best] {
  border: 2px solid var(--accent);
  box-shadow: 0 0 0 4px rgba(129, 140, 248, 0.15); /* indigo glow */
  transform: scale(1.02);
}
```

**Share button:** show only if `'share' in navigator`. Always present in DOM but
`hidden` attribute when API unavailable. Fallback: copy a pre-formatted text string
to clipboard. No alert() — show inline confirmation "Link copied!".

**Share text format:**
```
Sleep at {bedtime} to wake at {wakeTime} fully rested (5 cycles, 7.5h) 🌙
jpgbmr.github.io/sleep-calculator/
```

**Result grid layout:**
- Mobile (default): single column, cards stack vertically
- Desktop ≥ 640px: `display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 1rem`
  with the best card spanning `grid-column: 2; grid-row: 1 / 3` (centered, taller)

Actually simpler: single column on all sizes — the spec says "single column, max-width 480px". Do not add the desktop 3-column grid. Keep it 1 column. Max-width + margin auto handles centering on desktop naturally. The best card just appears larger in-flow via `padding` and `transform: scale(1.02)`.

**Mode tab UI:** The active tab has `border-bottom: 2px solid var(--accent)` and
`color: var(--accent)`. Inactive tab: `color: var(--muted)`.

---

### color-from-image

**Image preview size:** `max-width: 100%; max-height: 300px; object-fit: contain`.
Show at natural aspect ratio, never stretch.

**Reset button ("↩ New Image"):** Hides `#result`, shows `#drop-zone`,
revokes `URL.createObjectURL` if any, resets `state.colours = []`. Does NOT clear
the file input value (not needed — user picks a new file via drop/browse).

**Swatch grid CSS:**
```css
#palette {
  display: grid;
  grid-template-columns: repeat(4, 1fr); /* 4 cols on mobile (2 rows) */
  gap: 0.75rem;
}
@media (min-width: 480px) {
  #palette {
    grid-template-columns: repeat(8, 1fr); /* 8 across on desktop */
  }
}
```

**Copy feedback (all three copy buttons):** Use a shared `flashCopy(btn)` utility:
```js
function flashCopy(btn, originalText = 'Copy') {
  btn.textContent = '✓ Copied';
  btn.disabled = true;
  setTimeout(() => { btn.textContent = originalText; btn.disabled = false; }, 1500);
}
```

**Swatch copy copies hex only** (not RGB). Copy button label = "Copy", after click = "✓ Copied".

**`toHex` output:** uppercase, with `#` prefix. Example: `#A3B4C5`.
Elena's `toHex` function produces this correctly.

**Error state:** If image fails to load (corrupt file), `img.onerror` fires.
Show a dismissible `.error-banner` inside the drop zone: "Could not read image. Try another file."
Re-show drop zone (do not leave blank state).

---

### fake-data-gen

**Corrected Date generator** (see BUG-1 above — use this version, not Elena's).

**Multi-column mode (Colombo decision):**

State additions:
```js
const state = {
  type: 'Full Name',   // active single type
  types: [],           // active types in multi mode (max 4)
  multiMode: false,    // toggle
  quantity: 10,
  format: 'list',
  results: []
};
```

When `multiMode = true`:
- Chips become checkboxes (toggle add/remove from `state.types`)
- Max 4 types — if 4 already selected, clicking a 5th shows inline warning
- Generate builds one column per type in `state.types`
- `format` forces to `csv` when `multiMode` and `types.length > 1` (list/json don't make sense for multi-column)
- CSV output: first row = type names (header), subsequent rows = one generated value per column

When `multiMode = false`: revert to single `state.type`, all formats available.

**Individual row copy (tap to copy a line):**
```js
// On render, wrap each output line in a span
// User clicks span → copies that line's text
document.getElementById('output').addEventListener('click', e => {
  if (e.target.tagName === 'SPAN') {
    navigator.clipboard.writeText(e.target.textContent.trim());
    e.target.classList.add('flash'); // 300ms highlight
    setTimeout(() => e.target.classList.remove('flash'), 300);
  }
});
```
Output area uses `<pre>` containing `<span>` per line for this to work.
`.flash { background: var(--accent); color: var(--bg); }` transition.

**Quantity slider:** range input min=1, max=100. Adjacent `<output>` element
(not `<span>`) shows live value: `<output for="qty-slider">{n}</output>`.

**Format of Number type:** `randInt(1, 99999)` as Elena specced. Range is not
configurable in V1 — this is explicitly out of scope. File as [DEBT].

**`crypto.randomUUID()` availability:** supported in all modern browsers on HTTPS.
GitHub Pages is HTTPS. No polyfill needed. If Vitalik wants to be safe:
```js
const uuid = () => typeof crypto.randomUUID === 'function'
  ? crypto.randomUUID()
  : // fallback: build UUID from getRandomValues
    ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
      (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16));
```
Include this fallback. Belt and suspenders.

**CSV format for single type:**
```
{type name}
{value 1}
{value 2}
```
First line is the header. Matches Elena's spec.

**CSV format for multi-column:**
```
{type1},{type2},{type3}
{val1},{val2},{val3}
...
```
Headers are the selected type labels joined by commas.

**Download filename pattern:**
- Single: `fake-{type-slug}.{ext}` e.g. `fake-full-name.json`
- Multi: `fake-multicolumn.csv`

---

## FILES (per project — Vitalik creates all)

### sleep-calculator/
```
index.html
style.css
app.js
README.md
.gitignore
.github/workflows/ci.yml     ← copy from repo-bootstrap/templates/ci-html.yml
.github/workflows/cd-pages.yml ← copy from repo-bootstrap/templates/cd-pages.yml
```

### color-from-image/
```
index.html
style.css
app.js
README.md
.gitignore
.github/workflows/ci.yml
.github/workflows/cd-pages.yml
```

### fake-data-gen/
```
index.html
style.css
app.js
README.md
.gitignore
.github/workflows/ci.yml
.github/workflows/cd-pages.yml
```

No `vendor/` directories. No external libraries for any of the three.

---

## README STANDARD (copy for each project, swap placeholders)

```markdown
# {Project Name}

[![Live Demo](https://img.shields.io/badge/Live%20Demo-jpgbmr.github.io-58a6ff?style=flat-square)](https://jpgbmr.github.io/{slug}/)
[![HTML](https://img.shields.io/badge/HTML5-E34F26?style=flat-square&logo=html5&logoColor=white)](https://github.com/JPGBMR/{slug})

{One-line description from Elena's spec}

## Getting Started

Open `index.html` in your browser. No install required.

---
*Part of the [JPGBMR](https://github.com/JPGBMR) open-source portfolio.*
```

---

## ISSUES TO RAISE (on JPGBMR/repo-bootstrap)

```
[BUG]  fake-data-gen — Date generator uses Math.random() in Elena's spec  priority:p1 type:bug
[BUG]  sleep-calculator — sleep-mode AC has wrong input (11:00 PM → should be 10:30 PM)  priority:p2 type:bug
[FIX]  color-from-image — exportCSS missing :root{} wrapper  priority:p1 type:fix
[DECISION] fake-data-gen — multi-column mode via toggle button, not long-press  type:decision
[SPEC] sleep-calculator — build and deploy to JPGBMR/sleep-calculator  priority:p1 vitalic:ready stack:html effort:small
[SPEC] color-from-image — build and deploy to JPGBMR/color-from-image  priority:p1 vitalic:ready stack:html effort:medium
[SPEC] fake-data-gen — build and deploy to JPGBMR/fake-data-gen  priority:p1 vitalic:ready stack:html effort:medium
[DEBT] jpgbmr-site — app.js must be generated; manually add 3 cards after this sprint  priority:p3 type:debt
[DEBT] fake-data-gen — Number type range is hardcoded 1-99999; no user config in V1  priority:p3 type:debt
```

---

## BUILD SEQUENCE

```
1. sleep-calculator    (30 min, pure math, 0 deps, lowest risk — start here)
2. color-from-image    (60 min, algorithm provided verbatim, Canvas API)
3. fake-data-gen       (90 min, largest UI, multi-column adds complexity)

All three are independent — Vitalik can build in parallel if two sessions available.
Recommended sequential order above if solo.

Per project:
  a. Build index.html, style.css, app.js locally
  b. gh repo create JPGBMR/{name} --public --description "..."
  c. git init && git add . && git commit -m "feat: initial release — {name}"
  d. git remote add origin https://github.com/JPGBMR/{name}.git && git push -u origin main
  e. gh api repos/JPGBMR/{name}/pages -X POST -f "source[branch]=main" -f "source[path]=/"
  f. Add repo topics: html javascript web-app open-source
  g. Wait for CI green + Pages deploy
  h. Manually add entry to jpgbmr-site/app.js PROJECTS array

Post-sprint: update CLAUDE.md — move 3 names from wip- list to Live section.
```

---

## RISKS AND NOTES

**sleep-calculator:**
- `input[type=time]` renders a native time picker — styling is browser-controlled.
  Use `appearance: none` and style width/height/font only. Do not try to replace it
  with a custom picker — out of scope and breaks mobile UX.
- The 5-cycle "best" card is identified by index (cycles === 5), not by position in
  the array. `results[3]` (0-indexed) is always the 5-cycle entry. Use
  `data-cycles={cycles}` on each card and target `[data-cycles="5"]` in CSS.
- Web Share API: `navigator.share()` can throw on desktop Safari (shares require
  user gesture AND supported content types). Wrap in try/catch. On throw, fall
  through to clipboard fallback silently.

**color-from-image:**
- `medianCut()` is recursive with depth 3 → 8 calls. For a 100×100 canvas (10,000
  pixels), this runs in <5ms. No performance concern. Do not add a Web Worker.
- The algorithm sorts `pixels` in-place with `.sort()`. For large slices this mutates
  shared array references. Since we call `medianCut(pixels, 3)` once on the full
  pixel array and then discard it, mutation is fine. Do not add `.slice()` guards
  for performance — unnecessary at 10k pixels.
- GIF support: `<input accept="image/*">` allows GIF. Canvas will render the first
  frame. Animated GIFs are fine — only frame 1 is sampled. No special handling needed.
- CORS: user uploads a local file via FileReader — no CORS issue. Only cross-origin
  `<img src="url">` triggers CORS on canvas. Since we're loading from FileReader
  data URLs, `canvas.getImageData()` is always safe.

**fake-data-gen:**
- `crypto.getRandomValues` on `Uint32Array` returns values 0–4294967295.
  `% arr.length` introduces modulo bias when arr.length doesn't divide evenly into
  2^32. For array lengths < 1000, bias is < 0.03% — acceptable for fake data.
  Do not add rejection sampling — overkill for this use case.
- Luhn algorithm: Elena's implementation generates valid Luhn digits. The label
  "(VISA test)" is mandatory — prevents user confusion with real cards. Never omit it.
- UUID v4 from `crypto.randomUUID()` is always RFC 4122 compliant on HTTPS.
  Include the fallback (see spec addenda) for belt-and-suspenders safety.
- `<pre>` output with `<span>` per line: `white-space: pre-wrap; word-break: break-all`
  to prevent horizontal scroll on long lines (UUIDs, addresses).

---

## MESSAGE TO VITALIK

```
READ FIRST — two bugs in the E-009 spec, fix before you write a line:
1. fake-data-gen: Date generator uses Math.random(). Replace with the
   crypto version in this blueprint. Do not ship the Elena version.
2. sleep-calculator: AC says "input 11:00 PM" but the expected wake times
   match "10:30 PM". The code is correct. Use 10:30 PM when you verify.

BUILD ORDER:
1. sleep-calculator     — math is 40 lines, UI is 60 lines. First ship.
2. color-from-image     — copy medianCut() verbatim. Wire FileReader → canvas
                          → medianCut → swatches → export buttons.
3. fake-data-gen        — copy DATA object + generators verbatim. Add UI + multi-mode.

WATCH OUT FOR:
- sleep: "now" button sets input value as 24h "HH:MM" string (e.g. "14:30")
- sleep: 5-cycle best card selected by data-cycles="5", not by array index
- sleep: Web Share API must be in try/catch — throws on some desktop browsers
- color: medianCut sorts in-place — this is fine, don't add .slice() guard
- color: exportCSS must wrap in :root {} — Elena's spec is missing this wrapper
- color: image.onerror must show error state in drop zone (corrupt file case)
- fake: Multi mode uses toggle button (not long-press) — see blueprint decision
- fake: UUID fallback for browsers without crypto.randomUUID — include it
- fake: <pre> output wraps at word boundaries — use white-space: pre-wrap
- ALL: Never Math.random() — crypto.getRandomValues everywhere
- ALL: pointer events (not mouse events) on interactive elements
- ALL: try/catch on all localStorage reads

DO NOT:
- Do not try to style input[type=time] beyond width/height/font — browser owns it
- Do not add Web Worker to color-from-image — 10k pixels at depth 3 is <5ms
- Do not add configurable range to Number type — V1, file as debt, ship it
- Do not use setInterval or setTimeout for anything except 1.5s copy confirmation
- Do not add a framework. Not even Alpine. Not even Preact.

DONE WHEN:
- 3 repos on JPGBMR with CI green and Pages live
- sleep: 7:00 AM wake → bedtimes include 11:15 PM (5 cycles) as best card
- sleep: 10:30 PM sleep mode → first card shows 1:45 AM
- color: sunset JPEG returns warm orange/red/purple palette in 8 swatches
- color: "Copy CSS Variables" clipboard contains valid :root { --color-1: #...; } block
- fake: 20 emails generated, all look plausible (name@domain.tld)
- fake: UUID output matches /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
- fake: Luhn check — all credit cards in output pass Luhn algorithm
- fake: CSV format has header row matching type name
- 3 new entries added to jpgbmr-site/app.js PROJECTS array
- CLAUDE.md updated: 3 names moved from wip- to Live section
```
