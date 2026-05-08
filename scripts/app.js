const $ = (s, el = document) => el.querySelector(s);
const $$ = (s, el = document) => Array.from(el.querySelectorAll(s));
const state = { token: sessionStorage.getItem("token") || "", user: JSON.parse(sessionStorage.getItem("user") || "null"), role: sessionStorage.getItem("role") || "", base: new URL("API/v1/", window.location.href).href.replace(/\/$/, "") };
const ui = { authPanel: $("#authPanel"), appPanel: $("#appPanel"), authMsg: $("#authMsg"), sessionLabel: $("#sessionLabel"), logoutBtn: $("#logoutBtn") };

async function api(path, method = "GET", body = null, auth = true) {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), 12000);
  const headers = { "Content-Type": "application/json" };
  if (auth && state.token) headers.Authorization = `Bearer ${state.token}`;
  const res = await fetch(`${state.base}${path}`, { method, headers, body: body ? JSON.stringify(body) : undefined, signal: ctrl.signal });
  clearTimeout(timer);
  const json = await res.json().catch(() => ({ success: false, message: "Invalid JSON response" }));
  if (!res.ok || json.success === false) throw new Error(json.message || `HTTP ${res.status}`);
  return json.data;
}

function setSession(token, user) {
  state.token = token || "";
  state.user = user || null;
  state.role = (user && user.role) || "";
  sessionStorage.setItem("token", state.token);
  sessionStorage.setItem("user", JSON.stringify(state.user));
  sessionStorage.setItem("role", state.role);
  ui.sessionLabel.textContent = state.user ? `${state.user.email} (${state.role})` : "Guest";
  ui.logoutBtn.hidden = !state.user;
  ui.authPanel.hidden = !!state.user;
  ui.appPanel.hidden = !state.user;
  $$('[data-admin="1"]').forEach(b => b.hidden = state.role !== "admin");
}

function print(el, data) { el.textContent = JSON.stringify(data, null, 2); }
function switchView(viewId) { $$(".view").forEach(v => v.hidden = v.id !== viewId); }

async function renderDashboard() {
  const box = $("#dashboard");
  box.innerHTML = `<h3>Dashboard</h3><div class="kpis"><div class="kpi" id="k1">Loading...</div><div class="kpi" id="k2">Loading...</div><div class="kpi" id="k3">Loading...</div></div><div class="card" id="dInfo"></div>`;
  const out = $("#dInfo");
  try {
    const [teams, games, standings] = await Promise.all([api("/teams?limit=5&offset=0"), api("/games?limit=5&offset=0"), api("/standings?limit=5&offset=0")]);
    $("#k1").textContent = `Teams loaded: ${teams.length}`;
    $("#k2").textContent = `Games loaded: ${games.length}`;
    $("#k3").textContent = `Standings loaded: ${standings.length}`;
    out.textContent = state.role === "admin" ? "Admin can manage all modules using the menu." : "Read-only sections: standings, profile and recent games overview.";
  } catch (e) { out.textContent = e.message; }
}

function mountCrud(viewId, title, endpoint, createSample, updateSample) {
  const view = $(`#${viewId}`), tpl = $("#crudTemplate").content.cloneNode(true), out = $("[data-output]", tpl);
  $("[data-title]", tpl).textContent = title;
  $("[data-create]", tpl).value = JSON.stringify(createSample, null, 2);
  $("[data-update]", tpl).value = JSON.stringify(updateSample, null, 2);
  $("[data-list]", tpl).onclick = async () => { try { print(out, await api(`${endpoint}?limit=${$("[data-limit]", view).value || 10}&offset=${$("[data-offset]", view).value || 0}`)); } catch (e) { out.textContent = e.message; } };
  $("[data-show]", tpl).onclick = async () => { try { print(out, await api(`${endpoint}/${$("[data-id]", view).value}`)); } catch (e) { out.textContent = e.message; } };
  $("[data-delete]", tpl).onclick = async () => { try { print(out, await api(`${endpoint}/${$("[data-id]", view).value}`, "DELETE")); } catch (e) { out.textContent = e.message; } };
  $("[data-create-btn]", tpl).onclick = async () => { try { print(out, await api(endpoint, "POST", JSON.parse($("[data-create]", view).value))); } catch (e) { out.textContent = e.message; } };
  $("[data-update-btn]", tpl).onclick = async () => { try { print(out, await api(`${endpoint}/${$("[data-id]", view).value}`, "PUT", JSON.parse($("[data-update]", view).value))); } catch (e) { out.textContent = e.message; } };
  view.innerHTML = "";
  view.appendChild(tpl);
}

function renderStandings() {
  const v = $("#standings");
  v.innerHTML = `<h3>Standings</h3><div class="card"><label>Category ID<input id="stCat" type="number"></label><label>Season Year<input id="stYear" type="number" value="2026"></label><button id="stLoad">Load</button><pre id="stOut"></pre></div>`;
  $("#stLoad").onclick = async () => { try { const q = `?category_id=${$("#stCat").value || ""}&season_year=${$("#stYear").value || ""}&limit=100&offset=0`; print($("#stOut"), await api(`/standings${q}`)); } catch (e) { $("#stOut").textContent = e.message; } };
}

function renderProfile() {
  const v = $("#profile"), uid = state.user ? state.user.id : "";
  v.innerHTML = `<h3>Profile</h3><div class="card"><label>User ID<input id="pfUser" type="number" value="${uid}"></label><button id="pfGet">Get Profile</button><button id="pfSave">Upsert Profile</button><textarea id="pfBody" rows="10">{
  "team_id": 1,
  "first_name": "",
  "paternal_surname": "",
  "maternal_surname": "",
  "birth_date": "1990-01-01",
  "phone": "",
  "jersey_number": 0,
  "position": "",
  "employee_class": "base_employee",
  "employee_number": "",
  "isstecali_affiliation": ""
}</textarea><pre id="pfOut"></pre></div>`;
  $("#pfGet").onclick = async () => { try { print($("#pfOut"), await api(`/users/${$("#pfUser").value}/profile`)); } catch (e) { $("#pfOut").textContent = e.message; } };
  $("#pfSave").onclick = async () => { try { print($("#pfOut"), await api(`/users/${$("#pfUser").value}/profile`, "PUT", JSON.parse($("#pfBody").value))); } catch (e) { $("#pfOut").textContent = e.message; } };
}

async function init() {
  $("#healthBtn").onclick = async () => { try { ui.authMsg.textContent = JSON.stringify(await api("/health", "GET", null, false)); } catch (e) { ui.authMsg.textContent = e.message; } };
  $("#loginBtn").onclick = async () => { try { const data = await api("/auth/login", "POST", { email: $("#email").value.trim(), password: $("#password").value }, false); setSession(data.access_token, data.user); ui.authMsg.textContent = ""; await renderDashboard(); renderStandings(); renderProfile(); } catch (e) { ui.authMsg.textContent = e.message; } };
  ui.logoutBtn.onclick = async () => { try { await api("/auth/logout", "POST"); } catch (e) {} setSession("", null); switchView("dashboard"); };
  $("#nav").onclick = e => { if (e.target.tagName !== "BUTTON") return; const v = e.target.dataset.view; switchView(v); if (v === "dashboard") renderDashboard(); if (v === "standings") renderStandings(); if (v === "profile") renderProfile(); };
  mountCrud("categories", "Categories CRUD", "/categories", { name: "Category UI", description: "Created from UI", is_active: 1 }, { name: "Category UI Updated", description: "Updated from UI", is_active: 1 });
  mountCrud("teams", "Teams CRUD", "/teams", { name: "Team UI", category_id: 1, logo_url: null, is_active: 1 }, { name: "Team UI Updated", category_id: 1, logo_url: null, is_active: 1 });
  mountCrud("venues", "Venues CRUD", "/venues", { name: "Venue UI", address: "Address from UI", is_active: 1 }, { name: "Venue UI Updated", address: "Updated address", is_active: 1 });
  mountCrud("games", "Games CRUD", "/games", { game_date: "2026-06-01", game_time: "19:00:00", venue_id: 1, home_team_id: 1, away_team_id: 1, status: "scheduled", notes: "Created from UI" }, { status: "completed", home_score: 1, away_score: 0, innings_played: 9 });
  mountCrud("users", "Users CRUD", "/users", { email: `user.${Date.now()}@example.com`, password: "TempPass123", role: "player", is_active: 1 }, { role: "manager", is_active: 1 });
  setSession(state.token, state.user);
  if (state.token && state.user) { await renderDashboard(); renderStandings(); renderProfile(); }
}

init();