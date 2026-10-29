import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  makeIdentityMatcher, dayKey, buildWindow, aggregate, levelThresholds, levelFor,
  escapeXml, assertNoLeaks, renderStats,
} from './lib.mjs';

test('identity: matches login, exact emails and globs, case-insensitively', () => {
  const isMe = makeIdentityMatcher({ login: 'me', patterns: 'a@x.com, *me*.local\nb@y.dev' });
  assert.equal(isMe({ email: 'someone@else.com', user: { login: 'me' } }), true);
  assert.equal(isMe({ email: 'A@X.com', user: null }), true);
  assert.equal(isMe({ email: 'b@y.dev', user: null }), true);
  assert.equal(isMe({ email: 'me@MacBook-Me-3.local', user: null }), true);
  assert.equal(isMe({ email: 'other@MacBook.local', user: null }), false);
  assert.equal(isMe({ email: 'a@x.community', user: null }), false);
  assert.equal(isMe({ email: null, user: null }), false);
});

test('dayKey buckets by Jakarta time, not UTC', () => {
  assert.equal(dayKey('2026-10-28T16:59:59Z'), '2026-10-28');
  assert.equal(dayKey('2026-10-28T17:00:00Z'), '2026-10-29');
});

test('window: 52 full Monday-start weeks plus the current week', () => {
  const w = buildWindow('2026-10-29'); // a Thursday
  assert.equal(w.start, '2025-10-27'); // Monday, 52 weeks before this week's Monday
  assert.equal(w.days.at(-1), '2026-10-29');
  assert.equal(w.days.length, 52 * 7 + 4);
  assert.equal(w.sinceIso, '2025-10-26T17:00:00.000Z');
});

const repos = [
  { name: 'pub', isPrivate: false, languages: [{ name: 'Go', size: 100 }] },
  { name: 'secret-client', isPrivate: true, languages: [{ name: 'TypeScript', size: 300 }, { name: 'CSS', size: 100 }] },
  { name: 'copy-of-secret', isPrivate: true, languages: [{ name: 'Rust', size: 1_000_000 }] },
  { name: 'idle', isPrivate: true, languages: [{ name: 'PHP', size: 5_000 }] },
];
const commits = [
  { repo: 'pub', oid: 'a1', authoredDate: '2026-10-01T03:00:00Z' },
  { repo: 'secret-client', oid: 'b1', authoredDate: '2026-10-01T05:00:00Z' },
  { repo: 'secret-client', oid: 'b2', authoredDate: '2026-10-20T05:00:00Z' },
  { repo: 'secret-client', oid: 'b3', authoredDate: '2026-10-20T06:00:00Z' },
  { repo: 'copy-of-secret', oid: 'b3', authoredDate: '2026-10-20T06:00:00Z' }, // same commit, copied repo
  { repo: 'pub', oid: 'old', authoredDate: '2024-01-01T00:00:00Z' }, // outside the window
];

test('aggregate: dedupes commits, ignores out-of-window, counts days and projects', () => {
  const s = aggregate({ repos, commits, today: '2026-10-29' });
  assert.equal(s.totalCommits, 4);
  assert.equal(s.activeDays, 2);
  assert.equal(s.projects, 3);
  assert.equal(s.lastCommitDay, '2026-10-20');
  assert.equal(s.days.get('2026-10-20'), 2);
  assert.equal(s.totalRepos, 4);
});

test('aggregate: languages are weighted by my commits, not repo size', () => {
  const s = aggregate({ repos, commits, today: '2026-10-29' });
  const pct = Object.fromEntries(s.languages.map(l => [l.name, l.pct]));
  // weights: pub 1 commit (Go), secret-client 3 commits (TS 75%, CSS 25%), copy 1 commit (Rust)
  assert.ok(Math.abs(pct.TypeScript - 45) < 1e-9);
  assert.ok(Math.abs(pct.CSS - 15) < 1e-9);
  assert.ok(Math.abs(pct.Go - 20) < 1e-9);
  assert.ok(Math.abs(pct.Rust - 20) < 1e-9);
  assert.equal(pct.PHP, undefined); // no commits from me there
});

test('aggregate: keeps top five languages and folds the rest into Other', () => {
  const many = ['A', 'B', 'C', 'D', 'E', 'F', 'G'].map((n, i) => ({
    name: n, isPrivate: false, languages: [{ name: n, size: 1 }],
  }));
  const cs = many.flatMap((r, i) => Array.from({ length: 7 - i }, (_, k) => ({
    repo: r.name, oid: `${r.name}${k}`, authoredDate: '2026-10-01T00:00:00Z',
  })));
  const s = aggregate({ repos: many, commits: cs, today: '2026-10-29' });
  assert.deepEqual(s.languages.map(l => l.name), ['A', 'B', 'C', 'D', 'E', 'Other']);
  assert.ok(Math.abs(s.languages.reduce((t, l) => t + l.pct, 0) - 100) < 1e-9);
});

test('heatmap levels: quartiles of non-zero days; zero is always level 0', () => {
  const t = levelThresholds([0, 0, 1, 2, 3, 4, 5, 6, 7, 8]);
  assert.equal(levelFor(0, t), 0);
  assert.equal(levelFor(1, t), 1);
  assert.equal(levelFor(8, t), 4);
  assert.ok(levelFor(4, t) >= 2 && levelFor(4, t) <= 3);
  assert.deepEqual(levelThresholds([0, 0]), [1, 1, 1]);
});

test('escapeXml', () => {
  assert.equal(escapeXml(`C++ & <"F#">'`), 'C++ &amp; &lt;&quot;F#&quot;&gt;&apos;');
});

test('assertNoLeaks: throws without echoing the leaked names', () => {
  assert.doesNotThrow(() => assertNoLeaks(['<text>TypeScript 40%</text>'], ['secret-client', 'qr']));
  assert.throws(
    () => assertNoLeaks(['<text>Secret-Client</text>'], ['secret-client']),
    err => /1 private repository name/.test(err.message) && !/secret/i.test(err.message),
  );
  // whole-word only: "qr" must not match inside other words
  assert.doesNotThrow(() => assertNoLeaks(['<text>qrcode</text>'], ['qr']));
});

test('rendered stats card never contains private repo names', () => {
  const s = aggregate({ repos, commits, today: '2026-10-29' });
  for (const theme of ['light', 'dark']) {
    const svg = renderStats(s, theme, { fonts: {} });
    assert.match(svg, /^<svg[\s\S]*<\/svg>\n?$/);
    assert.doesNotThrow(() => assertNoLeaks([svg], ['secret-client', 'copy-of-secret', 'idle']));
  }
});
