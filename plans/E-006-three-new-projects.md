# ELENA — Task Plan E-006
## Three New Projects: URL Shortener · Image Compressor · Unit Converter

---

```
[CONTEXT]
wip-unit-converter already exists with a basic spec (6 categories, functional but plain).
The new version requested here supersedes it — same concept but built to a higher standard.
The wip- folder should be removed from disk after this plan ships.
```

```
[ASSUMPTION]
"Amazing" = production-quality UX, not just functional code. That means:
smooth transitions, thoughtful empty states, mobile-first layout that works at 320px,
44px minimum touch targets, copy-to-clipboard with visual feedback, drag-and-drop where
relevant, localStorage for persistence, and zero loading spinners for local operations.
Colombo must encode all of this in the blueprint — Vitalik should not be making design
decisions mid-build.
```

```
[ASSUMPTION]
URL Shortener: a pure frontend tool cannot create short URLs without calling an
external service. Using the is.gd free API (no auth, CORS-safe):
  GET https://is.gd/create.php?format=json&url={encodedURL}
This is the correct tech choice. No backend needed. Fallback: tinyurl.com/api-create.php.
Colombo must spec both endpoints with the fallback logic.
```

```
[ENHANCEMENT]
URL Shortener: adding QR code generation per shortened URL via qrcode.js CDN.
Every shortened link gets an instant QR — one-click download as PNG.
High value addition, zero complexity cost. Proceeding.
```

```
[ENHANCEMENT]
Image Compressor: adding WebP output alongside JPEG.
Canvas toBlob() supports 'image/webp' natively in all modern browsers.
WebP typically achieves 25-35% better compression than JPEG at equal quality.
Adding WebP toggle costs ~5 lines. Proceeding.
```

---

```json
{
  "agent": "elena",
  "type": "task_plan",
  "plan_id": "E-006",
  "timestamp": "2026-02-22T00:00:00Z",
  "operator_request": "Build URL shortener, image compressor, unit converter — brand new, amazing, frontend JS, mobile-first. Colombo architects knowing our best tech stack.",
  "interpreted_intent": "Build three new portfolio-grade HTML/CSS/JS projects. Each must be genuinely useful, visually polished, mobile-first, and showcase Vitalik's best frontend work. No frameworks, no build step, no backend. Colombo closes every design decision in the blueprint.",
  "priority": "p1",
  "target_account": "JPGBMR",

  "tasks": [

    {
      "task_id": "E-006-01",
      "title": "url-shortener — paste URL, get short link + QR code",
      "description": "Build a URL shortener frontend. Single index.html. Stack: HTML5 + CSS custom properties + vanilla JS + qrcode.js CDN. Two CDN dependencies only: qrcode.js (QR generation) — no others.\n\nCORE FLOW: User pastes or types a long URL → clicks Shorten → app calls is.gd API → displays short URL → copy-to-clipboard button + QR code rendered inline → one-click QR download as PNG.\n\nFEATURES:\n1. URL input field — full width, large, with inline 'Paste' button that reads clipboard\n2. Shorten button — disabled until valid URL entered (basic regex validation)\n3. Result card: short URL (large text), copy button with checkmark animation on click, QR code (128×128), download QR button\n4. History panel: last 10 shortened URLs stored in localStorage — each card shows original (truncated), short URL, copy button, QR thumbnail, timestamp\n5. Clear history button\n6. Error states: invalid URL (inline), API failure (retry button + fallback to tinyurl API)\n7. Character counter on input (URLs >2048 chars warn the user)\n8. Loading state: spinner on the Shorten button while API call is in-flight\n\nMOBILE-FIRST LAYOUT:\n- Single column, max-width 600px centered on desktop\n- Input + button stacked vertically on mobile, inline on desktop ≥ 480px\n- History cards: full width, scrollable list\n- QR code below result URL on all breakpoints\n\nANIMATIONS: result card slides in from below on success (CSS transform + opacity transition, 200ms). Copy checkmark fades in/out (300ms). No JS animation libraries.\n\nAPI CALLS:\n  Primary:  GET https://is.gd/create.php?format=json&url={encodeURIComponent(url)}\n  Fallback: GET https://tinyurl.com/api-create.php?url={encodeURIComponent(url)} (returns plain text)\n  Fallback triggers on: HTTP error, network failure, or is.gd JSON error field present\n\nCOLOR SCHEME: Deep navy background (#0D1117), electric blue accent (#2F81F7), white text, card background (#161B22). Matches GitHub dark tone — fits the JPGBMR brand.",
      "stack": "html",
      "scope": "url-shortener (new repo)",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/url-shortener/ loads. Pasting a valid URL and clicking Shorten returns a short link within 3s. Copy button works. QR renders and downloads as PNG. History persists on refresh. Invalid URL input shows inline error. Mobile layout renders correctly at 375px viewport.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "medium",
      "files_affected": [
        "index.html",
        "style.css",
        "app.js",
        "README.md",
        ".gitignore",
        ".github/workflows/ci.yml",
        ".github/workflows/cd-pages.yml"
      ],
      "pre_flight_fixes": [],
      "risks": [
        "is.gd CORS: confirmed CORS-safe for browser requests — no proxy needed",
        "tinyurl fallback returns plain text not JSON — parse accordingly",
        "QR download: use canvas.toDataURL() + programmatic anchor click — not window.open()",
        "Clipboard read (paste button): requires navigator.clipboard.readText() — needs HTTPS (Pages provides this)",
        "localStorage: JSON.parse on corrupt data must be wrapped in try/catch with silent reset"
      ],
      "out_of_scope": [
        "Custom slug input, analytics/click tracking, link expiry, user accounts, backend of any kind",
        "Bulk URL shortening"
      ]
    },

    {
      "task_id": "E-006-02",
      "title": "image-compressor — drag-drop compress with before/after + WebP",
      "description": "Build a browser-native image compressor using the Canvas API. Single index.html. Stack: HTML5 Canvas + CSS + vanilla JS + JSZip CDN (batch download only). Zero other dependencies.\n\nCORE FLOW: User drops or selects image(s) → each image is drawn to an offscreen canvas → re-encoded at selected quality → output shown with file size comparison → download individually or batch.\n\nFEATURES:\n1. Drop zone: full-width dashed border area, accepts image/* files. Click-to-browse fallback. Accepts up to 10 files simultaneously.\n2. Per-image processing card (added to page as each file loads):\n   a. Before/After split-view: single image with a draggable divider line — left = original, right = compressed (CSS clip-path approach, no canvas layering)\n   b. Original size, compressed size, reduction % badge (green if >20% saving, orange if <20%)\n   c. Format selector: JPEG | WebP (default JPEG)\n   d. Quality slider: 0–100 (default 80). Updates preview live on slider change (debounced 150ms)\n   e. Dimensions display: W×H px\n   f. Download button for individual file\n   g. Remove card button (×)\n3. Global controls (top of page): Quality preset buttons (Low 40 / Medium 70 / High 85 / Lossless — applies to all cards), Download All (JSZip batch), Clear All\n4. Output filenames: {original-name}-compressed.jpg or .webp\n\nMOBILE-FIRST LAYOUT:\n- Drop zone: 160px tall on mobile, 240px on desktop\n- Cards: full-width stacked column\n- Before/after divider: touch-draggable (pointer events, not mouse-only)\n- Quality slider: full width, large touch target (height: 32px)\n- Global controls: sticky top bar on scroll\n\nCANVAS COMPRESSION LOGIC:\n  1. FileReader.readAsDataURL() → new Image() → drawImage to offscreen canvas\n     at original dimensions (no resize unless user requests it)\n  2. canvas.toBlob(callback, 'image/jpeg'|'image/webp', quality/100)\n  3. Create object URL from blob → display in right side of split view\n  4. File size = blob.size, format as KB or MB\n\nBEFORE/AFTER IMPLEMENTATION:\n  Both images loaded as CSS background-image on two absolutely-positioned divs\n  inside a relative container. Clip-path: inset(0 X% 0 0) on the overlay div,\n  where X is controlled by a range input overlaid on the image. No canvas needed\n  for the split display.\n\nCOLOR SCHEME: Dark charcoal (#1A1A2E), purple accent (#7B2FBE), white cards with\nsubtle border. Drop zone: dashed border pulses on dragover (CSS animation).",
      "stack": "html",
      "scope": "image-compressor (new repo)",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/image-compressor/ loads. Dropping a JPEG renders a before/after comparison. Quality slider updates compressed size in real-time. WebP toggle changes output format. Download saves the compressed file. Batch download (3 files) produces a ZIP. Works on mobile at 375px with touch-draggable divider.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "large",
      "files_affected": [
        "index.html",
        "style.css",
        "app.js",
        "README.md",
        ".gitignore",
        ".github/workflows/ci.yml",
        ".github/workflows/cd-pages.yml"
      ],
      "pre_flight_fixes": [],
      "risks": [
        "PNG input: canvas re-encodes PNG as JPEG (lossy) — warn the user with a banner when PNG is detected",
        "Large images (>20MB): drawImage blocks the main thread — use createImageBitmap() which is async and off-thread",
        "WebP support: all modern browsers support canvas toBlob webp — no polyfill needed, but add feature detection",
        "JSZip CDN: use jsdelivr (https://cdn.jsdelivr.net/npm/jszip) — always pinned to a version in the blueprint",
        "Object URLs: call URL.revokeObjectURL() when card is removed to prevent memory leaks",
        "iOS Safari: drag-and-drop is not supported — click-to-browse must always be present and obvious"
      ],
      "out_of_scope": [
        "Image resize/crop, filters, background removal, format conversion beyond JPEG/WebP",
        "PNG lossless compression (requires pngquant — needs WASM, out of scope)",
        "Server-side processing"
      ]
    },

    {
      "task_id": "E-006-03",
      "title": "unit-converter — multi-category converter with search and formula display",
      "description": "Build a production-grade unit converter. Supersedes wip-unit-converter. Single index.html. Stack: HTML5 + CSS + vanilla JS. Zero dependencies.\n\nCATEGORIES (10 total):\n  Length     | mm, cm, m, km, in, ft, yd, mi, nautical mile, light year\n  Weight     | mg, g, kg, t (metric ton), oz, lb, stone, short ton\n  Temperature| °C, °F, K, °R (Rankine)\n  Speed      | m/s, km/h, mph, knots, mach (sea level)\n  Area       | mm², cm², m², km², in², ft², yd², acre, hectare\n  Volume     | ml, cl, dl, l, m³, tsp, tbsp, fl oz, cup, pt, qt, gal (US), gal (UK)\n  Time       | ms, s, min, h, day, week, month (avg), year, decade\n  Data       | bit, byte, KB, MB, GB, TB, PB (both SI and binary — toggle)\n  Energy     | J, kJ, cal, kcal, Wh, kWh, BTU, eV\n  Pressure   | Pa, kPa, MPa, bar, psi, atm, mmHg, inHg\n\nCORE CONVERSION ENGINE:\n  - Each category stores all units as conversion factors TO a base unit\n  - Convert: value → base unit (÷ from_factor) → target unit (× to_factor)\n  - Temperature: special-cased (offset + scale, not pure multiplication)\n  - All factors stored as exact decimal or fraction constants in a JS object\n\nFEATURES:\n1. Category selector: icon grid (10 icons, SVG inline) — selected category highlighted\n2. Conversion panel:\n   a. FROM: number input + unit dropdown\n   b. Large ↔ swap button (swaps units AND values)\n   c. TO: result display (read-only, auto-updates) + unit dropdown\n   d. Copy result button\n3. Formula display panel (below conversion): shows the conversion formula used,\n   e.g. '1 km = 1000 m' or 'F = C × 9/5 + 32'\n4. Quick-reference table: top 5 most useful conversions for selected category\n   (e.g. for Length: 1 in = 2.54 cm, 1 ft = 30.48 cm, 1 mi = 1.609 km, etc.)\n5. Search: type any unit name in a search input → filters both dropdowns live\n6. Favorite pairs (★ button): save FROM/TO unit pair to localStorage — appears\n   as quick-launch chips below the search box\n7. Input: accepts commas as decimal separator (European users), strips them before parsing\n8. Precision selector: 2 / 4 / 6 / 10 decimal places\n\nMOBILE-FIRST LAYOUT:\n- Category selector: horizontal scrollable icon row (no wrap) on mobile,\n  2-column grid on ≥ 480px, 5-column grid on ≥ 768px\n- Conversion panel: single column stack on mobile (FROM → swap → TO vertical)\n  Side-by-side on ≥ 600px\n- Formula panel: collapsible accordion on mobile (tap to expand)\n- Quick reference table: horizontal scroll on mobile\n\nANIMATIONS:\n- Category switch: result fades (opacity 1→0→1, 150ms) while new units load\n- Swap button: 180° rotate on click (CSS transform, 200ms)\n- Copy button: checkmark for 1.5s then reverts\n- Category icon: scale(1.05) + accent border on hover/active\n\nCOLOR SCHEME: Clean white/off-white cards (#FAFAFA) on light grey background (#F0F0F0).\nAccent: vibrant teal (#00B4A6). Mobile-first, feels like a native app.\nSwitchable dark mode via CSS custom properties + prefers-color-scheme media query.",
      "stack": "html",
      "scope": "unit-converter (new repo) — wip-unit-converter folder deleted after this ships",
      "action_type": "create",
      "acceptance_criteria": "https://jpgbmr.github.io/unit-converter/ loads with category grid. Selecting Length, entering 100 in km → mi shows 62.1371. Swap reverses units and values. Search for 'mile' filters dropdowns. Formula panel shows correct formula. Favorites saved and restored. Dark mode applies from system preference. Works at 320px viewport width.",
      "depends_on": ["E-004-01"],
      "estimated_effort": "large",
      "files_affected": [
        "index.html",
        "style.css",
        "app.js",
        "README.md",
        ".gitignore",
        ".github/workflows/ci.yml",
        ".github/workflows/cd-pages.yml"
      ],
      "pre_flight_fixes": [
        "Delete wip-unit-converter folder from local disk after this ships — it is superseded"
      ],
      "risks": [
        "Temperature conversion must be special-cased — it cannot use the base-unit factor pattern",
        "Data units: SI (1 KB = 1000 bytes) vs binary (1 KiB = 1024 bytes) — add a toggle, default to SI",
        "Floating point precision: 1/3 conversions produce long decimals — always apply toFixed(precision) before display, never show raw float",
        "Mach speed varies with altitude/temperature — use sea-level standard (340.29 m/s)",
        "Search: filter must match both unit name and common abbreviation (e.g. 'lb' must match 'pound')"
      ],
      "out_of_scope": [
        "Currency conversion (requires live API, out of scope for offline tool)",
        "Custom unit creation, cooking-specific units, astronomical units beyond light year",
        "Historical unit systems (cubits, furlongs — add later if requested)"
      ]
    }

  ],

  "build_sequence": "All three are fully independent. Run in parallel after E-004-01 (CI injection) is complete. If sequential, recommended order: unit-converter (pure logic, warmup) → url-shortener (API integration) → image-compressor (Canvas API, most complex).",

  "done_when": "Three repos live on JPGBMR. Three GitHub Pages URLs return 200 and are fully functional. CI green on all three main branches. Lighthouse ≥ 90 performance on unit-converter and url-shortener. ≥ 85 on image-compressor (Canvas operations cost). wip-unit-converter folder removed from local disk.",

  "elena_notes": "Colombo — three things to lock down before Vitalik touches anything:\n\n1. URL-SHORTENER: include the exact is.gd and tinyurl endpoint URLs + the fallback trigger logic in the blueprint. Vitalik must not guess which API to hit first or how to detect failure.\n\n2. IMAGE-COMPRESSOR: the before/after split-view implementation must be specced exactly — clip-path CSS approach, NOT two canvases. Two canvases require synchronizing zoom/pan and will balloon scope. Clip-path is 10 lines of CSS.\n\n3. UNIT-CONVERTER: all 10 category conversion tables (unit name → base factor) must be in the blueprint as a JS object literal. Do not make Vitalik look up 80 conversion factors — supply them. Temperature special-case formula must also be explicitly specced.\n\nAll three projects follow the same 3-file structure: index.html + style.css + app.js. Colombo should spec CSS custom properties at the top of style.css for all color/spacing tokens — this enforces design consistency and makes dark mode trivial."
}
```

---

## Colombo Architecture Notes (outside the JSON)

### Stack decision — why no frameworks

These three projects are portfolio tools, not apps. The constraint is a feature:
- Zero build step = instant contribution from anyone (including Flavio)
- No node_modules = no supply chain risk, no version rot
- Single index.html = deployable by dragging to any web server
- Vanilla JS = readable by any developer without framework knowledge

React/Vue for these would add 150KB of overhead to tools that need 8KB of logic.
That is an embarrassing trade. Colombo knows this. Vitalik agrees violently.

### CSS Architecture (apply to all three)

```css
:root {
  /* All colors, spacing, radii as custom properties */
  --color-bg: #0D1117;        /* or per-project scheme */
  --color-accent: #2F81F7;
  --color-card: #161B22;
  --radius-card: 12px;
  --space-md: 1rem;
  --transition-fast: 150ms ease;
  --transition-base: 200ms ease;
}

/* Mobile base styles first — NO min-width media query for base */
/* Desktop enhancement at 480px, 768px only */
@media (min-width: 480px) { ... }
@media (min-width: 768px) { ... }
```

### JS Architecture (apply to all three)

No classes. No IIFE wrappers. Modern ES6 modules or clean top-level functions.
State lives in plain objects, not DOM queries.
One source of truth per piece of data — never read state from the DOM.

```js
// Pattern Colombo specifies for all three:
const state = { /* all app state here */ };
function render() { /* DOM reflects state, never the reverse */ }
function handleEvent(e) { /* update state → call render() */ }
```

### Per-project CDN dependencies (pinned versions — Colombo locks these)

| Project | Dependency | CDN URL pattern |
|---------|-----------|-----------------|
| url-shortener | qrcode.js 1.5.3 | jsdelivr, pinned |
| image-compressor | JSZip 3.10.1 | jsdelivr, pinned |
| unit-converter | none | — |
