// Builds assets/stats-{light,dark}.svg from every repository the token's owner
// owns, private ones included. Only aggregates are written; private repository
// names never leave this process (and are never logged: CI logs are public).
//
//   STATS_TOKEN=<token> AUTHOR_EMAILS="me@example.com,*me*.local" node scripts/build-stats.mjs
//
// STATS_TOKEN    read-only token with access to all your repositories
// AUTHOR_EMAILS  commit emails that are you but aren't linked to your account
//                (comma separated, `*` wildcard); linked commits count anyway

import { readFile, writeFile } from 'node:fs/promises';
import { aggregate, assertNoLeaks, buildWindow, dayKey, makeIdentityMatcher, renderStats } from './lib.mjs';

const root = new URL('../', import.meta.url);
const token = process.env.STATS_TOKEN;
if (!token) {
  console.error('STATS_TOKEN is not set.');
  process.exit(1);
}

async function gql(query, variables = {}) {
  for (let attempt = 1; ; attempt++) {
    const res = await fetch('https://api.github.com/graphql', {
      method: 'POST',
      headers: { Authorization: `bearer ${token}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ query, variables }),
      signal: AbortSignal.timeout(30_000),
    });
    const body = await res.json().catch(() => ({}));
    const retryable = res.status >= 500 || res.status === 403 || res.status === 429;
    if (retryable && attempt < 4) {
      await new Promise(r => setTimeout(r, 2 ** attempt * 1000));
      continue;
    }
    // Error types only: GitHub's messages can include repository names.
    if (!res.ok || body.errors) {
      const types = body.errors?.map(e => e.type ?? 'error').join(', ');
      throw new Error(`GitHub GraphQL request failed (HTTP ${res.status}${types ? `, ${types}` : ''}).`);
    }
    return body.data;
  }
}

async function fetchRepos() {
  const repos = [];
  let login, after = null;
  do {
    const { viewer } = await gql(`query($after: String) {
      viewer {
        login
        repositories(ownerAffiliations: OWNER, isFork: false, first: 100, after: $after) {
          pageInfo { hasNextPage endCursor }
          nodes {
            name isPrivate
            defaultBranchRef { name }
            languages(first: 20, orderBy: { field: SIZE, direction: DESC }) { edges { size node { name } } }
          }
        }
      }
    }`, { after });
    login = viewer.login;
    const page = viewer.repositories;
    for (const r of page.nodes) {
      repos.push({
        name: r.name,
        isPrivate: r.isPrivate,
        hasCommits: !!r.defaultBranchRef,
        languages: r.languages.edges.map(e => ({ name: e.node.name, size: e.size })),
      });
    }
    after = page.pageInfo.hasNextPage ? page.pageInfo.endCursor : null;
  } while (after);
  return { login, repos };
}

// All commits on the default branch since `since`; filtering to "me" happens later.
async function fetchHistory(repo, since) {
  const commits = [];
  let after = null;
  do {
    const { viewer } = await gql(`query($name: String!, $since: GitTimestamp!, $after: String) {
      viewer {
        repository(name: $name) {
          defaultBranchRef {
            target {
              ... on Commit {
                history(first: 100, since: $since, after: $after) {
                  pageInfo { hasNextPage endCursor }
                  nodes { oid authoredDate author { email user { login } } }
                }
              }
            }
          }
        }
      }
    }`, { name: repo, since, after });
    const history = viewer.repository?.defaultBranchRef?.target?.history;
    if (!history) break;
    commits.push(...history.nodes);
    after = history.pageInfo.hasNextPage ? history.pageInfo.endCursor : null;
  } while (after);
  return commits;
}

async function mapLimit(items, limit, fn) {
  const results = new Array(items.length);
  let next = 0;
  await Promise.all(Array.from({ length: limit }, async () => {
    while (next < items.length) {
      const i = next++;
      results[i] = await fn(items[i]);
    }
  }));
  return results;
}

const today = dayKey(new Date().toISOString());
const { sinceIso } = buildWindow(today);
const { login, repos } = await fetchRepos();
const isMe = makeIdentityMatcher({ login, patterns: process.env.AUTHOR_EMAILS });

const histories = await mapLimit(repos.filter(r => r.hasCommits), 6, async r =>
  (await fetchHistory(r.name, sinceIso))
    .filter(c => isMe(c.author))
    .map(c => ({ repo: r.name, oid: c.oid, authoredDate: c.authoredDate })));

const stats = aggregate({ repos, commits: histories.flat(), today });
const font = async name => (await readFile(new URL(`assets/fonts/${name}.woff2`, root))).toString('base64');
const fonts = { hg500: await font('HankenGrotesk-500'), hg600: await font('HankenGrotesk-600') };
const svgs = { light: renderStats(stats, 'light', { fonts }), dark: renderStats(stats, 'dark', { fonts }) };

assertNoLeaks(Object.values(svgs), repos.filter(r => r.isPrivate).map(r => r.name));
for (const [theme, svg] of Object.entries(svgs)) {
  await writeFile(new URL(`assets/stats-${theme}.svg`, root), svg);
}
console.log(`Stats for ${today}: ${stats.totalCommits} commits, ${stats.activeDays} active days, `
  + `${stats.projects} active projects, ${stats.totalRepos} repositories scanned.`);
