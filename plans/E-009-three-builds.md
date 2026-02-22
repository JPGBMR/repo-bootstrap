# E-009 — Full Deployment Plan
## sleep-calculator · color-from-image · fake-data-gen

**Standard: mobile-first · vanilla JS · no build step · GitHub Pages · CI green**

---

```
[ASSUMPTION]
"Serious but lightweight" = production-quality UX and code,
zero framework overhead, no npm, no bundler. Each project
ships as 3 files: index.html + style.css + app.js.
Colombo closes every design decision below. Vitalik ships
without one back-and-forth.
```

---
---

# PROJECT 1 — `sleep-calculator`

## Concept
Enter when you want to wake up → get the 5 optimal bedtimes based on 90-minute sleep cycles.
Or reverse: enter when you're going to sleep → get optimal wake times.
Science-backed, beautifully designed, instantly shareable.

## File Structure
```
sleep-calculator/
├── index.html
├── style.css
├── app.js
├── README.md
├── .gitignore
└── .github/
    └── workflows/
        ├── ci.yml
        └── cd-pages.yml
```

## Design Spec

**Color palette:**
```css
:root {
  --bg:        #0F172A;   /* deep navy */
  --surface:   #1E293B;   /* card bg */
  --border:    #334155;   /* subtle border */
  --accent:    #818CF8;   /* indigo */
  --accent-2:  #F59E0B;   /* amber — stars/moon */
  --text:      #F1F5F9;   /* near white */
  --muted:     #94A3B8;   /* slate */
  --success:   #34D399;   /* emerald */
  --warn:      #F87171;   /* red */

  --radius:    16px;
  --radius-sm: 8px;
  --font:      'Inter', system-ui, sans-serif;
}
```

**Typography:** Load Inter from Google Fonts CDN (single weight: 400, 500, 700).

**Layout (mobile-first):**
- Single column, max-width 480px, margin auto, padding 1.5rem
- No sidebar. Pure vertical stack.
- Desktop ≥ 640px: card gets subtle drop shadow, bg gets star pattern (CSS radial-gradient dots)

## HTML Structure

```html
<!-- Header -->
<header>
  <div class="moon-icon">🌙</div>
  <h1>Sleep Calculator</h1>
  <p class="subtitle">Wake up refreshed. Every time.</p>
</header>

<!-- Mode toggle -->
<div class="mode-tabs">
  <button class="tab active" data-mode="wake">I want to wake up at…</button>
  <button class="tab" data-mode="sleep">I'm going to sleep at…</button>
</div>

<!-- Time input -->
<div class="input-card">
  <input type="time" id="time-input" value="07:00">
  <button id="now-btn">Use current time</button>
</div>

<!-- Results -->
<div id="results" class="results-grid">
  <!-- 5 result cards injected by JS -->
</div>

<!-- Footer tip -->
<p class="tip">⏰ Set your alarm for the highlighted time.</p>
```

## Result Card Template (JS-generated)
```html
<div class="result-card {best-class}">
  <div class="card-emoji">{emoji}</div>
  <div class="card-time">{HH:MM AM/PM}</div>
  <div class="card-label">{label}</div>
  <div class="card-meta">{n} cycles · {hours}h sleep</div>
  <button class="copy-btn" data-time="{time}">Copy</button>
</div>
```

**Card ratings (wake-up mode, cycles = sleep cycles):**
| Cycles | Hours | Emoji | Label | CSS class |
|--------|-------|-------|-------|-----------|
| 2 | 3h | 😵 | Emergency only | `card--danger` |
| 3 | 4.5h | 😓 | Not enough | `card--warn` |
| 4 | 6h | 😐 | Bare minimum | `card--ok` |
| 5 | 7.5h | 😊 | Recommended | `card--good best` |
| 6 | 9h | 🌟 | Optimal | `card--best` |

Best card (5 cycles) gets: larger size, accent border, subtle glow.

## Core Math (app.js)

```javascript
const CYCLE_MINS = 90;
const FALL_ASLEEP_MINS = 15;

function timeToMins(timeStr) {
  const [h, m] = timeStr.split(':').map(Number);
  return h * 60 + m;
}

function minsToTime(mins) {
  const wrapped = ((mins % 1440) + 1440) % 1440;
  const h = Math.floor(wrapped / 60);
  const m = wrapped % 60;
  const period = h >= 12 ? 'PM' : 'AM';
  const h12 = h % 12 || 12;
  return `${h12}:${String(m).padStart(2,'0')} ${period}`;
}

// Mode: "wake" → user sets wake time, calculate bedtimes
function calcBedtimes(wakeTimeMins) {
  return [2, 3, 4, 5, 6].map(cycles => ({
    cycles,
    time: minsToTime(wakeTimeMins - FALL_ASLEEP_MINS - cycles * CYCLE_MINS),
    hours: (cycles * CYCLE_MINS) / 60
  }));
}

// Mode: "sleep" → user sets sleep time, calculate wake times
function calcWakeTimes(sleepTimeMins) {
  return [2, 3, 4, 5, 6].map(cycles => ({
    cycles,
    time: minsToTime(sleepTimeMins + FALL_ASLEEP_MINS + cycles * CYCLE_MINS),
    hours: (cycles * CYCLE_MINS) / 60
  }));
}
```

## State & Render Pattern
```javascript
const state = {
  mode: 'wake',       // 'wake' | 'sleep'
  inputTime: '07:00'
};

function render() {
  const mins = timeToMins(state.inputTime);
  const results = state.mode === 'wake'
    ? calcBedtimes(mins)
    : calcWakeTimes(mins);
  // inject result cards into #results
}

// Event listeners → mutate state → call render()
document.getElementById('time-input').addEventListener('input', e => {
  state.inputTime = e.target.value;
  render();
});
```

## Copy & Share
- Copy button on each card: `navigator.clipboard.writeText(time)` → button label → "✓ Copied" for 1.5s
- Share button (bottom): Web Share API → fallback clipboard copy of a text summary
  ```
  "Sleep at 10:30 PM to wake at 7:00 AM fully rested (5 cycles, 7.5h) 🌙 jpgbmr.github.io/sleep-calculator"
  ```

## Mobile UX
- `input[type=time]` styled full-width, 56px tall, large font (2rem), centered text
- Result grid: 1 column on mobile, best card highlighted with border
- "Use current time" button fills the input with `new Date()` formatted HH:MM
- No horizontal scroll at 320px viewport

## CI Workflow
Standard `ci-html.yml` (HTMLHint + LHCI continue-on-error) + `cd-pages.yml`.

## Acceptance Criteria
- Input `07:00 AM` wake → 5 cards showing `09:45 PM, 11:15 PM, 12:45 AM, 02:15 AM, 03:45 AM`
- Switch to sleep mode → input `11:00 PM` → wake times show `01:45 AM, 03:15 AM, 04:45 AM, 06:15 AM, 07:45 AM`
- "Use current time" fills correct current local time
- Copy button works, shows checkmark
- Renders correctly at 320px, 375px, 768px
- Lighthouse ≥ 95 performance (no images, no heavy JS)

---
---

# PROJECT 2 — `color-from-image`

## Concept
Drop or upload any image → instantly see 8 dominant colours as swatches with hex codes.
Copy individual hex, export as CSS variables, export as PNG swatch strip.
Designers will bookmark this on day one.

## File Structure
```
color-from-image/
├── index.html
├── style.css
├── app.js
├── README.md
├── .gitignore
└── .github/
    └── workflows/
        ├── ci.yml
        └── cd-pages.yml
```

## Design Spec

**Color palette:**
```css
:root {
  --bg:       #F8F7F4;   /* warm off-white */
  --surface:  #FFFFFF;
  --border:   #E2E0DB;
  --text:     #1A1A1A;
  --muted:    #6B6860;
  --accent:   #2563EB;   /* blue */
  --radius:   12px;
  --shadow:   0 2px 16px rgba(0,0,0,0.08);
}
```

**Dark mode:** `@media (prefers-color-scheme: dark)` → flip to `#0F0F0F` bg, `#1A1A1A` surface.

## HTML Structure
```html
<header>
  <h1>Color from Image</h1>
  <p>Extract the dominant colours from any photo or design.</p>
</header>

<!-- Drop zone -->
<div id="drop-zone" role="button" tabindex="0" aria-label="Upload image">
  <svg><!-- upload icon --></svg>
  <p>Drop an image here or <span class="link">click to browse</span></p>
  <p class="hint">PNG, JPG, WebP, GIF · Max 20MB</p>
  <input type="file" id="file-input" accept="image/*" hidden>
</div>

<!-- Result section (hidden until image loaded) -->
<section id="result" hidden>
  <div id="image-preview-wrap">
    <img id="image-preview" alt="Uploaded image">
  </div>

  <div id="palette">
    <!-- 8 swatch divs injected by JS -->
  </div>

  <div class="export-row">
    <button id="copy-css">Copy CSS Variables</button>
    <button id="copy-json">Copy JSON</button>
    <button id="export-png">Export Palette PNG</button>
    <button id="reset-btn">↩ New Image</button>
  </div>
</section>
```

## Swatch Card Template (JS-generated)
```html
<div class="swatch" style="--c: {hex}">
  <div class="swatch-color"></div>
  <div class="swatch-info">
    <span class="swatch-hex">{hex}</span>
    <span class="swatch-rgb">rgb({r},{g},{b})</span>
  </div>
  <button class="swatch-copy" aria-label="Copy {hex}">Copy</button>
</div>
```

CSS: `.swatch-color { background: var(--c); height: 80px; border-radius: 8px 8px 0 0; }`

## Core Algorithm (app.js)

### Step 1 — Load image to canvas
```javascript
function loadImageToCanvas(file) {
  return new Promise(resolve => {
    const reader = new FileReader();
    reader.onload = e => {
      const img = new Image();
      img.onload = () => {
        const SIZE = 100; // sample at 100×100 for performance
        const canvas = document.createElement('canvas');
        canvas.width = SIZE; canvas.height = SIZE;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, SIZE, SIZE);
        resolve(ctx.getImageData(0, 0, SIZE, SIZE).data);
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  });
}
```

### Step 2 — Extract pixel array (skip transparent)
```javascript
function getPixels(data) {
  const pixels = [];
  for (let i = 0; i < data.length; i += 4) {
    if (data[i + 3] < 128) continue; // skip transparent
    pixels.push([data[i], data[i+1], data[i+2]]);
  }
  return pixels;
}
```

### Step 3 — Median Cut (Colombo provides this verbatim)
```javascript
function medianCut(pixels, depth) {
  if (depth === 0 || pixels.length === 0) {
    const n = pixels.length || 1;
    const avg = pixels.reduce(
      (a, p) => [a[0]+p[0], a[1]+p[1], a[2]+p[2]],
      [0, 0, 0]
    );
    return [avg.map(v => Math.round(v / n))];
  }

  const ranges = [0,1,2].map(ch => {
    const vals = pixels.map(p => p[ch]);
    return Math.max(...vals) - Math.min(...vals);
  });
  const ch = ranges.indexOf(Math.max(...ranges));

  pixels.sort((a, b) => a[ch] - b[ch]);
  const mid = pixels.length >> 1;

  return [
    ...medianCut(pixels.slice(0, mid), depth - 1),
    ...medianCut(pixels.slice(mid),    depth - 1)
  ];
}
// Call: medianCut(pixels, 3) → 8 dominant colours
```

### Step 4 — Convert to hex, deduplicate, sort by luminance
```javascript
function toHex([r, g, b]) {
  return '#' + [r,g,b].map(v => v.toString(16).padStart(2,'0')).join('').toUpperCase();
}

function luminance([r, g, b]) {
  return 0.299*r + 0.587*g + 0.114*b;
}

function extractPalette(imageData) {
  const pixels = getPixels(imageData);
  const colours = medianCut(pixels, 3);
  return colours
    .map(c => ({ rgb: c, hex: toHex(c), lum: luminance(c) }))
    .sort((a, b) => b.lum - a.lum); // light to dark
}
```

## Export Functions

**Copy CSS Variables:**
```javascript
function exportCSS(colours) {
  return colours.map((c, i) => `  --color-${i+1}: ${c.hex};`).join('\n');
  // wrapped in :root { ... }
}
```

**Copy JSON:**
```javascript
function exportJSON(colours) {
  return JSON.stringify(colours.map(c => c.hex), null, 2);
}
```

**Export PNG (palette swatch strip):**
```javascript
function exportPNG(colours) {
  const W = 80, H = 120, LABEL = 20;
  const canvas = document.createElement('canvas');
  canvas.width = W * colours.length;
  canvas.height = H + LABEL;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = '#fff';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  colours.forEach((c, i) => {
    ctx.fillStyle = c.hex;
    ctx.fillRect(i * W, 0, W, H);
    ctx.fillStyle = '#000';
    ctx.font = '11px monospace';
    ctx.textAlign = 'center';
    ctx.fillText(c.hex, i * W + W/2, H + 14);
  });

  canvas.toBlob(blob => {
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'palette.png';
    a.click();
    URL.revokeObjectURL(a.href);
  });
}
```

## Drag & Drop
```javascript
const zone = document.getElementById('drop-zone');
zone.addEventListener('dragover', e => {
  e.preventDefault();
  zone.classList.add('dragover');
});
zone.addEventListener('dragleave', () => zone.classList.remove('dragover'));
zone.addEventListener('drop', e => {
  e.preventDefault();
  zone.classList.remove('dragover');
  handleFile(e.dataTransfer.files[0]);
});
```
`.dragover` class: border color → accent, background → subtle tint, scale(1.01).

## Mobile UX
- Drop zone: 180px tall on mobile, 260px on desktop
- Swatches: 4-column grid on mobile (2 rows of 4), 8-column on desktop
- Swatch height: 70px on mobile, 100px on desktop
- Export buttons: full-width stacked column on mobile, row on ≥ 480px

## Acceptance Criteria
- Upload sunset JPEG → returns palette with warm oranges/reds/purples
- Upload JPGBMR logo (or any solid-color PNG) → dominant brand colour appears first
- Transparent PNG → transparent pixels excluded from palette
- Copy CSS Variables → clipboard contains valid `:root { --color-1: #...; }` block
- Export PNG → downloads a flat PNG with 8 coloured blocks and hex labels
- Works at 320px viewport. Swatches readable on mobile.
- Lighthouse ≥ 90 performance

---
---

# PROJECT 3 — `fake-data-gen`

## Concept
Generate realistic fake data for forms, databases, and demos.
Names, emails, phones, addresses, UUIDs, usernames, companies, credit cards (Luhn-valid test numbers), Lorem text, dates, hex colours.
Pick type → pick quantity → copy or download as JSON/CSV.

## File Structure
```
fake-data-gen/
├── index.html
├── style.css
├── app.js
├── README.md
├── .gitignore
└── .github/
    └── workflows/
        ├── ci.yml
        └── cd-pages.yml
```

## Design Spec

**Color palette:**
```css
:root {
  --bg:       #111827;   /* dark grey-blue */
  --sidebar:  #1F2937;   /* slightly lighter */
  --surface:  #374151;   /* card/output bg */
  --border:   #4B5563;
  --accent:   #10B981;   /* emerald green — terminal feel */
  --text:     #F9FAFB;
  --muted:    #9CA3AF;
  --code-bg:  #0D1117;
  --radius:   8px;
}
```

**Feel:** terminal/developer tool. Monospace output font. Clean but functional.

## Layout

```
┌─────────────────────────────────────────────────┐
│  Header: fake-data-gen                          │
├────────────────┬────────────────────────────────┤
│   SIDEBAR      │   OUTPUT PANEL                 │
│                │                                │
│  Type selector │  [Format tabs: List/JSON/CSV]  │
│  (vertical     │                                │
│   list with    │  [monospace output area]       │
│   icons)       │                                │
│                │  [Quantity: ── slider ── 10]   │
│                │                                │
│                │  [Generate] [Copy] [Download]  │
└────────────────┴────────────────────────────────┘
Mobile: sidebar collapses to horizontal scrollable chip row at top
```

## Data Types & Icons

| Type | Icon | Output example |
|------|------|----------------|
| Full Name | 👤 | `James Rodriguez` |
| First Name | 🔤 | `Emma` |
| Last Name | 🔤 | `Williams` |
| Email | 📧 | `james.rodriguez@gmail.com` |
| Phone (US) | 📞 | `(555) 234-7890` |
| Username | 🆔 | `cool_panda_42` |
| Address | 📍 | `742 Oak St, Austin, TX 78701` |
| Company | 🏢 | `Delta Solutions LLC` |
| UUID | 🔑 | `550e8400-e29b-41d4-a716-446655440000` |
| Credit Card | 💳 | `4532 1234 5678 9010 (VISA)` |
| Date | 📅 | `2023-07-14` |
| Lorem | 📝 | `Lorem ipsum dolor sit amet...` |
| Hex Color | 🎨 | `#A3B4C5` |
| IP Address | 🌐 | `192.168.47.23` |
| Number | 🔢 | `42847` (configurable range) |

## Static Data Arrays (embed in app.js — Vitalik copies verbatim)

```javascript
const DATA = {
  firstNames: ['James','John','Robert','Michael','William','David','Richard','Joseph',
    'Thomas','Charles','Mary','Patricia','Jennifer','Linda','Barbara','Elizabeth',
    'Susan','Jessica','Sarah','Karen','Emma','Olivia','Noah','Liam','Ava','Sophia',
    'Isabella','Mia','Charlotte','Amelia','Oliver','Elijah','Lucas','Mason','Logan',
    'Ethan','Aiden','Jackson','Sofia','Camila','Luna','Diego','Mateo','Miguel',
    'Santiago','Valentina','Chloe','Harper','Evelyn','Abigail'],

  lastNames: ['Smith','Johnson','Williams','Brown','Jones','Garcia','Miller','Davis',
    'Rodriguez','Martinez','Hernandez','Lopez','Gonzalez','Wilson','Anderson','Thomas',
    'Taylor','Moore','Jackson','Martin','Lee','Perez','Thompson','White','Harris',
    'Sanchez','Clark','Ramirez','Lewis','Robinson','Walker','Young','Hall','Allen',
    'King','Wright','Scott','Torres','Nguyen','Hill','Flores','Green','Adams',
    'Nelson','Baker','Rivera','Mitchell','Carter','Roberts','Phillips'],

  domains: ['gmail.com','yahoo.com','hotmail.com','outlook.com','protonmail.com',
    'icloud.com','me.com','fastmail.com','zoho.com','mail.com','hey.com'],

  adjectives: ['cool','fast','brave','dark','wild','calm','lucky','happy','sharp','bright'],
  animals: ['panda','tiger','wolf','eagle','fox','bear','shark','lion','hawk','otter'],

  streetNames: ['Oak','Maple','Main','Park','Cedar','Elm','Pine','Walnut','Birch',
    'Cherry','Sunset','Highland','Lake','River','Hill','Valley','Forest','Garden',
    'Spring','Washington','Lincoln','Jefferson','Madison','Monroe'],

  streetTypes: ['St','Ave','Blvd','Rd','Dr','Ln','Ct','Way','Pl','Terrace'],

  cities: ['New York','Los Angeles','Chicago','Houston','Phoenix','Philadelphia',
    'San Antonio','San Diego','Dallas','San Jose','Austin','Jacksonville',
    'Fort Worth','Columbus','Charlotte','Indianapolis','San Francisco','Seattle',
    'Denver','Nashville','Portland','Las Vegas','Memphis','Louisville','Baltimore'],

  states: ['NY','CA','IL','TX','AZ','PA','FL','OH','NC','IN','WA','CO','TN',
    'OR','NV','KY','MD','WI','GA','MN','MO','NM','VA','MI','NJ'],

  companyWords: ['Tech','Global','Digital','Smart','Cloud','Data','Net','Cyber',
    'Micro','Alpha','Beta','Delta','Omega','Apex','Core','Peak','Blue','Silver',
    'Prime','First','Iron','Stone','Bright','Quantum','Nexus','Vertex','Pulse'],

  companySuffix: ['Inc','LLC','Corp','Ltd','Group','Solutions','Technologies',
    'Systems','Services','Industries','Enterprises','Partners','Ventures','Dynamics'],

  loremWords: ['lorem','ipsum','dolor','sit','amet','consectetur','adipiscing','elit',
    'sed','do','eiusmod','tempor','incididunt','ut','labore','et','dolore','magna',
    'aliqua','enim','ad','minim','veniam','quis','nostrud','exercitation','ullamco',
    'laboris','nisi','aliquip','ex','ea','commodo','consequat']
};
```

## Generator Functions (app.js)

```javascript
const rand = arr => arr[crypto.getRandomValues(new Uint32Array(1))[0] % arr.length];
const randInt = (min, max) => min + (crypto.getRandomValues(new Uint32Array(1))[0] % (max - min + 1));

const generators = {
  'Full Name':    () => `${rand(DATA.firstNames)} ${rand(DATA.lastNames)}`,
  'First Name':   () => rand(DATA.firstNames),
  'Last Name':    () => rand(DATA.lastNames),
  'Email':        () => {
    const name = `${rand(DATA.firstNames).toLowerCase()}.${rand(DATA.lastNames).toLowerCase()}`;
    return `${name}@${rand(DATA.domains)}`;
  },
  'Phone (US)':   () => {
    const area = randInt(200,999);
    const pre  = randInt(200,999);
    const line = String(randInt(1000,9999));
    return `(${area}) ${pre}-${line}`;
  },
  'Username':     () => `${rand(DATA.adjectives)}_${rand(DATA.animals)}_${randInt(10,99)}`,
  'Address':      () => {
    const num  = randInt(1, 9999);
    const zip  = String(randInt(10000,99999));
    return `${num} ${rand(DATA.streetNames)} ${rand(DATA.streetTypes)}, ${rand(DATA.cities)}, ${rand(DATA.states)} ${zip}`;
  },
  'Company':      () => `${rand(DATA.companyWords)} ${rand(DATA.companySuffix)}`,
  'UUID':         () => crypto.randomUUID(),
  'Credit Card':  () => generateLuhn(),
  'Date':         () => {
    const start = new Date(2000,0,1), end = new Date();
    const d = new Date(start.getTime() + Math.random() * (end - start));
    return d.toISOString().split('T')[0];
  },
  'Lorem':        () => {
    const count = randInt(8, 20);
    return Array.from({length: count}, () => rand(DATA.loremWords)).join(' ') + '.';
  },
  'Hex Color':    () => '#' + [...crypto.getRandomValues(new Uint8Array(3))]
                          .map(v => v.toString(16).padStart(2,'0')).join('').toUpperCase(),
  'IP Address':   () => Array.from({length:4}, () => randInt(0,255)).join('.'),
  'Number':       () => String(randInt(1, 99999))
};
```

## Luhn-Valid Credit Card Generator
```javascript
function generateLuhn() {
  // Visa: starts with 4, 16 digits
  const prefix = '4';
  const digits = [4, ...Array.from({length: 14}, () => randInt(0,9))];

  // Luhn check digit
  let sum = 0;
  for (let i = digits.length - 1; i >= 0; i--) {
    let d = digits[i];
    if ((digits.length - i) % 2 === 0) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
  }
  const check = (10 - (sum % 10)) % 10;
  digits.push(check);

  // Format: XXXX XXXX XXXX XXXX
  const formatted = digits.join('').match(/.{4}/g).join(' ');
  return `${formatted} (VISA test)`;
}
```

## Output Formats

**List (default):**
```
james.rodriguez@gmail.com
emma.williams@outlook.com
```

**JSON:**
```json
[
  "james.rodriguez@gmail.com",
  "emma.williams@outlook.com"
]
```

**CSV (single column for single type, multi-column if multi-type selected):**
```
email
james.rodriguez@gmail.com
emma.williams@outlook.com
```

## Multi-Column Mode
Allow selecting 2–4 types simultaneously → output as CSV with one column per type.
UI: each type chip has a "+" indicator when in multi-select mode (toggle via long-press or dedicated button).

## App State & Render

```javascript
const state = {
  type: 'Full Name',   // selected type key
  quantity: 10,        // 1–100
  format: 'list',      // 'list' | 'json' | 'csv'
  results: []          // generated strings
};

function generate() {
  state.results = Array.from(
    { length: state.quantity },
    () => generators[state.type]()
  );
  render();
}

function render() {
  const out = formatOutput(state.results, state.format);
  document.getElementById('output').textContent = out;
}
```

## Copy & Download
```javascript
function copyAll() {
  navigator.clipboard.writeText(document.getElementById('output').textContent);
  // button → "✓ Copied" for 1.5s
}

function download() {
  const ext = { list: 'txt', json: 'json', csv: 'csv' }[state.format];
  const content = document.getElementById('output').textContent;
  const blob = new Blob([content], { type: 'text/plain' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `fake-${state.type.toLowerCase().replace(/ /g,'-')}.${ext}`;
  a.click();
  URL.revokeObjectURL(a.href);
}
```

## Mobile UX
- Sidebar → horizontal scrollable chip row at top (no sidebar on mobile)
- Chips: 36px tall, icon + label, horizontally scrollable, no wrap
- Output area: `font-family: monospace`, font-size: 13px, min-height: 200px, `overflow-y: auto`
- Quantity: large range input (height 32px) + adjacent number display
- Generate / Copy / Download: full-width button row, 48px tall each
- Individual row copy on click (tap any line in output → copies just that line)

## Acceptance Criteria
- Select Email, quantity 20 → 20 unique-looking valid email strings
- Select UUID → all outputs are valid UUID v4 format (`crypto.randomUUID()`)
- Select Credit Card → all outputs are Luhn-valid 16-digit VISA numbers labeled "(VISA test)"
- Format → JSON → output is valid JSON array (verify via JSON.parse)
- Format → CSV → first line is header matching type name
- Download saves file with correct extension and content
- Works at 320px viewport. Chip row scrolls horizontally without wrapping.
- Lighthouse ≥ 90 performance

---
---

# DEPLOYMENT CHECKLIST (all three)

## CI Workflow (`ci.yml`) — HTML standard
```yaml
name: CI
on:
  push:
    branches: [main, 'feat/**']
  pull_request:
    branches: [main]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: HTMLHint
        run: npx --yes htmlhint "**/*.html" --ignore "node_modules/**"
      - name: LHCI
        uses: treosh/lighthouse-ci-action@v11
        with:
          urls: https://jpgbmr.github.io/${{ github.event.repository.name }}/
          uploadArtifacts: true
          temporaryPublicStorage: true
        continue-on-error: true
```

## Pages Deploy (`cd-pages.yml`) — standard
```yaml
name: Deploy to Pages
on:
  push:
    branches: [main]
permissions:
  contents: read
  pages: write
  id-token: write
concurrency:
  group: pages
  cancel-in-progress: true
jobs:
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/configure-pages@v5
      - uses: actions/upload-pages-artifact@v3
        with:
          path: '.'
      - uses: actions/deploy-pages@v4
        id: deployment
```

## Launch Steps (Vitalik runs after each build)
```bash
# 1. Create repo
gh repo create JPGBMR/{project} --public --description "{desc}"

# 2. Push
git init && git add . && git commit -m "feat: initial release — {project}"
git remote add origin https://github.com/JPGBMR/{project}.git
git push -u origin main

# 3. Enable Pages
gh api repos/JPGBMR/{project}/pages -X POST \
  -f "source[branch]=main" -f "source[path]=/"

# 4. Add topics
gh repo edit JPGBMR/{project} \
  --add-topic html --add-topic javascript \
  --add-topic web-app --add-topic open-source

# 5. Add labels
gh label create "build: vitalik" --color "0052cc" --repo "JPGBMR/{project}" 2>/dev/null || true
gh label create "agent"          --color "bfd4f2" --repo "JPGBMR/{project}" 2>/dev/null || true
```

## Live URLs after deploy
- `https://jpgbmr.github.io/sleep-calculator/`
- `https://jpgbmr.github.io/color-from-image/`
- `https://jpgbmr.github.io/fake-data-gen/`

---

## MESSAGE TO VITALIK

```
BUILD ORDER:
1. sleep-calculator  — pure math, 0 dependencies, 60 lines. Ship in 30 min.
2. fake-data-gen     — copy the DATA object and generators verbatim from this spec.
                       Add the UI around them. The hard part is already done.
3. color-from-image  — copy medianCut() verbatim. Wire up FileReader → canvas
                       → medianCut → render swatches. The algorithm is provided.

WATCH OUT FOR:
- sleep-calculator: midnight crossover — use ((mins % 1440) + 1440) % 1440
- sleep-calculator: input[type=time] gives 24h "HH:MM" — convert to 12h for display
- fake-data-gen: crypto.getRandomValues returns Uint32Array — modulo the array length
- fake-data-gen: credit card labeled "(VISA test)" so no one mistakes it for real
- color-from-image: skip pixels with alpha < 128 (transparent images)
- color-from-image: scale image to 100×100 before sampling — essential for performance
- color-from-image: revoke object URLs on reset — URL.revokeObjectURL()
- ALL THREE: touch events on interactive elements — use pointer events not mouse-only
- ALL THREE: localStorage try/catch on every read

DO NOT:
- Import any npm package or use a CDN for sleep-calculator or fake-data-gen
- Use Math.random() anywhere — crypto.getRandomValues() only
- Add any framework — not even Alpine
- Use setInterval for timers — not needed in any of these three
- Leave any TODO in shipped code

DONE WHEN:
- 3 repos exist on JPGBMR, each with CI green on main
- 3 Pages URLs return 200 and are fully functional
- sleep-calculator: verified math correct for multiple inputs
- fake-data-gen: UUID output passes regex /^[0-9a-f-]{36}$/
- color-from-image: sunset photo returns warm palette
```
