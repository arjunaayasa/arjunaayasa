// Pure logic for the profile stats card: who counts as "me", how commits are
// aggregated, and how the SVG is drawn. No network or file access here.

export const TIME_ZONE = 'Asia/Jakarta';
const WEEKS = 53;
const DAY_MS = 86_400_000;

// --- identity -------------------------------------------------------------

// `patterns` is a comma/newline separated list of emails; `*` is a wildcard.
export function makeIdentityMatcher({ login, patterns = '' }) {
  const regexes = patterns.split(/[\s,]+/).filter(Boolean).map(p =>
    new RegExp('^' + p.split('*').map(s => s.replace(/[.+?^${}()|[\]\\]/g, '\\$&')).join('.*') + '$', 'i'));
  const me = login?.toLowerCase();
  return author => {
    if (me && author?.user?.login?.toLowerCase() === me) return true;
    const email = author?.email;
    return !!email && regexes.some(r => r.test(email));
  };
}

// --- dates ----------------------------------------------------------------

const dayFormat = new Intl.DateTimeFormat('en-CA', {
  timeZone: TIME_ZONE, year: 'numeric', month: '2-digit', day: '2-digit',
});
export const dayKey = iso => dayFormat.format(new Date(iso));

const keyToUtc = key => Date.parse(key + 'T00:00:00Z');
const utcToKey = ms => new Date(ms).toISOString().slice(0, 10);

// 52 full Monday-start weeks plus the current (partial) week, ending today.
export function buildWindow(today) {
  const t = keyToUtc(today);
  const mondayOffset = (new Date(t).getUTCDay() + 6) % 7;
  const start = t - (mondayOffset + (WEEKS - 1) * 7) * DAY_MS;
  const days = [];
  for (let d = start; d <= t; d += DAY_MS) days.push(utcToKey(d));
  // Midnight in Jakarta (UTC+7, no DST) of the first day.
  const sinceIso = new Date(start - 7 * 3_600_000).toISOString();
  return { start: days[0], days, sinceIso };
}

// --- aggregation ----------------------------------------------------------

const TOP_LANGUAGES = 5;

// repos:   [{ name, isPrivate, languages: [{ name, size }] }]
// commits: [{ repo, oid, authoredDate }]  — already filtered to "me"
export function aggregate({ repos, commits, today }) {
  const window = buildWindow(today);
  const inWindow = new Set(window.days);

  const days = new Map();
  const seen = new Set();
  const perRepo = new Map();
  let lastCommitDay = null;

  for (const c of commits) {
    const day = dayKey(c.authoredDate);
    if (!inWindow.has(day)) continue;
    perRepo.set(c.repo, (perRepo.get(c.repo) ?? 0) + 1);
    if (seen.has(c.oid)) continue; // same commit pushed to more than one repo
    seen.add(c.oid);
    days.set(day, (days.get(day) ?? 0) + 1);
    if (!lastCommitDay || day > lastCommitDay) lastCommitDay = day;
  }

  // Each repo's language mix, weighted by how many of my commits went into it,
  // so large codebases I imported but barely touched don't dominate.
  const weights = new Map();
  for (const repo of repos) {
    const n = perRepo.get(repo.name);
    const total = repo.languages.reduce((t, l) => t + l.size, 0);
    if (!n || !total) continue;
    for (const l of repo.languages) weights.set(l.name, (weights.get(l.name) ?? 0) + n * l.size / total);
  }
  const sum = [...weights.values()].reduce((t, w) => t + w, 0);
  const ranked = [...weights].sort((a, b) => b[1] - a[1]).map(([name, w]) => ({ name, pct: 100 * w / sum }));
  const languages = ranked.slice(0, TOP_LANGUAGES);
  const rest = ranked.slice(TOP_LANGUAGES).reduce((t, l) => t + l.pct, 0);
  if (rest > 0) languages.push({ name: 'Other', pct: rest });

  return {
    window,
    days,
    totalCommits: seen.size,
    activeDays: days.size,
    projects: perRepo.size,
    totalRepos: repos.length,
    lastCommitDay,
    languages,
    today,
  };
}

// Quartiles of the non-zero days (nearest rank), like GitHub's own calendar.
export function levelThresholds(counts) {
  const v = counts.filter(c => c > 0).sort((a, b) => a - b);
  if (!v.length) return [1, 1, 1];
  const q = p => v[Math.max(0, Math.ceil(p * v.length) - 1)];
  return [q(0.25), q(0.5), q(0.75)];
}

export function levelFor(count, [t1, t2, t3]) {
  if (count <= 0) return 0;
  if (count <= t1) return 1;
  if (count <= t2) return 2;
  if (count <= t3) return 3;
  return 4;
}

// --- safety ---------------------------------------------------------------

export const escapeXml = s => String(s).replace(/[&<>"']/g, c =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&apos;' })[c]);

// Fails the build if any private repo name made it into the output. The error
// deliberately does not say which names: CI logs of a public repo are public.
export function assertNoLeaks(outputs, privateNames) {
  const text = outputs.join('\n').toLowerCase();
  const leaked = privateNames.filter(name => {
    const n = name.toLowerCase().replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    return new RegExp(`(^|[^a-z0-9_-])${n}([^a-z0-9_-]|$)`).test(text);
  });
  if (leaked.length) {
    throw new Error(`${leaked.length} private repository name(s) found in the generated output; refusing to write it.`);
  }
}

// --- rendering ------------------------------------------------------------

// Arsya Digital brand surfaces and ink. Heat ramps are one terracotta hue,
// monotone in lightness (empty -> level 4); language slots are the validated
// categorical palette, checked against these surfaces.
export const THEMES = {
  light: {
    surface: '#f5efe4', ink: '#2b2118', inkSoft: '#6f6051', hairline: 'rgba(43,33,24,0.14)', accent: '#c2613e',
    heat: ['#e6d8c9', '#e9ae99', '#d78263', '#bb5a37', '#8e3b1c'],
    langs: ['#2a78d6', '#eb6834', '#1baf7a', '#eda100', '#e87ba4'], other: '#b3a591',
  },
  dark: {
    surface: '#261c13', ink: '#f1e9da', inkSoft: '#b3a591', hairline: 'rgba(241,233,218,0.14)', accent: '#c2613e',
    heat: ['#342c23', '#673a2a', '#9a4d32', '#c96643', '#eb9070'],
    langs: ['#3987e5', '#d95926', '#199e70', '#c98500', '#d55181'], other: '#6f6051',
  },
};

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const formatDay = (key, today) => {
  const [y, m, d] = key.split('-').map(Number);
  return `${d} ${MONTHS[m - 1]}` + (key.slice(0, 4) === today.slice(0, 4) ? '' : ` ’${String(y).slice(2)}`);
};
const formatInt = n => n.toLocaleString('en-US');
const pct = p => (p >= 10 ? p.toFixed(0) : p.toFixed(1)) + '%';

function fontFaces(fonts) {
  return Object.entries({ 500: fonts.hg500, 600: fonts.hg600 })
    .filter(([, data]) => data)
    .map(([w, data]) => `@font-face{font-family:"HG";font-weight:${w};src:url(data:font/woff2;base64,${data}) format("woff2")}`)
    .join('');
}

// fonts: { hg500, hg600 } as base64 woff2; missing fonts fall back to system sans.
export function renderStats(stats, themeName, { fonts = {} } = {}) {
  const th = THEMES[themeName];
  const W = 840, PAD = 36, CELL = 11, PITCH = 14;
  const gridW = WEEKS * PITCH - (PITCH - CELL);
  const gx = W - PAD - gridW;
  const out = [];
  const text = (x, y, s, cls, extra = '') => out.push(`<text x="${x}" y="${y}" class="${cls}"${extra}>${escapeXml(s)}</text>`);
  const eyebrow = (y, label) => {
    out.push(`<circle cx="${PAD + 3.5}" cy="${y - 4}" r="3.5" fill="${th.accent}"/>`);
    text(PAD + 14, y, label, 'eyebrow');
  };

  // Header
  eyebrow(44, 'ACTIVITY · PAST YEAR');
  text(W - PAD, 44, `Updated ${formatDay(stats.today, stats.today)} ${stats.today.slice(0, 4)}`, 'small', ' text-anchor="end"');
  text(PAD, 68, 'Counted across every repository I own, private client work included.', 'body');

  // Stat tiles
  const tiles = [
    [formatInt(stats.totalCommits), 'commits'],
    [formatInt(stats.activeDays), 'active days'],
    [formatInt(stats.projects), 'active projects'],
    [stats.lastCommitDay ? formatDay(stats.lastCommitDay, stats.today) : '—', 'last commit'],
  ];
  const tileW = (W - 2 * PAD) / tiles.length;
  tiles.forEach(([value, label], i) => {
    const x = PAD + i * tileW + (i ? 20 : 0);
    if (i) out.push(`<line x1="${PAD + i * tileW}" y1="98" x2="${PAD + i * tileW}" y2="158" stroke="${th.hairline}"/>`);
    text(x, 134, value, 'value');
    text(x, 156, label, 'body');
  });

  // Heatmap
  const gy = 206;
  const counts = stats.window.days.map(d => stats.days.get(d) ?? 0);
  const thresholds = levelThresholds(counts);
  let lastLabelCol = -3;
  stats.window.days.forEach((day, i) => {
    const col = Math.floor(i / 7), row = i % 7;
    out.push(`<rect x="${gx + col * PITCH}" y="${gy + row * PITCH}" width="${CELL}" height="${CELL}" rx="2" fill="${th.heat[levelFor(counts[i], thresholds)]}"/>`);
    if (day.endsWith('-01') && col - lastLabelCol >= 3) {
      text(gx + col * PITCH, gy - 8, MONTHS[Number(day.slice(5, 7)) - 1], 'small');
      lastLabelCol = col;
    }
  });
  [['Mon', 0], ['Wed', 2], ['Fri', 4]].forEach(([d, r]) => text(PAD, gy + r * PITCH + 9, d, 'small'));

  const ly = gy + 7 * PITCH + 18;
  text(PAD, ly, 'One square per day, Jakarta time', 'small');
  let lx = W - PAD;
  text(lx, ly, 'More', 'small', ' text-anchor="end"');
  lx -= 34 + 5 * PITCH;
  th.heat.forEach((c, i) => out.push(`<rect x="${lx + i * PITCH}" y="${ly - 10}" width="${CELL}" height="${CELL}" rx="2" fill="${c}"/>`));
  text(lx - 6, ly, 'Less', 'small', ' text-anchor="end"');

  // Languages: one 100% stacked bar, 2px surface gaps, legend with values.
  const ey = ly + 46;
  eyebrow(ey, 'LANGUAGES · WEIGHTED BY MY COMMITS');
  const by = ey + 16, barW = W - 2 * PAD, GAP = 2;
  const langs = stats.languages;
  const colorOf = i => (langs[i].name === 'Other' ? th.other : th.langs[i]);
  let legendBottom = by + 12;
  if (langs.length) {
    out.push(`<clipPath id="bar"><rect x="${PAD}" y="${by}" width="${barW}" height="12" rx="4"/></clipPath><g clip-path="url(#bar)">`);
    const usable = barW - GAP * (langs.length - 1);
    let x = PAD;
    langs.forEach((l, i) => {
      const w = Math.max(2, usable * l.pct / 100);
      out.push(`<rect x="${x.toFixed(2)}" y="${by}" width="${w.toFixed(2)}" height="12" fill="${colorOf(i)}"/>`);
      x += w + GAP;
    });
    out.push('</g>');
    const colW = barW / 3;
    langs.forEach((l, i) => {
      const x = PAD + (i % 3) * colW, y = by + 42 + Math.floor(i / 3) * 26;
      out.push(`<rect x="${x}" y="${y - 10}" width="10" height="10" rx="2.5" fill="${colorOf(i)}"/>`);
      out.push(`<text x="${x + 18}" y="${y}" class="label">${escapeXml(l.name)} <tspan class="body">${pct(l.pct)}</tspan></text>`);
      legendBottom = y;
    });
  } else {
    text(PAD, by + 10, 'No language data yet.', 'body');
  }

  const H = legendBottom + 34;
  const summary = `${formatInt(stats.totalCommits)} commits on ${formatInt(stats.activeDays)} days across ${formatInt(stats.projects)} projects in the past year.`
    + (langs.length ? ` Languages: ${langs.map(l => `${l.name} ${pct(l.pct)}`).join(', ')}.` : '');
  const sans = `"HG","Hanken Grotesk",-apple-system,"Segoe UI",Helvetica,Arial,sans-serif`;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}" role="img" aria-labelledby="t d">
<title id="t">Coding activity, past year</title>
<desc id="d">${escapeXml(summary)}</desc>
<style>${fontFaces(fonts)}text{font-family:${sans};fill:${th.ink}}
.eyebrow{font-size:12px;font-weight:600;letter-spacing:1.6px;fill:${th.inkSoft}}
.small{font-size:11.5px;font-weight:500;fill:${th.inkSoft}}
.body{font-size:13.5px;font-weight:500;fill:${th.inkSoft}}
.label{font-size:13.5px;font-weight:600}
.value{font-size:34px;font-weight:600;letter-spacing:-0.5px}</style>
<rect x="0.5" y="0.5" width="${W - 1}" height="${H - 1}" rx="14" fill="${th.surface}" stroke="${th.hairline}"/>
${out.join('\n')}
</svg>
`;
}
