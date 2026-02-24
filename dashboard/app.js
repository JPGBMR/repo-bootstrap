(() => {
  const PATHS = {
    inventory: "../state/inventory-ledger.json",
    grading: "../state/qa-grading.json",
    feed: "../state/agent-feed.jsonl"
  };

  const STAGE_ORDER = ["plan", "blueprint", "build", "qa", "route", "done"];
  const STATUS_ORDER = { blocked: 0, fail: 1, unknown: 2, pass: 3 };
  const LANE_ORDER = ["Elena", "Colombo", "Vitalik", "Athena", "Ship"];
  const CANONICAL_CONTEXT = /^E-\d{3}(?:-\d{2})?$/;
  const REASON_CODE = /^[A-Z0-9_]+$/;
  const STALE_HOURS = 24;
  const TIMELINE_CAP = 20;

  const el = {
    kpiBar: document.getElementById("kpiBar"),
    nextAction: document.getElementById("nextAction"),
    trustStats: document.getElementById("trustStats"),
    trustIssues: document.getElementById("trustIssues"),
    statusFilter: document.getElementById("statusFilter"),
    agentFilter: document.getElementById("agentFilter"),
    waveFilter: document.getElementById("waveFilter"),
    searchFilter: document.getElementById("searchFilter"),
    laneGrid: document.getElementById("laneGrid"),
    needsMapping: document.getElementById("needsMapping"),
    summaryList: document.getElementById("summaryList"),
    summaryEmpty: document.getElementById("summaryEmpty"),
    contextList: document.getElementById("contextList"),
    contextEmpty: document.getElementById("contextEmpty"),
    needsActionList: document.getElementById("needsActionList"),
    needsActionEmpty: document.getElementById("needsActionEmpty"),
    latestDecision: document.getElementById("latestDecision"),
    timeline: document.getElementById("timeline"),
    timelineEmpty: document.getElementById("timelineEmpty")
  };

  const state = {
    contexts: [],
    summaries: [],
    needsAction: [],
    selectedKey: "",
    trust: {
      total: 0,
      valid: 0,
      rejected: 0,
      rejectedLegacy: 0,
      conflicts: 0,
      stale: 0,
      orphans: 0,
      diagnostics: []
    }
  };

  function parseTimestamp(value) {
    const ms = Date.parse(value);
    return Number.isNaN(ms) ? null : ms;
  }

  function statusClass(value) {
    const s = String(value || "").toLowerCase();
    return ["pass", "fail", "blocked", "unknown"].includes(s) ? s : "unknown";
  }

  function statusBadge(status) {
    const s = statusClass(status);
    return `<span class="badge status-${s}">${s}</span>`;
  }

  function stageIndex(stage) {
    return STAGE_ORDER.indexOf(String(stage || "").toLowerCase());
  }

  function normalizeAgent(value) {
    const v = String(value || "").toLowerCase();
    if (v.includes("elena")) return "elena";
    if (v.includes("colombo")) return "colombo";
    if (v.includes("vitalic") || v.includes("vitalik")) return "vitalic";
    if (v.includes("athena")) return "athena";
    return "unknown";
  }

  function laneFromAgent(agent) {
    if (agent === "elena") return "Elena";
    if (agent === "colombo") return "Colombo";
    if (agent === "vitalic") return "Vitalik";
    if (agent === "athena") return "Athena";
    return "Needs Mapping";
  }

  function laneFromStage(stage, ownerAgent) {
    const s = String(stage || "").toLowerCase();
    if (s === "plan") return "Elena";
    if (s === "blueprint") return "Colombo";
    if (s === "build") return "Vitalik";
    if (s === "qa") return "Athena";
    if (s === "route" || s === "done") return "Ship";
    return laneFromAgent(ownerAgent);
  }

  function normalizeContextId(raw) {
    const value = String(raw || "").trim();
    if (CANONICAL_CONTEXT.test(value)) return { valid: true, legacy: false, canonical: value };
    const m = /^e-(\d{1,})(?:-(\d{1,2}))?$/i.exec(value);
    if (!m) return { valid: false, legacy: false, canonical: "" };
    const root = m[1].padStart(3, "0");
    const suffix = m[2] ? `-${m[2].padStart(2, "0")}` : "";
    return { valid: true, legacy: true, canonical: `E-${root}${suffix}` };
  }

  function rootContext(contextId) {
    const m = /^E-(\d{3})/.exec(contextId);
    return m ? `E-${m[1]}` : "E-000";
  }

  function requiredString(obj, field) {
    return typeof obj[field] === "string" && obj[field].trim().length > 0;
  }

  function addDiag(code, msg) {
    state.trust.diagnostics.push(`${code}: ${msg}`);
  }

  function markLegacy(msg) {
    state.trust.rejectedLegacy += 1;
    addDiag("rejected_legacy", msg);
  }

  async function loadJsonArray(path) {
    const res = await fetch(path, { cache: "no-store" });
    if (!res.ok) throw new Error(`missing file: ${path}`);
    const text = await res.text();
    if (!text.trim()) return [];
    const parsed = JSON.parse(text);
    return Array.isArray(parsed) ? parsed : [];
  }

  async function loadJsonl(path) {
    const res = await fetch(path, { cache: "no-store" });
    if (!res.ok) throw new Error(`missing file: ${path}`);
    const text = await res.text();
    if (!text.trim()) return [];

    const rows = [];
    text.split(/\r?\n/).forEach((line, i) => {
      const t = line.trim();
      if (!t) return;
      try {
        rows.push({ lineNo: i + 1, row: JSON.parse(t), parseError: "" });
      } catch {
        rows.push({ lineNo: i + 1, row: null, parseError: "invalid JSON" });
      }
    });
    return rows;
  }

  function validateLedger(row, idx) {
    const req = ["context_id", "spec_id", "wave_id", "stage", "owner", "status", "timestamp", "context_ref"];
    for (const key of req) if (!requiredString(row, key)) return { ok: false, code: "rejected_invalid", msg: `inventory row ${idx + 1} missing ${key}` };
    if (parseTimestamp(row.timestamp) === null) return { ok: false, code: "rejected_invalid", msg: `inventory row ${idx + 1} invalid timestamp` };
    if (stageIndex(row.stage) < 0) return { ok: false, code: "rejected_stage", msg: `inventory row ${idx + 1} invalid stage` };
    const norm = normalizeContextId(row.context_id);
    if (!norm.valid) return { ok: false, code: "rejected_invalid_context", msg: `inventory row ${idx + 1} invalid context` };
    if (norm.legacy) markLegacy(`inventory row ${idx + 1} context normalized ${row.context_id} -> ${norm.canonical}`);

    return {
      ok: true,
      row: {
        context_id: norm.canonical,
        spec_id: row.spec_id,
        wave_id: row.wave_id,
        stage: String(row.stage).toLowerCase(),
        owner: normalizeAgent(row.owner),
        status: statusClass(row.status),
        timestamp: row.timestamp,
        context_ref: row.context_ref
      }
    };
  }

  function validateGrading(row, idx) {
    const req = ["context_id", "spec_id", "status", "recommendation", "timestamp"];
    for (const key of req) if (!requiredString(row, key)) return { ok: false, code: "rejected_invalid", msg: `grading row ${idx + 1} missing ${key}` };
    if (parseTimestamp(row.timestamp) === null) return { ok: false, code: "rejected_invalid", msg: `grading row ${idx + 1} invalid timestamp` };
    const norm = normalizeContextId(row.context_id);
    if (!norm.valid) return { ok: false, code: "rejected_invalid_context", msg: `grading row ${idx + 1} invalid context` };
    if (norm.legacy) markLegacy(`grading row ${idx + 1} context normalized ${row.context_id} -> ${norm.canonical}`);

    const out = Object.assign({}, row, {
      context_id: norm.canonical,
      status: statusClass(row.status),
      github_gate: "unknown",
      blocked_reason_code: ""
    });

    if (requiredString(row, "github_gate")) {
      out.github_gate = String(row.github_gate).toLowerCase();
      out.blocked_reason_code = String(row.blocked_reason_code || "");
      if (!["pass", "blocked", "unknown"].includes(out.github_gate)) return { ok: false, code: "rejected_github_gate", msg: `grading row ${idx + 1} invalid github_gate` };
      if (out.github_gate === "blocked") {
        if (!REASON_CODE.test(out.blocked_reason_code)) return { ok: false, code: "rejected_github_gate", msg: `grading row ${idx + 1} blocked github_gate missing reason` };
      } else if (out.blocked_reason_code) {
        return { ok: false, code: "rejected_github_gate", msg: `grading row ${idx + 1} reason only allowed when blocked` };
      }
    } else {
      markLegacy(`grading row ${idx + 1} missing github_gate defaulted unknown`);
    }

    return { ok: true, row: out };
  }

  function inferLegacyStage(message, status) {
    const m = String(message || "").toLowerCase();
    if (m.includes("plan")) return "plan";
    if (m.includes("blueprint")) return "blueprint";
    if (m.includes("qa")) return "qa";
    if (m.includes("route")) return "route";
    if (m.includes("done") || m.includes("ship")) return "done";
    if (status === "blocked") return "qa";
    return "build";
  }

  function validateFeed(entry, idx) {
    if (entry.parseError) return { ok: false, code: "rejected_invalid", msg: `feed line ${entry.lineNo} ${entry.parseError}` };
    const row = entry.row;
    const baseReq = ["agent", "context_id", "status", "timestamp", "message"];
    for (const key of baseReq) if (!requiredString(row, key)) return { ok: false, code: "rejected_invalid", msg: `feed line ${entry.lineNo} missing ${key}` };
    if (parseTimestamp(row.timestamp) === null) return { ok: false, code: "rejected_invalid", msg: `feed line ${entry.lineNo} invalid timestamp` };

    const norm = normalizeContextId(row.context_id);
    if (!norm.valid) return { ok: false, code: "rejected_invalid_context", msg: `feed line ${entry.lineNo} invalid context` };
    if (norm.legacy) markLegacy(`feed line ${entry.lineNo} context normalized ${row.context_id} -> ${norm.canonical}`);

    const strict = requiredString(row, "entry_type") && requiredString(row, "stage") && ("refs" in row) && requiredString(row, "github_gate");
    const out = {
      entry_type: "event",
      agent: normalizeAgent(row.agent),
      context_id: norm.canonical,
      stage: "build",
      status: statusClass(row.status),
      timestamp: row.timestamp,
      message: row.message,
      refs: [],
      summary_scope: "",
      github_gate: "unknown",
      blocked_reason_code: ""
    };

    if (!strict) {
      markLegacy(`feed line ${entry.lineNo} legacy shape defaulted`);
      out.stage = inferLegacyStage(row.message, out.status);
      return { ok: true, row: out };
    }

    out.entry_type = String(row.entry_type).toLowerCase();
    out.stage = String(row.stage).toLowerCase();
    out.refs = row.refs;
    out.summary_scope = String(row.summary_scope || "").toLowerCase();
    out.github_gate = String(row.github_gate).toLowerCase();
    out.blocked_reason_code = String(row.blocked_reason_code || "");

    if (!["event", "evidence"].includes(out.entry_type)) return { ok: false, code: "rejected_feed_type", msg: `feed line ${entry.lineNo} invalid entry_type` };
    if (stageIndex(out.stage) < 0) return { ok: false, code: "rejected_stage", msg: `feed line ${entry.lineNo} invalid stage` };
    if (!Array.isArray(out.refs) || !out.refs.every((x) => typeof x === "string")) return { ok: false, code: "rejected_invalid", msg: `feed line ${entry.lineNo} invalid refs` };
    if (!["pass", "blocked", "unknown"].includes(out.github_gate)) return { ok: false, code: "rejected_github_gate", msg: `feed line ${entry.lineNo} invalid github_gate` };
    if (out.github_gate === "blocked") {
      if (!REASON_CODE.test(out.blocked_reason_code)) return { ok: false, code: "rejected_github_gate", msg: `feed line ${entry.lineNo} blocked gate missing reason` };
    } else if (out.blocked_reason_code) {
      return { ok: false, code: "rejected_github_gate", msg: `feed line ${entry.lineNo} reason allowed only when blocked` };
    }
    if (out.summary_scope && out.summary_scope !== "wave") return { ok: false, code: "rejected_invalid", msg: `feed line ${entry.lineNo} invalid summary_scope` };

    return { ok: true, row: out };
  }

  function enforceStageGate(feedRows) {
    const byContext = new Map();
    feedRows.forEach((r) => {
      if (!byContext.has(r.context_id)) byContext.set(r.context_id, []);
      byContext.get(r.context_id).push(r);
    });

    const accepted = [];
    byContext.forEach((rows, contextId) => {
      const sorted = rows.slice().sort((a, b) => parseTimestamp(a.timestamp) - parseTimestamp(b.timestamp));
      let current = -1;
      sorted.forEach((r) => {
        if (r.entry_type !== "event") {
          accepted.push(r);
          return;
        }
        const idx = stageIndex(r.stage);
        if (current === -1) {
          if (idx !== 0) {
            addDiag("rejected_transition", `context ${contextId} first stage must be plan`);
            return;
          }
          current = idx;
          accepted.push(r);
          return;
        }
        if (idx === current || idx === current + 1) {
          current = Math.max(current, idx);
          accepted.push(r);
        } else {
          addDiag("rejected_transition", `context ${contextId} invalid transition ${STAGE_ORDER[current]} -> ${r.stage}`);
        }
      });
    });

    return accepted;
  }

  function deriveState(ledgerRows, gradingRows, feedRows) {
    const ledgerByKey = new Map();
    const gradingByKey = new Map();
    const feedByContext = new Map();

    ledgerRows.forEach((r) => {
      const key = `${r.context_id}|${r.spec_id}`;
      if (!ledgerByKey.has(key)) ledgerByKey.set(key, []);
      ledgerByKey.get(key).push(r);
    });
    gradingRows.forEach((r) => {
      const key = `${r.context_id}|${r.spec_id}`;
      if (!gradingByKey.has(key)) gradingByKey.set(key, []);
      gradingByKey.get(key).push(r);
    });
    feedRows.forEach((r) => {
      if (!feedByContext.has(r.context_id)) feedByContext.set(r.context_id, []);
      feedByContext.get(r.context_id).push(r);
    });

    let conflicts = 0;
    let stale = 0;
    let orphans = 0;

    const ledgerContextIds = new Set(ledgerRows.map((r) => r.context_id));
    gradingRows.forEach((r) => { if (!ledgerContextIds.has(r.context_id)) orphans += 1; });
    feedRows.forEach((r) => { if (!ledgerContextIds.has(r.context_id)) orphans += 1; });

    const contexts = [];
    ledgerByKey.forEach((rows, key) => {
      const ledgerLatest = rows.slice().sort((a, b) => parseTimestamp(b.timestamp) - parseTimestamp(a.timestamp))[0];
      const gradingRowsForKey = gradingByKey.get(key) || [];
      const gradingLatest = gradingRowsForKey.length ? gradingRowsForKey.slice().sort((a, b) => parseTimestamp(b.timestamp) - parseTimestamp(a.timestamp))[0] : null;
      const feedRowsForContext = (feedByContext.get(ledgerLatest.context_id) || []).slice().sort((a, b) => parseTimestamp(b.timestamp) - parseTimestamp(a.timestamp));

      const events = [];
      rows.forEach((r) => {
        events.push({
          source: "ledger",
          timestamp: r.timestamp,
          context_id: r.context_id,
          spec_id: r.spec_id,
          stage: r.stage,
          status: r.status,
          lane: laneFromStage(r.stage, r.owner),
          agent: r.owner,
          message: r.context_ref,
          github_gate: "unknown",
          blocked_reason_code: ""
        });
      });
      gradingRowsForKey.forEach((r) => {
        events.push({
          source: "grading",
          timestamp: r.timestamp,
          context_id: r.context_id,
          spec_id: r.spec_id,
          stage: "qa",
          status: r.status,
          lane: "Athena",
          agent: "athena",
          message: `recommendation=${r.recommendation}`,
          github_gate: r.github_gate,
          blocked_reason_code: r.blocked_reason_code || ""
        });
      });
      feedRowsForContext.forEach((r) => {
        events.push({
          source: "feed",
          timestamp: r.timestamp,
          context_id: r.context_id,
          spec_id: ledgerLatest.spec_id,
          stage: r.stage,
          status: r.status,
          lane: laneFromStage(r.stage, r.agent),
          agent: r.agent,
          message: r.message,
          entry_type: r.entry_type,
          summary_scope: r.summary_scope,
          refs: r.refs,
          github_gate: r.github_gate,
          blocked_reason_code: r.blocked_reason_code || ""
        });
      });

      events.sort((a, b) => parseTimestamp(b.timestamp) - parseTimestamp(a.timestamp));
      const latest = events[0];
      const statusSet = new Set(events.map((e) => e.status));
      if (statusSet.size > 1) conflicts += 1;

      const effectiveStatus = events.reduce((best, e) => STATUS_ORDER[e.status] < STATUS_ORDER[best] ? e.status : best, "pass");
      const staleFlag = ((Date.now() - parseTimestamp(latest.timestamp)) / 3600000) > STALE_HOURS;
      if (staleFlag) stale += 1;

      contexts.push({
        key,
        context_id: ledgerLatest.context_id,
        spec_id: ledgerLatest.spec_id,
        wave_id: ledgerLatest.wave_id,
        stage: latest.stage,
        lane: latest.lane,
        agent: latest.agent,
        status: effectiveStatus,
        timestamp: latest.timestamp,
        recommendation: gradingLatest ? gradingLatest.recommendation : "",
        github_gate: latest.github_gate || "unknown",
        blocked_reason_code: latest.blocked_reason_code || "",
        conflictCount: statusSet.size > 1 ? statusSet.size - 1 : 0,
        stale: staleFlag,
        events
      });
    });

    const summaryMap = new Map();
    feedRows.forEach((r) => {
      if (r.entry_type !== "event") return;
      const key = `${r.agent}|${rootContext(r.context_id)}`;
      const existing = summaryMap.get(key);
      if (!existing || parseTimestamp(r.timestamp) > parseTimestamp(existing.timestamp)) {
        summaryMap.set(key, {
          key,
          agent: r.agent,
          wave_root: rootContext(r.context_id),
          context_id: r.context_id,
          stage: r.stage,
          status: r.status,
          timestamp: r.timestamp,
          message: r.message
        });
      }
    });
    const summaries = Array.from(summaryMap.values()).sort((a, b) => parseTimestamp(b.timestamp) - parseTimestamp(a.timestamp));

    const ownerByStage = {
      plan: "colombo",
      blueprint: "vitalic",
      build: "athena",
      qa: "elena",
      route: "elena",
      done: "elena"
    };

    const needsAction = contexts
      .filter((c) => c.status === "blocked")
      .map((c) => {
        const blockedFeed = c.events.filter((e) => e.source === "feed" && e.status === "blocked");
        const latestBlocked = blockedFeed.length ? blockedFeed[0] : null;
        const reason = latestBlocked && latestBlocked.blocked_reason_code ? latestBlocked.blocked_reason_code : "UNKNOWN_BLOCKER";
        const githubOnly = !!(latestBlocked && latestBlocked.github_gate === "blocked" && /^GITHUB_/.test(reason));
        const githubRetries = blockedFeed.filter((e) => e.github_gate === "blocked" && /^GITHUB_/.test(e.blocked_reason_code || "")).length;
        const retryCount = Math.min(githubRetries, 1);
        const owner = githubOnly ? "elena" : (ownerByStage[c.stage] || "elena");
        const nextAction = githubOnly
          ? (githubRetries <= 1 ? "Escalate once to Elena for GitHub evidence gate." : "Retry cap reached; wait Elena decision.")
          : `Resolve in ${c.stage} stage and hand to ${owner}.`;

        return {
          key: c.key,
          context_id: c.context_id,
          spec_id: c.spec_id,
          owner,
          reason_code: reason,
          retry_count: retryCount,
          next_action: nextAction,
          timestamp: c.timestamp
        };
      })
      .sort((a, b) => parseTimestamp(b.timestamp) - parseTimestamp(a.timestamp));

    state.trust.conflicts = conflicts;
    state.trust.stale = stale;
    state.trust.orphans = orphans;
    return { contexts, summaries, needsAction };
  }

  function applyFilters(rows) {
    const sf = el.statusFilter.value;
    const af = el.agentFilter.value;
    const wf = el.waveFilter.value;
    const q = el.searchFilter.value.trim().toLowerCase();

    return rows.filter((r) => {
      if (sf !== "all" && r.status !== sf) return false;
      if (af !== "all" && r.agent !== af) return false;
      if (wf !== "all" && r.wave_id !== wf) return false;
      if (q) {
        const topMessage = r.events.length ? r.events[0].message : "";
        const hay = `${r.context_id} ${r.spec_id} ${topMessage}`.toLowerCase();
        if (!hay.includes(q)) return false;
      }
      return true;
    });
  }

  function renderKpis(filtered) {
    const all = state.contexts;
    const health = state.trust.total > 0 ? Math.round((state.trust.valid / state.trust.total) * 100) : 0;
    const shipReady = all.filter((r) => r.recommendation === "ship" && r.status === "pass").length;
    const blocked = all.filter((r) => r.status === "blocked").length;
    const chips = [
      `Ship Ready: ${shipReady}`,
      `Blocked: ${blocked}`,
      `Contexts: ${filtered.length}/${all.length}`,
      `Summaries: ${state.summaries.length}`,
      `Data Health: ${health}%`
    ];
    el.kpiBar.innerHTML = "";
    chips.forEach((c) => {
      const span = document.createElement("span");
      span.className = "kpi";
      span.textContent = c;
      el.kpiBar.appendChild(span);
    });
    const top = state.needsAction[0];
    el.nextAction.textContent = top ? `Next Action: ${top.context_id} -> ${top.owner} (${top.reason_code})` : "Next Action: no blocked queue.";
  }

  function renderTrust() {
    const health = state.trust.total > 0 ? Math.round((state.trust.valid / state.trust.total) * 100) : 0;
    const stats = [
      ["Health", `${health}%`],
      ["Rejected", String(state.trust.rejected)],
      ["Rejected Legacy", String(state.trust.rejectedLegacy)],
      ["Conflicts", String(state.trust.conflicts)],
      ["Stale >24h", String(state.trust.stale)],
      ["Orphans", String(state.trust.orphans)]
    ];
    el.trustStats.innerHTML = "";
    stats.forEach((kv) => {
      const d = document.createElement("div");
      d.className = "trust-item";
      d.innerHTML = `<small>${kv[0]}</small><strong>${kv[1]}</strong>`;
      el.trustStats.appendChild(d);
    });
    el.trustIssues.innerHTML = "";
    if (!state.trust.diagnostics.length) {
      const li = document.createElement("li");
      li.textContent = "No trust diagnostics.";
      el.trustIssues.appendChild(li);
    } else {
      state.trust.diagnostics.slice(0, 30).forEach((d) => {
        const li = document.createElement("li");
        li.textContent = d;
        el.trustIssues.appendChild(li);
      });
    }
  }

  function renderLanes(filtered) {
    const laneMap = new Map();
    LANE_ORDER.forEach((lane) => laneMap.set(lane, { total: 0, blocked: 0 }));
    let needsMapping = 0;

    const source = state.summaries.length ? state.summaries.map((s) => ({ lane: laneFromStage(s.stage, s.agent), status: s.status })) : filtered;
    source.forEach((r) => {
      if (!laneMap.has(r.lane)) {
        needsMapping += 1;
        return;
      }
      const slot = laneMap.get(r.lane);
      slot.total += 1;
      if (r.status === "blocked") slot.blocked += 1;
    });

    el.laneGrid.innerHTML = "";
    LANE_ORDER.forEach((lane) => {
      const row = laneMap.get(lane);
      const div = document.createElement("div");
      div.className = "lane";
      div.innerHTML = `<strong>${lane}</strong><span>Total: ${row.total}</span><span>Blocked: ${row.blocked}</span>`;
      el.laneGrid.appendChild(div);
    });
    el.needsMapping.textContent = `Needs Mapping: ${needsMapping}`;
  }

  function renderSummaries() {
    el.summaryList.innerHTML = "";
    el.summaryEmpty.hidden = state.summaries.length > 0;
    state.summaries.forEach((s) => {
      const li = document.createElement("li");
      li.className = "row";
      li.innerHTML = `<span>${s.agent} | ${s.wave_root}</span><span>${s.stage}</span>${statusBadge(s.status)}<span>${s.timestamp}</span>`;
      el.summaryList.appendChild(li);
    });
  }

  function renderContexts(filtered) {
    const ordered = filtered.slice().sort((a, b) => {
      const ap = STATUS_ORDER[a.status] ?? 9;
      const bp = STATUS_ORDER[b.status] ?? 9;
      if (ap !== bp) return ap - bp;
      return parseTimestamp(b.timestamp) - parseTimestamp(a.timestamp);
    });
    el.contextList.innerHTML = "";
    el.contextEmpty.hidden = ordered.length > 0;
    ordered.forEach((r) => {
      const li = document.createElement("li");
      li.className = `row${r.stale ? " stale" : ""}${r.conflictCount ? " conflict" : ""}`;
      li.innerHTML = `<button data-key="${r.key}">${r.context_id} | ${r.spec_id}</button><span>${r.wave_id}</span>${statusBadge(r.status)}${r.conflictCount ? `<span class="conflict-badge">conflict:${r.conflictCount}</span>` : ""}`;
      el.contextList.appendChild(li);
    });
    if (!state.selectedKey && ordered.length) state.selectedKey = ordered[0].key;
    if (state.selectedKey && !ordered.some((r) => r.key === state.selectedKey)) state.selectedKey = ordered[0] ? ordered[0].key : "";
  }

  function renderNeedsAction() {
    el.needsActionList.innerHTML = "";
    el.needsActionEmpty.hidden = state.needsAction.length > 0;
    state.needsAction.forEach((n) => {
      const li = document.createElement("li");
      li.className = "row";
      li.innerHTML = `<button data-key="${n.key}">${n.context_id} | ${n.spec_id}</button><span class="owner-chip">owner:${n.owner}</span><span class="reason-code">${n.reason_code}</span><span>retry:${n.retry_count} | ${n.next_action}</span>`;
      el.needsActionList.appendChild(li);
    });
  }

  function renderDecisionTimeline(filtered) {
    const ctx = filtered.find((r) => r.key === state.selectedKey);
    el.timeline.innerHTML = "";
    if (!ctx) {
      el.latestDecision.innerHTML = "<span class='empty'>No selected context.</span>";
      el.timelineEmpty.hidden = false;
      return;
    }
    const latest = ctx.events[0];
    el.latestDecision.innerHTML = `<strong>${ctx.context_id} | ${ctx.spec_id}</strong><span>${latest.timestamp} | ${latest.source}/${latest.stage} | ${latest.agent}</span><span>${statusBadge(ctx.status)} | github_gate=${ctx.github_gate}</span><span>${latest.message}</span>`;
    const events = ctx.events.slice(0, TIMELINE_CAP);
    el.timelineEmpty.hidden = events.length > 0;
    events.forEach((e) => {
      const li = document.createElement("li");
      li.className = "time-row";
      li.innerHTML = `<span>${e.timestamp}</span><span>${e.source}/${e.stage}</span>${statusBadge(e.status)}<div class="time-message">${e.message}</div>`;
      el.timeline.appendChild(li);
    });
  }

  function fillWaveFilter(rows) {
    const prev = el.waveFilter.value || "all";
    const waves = Array.from(new Set(rows.map((r) => r.wave_id).filter((w) => w && w !== "n/a"))).sort();
    el.waveFilter.innerHTML = '<option value="all">All</option>';
    waves.forEach((w) => {
      const opt = document.createElement("option");
      opt.value = w;
      opt.textContent = w;
      el.waveFilter.appendChild(opt);
    });
    el.waveFilter.value = waves.includes(prev) || prev === "all" ? prev : "all";
  }

  function renderAll() {
    const filtered = applyFilters(state.contexts);
    renderKpis(filtered);
    renderTrust();
    renderLanes(filtered);
    renderSummaries();
    renderContexts(filtered);
    renderNeedsAction();
    renderDecisionTimeline(filtered);
  }

  function bindEvents() {
    [el.statusFilter, el.agentFilter, el.waveFilter, el.searchFilter].forEach((n) => {
      n.addEventListener("input", renderAll);
      n.addEventListener("change", renderAll);
    });
    document.addEventListener("click", (ev) => {
      const t = ev.target;
      if (!(t instanceof HTMLElement)) return;
      const key = t.getAttribute("data-key");
      if (!key) return;
      state.selectedKey = key;
      renderAll();
    });
  }

  async function init() {
    const [ledgerRaw, gradingRaw, feedRaw] = await Promise.all([
      loadJsonArray(PATHS.inventory),
      loadJsonArray(PATHS.grading),
      loadJsonl(PATHS.feed)
    ]);

    state.trust = {
      total: 0,
      valid: 0,
      rejected: 0,
      rejectedLegacy: 0,
      conflicts: 0,
      stale: 0,
      orphans: 0,
      diagnostics: []
    };

    const validLedger = [];
    const validGrading = [];
    const validFeed = [];

    ledgerRaw.forEach((row, idx) => {
      const r = validateLedger(row, idx);
      if (r.ok) validLedger.push(r.row);
      else addDiag(r.code, r.msg);
    });
    gradingRaw.forEach((row, idx) => {
      const r = validateGrading(row, idx);
      if (r.ok) validGrading.push(r.row);
      else addDiag(r.code, r.msg);
    });
    feedRaw.forEach((row, idx) => {
      const r = validateFeed(row, idx);
      if (r.ok) validFeed.push(r.row);
      else addDiag(r.code, r.msg);
    });

    const gatedFeed = enforceStageGate(validFeed);
    state.trust.total = ledgerRaw.length + gradingRaw.length + feedRaw.length;
    state.trust.valid = validLedger.length + validGrading.length + gatedFeed.length;
    state.trust.rejected = Math.max(0, state.trust.total - state.trust.valid);

    const derived = deriveState(validLedger, validGrading, gatedFeed);
    state.contexts = derived.contexts;
    state.summaries = derived.summaries;
    state.needsAction = derived.needsAction;

    fillWaveFilter(state.contexts);
    bindEvents();
    renderAll();
  }

  init().catch((err) => {
    el.trustIssues.innerHTML = `<li>fatal load error: ${String(err.message || err)}</li>`;
  });
})();
