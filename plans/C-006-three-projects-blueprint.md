# COLOMBO BLUEPRINT — C-006
## Three New Projects: URL Shortener · Image Compressor · Unit Converter

**Agent:** Colombo | **Source:** E-006 | **Priority:** P1 | **Effort:** Large (3 projects)
**Date:** 2026-02-22

---

## ATHENA DECISIONS — RESOLVED BEFORE BUILD

### D-01: CI Template Drift — inject-workflows.sh force flag
**Decision: ADD `--force` flag.**

Without it, 34 repos are permanently locked to C-003 templates (no pip cache, no
http-server for Lighthouse, no `feat/**` trigger). Every future template improvement
would require a separate spec. The --force flag makes inject-workflows.sh the
canonical upgrade mechanism.

Vitalik adds one `--force` check at the top of inject-workflows.sh:
```bash
FORCE=false
[[ "$1" == "--force" ]] && FORCE=true
# In per-repo loop:
if [[ -f ".github/workflows/ci.yml" && "$FORCE" == "false" ]]; then
  log_state "$repo" "inject-workflows" "skip" "ci.yml exists, use --force to overwrite"
  continue
fi
```
Default behavior unchanged — safe re-run. `--force` overwrites. pipeline-state.json
records both paths. Colombo raises `[DECISION] inject-workflows.sh — --force flag added`
issue for audit trail.

### D-02: preflight.sh OPEN_PR — WARN not EXIT 1
**Decision: CHANGE to WARN + exit 0.**

With C-003 Rule 1 (CI pushed to feature branches), open PRs are handled by
inject-workflows.sh. Blocking preflight on open PRs makes it unusable during
normal development. The meaningful errors are structural, not transient.

New preflight.sh exit logic:
```
EXIT 1 conditions (hard blockers — nothing runs):
  - Repo missing on JPGBMR
  - Default branch is not 'main' (master/other)
  - Required local template file missing

WARN + continue (print list, exit 0):
  - Open PRs on any repo (list them, do not block)
```

---

## IMMEDIATE BUG STATUS

**Athena reported:** app.js missing password-generator, index.html shows "34 projects".
**Status:** ALREADY FIXED in local files. app.js line 27 has password-generator entry.
index.html reads "35 live projects". No Vitalik action needed. Closing this item.

---

## OPERATOR OVERRIDES APPLIED (from user message, 2026-02-22)

All three E-006 projects are modified from Elena's spec as follows:

| Override | Elena spec | Colombo override |
|---|---|---|
| Aesthetic | Per-project dark color schemes (navy/purple/teal) | Clean black-and-white for all three |
| Math library | math.js suggested | Rejected — 900KB. Pure JS factor tables |
| Unit categories | Elena's 10 categories | Revised to 10 practical categories (see C-006-03) |
| Dependencies | CDN delivery | Vendor locally (qrcode.js + JSZip downloaded to vendor/) |
| Architecture | Elena's approach maintained | Lightweight-first: no frameworks, no bundler |

---

## SHARED CSS TOKEN SPEC (apply to all three projects)

All three `style.css` files MUST open with this `:root` block verbatim.
Colors are B&W only. Dark mode is automatic via `prefers-color-scheme`.

```css
/* ─── Design Tokens ─────────────────────────────────────── */
:root {
  --bg:           #ffffff;
  --bg-secondary: #f5f5f5;
  --border:       #e0e0e0;
  --text:         #111111;
  --text-muted:   #666666;
  --text-faint:   #999999;
  --card:         #ffffff;
  --shadow:       0 1px 3px rgba(0,0,0,0.10), 0 1px 2px rgba(0,0,0,0.06);
  --shadow-lg:    0 4px 12px rgba(0,0,0,0.12);
  --accent:       #111111;
  --accent-hover: #333333;
  --accent-text:  #ffffff;
  --danger:       #cc0000;
  --success:      #006600;
  --r-sm: 4px;
  --r-md: 8px;
  --r-lg: 12px;
  --sp-xs: 0.25rem;
  --sp-sm: 0.5rem;
  --sp-md: 1rem;
  --sp-lg: 1.5rem;
  --sp-xl: 2rem;
  --t-fast: 150ms ease;
  --t-base: 200ms ease;
  --t-slow: 300ms ease;
  --font: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --mono: 'Courier New', Courier, monospace;
}

@media (prefers-color-scheme: dark) {
  :root {
    --bg:           #111111;
    --bg-secondary: #1a1a1a;
    --border:       #2e2e2e;
    --text:         #f0f0f0;
    --text-muted:   #aaaaaa;
    --text-faint:   #555555;
    --card:         #1a1a1a;
    --shadow:       0 1px 3px rgba(0,0,0,0.40);
    --shadow-lg:    0 4px 12px rgba(0,0,0,0.50);
    --accent:       #f0f0f0;
    --accent-hover: #cccccc;
    --accent-text:  #111111;
  }
}

/* ─── Reset & Base ───────────────────────────────────────── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 16px; }
body {
  font-family: var(--font);
  background: var(--bg);
  color: var(--text);
  line-height: 1.5;
  min-height: 100dvh;
}

/* ─── Mobile-first breakpoints ──────────────────────────── */
/* Base styles: 320px+. Enhance at 480px and 768px.        */
/* @media (min-width: 480px) { ... }                        */
/* @media (min-width: 768px) { ... }                        */
```

---

## JS ARCHITECTURE PATTERN (apply to all three)

```js
// Single state object — all app data lives here, not in the DOM.
const state = {};

// Render reads from state and updates DOM.
function render() {}

// Event handlers update state then call render().
function handleSomeEvent(e) {
  // update state
  render();
}

// Init: set initial state, attach all listeners, call render().
function init() {
  render();
}

document.addEventListener('DOMContentLoaded', init);
```

No classes. No IIFE. No global leaks. One `state` object per file.

---

## SPECS

---

### C-006-01 — url-shortener

**Effort:** medium | **Stack:** html | **Repo:** JPGBMR/url-shortener (new)

#### Files

| File | Action | Purpose |
|---|---|---|
| `index.html` | create | Single-page app shell, no JS logic |
| `style.css` | create | B&W tokens + component styles |
| `app.js` | create | All app logic |
| `vendor/qrcode.min.js` | create | qrcode.js 1.5.3, downloaded from jsdelivr, vendored locally |
| `README.md` | create | Standard README with Live Demo badge |
| `.gitignore` | create | Standard web .gitignore |
| `.github/workflows/ci.yml` | create | Copy from repo-bootstrap/templates/ci-html.yml |
| `.github/workflows/cd-pages.yml` | create | Copy from repo-bootstrap/templates/cd-pages.yml |

#### index.html Structure

```
<head>
  meta charset, viewport, title="URL Shortener", description
  <link rel="stylesheet" href="style.css">
  <!-- qrcode.js vendored locally -->
  <script src="vendor/qrcode.min.js"></script>
</head>
<body>
  <header>
    <h1>URL Shortener</h1>
    <p class="subtitle">Paste a long URL. Get a short one.</p>
  </header>

  <main>
    <!-- Input section -->
    <section class="input-section">
      <div class="input-row">
        <input id="url-input" type="url" placeholder="https://example.com/very/long/url"
               autocomplete="off" spellcheck="false" maxlength="2048">
        <button id="paste-btn" type="button">Paste</button>
      </div>
      <div id="url-error" class="error-msg" aria-live="polite" hidden></div>
      <div id="char-counter" class="char-counter" aria-live="polite"></div>
      <button id="shorten-btn" type="button" disabled>Shorten</button>
    </section>

    <!-- Result card (hidden until success) -->
    <section id="result-card" class="result-card" hidden>
      <a id="short-url" href="#" target="_blank" rel="noopener noreferrer"></a>
      <div class="result-actions">
        <button id="copy-btn" type="button">Copy</button>
        <button id="download-qr-btn" type="button">Download QR</button>
      </div>
      <div id="qr-container"></div>
    </section>

    <!-- History panel -->
    <section class="history-section">
      <div class="history-header">
        <h2>Recent</h2>
        <button id="clear-history-btn" type="button">Clear</button>
      </div>
      <ul id="history-list" role="list"></ul>
    </section>
  </main>

  <script src="app.js"></script>
</body>
```

#### app.js Logic Spec

**State object:**
```js
const state = {
  inputValue: '',    // current text in #url-input
  isLoading: false,  // true while API call in-flight
  result: null,      // { shortUrl, longUrl, qrCanvas } or null
  history: [],       // array of { shortUrl, longUrl, ts }, max 10, from localStorage
  error: null        // string or null
};
```

**URL validation:** Simple regex test before enabling Shorten button.
Pattern: `^https?:\/\/.+\..+` — accepts any http/https URL with a TLD.
Character limit warning: if input.length > 2000, show warning in #char-counter.
Shorten button enables only when: URL passes regex AND input.length <= 2048.

**API call logic (in order):**
```
PRIMARY:  GET https://is.gd/create.php?format=json&url={encodeURIComponent(url)}
  Response: { "shorturl": "https://is.gd/..." } on success
            { "errorcode": N, "errormessage": "..." } on error

FALLBACK triggers when:
  1. fetch() throws (network failure)
  2. HTTP status is not 200-299
  3. JSON response contains an "errorcode" field

FALLBACK: GET https://tinyurl.com/api-create.php?url={encodeURIComponent(url)}
  Response: plain text — the short URL string (e.g. "https://tinyurl.com/abc123")
  Parse with: response.text() — not response.json()
  Error detection: if text starts with "Error" → treat as failure
```

**Loading state:** While API is in-flight, set `state.isLoading = true`. render()
adds `aria-busy` to #shorten-btn, replaces button text with "Shortening…", disables
the button. On completion (success or fail), `state.isLoading = false`.

**Result card:**
- Short URL displayed as a clickable `<a>` tag, opens in new tab
- Copy button: calls `navigator.clipboard.writeText(state.result.shortUrl)`.
  On success: button text changes to "Copied ✓" for 1500ms then reverts.
  Fallback for no clipboard API: create temp textarea, select, execCommand('copy').
- QR generation: `new QRCode(document.getElementById('qr-container'), { text: shortUrl, width: 128, height: 128, colorDark: '#111111', colorLight: '#ffffff' })`
- QR download: get the `<canvas>` or `<img>` qrcode.js renders. Call `canvas.toDataURL('image/png')`. Create a hidden `<a>` with `download="qr-code.png"`, set href to data URL, trigger `.click()`.

**Result card animation:** Card starts with `transform: translateY(16px); opacity: 0`.
On show: remove `hidden`, then on next frame set `transform: translateY(0); opacity: 1`
with `transition: transform var(--t-base), opacity var(--t-base)`.

**History:**
- Load from `localStorage.getItem('url_shortener_history')` on init. JSON.parse wrapped in try/catch — silent reset to `[]` on error.
- After each successful shorten: prepend to `state.history`, truncate to 10 items, write back to localStorage (`JSON.stringify(state.history)`).
- Each history item renders as `<li>` with: truncated longUrl (max 40 chars + "…"), short URL as `<a>`, copy button, mini QR (64×64), timestamp formatted as `"X min ago"` or date string.
- Clear button: `state.history = []`, clear localStorage key, re-render.

**Edge cases:**
- Clipboard paste button: `navigator.clipboard.readText()`. Catch error (permission denied) — show "Paste blocked by browser, use Ctrl+V" as #url-error for 2s.
- QR canvas race: qrcode.js renders async. Use `setTimeout(findCanvas, 100)` to locate the canvas/img after QR generation before attempting download.
- localStorage corrupt: any JSON.parse failure resets to `[]` and rewrites key.

#### Acceptance Criteria
- Paste a valid URL → Shorten → short link appears with QR within 3s
- Copy button works + shows confirmation animation
- QR downloads as PNG with correct content
- History survives page refresh
- Invalid URL input keeps button disabled, shows inline error
- Mobile layout correct at 375px

---

### C-006-02 — image-compressor

**Effort:** large | **Stack:** html | **Repo:** JPGBMR/image-compressor (new)

#### Files

| File | Action | Purpose |
|---|---|---|
| `index.html` | create | App shell |
| `style.css` | create | B&W tokens + component styles |
| `app.js` | create | All compression logic |
| `vendor/jszip.min.js` | create | JSZip 3.10.1, vendored locally |
| `README.md` | create | Standard README with Live Demo badge |
| `.gitignore` | create | Standard web .gitignore |
| `.github/workflows/ci.yml` | create | Copy from templates/ci-html.yml |
| `.github/workflows/cd-pages.yml` | create | Copy from templates/cd-pages.yml |

#### index.html Structure

```
<head>
  meta charset, viewport, title="Image Compressor"
  <link rel="stylesheet" href="style.css">
  <script src="vendor/jszip.min.js"></script>
</head>
<body>
  <header>
    <h1>Image Compressor</h1>
    <p class="subtitle">Compress images in your browser. Nothing is uploaded.</p>
  </header>

  <!-- Sticky global controls bar -->
  <div class="global-bar" id="global-bar" hidden>
    <span id="file-count">0 images</span>
    <div class="preset-group">
      <button class="preset-btn" data-q="40">Low</button>
      <button class="preset-btn" data-q="70">Medium</button>
      <button class="preset-btn" data-q="85">High</button>
    </div>
    <button id="download-all-btn" type="button">Download All (ZIP)</button>
    <button id="clear-all-btn" type="button">Clear All</button>
  </div>

  <main>
    <!-- Drop zone -->
    <div id="drop-zone" role="region" aria-label="File drop zone">
      <div class="drop-icon">↓</div>
      <p>Drop images here</p>
      <p class="drop-sub">or <label for="file-input" class="file-label">browse files</label></p>
      <p class="drop-hint">JPEG and PNG · Up to 10 files</p>
      <input type="file" id="file-input" accept="image/jpeg,image/png,image/webp"
             multiple hidden>
    </div>

    <!-- Cards container — populated dynamically -->
    <div id="cards-container"></div>
  </main>

  <script src="app.js"></script>
</body>
```

#### Per-Image Card Template (generated by app.js)

Each card is a `<div class="image-card" data-id="{id}">` containing:
```
.card-header
  .card-filename  (original filename)
  button.remove-btn  (×)
  span.png-warning  (hidden by default, shown for PNG input: "PNG→JPEG: lossy")

.split-view-container  (relative position)
  .split-original  (absolutely positioned, full size, background-image: original)
  .split-compressed  (absolutely positioned, full size, background-image: compressed,
                       clip-path: inset(0 calc(100% - {sliderPct}%) 0 0))
  input.split-slider  (type="range", min=0, max=100, value=50, aria-label="Compare")
  .split-label-left   "Original"
  .split-label-right  "Compressed"

.card-meta
  .size-original  "1.2 MB"
  .size-arrow     "→"
  .size-compressed  "312 KB"
  .size-saving    "-74%" (class "good" if >20%, "warn" if <20%)
  .dimensions     "1920 × 1080"

.card-controls
  .format-group
    label + input[type=radio name=format-{id} value=jpeg] JPEG
    label + input[type=radio name=format-{id} value=webp] WebP
  label.quality-label  "Quality: {value}"
  input.quality-slider  (type="range", min=1, max=100, value=80)
  button.download-btn  "Download"
```

#### app.js Logic Spec

**State object:**
```js
const state = {
  cards: []  // array of card objects (see below)
};

// Card object shape:
{
  id: Date.now() + Math.random(),  // unique ID
  file: File,                      // original File object
  originalBlob: null,              // original as Blob (from FileReader)
  compressedBlob: null,            // compressed Blob (from canvas.toBlob)
  originalUrl: null,               // object URL for original
  compressedUrl: null,             // object URL for compressed
  format: 'jpeg',                  // 'jpeg' | 'webp'
  quality: 80,                     // 1-100
  splitPct: 50,                    // divider position 0-100
  width: 0,
  height: 0
}
```

**File ingestion (processFile function per file):**
1. Guard: if state.cards.length >= 10, show alert "Maximum 10 files" and return.
2. Detect PNG: if `file.type === 'image/png'`, flag the card for PNG warning.
3. Use `createImageBitmap(file)` (async, off-main-thread decode) → get width/height.
4. Draw to offscreen canvas: `new OffscreenCanvas(width, height)`.
   `ctx.drawImage(imageBitmap, 0, 0)`.
5. `canvas.convertToBlob({ type: 'image/jpeg', quality: card.quality / 100 })` for
   initial compress. Store as `card.compressedBlob`.
6. `URL.createObjectURL(file)` → `card.originalUrl`.
7. `URL.createObjectURL(card.compressedBlob)` → `card.compressedUrl`.
8. Push card to `state.cards`, call render().

   **OffscreenCanvas note:** `OffscreenCanvas.convertToBlob()` returns a Promise.
   Must be awaited. If OffscreenCanvas not supported (old Safari), fall back to
   `HTMLCanvasElement.toBlob()` on a regular canvas.

**Split-view implementation (clip-path approach):**
- `.split-original` and `.split-compressed` are both `position: absolute; inset: 0`.
- Both have `background-image: url(...)`, `background-size: cover`, `background-position: center`.
- `.split-compressed` has `clip-path: inset(0 calc(100% - {pct}%) 0 0)`.
  When slider is at 50% → `inset(0 50% 0 0)` = right half clipped away = left half shows.
  Wait — this clips the compressed to the LEFT side. Left = original, right = compressed.
  Correct logic: `.split-original` is the background layer (no clip).
  `.split-compressed` is overlay with `clip-path: inset(0 0 0 {pct}%)`.
  As slider moves right, more of compressed is revealed on the right.
  Divider line: `::after` pseudo on container, positioned at `left: {pct}%`.

- Slider input event: `card.splitPct = slider.value`, update `.split-compressed` style
  and divider position. No re-render needed — direct DOM write for performance.
- Touch events: `pointer` events (not `mouse`) for cross-device support.

**Quality slider → live recompress:**
- Debounce 150ms using `clearTimeout` + `setTimeout` pattern.
- On debounce trigger: run compression again via OffscreenCanvas with new quality.
- Revoke old `card.compressedUrl` via `URL.revokeObjectURL()` before replacing.
- Update `.size-compressed`, `.size-saving`, `.split-compressed` background-image.

**Format toggle (JPEG ↔ WebP):**
- `card.format = 'jpeg'|'webp'`
- Run full recompress with `image/webp` or `image/jpeg` type.
- WebP feature detection: `canvas.toDataURL('image/webp').startsWith('data:image/webp')`.
  If WebP not supported: disable WebP radio + show "(not supported in this browser)".

**Individual download:**
- Create `<a download="{name}-compressed.{ext}">` with `href = URL.createObjectURL(card.compressedBlob)`.
- Trigger `.click()`, then `URL.revokeObjectURL` after 60s timeout.

**Batch download (JSZip):**
- Create `new JSZip()`.
- For each card: `zip.file(card.file.name.replace(/\.\w+$/, '') + '-compressed.' + ext, card.compressedBlob)`.
- `zip.generateAsync({ type: 'blob' })` → download as `compressed-images.zip`.

**Card removal:**
- `URL.revokeObjectURL(card.originalUrl)` and `URL.revokeObjectURL(card.compressedUrl)`.
- Remove from `state.cards`, re-render.

**Drop zone behavior:**
- `dragover`: add `.dragover` class (CSS: dashed border animates, background-color shifts).
- `dragleave` / `drop`: remove `.dragover`.
- `drop`: `e.dataTransfer.files` → filter `image/*`, process each.

**Global controls:**
- Preset buttons (Low/Medium/High): iterate `state.cards`, set `card.quality = preset`, trigger recompress on each.
- Clear All: revoke all object URLs, `state.cards = []`, render.
- Global bar: hidden until `state.cards.length > 0`.

**Edge cases:**
- PNG input: show `.png-warning` banner on card. Still compresses to JPEG/WebP.
- File > 20MB: `if (file.size > 20 * 1024 * 1024)` — show "Large file detected, may take a moment" in card header.
- Zero reduction: if compressed >= original, show "No saving — try lower quality" instead of green badge.

#### Acceptance Criteria
- Drop JPEG → before/after split renders with draggable divider
- Quality slider updates compressed size in real-time (150ms debounce)
- WebP toggle switches output format
- Individual download saves correct file
- 3-file batch → ZIP with correct names
- Touch-drag divider works on mobile at 375px

---

### C-006-03 — unit-converter

**Effort:** large | **Stack:** html | **Repo:** JPGBMR/unit-converter (new, supersedes wip-unit-converter)

#### Files

| File | Action | Purpose |
|---|---|---|
| `index.html` | create | App shell |
| `style.css` | create | B&W tokens + component styles |
| `app.js` | create | All conversion logic + UNITS object |
| `README.md` | create | Standard README with Live Demo badge |
| `.gitignore` | create | Standard web .gitignore |
| `.github/workflows/ci.yml` | create | Copy from templates/ci-html.yml |
| `.github/workflows/cd-pages.yml` | create | Copy from templates/cd-pages.yml |

#### Revised Unit Categories (operator override)

Elena's 10 categories revised. Replaced Time (trivial, everyone knows it) and
Energy (specialized) with Angle (dev/engineering essential) and Power (appliances,
engines). All other categories kept but unit lists trimmed to practical-only.

| # | Category | Base unit | Icon (inline SVG text) |
|---|---|---|---|
| 1 | Length | meter (m) | ↔ |
| 2 | Mass | gram (g) | ⊖ |
| 3 | Temperature | Celsius (special) | ∼ |
| 4 | Speed | m/s | → |
| 5 | Area | sq meter (m²) | ▪ |
| 6 | Volume | liter (L) | ◈ |
| 7 | Data | byte (B) | ▤ |
| 8 | Angle | degree (°) | ∠ |
| 9 | Pressure | pascal (Pa) | ⊙ |
| 10 | Power | watt (W) | ⚡ |

#### Complete UNITS Object (ready-to-paste JS literal)

Vitalik pastes this verbatim at the top of app.js. No lookups required.
Conversion: `base_value = input_value * from.factor`, then `result = base_value / to.factor`.
Temperature and Data are special-cased (see below).

```js
const UNITS = {
  length: {
    label: 'Length', icon: '↔', base: 'm',
    quick: [
      '1 in = 2.54 cm', '1 ft = 30.48 cm', '1 yd = 91.44 cm',
      '1 mi = 1.609 km', '1 nmi = 1.852 km'
    ],
    units: {
      mm:  { label: 'Millimeter',    sym: 'mm',  factor: 0.001     },
      cm:  { label: 'Centimeter',    sym: 'cm',  factor: 0.01      },
      m:   { label: 'Meter',         sym: 'm',   factor: 1         },
      km:  { label: 'Kilometer',     sym: 'km',  factor: 1000      },
      in:  { label: 'Inch',          sym: 'in',  factor: 0.0254    },
      ft:  { label: 'Foot',          sym: 'ft',  factor: 0.3048    },
      yd:  { label: 'Yard',          sym: 'yd',  factor: 0.9144    },
      mi:  { label: 'Mile',          sym: 'mi',  factor: 1609.344  },
      nmi: { label: 'Nautical Mile', sym: 'nmi', factor: 1852      }
    }
  },

  mass: {
    label: 'Mass', icon: '⊖', base: 'g',
    quick: [
      '1 oz = 28.35 g', '1 lb = 453.6 g', '1 stone = 6.35 kg',
      '1 kg = 2.205 lb', '1 t = 1000 kg'
    ],
    units: {
      mg:    { label: 'Milligram',  sym: 'mg', factor: 0.001        },
      g:     { label: 'Gram',       sym: 'g',  factor: 1            },
      kg:    { label: 'Kilogram',   sym: 'kg', factor: 1000         },
      t:     { label: 'Metric Ton', sym: 't',  factor: 1000000      },
      oz:    { label: 'Ounce',      sym: 'oz', factor: 28.349523    },
      lb:    { label: 'Pound',      sym: 'lb', factor: 453.59237    },
      stone: { label: 'Stone',      sym: 'st', factor: 6350.29318   }
    }
  },

  temperature: {
    label: 'Temperature', icon: '∼', base: null,  // SPECIAL CASE
    quick: [
      '0°C = 32°F = 273.15 K', '100°C = 212°F = 373.15 K',
      '37°C = 98.6°F (body temp)', '20°C = 68°F (room temp)',
      '-40°C = -40°F (crossover)'
    ],
    units: {
      c: { label: 'Celsius',    sym: '°C' },
      f: { label: 'Fahrenheit', sym: '°F' },
      k: { label: 'Kelvin',     sym: 'K'  }
    }
  },

  speed: {
    label: 'Speed', icon: '→', base: 'ms',
    quick: [
      '1 mph = 1.609 km/h', '1 knot = 1.852 km/h',
      '60 mph = 96.56 km/h', 'Mach 1 = 1235 km/h',
      '100 km/h = 62.14 mph'
    ],
    units: {
      ms:   { label: 'Meter/sec',    sym: 'm/s',  factor: 1         },
      kmh:  { label: 'Kilometer/h',  sym: 'km/h', factor: 0.277778  },
      mph:  { label: 'Mile/hour',    sym: 'mph',  factor: 0.44704   },
      kn:   { label: 'Knot',         sym: 'kn',   factor: 0.514444  },
      mach: { label: 'Mach (sea lvl)', sym: 'M',  factor: 340.29    }
    }
  },

  area: {
    label: 'Area', icon: '▪', base: 'm2',
    quick: [
      '1 acre = 4047 m²', '1 ha = 10,000 m²', '1 km² = 100 ha',
      '1 ft² = 929 cm²', '1 mi² = 2.59 km²'
    ],
    units: {
      mm2:  { label: 'Sq Millimeter', sym: 'mm²',  factor: 0.000001   },
      cm2:  { label: 'Sq Centimeter', sym: 'cm²',  factor: 0.0001     },
      m2:   { label: 'Sq Meter',      sym: 'm²',   factor: 1          },
      km2:  { label: 'Sq Kilometer',  sym: 'km²',  factor: 1000000    },
      in2:  { label: 'Sq Inch',       sym: 'in²',  factor: 0.00064516 },
      ft2:  { label: 'Sq Foot',       sym: 'ft²',  factor: 0.092903   },
      yd2:  { label: 'Sq Yard',       sym: 'yd²',  factor: 0.836127   },
      acre: { label: 'Acre',          sym: 'ac',   factor: 4046.8564  },
      ha:   { label: 'Hectare',       sym: 'ha',   factor: 10000      }
    }
  },

  volume: {
    label: 'Volume', icon: '◈', base: 'l',
    quick: [
      '1 tsp = 4.93 ml', '1 tbsp = 14.79 ml', '1 cup = 236.6 ml',
      '1 US gal = 3.785 L', '1 UK gal = 4.546 L'
    ],
    units: {
      ml:     { label: 'Milliliter',   sym: 'ml',     factor: 0.001       },
      l:      { label: 'Liter',        sym: 'L',      factor: 1           },
      m3:     { label: 'Cubic Meter',  sym: 'm³',     factor: 1000        },
      tsp:    { label: 'Teaspoon',     sym: 'tsp',    factor: 0.00492892  },
      tbsp:   { label: 'Tablespoon',   sym: 'tbsp',   factor: 0.01478676  },
      fl_oz:  { label: 'Fl Ounce',     sym: 'fl oz',  factor: 0.02957353  },
      cup:    { label: 'Cup (US)',      sym: 'cup',    factor: 0.23658824  },
      pt:     { label: 'Pint (US)',     sym: 'pt',     factor: 0.47317647  },
      qt:     { label: 'Quart (US)',    sym: 'qt',     factor: 0.94635295  },
      gal_us: { label: 'Gallon (US)',   sym: 'gal',    factor: 3.78541178  },
      gal_uk: { label: 'Gallon (UK)',   sym: 'gal UK', factor: 4.54609     }
    }
  },

  data: {
    label: 'Data', icon: '▤', base: 'byte',
    // SPECIAL CASE: two factor sets — SI (1KB=1000) and binary (1KiB=1024)
    // state.siMode toggles which set is active
    quick: [
      '1 byte = 8 bits', '1 KB (SI) = 1,000 bytes', '1 KiB = 1,024 bytes',
      '1 MB (SI) = 1,000,000 bytes', '1 GiB = 1,073,741,824 bytes'
    ],
    units: {
      bit:  { label: 'Bit',      sym: 'bit', si: 0.125,                    bin: 0.125                    },
      byte: { label: 'Byte',     sym: 'B',   si: 1,                        bin: 1                        },
      kb:   { label: 'Kilobyte', sym: 'KB',  si: 1000,                     bin: 1024                     },
      mb:   { label: 'Megabyte', sym: 'MB',  si: 1000000,                  bin: 1048576                  },
      gb:   { label: 'Gigabyte', sym: 'GB',  si: 1000000000,               bin: 1073741824               },
      tb:   { label: 'Terabyte', sym: 'TB',  si: 1000000000000,            bin: 1099511627776            },
      pb:   { label: 'Petabyte', sym: 'PB',  si: 1000000000000000,         bin: 1125899906842624         }
    }
  },

  angle: {
    label: 'Angle', icon: '∠', base: 'deg',
    quick: [
      '1 turn = 360°', '1 rad ≈ 57.296°', 'π rad = 180°',
      '1° = 60 arcmin', "1' = 60 arcsec"
    ],
    units: {
      deg:    { label: 'Degree',    sym: '°',   factor: 1                 },
      rad:    { label: 'Radian',    sym: 'rad', factor: 57.29577951       },
      grad:   { label: 'Gradian',   sym: 'grd', factor: 0.9               },
      arcmin: { label: 'Arcminute', sym: "'",   factor: 0.01666667        },
      arcsec: { label: 'Arcsecond', sym: '"',   factor: 0.00027778        },
      turn:   { label: 'Turn',      sym: 'tr',  factor: 360               }
    }
  },

  pressure: {
    label: 'Pressure', icon: '⊙', base: 'pa',
    quick: [
      '1 atm = 101,325 Pa', '1 bar = 100,000 Pa', '1 atm = 14.696 psi',
      'Tire: 30–35 psi', '1 mmHg = 133.32 Pa'
    ],
    units: {
      pa:   { label: 'Pascal',     sym: 'Pa',   factor: 1         },
      kpa:  { label: 'Kilopascal', sym: 'kPa',  factor: 1000      },
      mpa:  { label: 'Megapascal', sym: 'MPa',  factor: 1000000   },
      bar:  { label: 'Bar',        sym: 'bar',  factor: 100000    },
      psi:  { label: 'PSI',        sym: 'psi',  factor: 6894.757  },
      atm:  { label: 'Atmosphere', sym: 'atm',  factor: 101325    },
      mmhg: { label: 'mmHg',       sym: 'mmHg', factor: 133.322   },
      inhg: { label: 'inHg',       sym: 'inHg', factor: 3386.39   }
    }
  },

  power: {
    label: 'Power', icon: '⚡', base: 'w',
    quick: [
      '1 hp = 745.7 W', '1 kW = 1000 W', '1 BTU/h = 0.293 W',
      '1 MW = 1,000,000 W', '1 cal/s = 4.184 W'
    ],
    units: {
      w:     { label: 'Watt',       sym: 'W',     factor: 1       },
      kw:    { label: 'Kilowatt',   sym: 'kW',    factor: 1000    },
      mw:    { label: 'Megawatt',   sym: 'MW',    factor: 1000000 },
      hp:    { label: 'Horsepower', sym: 'hp',    factor: 745.7   },
      btu_h: { label: 'BTU/hour',   sym: 'BTU/h', factor: 0.29307 },
      cals:  { label: 'cal/second', sym: 'cal/s', factor: 4.184   }
    }
  }
};
```

#### Temperature Conversion (special case function)

```js
// Convert value FROM one temp unit TO another.
// Neither uses the base-unit factor pattern.
function convertTemp(value, from, to) {
  if (from === to) return value;
  const toCelsius = {
    c: v => v,
    f: v => (v - 32) * 5 / 9,
    k: v => v - 273.15
  };
  const fromCelsius = {
    c: v => v,
    f: v => v * 9 / 5 + 32,
    k: v => v + 273.15
  };
  return fromCelsius[to](toCelsius[from](value));
}
```

#### Data Conversion (special case function)

```js
// state.siMode: true = SI (1KB=1000), false = binary (1KiB=1024)
function convertData(value, from, to) {
  const mode = state.siMode ? 'si' : 'bin';
  return value * UNITS.data.units[from][mode] / UNITS.data.units[to][mode];
}
```

#### General Conversion Function

```js
function convert(value, fromKey, toKey, category) {
  if (isNaN(value)) return '';
  if (category === 'temperature') return convertTemp(value, fromKey, toKey);
  if (category === 'data') return convertData(value, fromKey, toKey);
  const from = UNITS[category].units[fromKey].factor;
  const to   = UNITS[category].units[toKey].factor;
  return (value * from) / to;
}
```

#### Formula Display Function

```js
// Returns a human-readable formula string for the current conversion.
function getFormula(fromKey, toKey, category) {
  if (category === 'temperature') {
    const pairs = {
      'c→f': 'F = C × 9/5 + 32',
      'f→c': 'C = (F − 32) × 5/9',
      'c→k': 'K = C + 273.15',
      'k→c': 'C = K − 273.15',
      'f→k': 'K = (F − 32) × 5/9 + 273.15',
      'k→f': 'F = (K − 273.15) × 9/5 + 32'
    };
    return pairs[`${fromKey}→${toKey}`] || '';
  }
  if (category === 'data') {
    const mode = state.siMode ? 'SI' : 'Binary';
    const f = UNITS.data.units[fromKey];
    const t = UNITS.data.units[toKey];
    const ratio = convert(1, fromKey, toKey, 'data');
    return `1 ${f.sym} (${mode}) = ${formatNumber(ratio)} ${t.sym}`;
  }
  const f = UNITS[category].units[fromKey];
  const t = UNITS[category].units[toKey];
  const ratio = (f.factor / t.factor);
  return `1 ${f.sym} = ${formatNumber(ratio)} ${t.sym}`;
}

// formatNumber: if abs value >= 0.001 and <= 999999, show toFixed(precision).
// Otherwise use toPrecision(6) to avoid 0.000000... displays.
function formatNumber(n, precision = state.precision) {
  if (n === 0) return '0';
  const abs = Math.abs(n);
  if (abs >= 0.001 && abs < 1000000) return parseFloat(n.toFixed(precision)).toString();
  return n.toPrecision(6);
}
```

#### app.js State Object

```js
const state = {
  category:  'length',        // active category key
  fromUnit:  'km',            // FROM dropdown selected key
  toUnit:    'mi',            // TO dropdown selected key
  inputValue: '',             // raw input string
  precision:  4,              // 2 | 4 | 6 | 10
  siMode:     true,           // data category only
  searchQuery: '',            // search filter string
  favorites:  [],             // [{ category, from, to }], from localStorage
};
```

#### index.html Structure

```
<body>
  <header>
    <h1>Unit Converter</h1>
  </header>

  <main>
    <!-- Category selector -->
    <nav class="category-nav" role="navigation" aria-label="Categories">
      <!-- 10 buttons, one per category, generated by JS -->
      <!-- Each: <button class="cat-btn [active]" data-cat="length"> icon + label </button> -->
    </nav>

    <!-- Search -->
    <div class="search-bar">
      <input id="search-input" type="search" placeholder="Search units…" autocomplete="off">
    </div>

    <!-- Favorites chips (hidden if none) -->
    <div id="favorites-bar" class="favorites-bar" hidden></div>

    <!-- Converter panel -->
    <section class="converter-panel">
      <!-- FROM -->
      <div class="unit-group">
        <input id="from-input" type="number" inputmode="decimal"
               placeholder="0" autocomplete="off">
        <select id="from-select" aria-label="From unit"></select>
        <button id="fav-btn" type="button" aria-label="Save favorite">★</button>
      </div>

      <!-- Swap -->
      <button id="swap-btn" class="swap-btn" type="button" aria-label="Swap units">⇄</button>

      <!-- TO -->
      <div class="unit-group">
        <output id="to-output" for="from-input"></output>
        <select id="to-select" aria-label="To unit"></select>
        <button id="copy-btn" type="button" aria-label="Copy result">⎘</button>
      </div>

      <!-- Precision -->
      <div class="precision-row">
        <span>Decimal places:</span>
        <button class="prec-btn active" data-prec="2">2</button>
        <button class="prec-btn" data-prec="4">4</button>
        <button class="prec-btn" data-prec="6">6</button>
        <button class="prec-btn" data-prec="10">10</button>
        <!-- Data category only: -->
        <label class="si-toggle" id="si-toggle" hidden>
          <input type="checkbox" id="si-check" checked> SI (1KB=1000B)
        </label>
      </div>
    </section>

    <!-- Formula display -->
    <details class="formula-panel" open>
      <summary>Formula</summary>
      <p id="formula-display"></p>
    </details>

    <!-- Quick reference table -->
    <section class="quick-ref">
      <h2>Quick Reference</h2>
      <ul id="quick-list" role="list"></ul>
    </section>
  </main>

  <script src="app.js"></script>
</body>
```

#### Interaction Behaviors

**Category switch:**
- Set `state.category`, reset `state.fromUnit` to first key in category, `state.toUnit` to second key.
- `#to-output` fades (opacity 0 → 1, 150ms) while dropdowns repopulate.
- Show/hide `#si-toggle` based on `state.category === 'data'`.

**Swap button:**
- Swap `state.fromUnit` ↔ `state.toUnit`. Also: current `#to-output` value goes into `#from-input`.
- Button gets `transform: rotate(180deg)` for 200ms then snaps back (CSS transition + JS class toggle).

**Search:**
- On input: filter both `<select>` dropdowns to only show `<option>` elements whose `label` or `sym` matches `state.searchQuery` (case-insensitive).
- Empty search = all options shown.
- If current selected unit is filtered out, auto-select first visible option.

**Favorites:**
- Save: push `{ category: state.category, from: state.fromUnit, to: state.toUnit }` to `state.favorites`. Write `JSON.stringify` to localStorage key `'uc_favorites'`. Max 8 favorites.
- Load: render as `<button class="fav-chip">` with format "km → mi" etc. Click → set category + units, call render().
- localStorage: try/catch on parse, silent reset to `[]`.

**Input handling:**
- Comma as decimal separator: `inputValue.replace(',', '.')` before `parseFloat`.
- NaN input → `#to-output` shows "—".

**Edge cases:**
- Division by zero (converting to base unit with factor 0): guard with `if (to === 0) return '∞'`.
- Very large numbers: `formatNumber` uses `toPrecision(6)` for abs > 999999.
- Swap when input is empty: swap units only, leave input empty, output shows "—".

#### Acceptance Criteria
- Length: 100 km → mi = 62.1371
- Temperature: 37 °C → °F = 98.6000
- Data SI: 1 GB = 1,000,000,000 bytes | Binary: 1 GB = 1,073,741,824 bytes
- Swap reverses both units and reflects value
- Search "mile" filters to mile/nautical mile in dropdown
- Formula panel: "1 km = 0.6214 mi"
- Favorites save + restore across refresh
- Works at 320px viewport width

---

## ISSUES TO RAISE (on JPGBMR/repo-bootstrap)

```
[SPEC] url-shortener — build and deploy to JPGBMR/url-shortener       priority:p1 vitalic:ready stack:html effort:medium
[SPEC] image-compressor — build and deploy to JPGBMR/image-compressor  priority:p1 vitalic:ready stack:html effort:large
[SPEC] unit-converter — build and deploy to JPGBMR/unit-converter      priority:p1 vitalic:ready stack:html effort:large
[DECISION] inject-workflows.sh — --force flag added for template propagation   type:decision
[DECISION] preflight.sh — OPEN_PR check changed to WARN, not EXIT 1   type:decision
[DEBT] jpgbmr-site/app.js — hardcoded PROJECTS array, must generate from source of truth   priority:p3 type:debt
[FIX] preflight.sh — update OPEN_PR block to warn-only (exit 0)       priority:p2 type:fix
[FIX] inject-workflows.sh — add --force flag for template overwrite    priority:p2 type:fix
```

---

## BUILD SEQUENCE SUMMARY

```
IMMEDIATE (no dependencies):
  1. Vitalik: apply D-01 --force flag fix to inject-workflows.sh
  2. Vitalik: apply D-02 OPEN_PR warn-only fix to preflight.sh

PARALLEL (all three fully independent, no blocking):
  3a. Vitalik: build url-shortener
      - vendor/qrcode.min.js downloaded from https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js
  3b. Vitalik: build unit-converter
  3c. Vitalik: build image-compressor
      - vendor/jszip.min.js downloaded from https://cdn.jsdelivr.net/npm/jszip@3.10.1/dist/jszip.min.js

  Each project: create files locally → gh repo create JPGBMR/{name} --public →
  git push to main → CI runs → CD deploys to Pages.

POST-SHIP:
  4. Delete local wip-unit-converter folder
  5. Update CLAUDE.md: remove wip-unit-converter, add unit-converter to Live section
  6. Run generate-site.sh (once built) to add 3 new cards to portfolio
     OR manually add 3 entries to jpgbmr-site/app.js until generate-site.sh exists
```

---

## RISKS AND NOTES

**url-shortener:**
- is.gd CORS: confirmed safe. No proxy. Standard `fetch()`.
- tinyurl fallback returns `text/plain`, not JSON — parse with `.text()` not `.json()`.
- qrcode.js renders a `<canvas>` or `<img>` depending on browser. Always attempt
  `container.querySelector('canvas')` first, fall back to `querySelector('img')`.
  For img-based QR download: draw to a temp canvas, export as PNG.
- Clipboard paste requires HTTPS — GitHub Pages provides this.

**image-compressor:**
- OffscreenCanvas is the correct async decode path. Fallback to HTMLCanvasElement
  + FileReader for browsers that don't support it (older Safari).
- PNG → JPEG warning is UX correctness, not a bug — user must know it's lossy.
- JSZip `generateAsync` is async — `await` it, show loading state on Download All button.
- clip-path split-view: test at multiple slider positions that no flicker/white-line
  appears between original and compressed layers. Use `will-change: clip-path` on the
  overlay div to promote to GPU layer.

**unit-converter:**
- Angle `factor` is in degrees (base = degree). rad factor = 57.29578 (not PI/180).
  The formula is: `base_deg = input_rad * 57.29578`. Then `result = base_deg / to.factor`.
- Data large numbers (PB): JS float64 handles up to 2^53. PB binary = 1125899906842624.
  This is within safe integer range. No BigInt needed.
- Precision selector "10" may show floating point noise on some conversions —
  acceptable. `parseFloat(n.toFixed(10))` strips trailing zeros.
- Temperature formula display: use a lookup table (see `getFormula` spec). Do not
  try to derive it algebraically from the conversion function.

**Operator override — color scheme:**
Elena's navy/purple/teal schemes are NOT built. All three use the shared B&W token
spec. Dark mode is automatic via `prefers-color-scheme: dark`. No manual toggle.

---

## MESSAGE TO VITALIK

```
BUILD ORDER:
1. scripts/inject-workflows.sh — add --force flag (10 lines, top of file)
2. scripts/preflight.sh — change OPEN_PR to WARN + exit 0 (not EXIT 1)
3. url-shortener/ — vendor qrcode.js, build 3 files, publish repo
4. unit-converter/ — paste UNITS object verbatim, build 3 files, publish repo
5. image-compressor/ — vendor jszip.js, build 3 files, publish repo

WATCH OUT FOR:
- CSS tokens: copy the :root block from this blueprint VERBATIM. No per-project colors.
- qrcode.js: download vendor/qrcode.min.js (do not use CDN script tag).
  URL: https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js
- jszip: download vendor/jszip.min.js
  URL: https://cdn.jsdelivr.net/npm/jszip@3.10.1/dist/jszip.min.js
- Temperature: use convertTemp() exactly as specced. Do NOT apply the factor pattern.
- Data: two factor columns (si / bin). state.siMode toggles which to use.
- angle base unit is DEGREE. rad factor = 57.29578, NOT 0.017453.
- image-compressor split-view: clip-path on OVERLAY div only. Original div has no clip.
  Formula: overlay clip-path = inset(0 0 0 {pct}%)  [reveals right side as pct increases]
- tinyurl fallback: response is plain text — call response.text(), not response.json().
- After build: delete wip-unit-converter/ from local disk.

DO NOT:
- Do not use Math.random() anywhere — crypto not needed here but Math.random() is
  a smell. Use Date.now() for IDs.
- Do not add color accents. B&W only. If you feel an urge to add color, resist it.
- Do not use any JS framework, bundler, or package manager. Zero build step.
- Do not use CDN script tags for qrcode or jszip — vendor them in vendor/ folder.
- Do not hardcode conversion factors inline — paste the full UNITS object from this blueprint.
- Do not add localStorage to image-compressor — blobs don't survive serialization.

DONE WHEN:
- https://jpgbmr.github.io/url-shortener/ loads, shortens a URL, shows QR
- https://jpgbmr.github.io/unit-converter/ loads, converts 100 km → mi = 62.1371
- https://jpgbmr.github.io/image-compressor/ loads, accepts a JPEG, shows split view
- CI green on all three main branches
- Lighthouse ≥ 90 on url-shortener and unit-converter
- Lighthouse ≥ 85 on image-compressor (Canvas ops cost points)
- wip-unit-converter/ deleted from local disk
- 3 new entries added to jpgbmr-site/app.js PROJECTS array
```
