# E-008 — High Traffic Builds
## 10 Projects People Actually Search For and Use Daily

**Ranking criteria: search intent + return visits + viral/sharing potential + one-shot confidence**

---

### RANK 1 — `sleep-calculator`
**Why people use it:** "What time should I go to sleep?" is googled millions of times daily.
**Hook:** Enter wake-up time → get 6 optimal bedtimes (90-min sleep cycles + 15 min fall-asleep buffer). OR reverse: enter bedtime → optimal wake times. Science-backed, shareable. People send this to friends.
**Weight:** ★☆☆ — 60 lines. Date arithmetic only.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Two big toggle buttons (Wake Up / Go to Bed). Time wheel input. Cards for each bedtime with cycle count and emoji indicator (☕ if cutting it close, 😴 if ideal). Share button generates a shareable text snippet.
**Colombo must spec:** Cycle math: `bedtime = wakeTime - (cycles × 90min) - 15min` for cycles 2–6. Handle midnight crossover (modulo 1440 minutes). `toLocaleTimeString` for display.
**Acceptance:** Input "7:00 AM wake" → outputs "11:45 PM, 10:15 PM, 8:45 PM, 7:15 PM, 5:45 PM, 4:15 PM" with cycle labels.

---

### RANK 2 — `diff-checker`
**Why people use it:** Developers, writers, legal teams — everyone compares two pieces of text. diffchecker.com gets millions of monthly visits.
**Hook:** Two text panels side by side. Changes highlighted inline: green = added, red = removed, yellow = modified line. Line numbers. Download diff as .txt. Copy diff button.
**Weight:** ★★☆ — Myers diff algorithm ~80 lines + UI.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Split pane (paste LEFT, paste RIGHT). Diff renders in a third panel below or replaces right panel. Mode toggle: character-level vs line-level diff. Stats bar: X lines added, Y removed.
**Colombo must spec:** LCS-based diff in plain JS. Line tokenization first, then char-level within changed lines. Render as a sequence of `<span class="added|removed|unchanged">` inside `<pre>`. No external lib.
**Acceptance:** Paste "Hello World" / "Hello Earth" → "Hello " unchanged, "World" red, "Earth" green. Line mode and char mode both work.

---

### RANK 3 — `css-shadow-gen`
**Why people use it:** Every frontend developer needs a box-shadow. They all Google "css box shadow generator" and bookmark the first good result.
**Hook:** Live preview card updates as you drag sliders. Multiple shadow layers (add/remove). Copy CSS one click. Presets: "Soft", "Hard", "Glow", "Inset", "Neumorphism".
**Weight:** ★☆☆ — 80 lines. Pure CSS string concatenation.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Preview card (white card on grey bg, shows shadow live). Controls: X offset, Y offset, blur, spread (sliders), color picker, opacity. Inset toggle. "+ Add Layer" for multiple shadows. Layers listed with individual delete. Output: `box-shadow: Xpx Ypx Ypx Xpx rgba(...)` in a copyable code block. Also generates `text-shadow` variant toggle.
**Colombo must spec:** State = array of shadow objects. `render()` joins all to CSS string, applies to preview element. Color picker → `rgba()` with alpha channel. Preset values as named constants.
**Acceptance:** Default shadow renders on page load. Slider changes update preview in real-time. Multi-layer shadow renders correctly. Copy button copies valid CSS.

---

### RANK 4 — `loan-calculator`
**Why people use it:** "Loan calculator" is one of the highest-search-volume financial queries on the internet. People making real money decisions.
**Hook:** Enter principal, interest rate, term → monthly payment + total interest paid + total cost. Amortization table (month by month breakdown). Payment vs interest split shown as a simple SVG donut chart (no library).
**Weight:** ★☆☆ — 90 lines. Financial math + SVG.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Three inputs (loan amount, annual interest %, years). Big result card: monthly payment in huge text, total interest, total cost. Toggle: show full amortization table (month, payment, principal paid, interest paid, remaining balance). SVG donut: principal vs interest split. Currency formatter (Intl.NumberFormat).
**Colombo must spec:** `M = P[r(1+r)^n]/[(1+r)^n-1]` where r = monthly rate (annual/12/100), n = months. Amortization: each month, interest = balance × r, principal = M - interest, balance -= principal. SVG donut: two `<circle>` elements with `stroke-dasharray`.
**Acceptance:** $300,000 at 6.5% for 30 years → $1,896.20/month, $382,633 total interest. Amortization table first row correct. Chart shows ~56% interest / 44% principal.

---

### RANK 5 — `fake-data-gen`
**Why people use it:** Developers need test data for forms, databases, demos. Every developer hits this need weekly. Currently they install Faker.js or go to a website. This replaces that.
**Hook:** Pick data type (Name, Email, Phone, Address, UUID, Username, Company, Credit Card [test], Lorem text, Date, Color). Set quantity (1–100). Generate → copy all or download as CSV/JSON. All generated client-side, nothing leaves the browser.
**Weight:** ★★☆ — 150 lines. Large static data tables + generators.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Left sidebar: type selector (chips, multi-select for CSV columns). Right: output panel with monospace result. Quantity slider. Format toggle (plain list / JSON array / CSV). Regenerate button. Copy all. Download. Each row individually copyable on click.
**Colombo must spec:** Static data arrays embedded in app.js: ~100 first names, ~100 last names, ~50 domains, ~50 street names, ~50 cities, ~50 companies. Combine with crypto.getRandomValues() for seeding. UUID: `crypto.randomUUID()`. Credit card: Luhn-valid test number generators (VISA: starts 4, MASTERCARD: starts 5).
**Acceptance:** Generate 10 emails → 10 unique valid-looking emails. Generate 5 UUIDs → 5 valid UUID v4 format. Download as CSV has header row. JSON is valid parseable array.

---

### RANK 6 — `color-from-image`
**Why people use it:** Designers constantly need to extract a colour palette from a photo — for brand colours, UI themes, presentations. They pay for this in design tools. Free browser version = bookmarked immediately.
**Hook:** Drop or upload any image → instantly see the 8 dominant colours as swatches with hex codes. One-click copy per colour. Download palette as PNG swatch strip or CSS variables. Works on photos, screenshots, logos, anything.
**Weight:** ★★☆ — Canvas API + colour quantization ~120 lines.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Large drop zone (drag image or click to upload). Image preview (constrained to 400px). Palette: 8 large swatches in a row, each shows hex code below, copy icon on hover. "Copy as CSS variables" → `--color-1: #xxxxxx;` etc. Export palette as flat PNG (8 colour blocks, hex labels, white bg).
**Colombo must spec:** Quantization: draw image to offscreen canvas (max 100×100 for performance). Sample every pixel → build colour histogram → median cut algorithm to reduce to 8 clusters → return cluster centroids. Sort by frequency. Median cut: ~60 lines. Canvas drawImage with `imageSmoothingEnabled: false` for speed.
**Acceptance:** Upload a sunset photo → returns warm palette (oranges, reds, purples). Upload a logo → dominant brand colours appear. Export as CSS variables produces valid CSS. Export PNG shows 8 coloured blocks.

---

### RANK 7 — `qr-scanner`
**Why people use it:** People on desktop constantly need to scan a QR code that's shown on their phone screen or in a document. No native desktop QR scanner. They Google this, find terrible apps, get frustrated.
**Hook:** One click → camera activates → QR code detected automatically → URL or text shown with copy button + auto-open URL. Also accepts image upload (scan QR from a screenshot).
**Weight:** ★★☆ — getUserMedia + jsQR CDN (~100 lines).
**Files:** `index.html` + `style.css` + `app.js`
**CDN:** jsQR (1 dependency, MIT license, ~30KB).
**Key UI:** Big camera viewfinder with a scanning animation frame. Auto-detects and highlights QR on success (green border flash). Result card: raw text (monospace), "Open URL" button if content is a URL, copy button, scan again button. Tab: Upload Image (drag image with a QR → decode). History of last 5 scans in localStorage.
**Colombo must spec:** `navigator.mediaDevices.getUserMedia({video: {facingMode: 'environment'}})` → stream to `<video>`. Each animation frame: `canvasCtx.drawImage(video)` → `getImageData` → `jsQR(data, width, height)`. On result: cancel animation frame, show result. Image upload: FileReader → Image → same canvas path.
**Acceptance:** Open on desktop with webcam → point at QR code → detects within 1 second → shows decoded text. URL QR opens link. Image upload with QR screenshot → decodes correctly.

---

### RANK 8 — `meme-gen`
**Why people use it:** Memes are the internet's primary communication format. People make them constantly for Slack, WhatsApp, Twitter. imgflip.com gets 30M+ monthly visits.
**Hook:** Upload any image OR pick from 12 built-in popular templates (Drake, Distracted Boyfriend, This Is Fine, etc.). Add top text + bottom text. Font size, colour, stroke. Download as PNG. Zero upload — everything stays in browser.
**Weight:** ★★☆ — Canvas API + text rendering ~120 lines.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Template grid (12 thumbnails, click to select) OR "Upload Your Own" button. Canvas preview (centered, responsive). Text inputs: top + bottom, with font size slider, colour picker, bold toggle. Download button (canvas.toBlob → anchor download). Share button (Web Share API on mobile).
**Colombo must spec:** Canvas text rendering: `ctx.font = 'bold {size}px Impact'`. Stroke first: `ctx.strokeStyle = '#000'; ctx.lineWidth = 6; ctx.strokeText(text, x, y)`. Fill over: `ctx.fillStyle = color; ctx.fillText(text, x, y)`. Text wrap: split at spaces, measure, wrap at 90% canvas width. Templates: 12 bundled base64 inline images (~5KB each, small enough to embed). Top text Y = fontSize + 10, bottom text Y = canvasHeight - 10.
**Acceptance:** Select Drake template → add top/bottom text → preview shows text with black stroke → download saves PNG with text. Upload custom image → same flow. Text wraps on long input.

---

### RANK 9 — `screen-recorder`
**Why people use it:** People pay $30/year for Loom. This does the same core thing for free in the browser. Bug reports, tutorials, demos, feedback — massive daily use case.
**Hook:** Click record → pick screen/window/tab (browser native picker) → record → stop → preview → download as WebM. No install, no account, no upload. 100% local.
**Weight:** ★★☆ — getDisplayMedia + MediaRecorder ~100 lines.
**Files:** `index.html` + `style.css` + `app.js`
**Key UI:** Single big "Start Recording" button. On click: browser shows native screen picker. Recording: pulsing red dot + elapsed timer + "Stop" button. After stop: video preview player. Download button. Record again button. Option: include microphone audio (checkbox before recording starts).
**Colombo must spec:** `navigator.mediaDevices.getDisplayMedia({video: true, audio: true})`. Mic: `getUserMedia({audio: true})` → `AudioContext` → merge tracks. `MediaRecorder(stream, {mimeType: 'video/webm;codecs=vp9'})`. Push chunks to array on `ondataavailable`. On stop: `new Blob(chunks, {type: 'video/webm'})` → `URL.createObjectURL` → video src + download anchor. Fallback mimeType: `video/webm` (no codec spec) if vp9 not supported.
**Acceptance:** Click Record → browser picker appears → select a tab → recording starts → elapsed timer counts → Stop → video preview plays back the recording → Download saves .webm file.

---

### RANK 10 — `resume-builder`
**Why people use it:** "Resume builder" is one of the most searched terms on the internet. People have immediate, high-stakes need. They hate paying for this.
**Hook:** Fill in your details (name, contact, summary, experience, education, skills) → choose from 3 clean templates → live preview updates → download as PDF. No account, no upload, no watermark.
**Weight:** ★★★ — jsPDF CDN + form management ~200 lines. Heaviest on this list.
**Files:** `index.html` + `style.css` + `app.js`
**CDN:** jsPDF (1 dependency).
**Key UI:** Left: form sections (collapsible accordions — Personal, Experience ×N, Education ×N, Skills). Right: live PDF preview (rendered as styled HTML div, not actual PDF until download). Add/remove experience and education entries. Three template buttons (Classic, Modern, Minimal). Download PDF button.
**Colombo must spec:** Template = CSS class on preview div. jsPDF: `html()` method on the preview div (renders HTML to PDF). Fonts: system serif for Classic, system sans for Modern. Experience entries: dynamic add/remove via JS with template literals. Skills: tag input (type + enter = chip). jsPDF html() requires `html2canvas` as peer — include both on CDN.
**Acceptance:** Fill all fields → preview updates live → switch template → preview changes style → Download PDF → file opens in PDF reader with all entered content correctly formatted.

---

## BUILD ORDER FOR VITALIK

```
DAY 1 (fast wins, ship 3):
  sleep-calculator   60 lines   pure math, zero risk
  css-shadow-gen     80 lines   pure CSS string gen
  loan-calculator    90 lines   financial math + SVG donut

DAY 2 (medium, ship 2):
  diff-checker       Myers algo + UI
  fake-data-gen      large static data tables + generators

DAY 3 (APIs + media, ship 2):
  qr-scanner         jsQR CDN + getUserMedia
  color-from-image   canvas + median cut quantization

DAY 4 (canvas heavy, ship 2):
  meme-gen           canvas text rendering + templates
  screen-recorder    getDisplayMedia + MediaRecorder

DAY 5 (heaviest, ship 1):
  resume-builder     jsPDF + html2canvas + form management
```

**Guaranteed high-traffic tools:** sleep-calculator, css-shadow-gen, loan-calculator, diff-checker.
**Viral/shareable:** sleep-calculator, meme-gen.
**Developer daily drivers:** diff-checker, css-shadow-gen, fake-data-gen, qr-scanner.
**High user intent (people need this NOW):** loan-calculator, resume-builder.
