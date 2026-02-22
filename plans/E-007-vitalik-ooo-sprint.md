# ELENA → COLOMBO → VITALIK
## E-007 — OOO Sprint: 15 Fresh Candidates → Colombo Top 10

---

```
[CONTEXT]
All pipeline projects (E-005, E-006) are already queued.
User wants net-new ideas not already in the wip- list.
Criteria: low weight (one session), high portfolio impact, fresh.
```

---

## ELENA — 15 FRESH CANDIDATES

Scored: Weight (1=light, 5=heavy) · Impact (1=low, 5=high)

| # | Project | Weight | Impact | Why |
|---|---------|--------|--------|-----|
| 1 | **jwt-decoder** | 1 | 5 | Paste JWT → decoded header/payload/expiry countdown. atob() + JSON.parse. Every dev needs this weekly. ~50 lines. |
| 2 | **2048** | 2 | 5 | Addictive number puzzle. Pure DOM+CSS grid, no canvas. Arrow keys + swipe. ~120 lines. Universally loved. |
| 3 | **epoch-converter** | 1 | 4 | Unix timestamp ↔ human date, live, timezone-aware. Copy button. Developer daily driver. ~60 lines. |
| 4 | **bpm-tap** | 1 | 4 | Tap spacebar → see BPM. Web Audio API click sound. LED display aesthetic. ~40 lines. Surprise delight. |
| 5 | **ascii-webcam** | 2 | 5 | getUserMedia + canvas → live ASCII video feed. Jaw-dropping demo. ~100 lines. Portfolio showstopper. |
| 6 | **lissajous** | 1 | 4 | Two frequency sliders → watch geometric curves animate in real-time. Canvas 2D. ~60 lines. Pure math beauty. |
| 7 | **wordle-clone** | 3 | 5 | 5-letter word guessing game, keyboard UI, streak tracking, color feedback. ~200 lines. Instantly recognizable. |
| 8 | **noise-field** | 2 | 5 | Perlin noise flow field — thousands of particles following vector field. Canvas. ~100 lines. Hypnotic. |
| 9 | **meta-tag-gen** | 1 | 4 | Fill form → get og:meta + twitter:card tags to copy-paste. Developer tool. ~80 lines. SEO teams will love it. |
| 10 | **color-blindness** | 2 | 4 | Upload image → view through deuteranopia/protanopia/tritanopia filter. Canvas + 3×3 color matrix. Educational. ~120 lines. |
| 11 | **chord-finder** | 3 | 4 | Click piano keys → identifies the chord. Web Audio API plays notes. Music theory logic. ~150 lines. |
| 12 | **gitignore-gen** | 1 | 4 | Select stack(s) → get a merged .gitignore → copy or download. Static data + UI. ~60 lines. Dev daily driver. |
| 13 | **breakout** | 2 | 4 | Arkanoid-style ball + bricks. Canvas 2D, requestAnimationFrame, collision. ~150 lines. Classic game. |
| 14 | **minesweeper** | 2 | 4 | Classic grid game, flag mode, first-click safe, timer, high score. Pure DOM. ~150 lines. |
| 15 | **svg-path-viewer** | 2 | 3 | Paste SVG `d` attribute → visualized path, bounding box, scale controls. Developer tool. ~100 lines. |

---

## COLOMBO — SELECTION & RANKING

**Colombo's cuts:**
- `chord-finder` (weight 3, requires music theory correctness — too many edge cases for one-shot)
- `wordle-clone` (weight 3, needs a static word list bundled — largest scope)
- `svg-path-viewer` (lowest impact score, niche audience)
- `color-blindness` (good but drops behind ascii-webcam for wow factor — same Canvas category)
- `minesweeper` (breakout covers the canvas game slot better, more visual)

**Colombo's ranked 10 — ordered by: guaranteed ship first, peak impact last:**

---

### RANK 1 — `epoch-converter`
**Why first:** 60 lines, zero risk, ships in 30 minutes. Clears Vitalik's hands for bigger builds.
**Stack:** Vanilla JS. `new Date(ts * 1000).toLocaleString()`. Timezone via `Intl.DateTimeFormat`.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** Input accepts seconds OR milliseconds (auto-detect by value magnitude >1e10). Live output updates on keyup. Three formats: ISO 8601, local, relative ("3 days ago"). Copy all. Reverse: pick a date → get epoch.
**Acceptance:** Input `1708560000` → shows `2024-02-22T00:00:00Z` + local time + "X days ago". Reverse works. Copy button puts value in clipboard.

---

### RANK 2 — `jwt-decoder`
**Why second:** 50 lines, ships in 20 minutes, every developer bookmarks it on day one.
**Stack:** Vanilla JS. `atob()` + `JSON.parse()`. Zero dependencies.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** Split JWT on `.` → base64url decode each part (replace `-`→`+`, `_`→`/`, pad `==`). Parse JSON. Render header + payload as syntax-highlighted JSON (CSS-only highlight via `<pre>` + regex span injection). Show `exp` as human datetime + color-coded expiry badge (green=valid, red=expired, orange=<1h). Signature section shows raw bytes, not decoded (signatures are not base64 JSON). Warning banner if no `exp` claim.
**Acceptance:** Paste any valid JWT → header/payload render formatted. `exp` shows countdown. Invalid JWT shows clear error inline.

---

### RANK 3 — `bpm-tap`
**Why third:** 40 lines, ships in 15 minutes, pure delight. Musicians, producers, DJs will share it.
**Stack:** Vanilla JS + Web Audio API (one click sound, synthesized — no audio file).
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** Track array of timestamps. On each tap (spacebar OR big button click): push `Date.now()`, trim to last 8 taps, compute average interval, BPM = 60000 / avgInterval. Reset if last tap >3s ago. Web Audio: `AudioContext.createOscillator()` for a 2ms click on each tap. Display: huge LED-style number. Confidence indicator (±X BPM) based on tap variance. Common BPM labels: "Adagio 66", "Andante 92", "Allegro 132" etc shown below.
**Design:** Full-screen dark background. Massive 7-segment LED font number (CSS). Tap anywhere on page.
**Acceptance:** Tap 8× at consistent tempo → BPM within ±2 of true value. Stops after 3s inactivity. Reset button works. Spacebar works.

---

### RANK 4 — `meta-tag-gen`
**Why fourth:** 80 lines, ships fast, SEO devs will bookmark it. Real daily utility.
**Stack:** Vanilla JS. Zero dependencies.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** Form fields: title (60 char counter), description (160 char counter), canonical URL, og:image URL, og:type (website/article/product), Twitter card type, author. Live preview panel shows rendered `<meta>` tags. Copy-all button. Validation: warn if title >60, description >160, image not https. Preview card: approximates how link looks in Slack/Twitter/WhatsApp (title + description + image thumbnail via CSS).
**Acceptance:** Fill form → meta tags appear live. Copy-all puts all tags in clipboard. Character counters turn red over limit. Link preview approximates real appearance.

---

### RANK 5 — `gitignore-gen`
**Why fifth:** 60 lines + static data, ships fast, every project starts with this.
**Stack:** Vanilla JS. Zero dependencies. Stack data embedded as JS object.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** Stack chips: Node, Python, Java, Go, Rust, Unity, macOS, Windows, Linux, VS Code, JetBrains, Xcode, Android. Multi-select (toggle). On selection change: merge gitignore templates for selected stacks (dedup lines, sort sections). Show in `<pre>`. Copy + Download buttons. Data: embed top-10 most popular gitignore templates inline as JS string constants (source: github/gitignore repo content, static).
**Acceptance:** Select Node + macOS → merged .gitignore with both sections. Download saves `.gitignore` file. Deselect one → updates live.

---

### RANK 6 — `lissajous`
**Why sixth:** 60 lines, pure math, gorgeous animation, requires zero prior knowledge to enjoy.
**Stack:** Vanilla JS. HTML Canvas 2D. Zero dependencies.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** `x(t) = A·sin(a·t + δ)`, `y(t) = B·sin(b·t)`. Sliders: frequency-x (1–10), frequency-y (1–10), phase delta (0–2π), line width, speed, trace length. Draw N points per frame, fade old points (globalAlpha decay or trail buffer). Color cycles through hue over time. Presets button: loads known beautiful ratios (3:2, 5:4, etc.) with labels. Animation loops continuously.
**Design:** Black canvas, glowing neon line. Controls panel on right, minimal.
**Acceptance:** Default 3:2 ratio renders a recognizable Lissajous figure. All sliders update live. Phase slider animates figure rotation. Presets load and label correctly.

---

### RANK 7 — `noise-field`
**Why seventh:** 100 lines, the most visually hypnotic thing on the portfolio. No Three.js needed.
**Stack:** Vanilla JS. HTML Canvas 2D. Needs a tiny noise function (~30 lines of simplex/Perlin inline).
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** Grid of points across canvas. Each point has a velocity vector derived from `noise(x, y, time*speed)`. Each frame: advance all particles along their noise-derived angle. Draw short line at each position. Particles wrap around edges. Controls: particle count (500–5000), speed, noise scale, line length, color mode (single hue / rainbow / monochrome). Fade canvas each frame (fillRect with low alpha) for trail effect.
**Noise implementation:** Use 2D simplex noise inline (~30 lines). Colombo provides this verbatim in the blueprint — Vitalik does not implement it from scratch.
**Acceptance:** Canvas loads with flowing particle field. Particles follow smooth curves. Speed slider visibly changes animation tempo. Color mode switch works.

---

### RANK 8 — `2048`
**Why eighth:** 120 lines, pure DOM+CSS, no canvas, universally loved mechanic.
**Stack:** Vanilla JS. CSS Grid. Zero dependencies.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** 4×4 grid stored as flat array[16]. On arrow key or swipe: slide all tiles in direction, merge equal adjacent tiles (each tile merges once per move), add new tile (value 2 with p=0.9, value 4 with p=0.1) to random empty cell. Score = sum of all merge values. Win condition: any tile = 2048. Game over: no valid moves exist. Tile colors: CSS custom property per power-of-2 value (2=beige, 4=tan, 8=orange, 1024=gold). Tile appearance: CSS transition `transform + background-color` for merge animation (scale 1.1 → 1). High score in localStorage.
**Acceptance:** Arrow keys move tiles. Tiles merge correctly (two 4s → one 8, scored 8). New tile appears after each move. Win/game-over overlays trigger at correct conditions. Swipe works on mobile. High score persists.

---

### RANK 9 — `breakout`
**Why ninth:** 150 lines, canvas physics, satisfying to play, demonstrates Vitalik's game loop skill.
**Stack:** Vanilla JS. HTML Canvas 2D. Zero dependencies.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** Ball physics: position + velocity vectors, `requestAnimationFrame`. Paddle: mouse/touch tracks X. Bricks: 2D array, each brick has health (1–3 hits, color-coded). Collision: ball vs brick = AABB, determine which face was hit to reflect correct axis. Ball vs paddle: reflect Y, adjust X velocity based on hit position (left side = deflect left). Lives (3). Speed increases every 5 bricks broken. Level 2: add indestructible bricks. Power-up: 1-in-5 bricks drops a falling powerup (wide paddle, multi-ball, slow). Score: localStorage high score.
**Acceptance:** Ball bounces off walls, paddle, and bricks. Brick hit removes it. Ball lost → life lost. Game over at 0 lives. Power-ups fall and apply on paddle catch. Score increments per brick.

---

### RANK 10 — `ascii-webcam`
**Why last (saved for peak impact):** 100 lines but needs camera permission UX. The most impressive demo on the entire portfolio. One look and people share it.
**Stack:** Vanilla JS. `navigator.mediaDevices.getUserMedia`. Canvas. Zero dependencies.
**Files:** `index.html` + `style.css` + `app.js`
**Key logic:** getUserMedia `{video: true}` → stream to hidden `<video>`. Each frame (via requestAnimationFrame at 15fps): drawImage video to offscreen canvas, getImageData, for each pixel-block (8×8 or 12×12): compute brightness (0.299R + 0.587G + 0.114B), map to character in density string `" .:-=+*#%@"`. Output to `<pre>` or a canvas-drawn monospace grid. Controls: font size (4–16), invert, color mode (green-on-black / white-on-black / color — for color mode: use actual pixel hue on the char). Mirror toggle.
**Permission UX:** If camera denied → show a fallback demo mode using a static image cycling through preset images.
**Acceptance:** Camera feed renders as ASCII in real-time. Characters update as you move. Font size slider changes resolution. Color mode switches appearance. Fallback demo works without camera.

---

## VITALIK — YOUR OOO SPRINT LIST

**Ship in this order. Each is a clean repo on JPGBMR with CI + Pages.**

```
RANK 1  epoch-converter      30 min   vanilla JS    timezone-aware timestamp converter
RANK 2  jwt-decoder          20 min   vanilla JS    paste JWT → decoded + expiry
RANK 3  bpm-tap              15 min   vanilla JS    tap spacebar → live BPM
RANK 4  meta-tag-gen         45 min   vanilla JS    fill form → og/twitter meta tags
RANK 5  gitignore-gen        45 min   vanilla JS    pick stacks → download .gitignore
RANK 6  lissajous            40 min   canvas 2D     frequency sliders → math curves
RANK 7  noise-field          60 min   canvas 2D     perlin particles (noise fn provided)
RANK 8  2048                 90 min   DOM+CSS       tile puzzle, swipe support
RANK 9  breakout             90 min   canvas 2D     ball + bricks + powerups
RANK 10 ascii-webcam         60 min   getUserMedia  live video → ASCII feed
```

**Total estimate: ~8 hours clean build time.**
**Guaranteed ships before OOO: 1–5 (under 3 hours combined).**
**Stretch goals: 6–8. Leave 9–10 for next sprint if needed.**

**WATCH OUT FOR (all projects):**
- Mobile touch events on all interactive elements (pointer events, not mouse-only)
- crypto.getRandomValues() not Math.random() for any randomness (dice, 2048 tile spawn)
- localStorage try/catch on every read (corrupted data must not crash the app)
- No hardcoded pixel values — use CSS custom properties and rem units
- Camera permission (ascii-webcam): always provide a fallback demo

**DO NOT:**
- Add a framework. Not even Alpine. Not even htmx.
- Reach for npm for anything in this list
- Add a build step
- Ship a file with a TODO in it
