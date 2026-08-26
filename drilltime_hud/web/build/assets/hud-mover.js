/**
 * HUD Element Mover — Drag-and-drop repositioning + scale for individual HUD elements.
 * Each element (Cash, Bank, Dirty Money, Drug Level, Gang, Ammo, ID, Job,
 * Status Bars, Vehicle HUD) can be moved independently.
 * Global scale applies to every HUD element uniformly.
 */
(function () {
  "use strict";

  var STORAGE_KEY = "hud_element_positions";
  var editMode = false;
  var positions = load();
  var overlay = null;
  var cleanups = [];

  var SCALE_MIN = 0.5;
  var SCALE_MAX = 2.0;
  var SCALE_STEP = 0.05;

  /* ── Persistence ──────────────────────────────────────────────── */
  function load() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {};
    } catch (e) {
      return {};
    }
  }

  function persist(pos) {
    positions = pos;
    localStorage.setItem(STORAGE_KEY, JSON.stringify(pos));
  }

  /* ── Discover individual draggable elements from the DOM ───────── */
  function discoverElements() {
    var elements = [];

    // Money items inside .moneyContainer
    var mc = document.querySelector(".moneyContainer.svelte-v69y6w");
    if (mc) {
      var items = mc.querySelectorAll(".newItem.svelte-v69y6w");
      for (var i = 0; i < items.length; i++) {
        var item = items[i];
        var labelEl = item.querySelector(".label.svelte-v69y6w");
        if (labelEl) {
          var txt = labelEl.textContent.trim();
          var id = "money_" + txt.toLowerCase().replace(/\s+/g, "_");
          elements.push({ id: id, label: txt, el: item });
        }
      }
      // Ammo (.moneyItem.ammoOnly — not wrapped in .newItem)
      var ammo = mc.querySelector(".moneyItem.ammoOnly");
      if (ammo) {
        elements.push({ id: "money_ammo", label: "Ammo", el: ammo });
      }
    }

    // Other UI items (ID, Job) inside .otherUI
    var oui = document.querySelector(".otherUI.svelte-v69y6w");
    if (oui) {
      var others = oui.querySelectorAll(".newOtherItem.svelte-v69y6w");
      for (var j = 0; j < others.length; j++) {
        var oItem = others[j];
        var oLabel = oItem.querySelector(".otherLabel.svelte-v69y6w");
        if (oLabel) {
          var oTxt = oLabel.textContent.trim();
          if (oTxt === "ID") {
            elements.push({ id: "info_id", label: "ID", el: oItem });
          } else {
            elements.push({ id: "info_job", label: "Job", el: oItem });
          }
        }
      }
    }

    // Status bars (only one variant active at a time)
    var statusSels = [
      ".status-container.svelte-164927t",
      ".status-container.svelte-1b96uaz",
      ".status-container.svelte-qg98gl",
    ];
    for (var s = 0; s < statusSels.length; s++) {
      var sEl = document.querySelector(statusSels[s]);
      if (sEl) {
        elements.push({ id: "status", label: "Status Bars", el: sEl });
        break;
      }
    }

    // Vehicle HUD (only one variant active at a time)
    var vehSels = [".wrap.svelte-1vwzjdu", ".hud.svelte-1hvzpmy"];
    for (var v = 0; v < vehSels.length; v++) {
      var vEl = document.querySelector(vehSels[v]);
      if (vEl) {
        elements.push({ id: "vehicle", label: "Vehicle HUD", el: vEl });
        break;
      }
    }

    return elements;
  }

  /* ── Build a combined transform string ─────────────────────────── */
  function buildTransform(p, scale) {
    var parts = [];
    if (p) parts.push("translate(" + p.x + "px, " + p.y + "px)");
    if (scale !== 1) parts.push("scale(" + scale + ")");
    return parts.join(" ") || "";
  }

  /* ── Element cache — rebuilt only when a cached ref leaves the DOM ─ */
  var cachedElements = null;

  function getElements() {
    if (cachedElements) {
      // Fast validity check — rescan only if an element was unmounted
      var allPresent = true;
      for (var i = 0; i < cachedElements.length; i++) {
        if (!document.body.contains(cachedElements[i].el)) {
          allPresent = false;
          break;
        }
      }
      if (allPresent) return cachedElements;
    }
    cachedElements = discoverElements();
    return cachedElements;
  }

  /* ── Apply saved offsets + scale as CSS transforms ─────────────── */
  function applyAll(pos) {
    var scale = pos._scale || 1;
    var elements = getElements();
    for (var i = 0; i < elements.length; i++) {
      var e = elements[i];
      var p = pos[e.id];
      e.el.style.transform = buildTransform(p, scale);
    }
    // Also scale the logo (not draggable, but should scale with HUD)
    var logo = document.querySelector('img[alt="Server Logo"]');
    if (logo) {
      logo.style.transform = scale !== 1 ? "scale(" + scale + ")" : "";
    }
  }

  // Apply on load + periodically for late-mounting elements (vehicle, ammo)
  applyAll(positions);
  setInterval(function () {
    if (!editMode) {
      cachedElements = null; // force re-discovery so re-equipped ammo gets its position reapplied
      applyAll(positions);
    }
  }, 1000);

  /* ── Inject edit-mode, logo-protection & scale CSS ──────────── */
  var css = document.createElement("style");
  css.textContent = [
    /* Force logo to always be visible — cannot be hidden */
    'img[alt="Server Logo"],',
    "img.serverLogo {",
    "  display: block !important;",
    "  visibility: visible !important;",
    "  opacity: 1 !important;",
    "  pointer-events: none;",
    "}",
    "",
    "#hud-edit-overlay {",
    "  position:fixed; inset:0; z-index:99998; pointer-events:none;",
    "  background: rgba(0,0,0,0.25);",
    "}",
    ".hud-edit-toolbar {",
    "  pointer-events:all; position:fixed; top:24px; left:50%;",
    "  transform:translateX(-50%); display:flex; align-items:center; gap:18px;",
    "  padding:14px 28px; background:rgba(26,26,46,0.96);",
    "  border:1px solid rgba(139,92,246,0.45); border-radius:14px;",
    "  box-shadow:0 8px 36px rgba(0,0,0,0.65); font-family:Inter,sans-serif;",
    "  z-index:100000; backdrop-filter:blur(8px);",
    "}",
    ".hud-edit-title {",
    "  font-size:15px; font-weight:800; color:#a78bfa;",
    "  letter-spacing:1.2px; text-transform:uppercase;",
    "}",
    ".hud-edit-hint { font-size:13px; color:#a1a1aa; }",
    ".hud-edit-buttons { display:flex; gap:10px; margin-left:16px; }",
    ".hud-edit-btn {",
    "  padding:9px 20px; border-radius:8px; border:1px solid #3a3a52;",
    "  font-size:13px; font-weight:600; cursor:pointer;",
    "  font-family:Inter,sans-serif; transition:all 0.2s;",
    "}",
    ".hud-edit-btn.save   { background:#8b5cf6; color:#fff; border-color:#a78bfa; }",
    ".hud-edit-btn.save:hover { background:#7c3aed; box-shadow:0 4px 18px rgba(139,92,246,0.45); }",
    ".hud-edit-btn.cancel { background:#25253d; color:#e4e4e7; }",
    ".hud-edit-btn.cancel:hover { background:#34345a; border-color:#8b5cf6; }",
    ".hud-edit-btn.reset  { background:#25253d; color:#ef4444; }",
    ".hud-edit-btn.reset:hover  { background:#34345a; border-color:#ef4444; }",
    "",
    /* Scale control */
    ".hud-scale-control {",
    "  display:flex; align-items:center; gap:6px;",
    "  padding:4px 8px; background:#25253d; border-radius:8px;",
    "  border:1px solid #3a3a52;",
    "}",
    ".hud-scale-btn {",
    "  width:28px; height:28px; display:grid; place-items:center;",
    "  border-radius:6px; border:1px solid #3a3a52; background:#1a1a2e;",
    "  color:#e4e4e7; font-size:16px; font-weight:700; cursor:pointer;",
    "  font-family:Inter,sans-serif; transition:all 0.15s; line-height:1;",
    "}",
    ".hud-scale-btn:hover { background:#8b5cf6; border-color:#a78bfa; }",
    ".hud-scale-value {",
    "  min-width:48px; text-align:center; font-size:13px; font-weight:700;",
    "  color:#e4e4e7; font-family:Inter,sans-serif;",
    "}",
    ".hud-scale-label {",
    "  font-size:11px; font-weight:600; color:#a1a1aa;",
    "  text-transform:uppercase; letter-spacing:.5px; margin-right:4px;",
    "}",
    "",
    ".hud-edit-label {",
    "  position:absolute; top:-28px; left:50%; transform:translateX(-50%);",
    "  padding:4px 12px; border-radius:6px; background:rgba(139,92,246,0.92);",
    "  color:#fff; font-size:11px; font-weight:700; font-family:Inter,sans-serif;",
    "  white-space:nowrap; pointer-events:none; letter-spacing:.6px;",
    "  text-transform:uppercase; box-shadow:0 2px 8px rgba(0,0,0,0.4);",
    "  z-index:100001;",
    "}",
    ".hud-edit-item {",
    "  outline:2px dashed rgba(139,92,246,0.5) !important;",
    "  outline-offset:4px !important;",
    "  cursor:grab !important;",
    "  pointer-events:all !important;",
    "  transition:outline-color 0.2s;",
    "}",
    ".hud-edit-item:hover {",
    "  outline-color:rgba(139,92,246,0.9) !important;",
    "}",
    ".hud-edit-item.dragging {",
    "  cursor:grabbing !important;",
    "  outline-color:#a78bfa !important;",
    "  outline-style:solid !important;",
    "}",
  ].join("\n");
  document.head.appendChild(css);

  /* ── Resource name helper ─────────────────────────────────────── */
  function resName() {
    return typeof GetParentResourceName === "function"
      ? GetParentResourceName()
      : "drilltime_hud";
  }

  function post(endpoint, body) {
    return fetch("https://" + resName() + "/" + endpoint, {
      method: "POST",
      body: JSON.stringify(body || {}),
    }).catch(function () {});
  }

  /* ── Clamp helper ──────────────────────────────────────────────── */
  function clamp(val, min, max) {
    return Math.min(max, Math.max(min, val));
  }

  /* ── Apply working state to all elements (used during edit) ────── */
  function applyWorking(working) {
    var scale = working._scale || 1;
    var elements = discoverElements();
    for (var i = 0; i < elements.length; i++) {
      var e = elements[i];
      var p = working[e.id];
      e.el.style.transform = buildTransform(p, scale);
    }
    var logo = document.querySelector('img[alt="Server Logo"]');
    if (logo) {
      logo.style.transform = scale !== 1 ? "scale(" + scale + ")" : "";
    }
  }

  /* ── Enter edit mode ──────────────────────────────────────────── */
  function enterEdit() {
    if (editMode) return;
    editMode = true;
    cachedElements = null; // Force fresh discovery in edit mode

    // Hide settings panel if visible
    var backdrop = document.querySelector(".backdrop.svelte-hvj0q9");
    var panelWrap = document.querySelector(".panel-wrapper.svelte-hvj0q9");
    if (backdrop) backdrop.style.display = "none";
    if (panelWrap) panelWrap.style.display = "none";

    // Working copy of positions + scale (user can cancel to revert)
    var working = {};
    for (var k in positions) {
      if (k === "_scale") {
        working._scale = positions._scale;
      } else {
        working[k] = { x: positions[k].x, y: positions[k].y };
      }
    }
    if (!working._scale) working._scale = 1;

    // Overlay with toolbar
    overlay = document.createElement("div");
    overlay.id = "hud-edit-overlay";
    overlay.innerHTML =
      '<div class="hud-edit-toolbar">' +
      '  <span class="hud-edit-title">Edit Layout</span>' +
      '  <span class="hud-edit-hint">Drag elements &middot; Scroll to scale</span>' +
      '  <div class="hud-scale-control">' +
      '    <span class="hud-scale-label">Scale</span>' +
      '    <button class="hud-scale-btn" data-dir="-1">&minus;</button>' +
      '    <span class="hud-scale-value">' + Math.round(working._scale * 100) + '%</span>' +
      '    <button class="hud-scale-btn" data-dir="1">+</button>' +
      "  </div>" +
      '  <div class="hud-edit-buttons">' +
      '    <button class="hud-edit-btn reset">Reset All</button>' +
      '    <button class="hud-edit-btn cancel">Cancel</button>' +
      '    <button class="hud-edit-btn save">Save</button>' +
      "  </div>" +
      "</div>";
    document.body.appendChild(overlay);

    var scaleDisplay = overlay.querySelector(".hud-scale-value");

    // ── Scale helpers ──
    function setScale(newVal) {
      working._scale = clamp(
        Math.round(newVal * 100) / 100,
        SCALE_MIN,
        SCALE_MAX
      );
      scaleDisplay.textContent = Math.round(working._scale * 100) + "%";
      applyWorking(working);
    }

    // Scale +/- buttons
    var scaleBtns = overlay.querySelectorAll(".hud-scale-btn");
    for (var b = 0; b < scaleBtns.length; b++) {
      (function (btn) {
        btn.addEventListener("click", function (e) {
          e.preventDefault();
          e.stopPropagation();
          var dir = parseInt(btn.getAttribute("data-dir"), 10);
          setScale((working._scale || 1) + dir * SCALE_STEP);
        });
      })(scaleBtns[b]);
    }

    // Mouse wheel to scale (anywhere on overlay)
    function onWheel(e) {
      e.preventDefault();
      var dir = e.deltaY < 0 ? 1 : -1;
      setScale((working._scale || 1) + dir * SCALE_STEP);
    }
    overlay.style.pointerEvents = "none"; // keep default
    // Attach wheel to the toolbar so it captures scroll when hovering toolbar
    var toolbar = overlay.querySelector(".hud-edit-toolbar");
    toolbar.addEventListener("wheel", onWheel, { passive: false });

    // Also allow wheel on the document during edit mode
    document.addEventListener("wheel", onWheel, { passive: false });
    cleanups.push(function () {
      document.removeEventListener("wheel", onWheel);
    });

    // Discover and set up each element as individually draggable
    var elements = discoverElements();
    elements.forEach(function (elem) {
      var el = elem.el;

      // Ensure the element is positioned so the label renders correctly
      var computed = window.getComputedStyle(el);
      if (computed.position === "static") {
        el.dataset.hudWasStatic = "1";
        el.style.position = "relative";
      }

      el.classList.add("hud-edit-item");

      // Floating label above each element
      var label = document.createElement("div");
      label.className = "hud-edit-label";
      label.textContent = elem.label;
      el.appendChild(label);

      // Drag handler
      function onDown(e) {
        e.preventDefault();
        e.stopPropagation();
        el.classList.add("dragging");
        var sx = e.clientX,
          sy = e.clientY;
        var cur = working[elem.id] || { x: 0, y: 0 };

        function onMove(e2) {
          var nx = cur.x + (e2.clientX - sx);
          var ny = cur.y + (e2.clientY - sy);
          working[elem.id] = { x: nx, y: ny };
          var sc = working._scale || 1;
          el.style.transform = buildTransform(working[elem.id], sc);
        }

        function onUp() {
          el.classList.remove("dragging");
          document.removeEventListener("mousemove", onMove);
          document.removeEventListener("mouseup", onUp);
        }

        document.addEventListener("mousemove", onMove);
        document.addEventListener("mouseup", onUp);
      }

      el.addEventListener("mousedown", onDown);

      cleanups.push(function () {
        el.removeEventListener("mousedown", onDown);
        el.classList.remove("hud-edit-item", "dragging");
        if (label.parentNode) label.remove();
        if (el.dataset.hudWasStatic) {
          el.style.position = "";
          delete el.dataset.hudWasStatic;
        }
      });
    });

    // ── Toolbar buttons ──

    overlay.querySelector(".save").onclick = function () {
      persist(working);
      exitEdit();
      post("hud:savePositions", working);
    };

    overlay.querySelector(".cancel").onclick = function () {
      applyAll(positions); // revert to last saved
      exitEdit();
    };

    overlay.querySelector(".reset").onclick = function () {
      // Clear working state (positions + scale)
      working = { _scale: 1 };
      scaleDisplay.textContent = "100%";
      // Clear every discovered element's transform
      var all = discoverElements();
      for (var i = 0; i < all.length; i++) {
        all[i].el.style.transform = "";
      }
      // Clear logo scale
      var logo = document.querySelector('img[alt="Server Logo"]');
      if (logo) logo.style.transform = "";
      // Persist the reset immediately and notify Lua
      persist({});
      post("hud:savePositions", {});
    };
  }

  /* ── Exit edit mode ───────────────────────────────────────────── */
  function exitEdit() {
    if (!editMode) return;
    editMode = false;
    cachedElements = null; // Discard edit-mode refs, re-discover on next apply

    cleanups.forEach(function (fn) {
      fn();
    });
    cleanups = [];

    if (overlay) {
      overlay.remove();
      overlay = null;
    }

    post("hud:exitEditMode");
  }

  /* ── NUI message listener ─────────────────────────────────────── */
  window.addEventListener("message", function (ev) {
    var d = ev.data || {};
    var action = d.action;

    if (action === "hud:enterEditMode") {
      enterEdit();
    }

    if (action === "hud:exitEditMode") {
      exitEdit();
    }

    // Restore settings panel visibility when settings open
    if (action === "hud:openSettings") {
      var backdrop = document.querySelector(".backdrop.svelte-hvj0q9");
      var panelWrap = document.querySelector(".panel-wrapper.svelte-hvj0q9");
      if (backdrop) backdrop.style.display = "";
      if (panelWrap) panelWrap.style.display = "";
    }

    // Load positions from Lua KVP (on resource start)
    if (action === "hud:loadPositions" && d.data) {
      try {
        var loaded =
          typeof d.data === "string" ? JSON.parse(d.data) : d.data;
        if (
          loaded &&
          typeof loaded === "object" &&
          Object.keys(loaded).length > 0
        ) {
          positions = loaded;
          localStorage.setItem(STORAGE_KEY, JSON.stringify(loaded));
          applyAll(positions);
        }
      } catch (e) {}
    }
  });

  /* ── Inject "Edit Layout" button into settings panel ──────────── */
  new MutationObserver(function () {
    if (editMode) return;
    var footer = document.querySelector(".footer.svelte-hvj0q9");
    if (!footer || footer.querySelector(".hud-edit-layout-btn")) return;

    var btn = document.createElement("button");
    btn.className = "hud-edit-layout-btn";
    btn.innerHTML = "&#10021;  Edit Layout";
    btn.style.cssText = [
      "flex:1; height:48px; display:flex; align-items:center;",
      "justify-content:center; border-radius:12px; font-size:15px;",
      "font-weight:600; cursor:pointer; background:#25253d;",
      "color:#e4e4e7; border:1px solid #3a3a52; transition:all 0.2s;",
      "font-family:Inter,sans-serif;",
    ].join(" ");
    btn.onmouseenter = function () {
      btn.style.background = "#34345a";
      btn.style.borderColor = "#8b5cf6";
      btn.style.transform = "translateY(-1px)";
    };
    btn.onmouseleave = function () {
      btn.style.background = "#25253d";
      btn.style.borderColor = "#3a3a52";
      btn.style.transform = "";
    };
    btn.onclick = function () {
      post("hud:startEditMode");
    };
    footer.insertBefore(btn, footer.firstChild);
  }).observe(document.body, { childList: true, subtree: true });
})();
