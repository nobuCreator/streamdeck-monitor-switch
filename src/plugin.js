// Monitor Switch - Stream Deck plugin (Windows)
//
// One key, three layouts:
//   short press  -> layout "short"
//   double press -> layout "double"
//   hold         -> layout "hold"
// Each layout is captured from the current Windows display arrangement in the key's settings.
// The key image shows the current arrangement (filled = on, dashed = off, white border = main monitor).
import streamDeck, { SingletonAction } from "@elgato/streamdeck";
import { execFile } from "node:child_process";
import path from "node:path";

const SCRIPT = path.join(process.cwd(), "bin", "Display.ps1");
const HOLD_MS = 500;    // held at least this long = hold
const DOUBLE_MS = 300;  // second press within this time = double press
const POLL_MS = 30000;  // refresh the key image this often (catches changes made in Windows Settings)
const SLOTS = ["short", "double", "hold"];

// ---------- Display.ps1 helpers ----------

function runScript(args) {
  return new Promise((resolve) => {
    execFile(
      "powershell.exe",
      ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", SCRIPT, ...args],
      { windowsHide: true, timeout: 60000 },
      (err, stdout, stderr) => {
        if (err) streamDeck.logger.error(`Display.ps1 ${args.join(" ")}: ${err}`);
        resolve(String(stdout || "") + String(stderr || ""));
      }
    );
  });
}

/** Returns the active monitors: [{ id, x, y, w, h, name }] */
async function listMonitors() {
  const out = await runScript(["--list"]);
  const list = [];
  for (const line of out.split(/\r?\n/)) {
    const p = line.split("\t");
    if (p.length >= 5 && p[0].trim()) {
      list.push({ id: p[0].trim(), x: +p[1], y: +p[2], w: +p[3], h: +p[4], name: (p[5] || "").trim() });
    }
  }
  return list;
}

async function applyLayout(layout) {
  const args = layout.monitors.map((m) => `${m.id}=${m.x},${m.y}`);
  const out = await runScript(args);
  streamDeck.logger.info(`apply ${args.join(" ")}\n${out}`);
}

// ---------- key image ----------

function svgImage(settings, current) {
  // Known monitors and where to draw them: prefer the layout with the most monitors.
  const known = new Map();
  const layouts = SLOTS.map((s) => settings[s]).filter(Boolean)
    .sort((a, b) => b.monitors.length - a.monitors.length);
  for (const l of layouts) for (const m of l.monitors) if (!known.has(m.id)) known.set(m.id, m);
  for (const m of current) if (!known.has(m.id)) known.set(m.id, m);

  const all = [...known.values()];
  let body = "";
  if (all.length) {
    const minX = Math.min(...all.map((m) => m.x)), minY = Math.min(...all.map((m) => m.y));
    const maxX = Math.max(...all.map((m) => m.x + (m.w || 1920))), maxY = Math.max(...all.map((m) => m.y + (m.h || 1080)));
    const area = 124, scale = Math.min(area / (maxX - minX), (area - 24) / (maxY - minY));
    const offX = (144 - (maxX - minX) * scale) / 2, offY = (120 - (maxY - minY) * scale) / 2 + 2;
    const on = new Map(current.map((m) => [m.id, m]));
    for (const m of all) {
      const x = offX + (m.x - minX) * scale + 3, y = offY + (m.y - minY) * scale + 3;
      const w = (m.w || 1920) * scale - 6, h = (m.h || 1080) * scale - 6;
      const c = on.get(m.id);
      if (!c) {
        body += `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="4" fill="none" stroke="#5a5f6b" stroke-width="3" stroke-dasharray="6 5"/>`;
      } else {
        const main = c.x === 0 && c.y === 0;
        const stroke = main ? `stroke="#ffffff" stroke-width="5"` : `stroke="#1d4f99" stroke-width="3"`;
        body += `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="4" fill="#3d8bff" ${stroke}/>`;
      }
    }
  }
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="144" height="144" viewBox="0 0 144 144">` +
    `<rect width="144" height="144" fill="#14161b"/>${body}</svg>`;
  return "data:image/svg+xml;charset=utf8," + encodeURIComponent(svg);
}

function countLabel(n) {
  const ja = String(streamDeck.info?.application?.language || "").startsWith("ja");
  return n ? (ja ? `${n}枚` : `${n}`) : "";
}

// ---------- action ----------

class MonitorSwitchAction extends SingletonAction {
  constructor() {
    super();
    this.manifestId = "com.monitorswitch.layout";
    this.keys = new Map();          // context -> press state
    this.queue = Promise.resolve();
    this.poll = null;
  }

  state(ctx) {
    if (!this.keys.has(ctx)) this.keys.set(ctx, { hold: null, single: null, holdFired: false, second: false });
    return this.keys.get(ctx);
  }

  async refreshAll() {
    const current = await listMonitors();
    for (const a of this.actions) {
      const settings = await a.getSettings();
      await a.setImage(svgImage(settings, current));
      await a.setTitle(countLabel(current.length));
    }
  }

  trigger(action, slot) {
    this.queue = this.queue.then(async () => {
      const settings = await action.getSettings();
      const layout = settings[slot];
      if (!layout || !layout.monitors?.length) { await action.showAlert(); return; }
      await action.setTitle("…");
      await applyLayout(layout);
      await this.refreshAll();
    }).catch((e) => streamDeck.logger.error(`trigger ${slot}: ${e}`));
  }

  async onWillAppear(ev) {
    if (!this.poll) this.poll = setInterval(() => this.refreshAll().catch(() => {}), POLL_MS);
    const current = await listMonitors();
    await ev.action.setImage(svgImage(ev.payload.settings, current));
    await ev.action.setTitle(countLabel(current.length));
  }

  onWillDisappear(ev) {
    this.keys.delete(ev.action.id);
    if ([...this.actions].length === 0 && this.poll) { clearInterval(this.poll); this.poll = null; }
  }

  onKeyDown(ev) {
    const s = this.state(ev.action.id);
    s.holdFired = false;
    if (s.single) { clearTimeout(s.single); s.single = null; s.second = true; } else s.second = false;
    s.hold = setTimeout(() => {
      s.hold = null; s.holdFired = true; s.second = false;
      this.trigger(ev.action, "hold");
    }, HOLD_MS);
  }

  onKeyUp(ev) {
    const s = this.state(ev.action.id);
    if (s.hold) { clearTimeout(s.hold); s.hold = null; }
    if (s.holdFired) { s.holdFired = false; return; }
    if (s.second) { s.second = false; this.trigger(ev.action, "double"); return; }
    s.single = setTimeout(() => { s.single = null; this.trigger(ev.action, "short"); }, DOUBLE_MS);
  }

  async onDidReceiveSettings(ev) {
    const current = await listMonitors();
    await ev.action.setImage(svgImage(ev.payload.settings, current));
  }

  // Messages from the settings page (ui/index.html)
  async onSendToPlugin(ev) {
    const msg = ev.payload || {};
    if (msg.event === "list") {
      await streamDeck.ui.current?.sendToPropertyInspector({ event: "list", monitors: await listMonitors() });
    } else if (msg.event === "capture" && SLOTS.includes(msg.slot)) {
      const monitors = await listMonitors();
      const settings = await ev.action.getSettings();
      settings[msg.slot] = { monitors };
      await ev.action.setSettings(settings);
      await streamDeck.ui.current?.sendToPropertyInspector({ event: "settings", settings, monitors });
      await this.refreshAll();
    } else if (msg.event === "clear" && SLOTS.includes(msg.slot)) {
      const settings = await ev.action.getSettings();
      delete settings[msg.slot];
      await ev.action.setSettings(settings);
      await streamDeck.ui.current?.sendToPropertyInspector({ event: "settings", settings });
      await this.refreshAll();
    } else if (msg.event === "test" && SLOTS.includes(msg.slot)) {
      this.trigger(ev.action, msg.slot);
    }
  }
}

streamDeck.actions.registerAction(new MonitorSwitchAction());
streamDeck.connect();
