#!/usr/bin/env node
// Release helpers behind the git_release / git_release_approve shell wrappers
// in config/shell/shared.sh. Implemented in JS rather than shell because both
// commands lean on npm (so node is always present) and most of the work is
// JSON wrangling, which shell handles poorly. Node builtins only, no deps.
//
//   git-release.mjs release <tag>      commit, tag, push, GitHub release
//   git-release.mjs approve [<pkg>] [--otp <code>]
//                                      review + approve a CI-staged npm publish
//                                      (without <pkg>: list all staged packages)

import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createInterface } from 'node:readline';

const tty = process.stdout.isTTY;
const c = tty
  ? { bold: '\x1b[1m', red: '\x1b[31m', green: '\x1b[32m', gray: '\x1b[38;5;8m', reset: '\x1b[0m' }
  : { bold: '', red: '', green: '', gray: '', reset: '' };

// Checklist UI: a gray pending line is rewritten in place with a green check
// or red cross once the step resolves. Degrades to plain lines when stdout is
// not a tty (pending prints nothing, results print once).
function pending(label) {
  if (tty) process.stdout.write(`  ${c.gray}· ${label}…${c.reset}`);
}

function ok(label, detail) {
  if (tty) {
    process.stdout.write(`\r\x1b[2K  ${c.green}✓${c.reset} ${label}`);
    if (detail) process.stdout.write(`  ${c.gray}${detail}${c.reset}`);
    process.stdout.write('\n');
  } else {
    process.stdout.write(`  ok   ${label}${detail ? `  ${detail}` : ''}\n`);
  }
}

function bad(message) {
  if (tty) {
    process.stdout.write(`\r\x1b[2K  ${c.red}✗ ${message}${c.reset}\n`);
  } else {
    process.stdout.write(`  FAIL ${message}\n`);
  }
}

function skipped(label, reason) {
  if (tty) {
    process.stdout.write(`  ${c.gray}· ${label} skipped; ${reason}${c.reset}\n`);
  } else {
    process.stdout.write(`  skip ${label}; ${reason}\n`);
  }
}

// Indented gray detail block under a failed check (captured command output).
function note(text) {
  for (const line of String(text).replace(/\n+$/, '').split('\n')) {
    process.stdout.write(`    ${c.gray}${line}${c.reset}\n`);
  }
}

function resume(command) {
  process.stdout.write(`    ${c.gray}resume:${c.reset} ${command}\n`);
}

function grayBlock(title, body) {
  process.stdout.write(`\n  ${c.gray}${title}${c.reset}\n`);
  for (const line of body.split('\n')) {
    process.stdout.write(`  ${c.gray}│${c.reset} ${line}\n`);
  }
}

function fail(message) {
  process.stderr.write(`${message}\n`);
}

// Captured execution; out interleaves roughly like `2>&1` for error notes.
// maxBuffer is raised well past spawnSync's 1 MB default so a chatty `npm ci`
// or build cannot fail the release with a misleading ENOBUFS, and a spawn
// failure (ENOENT, ETIMEDOUT) lands in out instead of vanishing.
function run(cmd, args, opts = {}) {
  const res = spawnSync(cmd, args, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, ...opts });
  const stdout = res.stdout ?? '';
  const stderr = res.stderr ?? '';
  let out = (stdout + stderr).replace(/\n+$/, '');
  if (res.error) out = out ? `${out}\n${cmd}: ${res.error.message}` : `${cmd}: ${res.error.message}`;
  return { status: res.error ? -1 : res.status, stdout, stderr, out };
}

// Synchronous sleep; the whole script already blocks on spawnSync, so there
// is no event loop to keep alive between retries.
const sleep = (ms) => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);

// Read-only network commands get a timeout and a couple of retries so a DNS
// hiccup or dropped connection does not fail a run that a rerun would pass.
// `settled` marks non-zero results that are real answers rather than
// transient failures (npm's E404/E401, ls-remote's exit 2 for a missing ref).
// Mutating commands (push, release create, approve) are never retried here.
function runNetwork(cmd, args, { settled, ...opts } = {}) {
  const attempts = 3;
  let res;
  for (let attempt = 1; attempt <= attempts; attempt++) {
    res = run(cmd, args, { timeout: 120_000, ...opts });
    if (res.status === 0 || settled?.(res)) break;
    if (attempt < attempts) sleep(2000 * attempt);
  }
  return res;
}

// npm answers E401 with a raw JSON error blob when its auth token is invalid
// or expired (common on a machine that has not logged in for a while). That
// is a settled answer — retrying cannot fix auth — so callers detect it and
// print one clear line instead of the blob.
const npmAuthError = (res) => res.status !== 0 && res.out.includes('E401');
const NPM_AUTH_HINT = 'npm auth token is invalid or expired; run: npm login';

// Pass the terminal through, e.g. for npm's 2FA/OTP prompt or bismar's pager.
function runInteractive(cmd, args, opts = {}) {
  const res = spawnSync(cmd, args, { stdio: 'inherit', ...opts });
  return res.error ? -1 : res.status;
}

function commandExists(name) {
  for (const dir of (process.env.PATH ?? '').split(path.delimiter)) {
    if (!dir) continue;
    try {
      fs.accessSync(path.join(dir, name), fs.constants.X_OK);
      return true;
    } catch {
      /* keep looking */
    }
  }
  return false;
}

// Prompt like shell `read`: typed-ahead lines are queued, not dropped —
// readline can emit several 'line' events from one stdin chunk, so a one-shot
// listener would lose everything after the first. Paused between questions so
// interactive children (npm's OTP prompt) can read stdin themselves.
let rl;
const inputLines = [];
let inputWaiter = null;
let stdinClosed = false;
function ask(prompt) {
  process.stdout.write(prompt);
  if (!rl) {
    rl = createInterface({ input: process.stdin, terminal: false });
    rl.on('line', (line) => {
      if (inputWaiter) {
        const waiter = inputWaiter;
        inputWaiter = null;
        rl.pause();
        waiter(line);
      } else {
        inputLines.push(line);
      }
    });
    rl.on('close', () => {
      stdinClosed = true;
      if (inputWaiter) {
        const waiter = inputWaiter;
        inputWaiter = null;
        waiter('');
      }
    });
  }
  if (inputLines.length > 0) return Promise.resolve(inputLines.shift());
  if (stdinClosed) return Promise.resolve('');
  rl.resume();
  return new Promise((resolve) => {
    inputWaiter = resolve;
  });
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (err) {
    fail(`git_release: could not read ${file}: ${err.message}`);
    return null;
  }
}

// Same format as the shell helper _git_with_utc_dates: commits and tags are
// dated in UTC, unless the caller already pinned GIT_*_DATE.
function utcDateEnv() {
  const ndate = new Date().toISOString().replace(/\.\d+Z$/, '+0000');
  return {
    ...process.env,
    GIT_AUTHOR_DATE: process.env.GIT_AUTHOR_DATE || ndate,
    GIT_COMMITTER_DATE: process.env.GIT_COMMITTER_DATE || ndate,
  };
}

const sha1 = (buf) => createHash('sha1').update(buf).digest('hex');
const seconds = (since) => `${Math.round((Date.now() - since) / 1000)}s`;

// ===================== jsr.json / CHANGELOG.md checks =====================

// Returns a list of mismatch descriptions, empty when npm and jsr metadata
// agree on name, dependencies, and exports.
function jsrMismatches(npm, jsr) {
  const problems = [];
  const shortName = (name) => name.split('/').pop();
  const sortedEntries = (entries) =>
    entries.sort(([nameA, rangeA], [nameB, rangeB]) =>
      nameA === nameB ? String(rangeA).localeCompare(String(rangeB)) : nameA.localeCompare(nameB)
    );

  if (shortName(npm.name) !== shortName(jsr.name)) {
    problems.push(`package names do not match: ${npm.name} != ${jsr.name}`);
  }

  const npmDeps = sortedEntries(
    Object.entries(npm.dependencies || {}).map(([name, range]) => [shortName(name), range])
  );
  const jsrDeps = sortedEntries(
    Object.values(jsr.imports || {}).map((specifier) => {
      const match = /^(?:jsr|npm):((?:@[^/]+\/)?[^@/]+)@(.+)$/.exec(specifier);
      if (!match) throw new Error(`unsupported jsr.json import: ${specifier}`);
      return [shortName(match[1]), match[2]];
    })
  );
  if (JSON.stringify(npmDeps) !== JSON.stringify(jsrDeps)) {
    problems.push(
      `dependencies do not match:\n` +
        `  package.json: ${JSON.stringify(npmDeps)}\n` +
        `  jsr.json:     ${JSON.stringify(jsrDeps)}`
    );
  }

  const exportNames = (exports) => {
    if (exports == null) return [];
    if (typeof exports === 'string') return ['.'];
    const names = Object.keys(exports);
    return (names.some((name) => name.startsWith('.')) ? names : ['.']).sort();
  };
  // A package.json without `exports` still exposes '.' via main/module.
  const npmExports = exportNames(npm.exports ?? npm.main ?? npm.module);
  const jsrExports = exportNames(jsr.exports);
  if (JSON.stringify(npmExports) !== JSON.stringify(jsrExports)) {
    problems.push(
      `exports do not match:\n` +
        `  package.json: ${JSON.stringify(npmExports)}\n` +
        `  jsr.json:     ${JSON.stringify(jsrExports)}`
    );
  }
  return problems;
}

// The published package's runtime tree must not contain the same dependency
// at two versions — e.g. a direct @scure/base 2.4.0 plus an older copy nested
// under micro-packed because its range does not admit the new one. Consumers
// would install both, bloating bundles and breaking instanceof checks across
// the copies. Dev-only entries are ignored; they never ship. Works on
// lockfileVersion 2/3 (the `packages` map). A knowingly-shipped duplicate is
// allow-listed per release: git_release <tag> --allow-dup <package>.
function lockfileDuplicates(lock, allowed = new Set()) {
  const byName = new Map();
  for (const [key, info] of Object.entries(lock.packages ?? {})) {
    if (info.dev) continue;
    const idx = key.lastIndexOf('node_modules/');
    if (idx === -1) continue;
    const name = key.slice(idx + 'node_modules/'.length);
    const parents = key
      .slice(0, idx)
      .split('node_modules/')
      .map((part) => part.replace(/^\/|\/$/g, ''))
      .filter(Boolean);
    const where = parents.length ? `via ${parents.join(' > ')}` : 'top level';
    if (!byName.has(name)) byName.set(name, []);
    byName.get(name).push({ version: info.version, where });
  }
  const problems = [];
  for (const [name, copies] of byName) {
    if (allowed.has(name)) continue;
    if (new Set(copies.map((copy) => copy.version)).size > 1) {
      problems.push(`${name}: ${copies.map((copy) => `${copy.version} (${copy.where})`).join(', ')}`);
    }
  }
  return problems;
}

// CHANGELOG.md: '## <version> (<utc date>)' heading, body until the next
// '## ' heading (blank edges trimmed), and the version of the next
// dotted-number heading below it (the previous release).
function parseChangelog(text, version) {
  const lines = text.split('\n');
  const fieldsOf = (line) => line.split(/\s+/).filter(Boolean);
  let heading = null;
  const body = [];
  let inSection = false;
  for (const line of lines) {
    const fields = fieldsOf(line);
    if (fields[0] === '##') {
      if (inSection) break;
      if (fields[1] === version) {
        heading = line;
        inSection = true;
      }
      continue;
    }
    if (inSection) body.push(line);
  }
  while (body.length && body[0].trim() === '') body.shift();
  while (body.length && body[body.length - 1].trim() === '') body.pop();

  let prevVersion = '';
  let found = false;
  for (const line of lines) {
    const fields = fieldsOf(line);
    if (fields[0] === '##' && /^[0-9]/.test(fields[1] ?? '')) {
      if (found) {
        prevVersion = fields[1];
        break;
      }
      if (fields[1] === version) found = true;
    }
  }
  return { heading, body: body.join('\n'), prevVersion };
}

// CI state of the last commit GitHub actually has: the remote branch tip is
// resolved live with ls-remote, not from @{upstream}'s tracking ref, which is
// only as fresh as the last fetch — and nothing in this script fetches. Uses
// the checks API rather than `gh run list` so checks from apps other than
// GitHub Actions count too. Returns { summary } when green (or when the repo
// has no checks), { error, detail? } otherwise.
function githubCiState() {
  const upstream = run('git', ['rev-parse', '--abbrev-ref', '@{upstream}']);
  if (upstream.status !== 0) {
    return { error: 'could not resolve the upstream branch to check CI', detail: upstream.out };
  }
  const [remote, ...branchParts] = upstream.stdout.trim().split('/');
  const lsRemote = runNetwork('git', ['ls-remote', '--exit-code', remote, `refs/heads/${branchParts.join('/')}`], {
    settled: (r) => r.status === 2,
  });
  if (lsRemote.status !== 0) {
    return { error: `could not resolve ${upstream.stdout.trim()} on the remote`, detail: lsRemote.out };
  }
  const sha = lsRemote.stdout.split(/\s+/)[0];
  const shortSha = sha.slice(0, 7);
  const res = runNetwork('gh', ['api', `repos/{owner}/{repo}/commits/${sha}/check-runs?per_page=100`]);
  if (res.status !== 0) {
    return { error: `could not fetch check runs for ${shortSha}`, detail: res.out };
  }
  let runs;
  try {
    runs = JSON.parse(res.stdout).check_runs;
  } catch {
    return { error: 'could not parse the check-runs response', detail: res.out };
  }
  if (runs.length === 0) return { summary: `no checks on ${shortSha}` };
  const failedRuns = runs.filter(
    (r) => r.status === 'completed' && !['success', 'neutral', 'skipped'].includes(r.conclusion)
  );
  if (failedRuns.length > 0) {
    return {
      error: `CI failed on ${shortSha}`,
      detail: failedRuns.map((r) => `${r.conclusion}  ${r.name}  ${r.html_url ?? ''}`).join('\n'),
    };
  }
  const pendingRuns = runs.filter((r) => r.status !== 'completed');
  if (pendingRuns.length > 0) {
    return {
      error: `CI is still running on ${shortSha}`,
      detail: pendingRuns.map((r) => `${r.status}  ${r.name}`).join('\n'),
    };
  }
  return { summary: `${runs.length} check${runs.length === 1 ? '' : 's'} on ${shortSha}` };
}

function originHttpsUrl() {
  let url = run('git', ['remote', 'get-url', 'origin']).stdout.trim();
  url = url.replace(/\.git$/, '');
  if (url.startsWith('git@')) url = `https://${url.slice(4).replace(':', '/')}`;
  return url;
}

// ============================== release ==============================

async function release(args) {
  const allowedDupes = new Set();
  const positional = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--allow-dup') {
      const name = args[++i];
      if (!name) {
        fail('git_release: --allow-dup needs a package name');
        return 2;
      }
      allowedDupes.add(name);
    } else {
      positional.push(args[i]);
    }
  }
  const tag = positional[0];
  if (!tag || positional.length > 1) {
    fail('Usage: git_release <tag> [--allow-dup <package>]...');
    return 2;
  }
  if (!commandExists('gh')) {
    fail('git_release: gh cli is not installed');
    return 1;
  }
  if (!fs.existsSync('package.json')) {
    fail('git_release: no package.json in current directory');
    return 1;
  }
  const pkg = readJson('package.json');
  if (!pkg) return 1;
  const npmName = pkg.name;
  const version = pkg.version;
  const bareTag = tag.replace(/^v/, '');

  process.stdout.write(`\n  ${c.bold}${npmName} ${tag}${c.reset}\n\n`);

  // Preflight: run every check and collect failures instead of dying on the
  // first, so one rerun fixes everything at once.
  let failed = false;

  pending('gh authenticated');
  if (run('gh', ['auth', 'status']).status === 0) {
    ok('gh authenticated');
  } else {
    bad('gh cli is not authenticated; run: gh auth login');
    failed = true;
  }

  if (bareTag === version) {
    ok(`package.json at ${version}`);
  } else {
    bad(`tag ${tag} does not match package.json version ${version}`);
    failed = true;
  }

  if (fs.existsSync('jsr.json')) {
    const jsr = readJson('jsr.json');
    if (!jsr) return 1;
    if (bareTag !== jsr.version) {
      bad(`tag ${tag} does not match jsr.json version ${jsr.version}`);
      failed = true;
    } else {
      pending('jsr.json in sync');
      let problems;
      try {
        problems = jsrMismatches(pkg, jsr);
      } catch (err) {
        problems = [err.message];
      }
      if (problems.length === 0) {
        ok('jsr.json in sync');
      } else {
        bad('jsr.json out of sync');
        note(problems.join('\n'));
        failed = true;
      }
    }

    // Translate JSR's allowSlowTypes opt-in to Deno's CLI flag.
    // Preflight runs before the release commit, so allow uncommitted changes.
    pending('deno publish dry run');
    const publishArgs = ['publish', '--dry-run', '--no-check', '--allow-dirty', '--config', 'jsr.json'];
    if (jsr.allowSlowTypes === true) publishArgs.push('--allow-slow-types');
    const publish = run('deno', publishArgs);
    if (publish.status === 0) {
      ok('deno publish dry run');
    } else {
      bad('deno publish dry run failed');
      note(publish.out);
      failed = true;
    }
  }

  if (fs.existsSync('package-lock.json')) {
    const lock = readJson('package-lock.json');
    if (!lock) return 1;
    pending('runtime deps deduped');
    const dupes = lockfileDuplicates(lock, allowedDupes);
    if (dupes.length === 0) {
      ok('runtime deps deduped', allowedDupes.size ? `${allowedDupes.size} allow-listed` : '');
    } else {
      bad('package-lock.json resolves a runtime dep at two versions');
      note(dupes.join('\n'));
      note('fix the ranges or use npm overrides; if intentional, rerun with --allow-dup <package>');
      failed = true;
    }
  }

  // The changelog entry for this version must be dated today (UTC, matching
  // _git_with_utc_dates); its body becomes the default release notes, with a
  // '**Full Changelog**: .../compare/<prev>...<tag>' line appended.
  let changelogNotes = '';
  if (fs.existsSync('CHANGELOG.md')) {
    pending(`changelog has ${version}`);
    const today = new Date().toISOString().slice(0, 10);
    const { heading, body, prevVersion } = parseChangelog(
      fs.readFileSync('CHANGELOG.md', 'utf8'),
      version
    );
    const clDate = heading ? /\(([^)]*)\)/.exec(heading)?.[1] : null;
    if (!heading) {
      bad(`CHANGELOG.md has no '## ${version}' entry`);
      failed = true;
    } else if (clDate !== today) {
      bad(`CHANGELOG.md entry is not dated today; want '## ${version} (${today})', have '${heading}'`);
      failed = true;
    } else if (!body) {
      bad(`CHANGELOG.md entry for ${version} is empty`);
      failed = true;
    } else {
      ok(`changelog has ${version}`, today);
      changelogNotes = body;
      const repoUrl = originHttpsUrl();
      if (prevVersion && repoUrl) {
        const prevTag = tag.startsWith('v') ? `v${prevVersion}` : prevVersion;
        changelogNotes += `\n\n**Full Changelog**: ${repoUrl}/compare/${prevTag}...${tag}`;
      }
    }
  }

  pending(`tag ${tag} free`);
  if (run('git', ['rev-parse', '-q', '--verify', `refs/tags/${tag}`]).status === 0) {
    bad(`tag ${tag} already exists locally`);
    failed = true;
  } else {
    const remote = runNetwork('git', ['ls-remote', '--exit-code', '--tags', 'origin', `refs/tags/${tag}`], {
      settled: (r) => r.status === 2,
    });
    if (remote.status === 0) {
      bad(`tag ${tag} already exists on origin`);
      failed = true;
    } else if (remote.status === 2) {
      ok(`tag ${tag} free locally and on origin`);
    } else {
      bad('could not reach origin to check for existing tags');
      failed = true;
    }
  }

  // The signing probe is the one preflight check with a user-visible side
  // effect (it pops the signing key prompt), so unlike the rest it is skipped
  // once the run is already doomed — no point approving a signature for a
  // release that cannot ship. The trade-off: a signing problem only surfaces
  // on a rerun that passes the checks above.
  if (failed) {
    skipped('signed tags probe', 'earlier checks failed');
  } else {
    pending('signed tags work');
    // Delete probe tags left behind by earlier runs killed mid-check, then
    // prove signing works with a fresh one.
    for (const stale of run('git', ['tag', '-l', '_git_release_probe_*']).stdout.split('\n').filter(Boolean)) {
      run('git', ['tag', '-d', '--', stale]);
    }
    const probeTag = `_git_release_probe_${process.pid}`;
    if (run('git', ['tag', '-s', '-m', '', '--', probeTag, 'HEAD']).status === 0) {
      run('git', ['tag', '-d', '--', probeTag]);
      ok('signed tags work');
    } else {
      bad('cannot create signed tags; check signing key and agent');
      failed = true;
    }
  }

  pending('push is fast-forward');
  if (run('git', ['push', '--dry-run', '--quiet']).status === 0) {
    ok('push is fast-forward');
  } else {
    bad('push would fail; is the branch behind origin?');
    failed = true;
  }

  pending('ci green on github');
  const ciState = githubCiState();
  if (ciState.error) {
    bad(ciState.error);
    if (ciState.detail) note(ciState.detail);
    failed = true;
  } else {
    ok('ci green on github', ciState.summary);
  }

  pending(`${npmName}@${version} unpublished`);
  const npmCheck = runNetwork('npm', ['view', `${npmName}@${version}`, 'version'], {
    settled: (r) => r.out.includes('E404') || npmAuthError(r),
  });
  if (npmCheck.status === 0) {
    bad(`${npmName}@${version} already exists on npm`);
    failed = true;
  } else if (npmCheck.out.includes('E404')) {
    ok(`${npmName}@${version} not on npm`);
  } else if (npmAuthError(npmCheck)) {
    bad(NPM_AUTH_HINT);
    failed = true;
  } else {
    bad(`could not check ${npmName}@${version} on npm`);
    note(npmCheck.out);
    failed = true;
  }

  const changes = run('git', ['status', '--short', '--untracked-files=no']).stdout.replace(/\n+$/, '');
  if (!changes) {
    bad('no tracked changes to commit');
    failed = true;
  }

  if (failed) {
    process.stdout.write('\n');
    fail('git_release: preflight failed');
    return 1;
  }

  grayBlock('changes', changes);

  // The changelog entry, when present, simply is the release notes — the
  // preflight already vetted it (dated today, non-empty), so shipping it is
  // folded into the single ship? question below.
  let notesMode;
  if (changelogNotes) {
    grayBlock('notes from CHANGELOG.md', changelogNotes);
    notesMode = 'changelog';
  } else {
    const reply = await ask(`\n  notes  (1) text  (2) file  (3) generate ${c.gray}→${c.reset} `);
    notesMode = { 1: 'text', 2: 'file', 3: 'generate' }[reply];
  }

  let ghArgs;
  if (notesMode === 'changelog') {
    // A file keeps the resume one-liners runnable; --notes would put the
    // whole multi-line body on them. Intentionally not cleaned up on failure
    // for the same reason.
    const notesFile = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'git_release_notes.')), 'notes.md');
    fs.writeFileSync(notesFile, `${changelogNotes}\n`);
    ghArgs = ['-F', notesFile];
  } else if (notesMode === 'text') {
    ghArgs = ['--notes', await ask('  text: ')];
  } else if (notesMode === 'file') {
    const notesPath = await ask('  file: ');
    if (!fs.existsSync(notesPath)) {
      fail(`git_release: file not found: ${notesPath}`);
      return 1;
    }
    ghArgs = ['-F', notesPath];
  } else if (notesMode === 'generate') {
    ghArgs = ['--generate-notes'];
  } else {
    fail('git_release: invalid choice');
    return 2;
  }
  const ghArgsText = ghArgs.join(' ');

  const ship = await ask(`\n  ship ${c.bold}${tag}${c.reset}? [y/N] `);
  if (ship !== 'y' && ship !== 'Y') {
    fail('git_release: aborted');
    return 2;
  }
  process.stdout.write('\n');

  const startTime = Date.now();

  let stepTime = Date.now();
  pending('npm ci');
  const ci = run('npm', ['ci']);
  if (ci.status !== 0) {
    bad('npm ci failed; nothing was released');
    note(ci.out);
    return 1;
  }
  ok('npm ci', seconds(stepTime));

  if (pkg.scripts?.build) {
    stepTime = Date.now();
    pending('npm run build');
    const build = run('npm', ['run', 'build']);
    if (build.status !== 0) {
      bad('npm run build failed; nothing was released');
      note(build.out);
      return 1;
    }
    ok('npm run build', seconds(stepTime));
  }

  pending('commit');
  const commit = run('git', ['commit', '-a', '-q', '-m', `Release ${tag}.`], { env: utcDateEnv() });
  if (commit.status !== 0) {
    bad('commit failed; nothing was released');
    note(commit.out);
    return 1;
  }
  const headShort = run('git', ['rev-parse', '--short', 'HEAD']).stdout.trim();
  ok(`commit   Release ${tag}.`, headShort);

  pending(`tag ${tag}`);
  const tagged = run('git', ['tag', '-s', '-m', '', '--', tag], { env: utcDateEnv() });
  if (tagged.status !== 0) {
    bad('tagging failed; the release commit exists');
    note(tagged.out);
    resume(`git tag -s -m '' -- ${tag} && git push --atomic --follow-tags && gh release create ${tag} ${ghArgsText}`);
    return 1;
  }
  ok(`tag      ${tag}`, 'signed');

  const branch = run('git', ['rev-parse', '--abbrev-ref', 'HEAD']).stdout.trim();
  pending(`push ${branch} + ${tag}`);
  // One atomic push instead of `git push` then `git push --tags`: the branch
  // and the tag land on origin together or not at all, so a failure never
  // leaves the remote half-updated. --follow-tags only sends annotated tags
  // reachable from the branch, so an unrelated stale local tag cannot break
  // the push the way --tags could.
  const push = run('git', ['push', '--atomic', '--follow-tags']);
  if (push.status !== 0) {
    bad('push failed; the commit and tag exist locally, origin is unchanged');
    note(push.out);
    resume(`git push --atomic --follow-tags && gh release create ${tag} ${ghArgsText}`);
    return 1;
  }
  ok(`push     ${branch} + ${tag} → origin`);

  pending('github release');
  const ghRelease = run('gh', ['release', 'create', tag, ...ghArgs]);
  if (ghRelease.status !== 0) {
    bad('GitHub release failed; the commit and tag are pushed');
    note(ghRelease.out);
    resume(`gh release create ${tag} ${ghArgsText}`);
    return 1;
  }
  ok(`release  ${ghRelease.out.trim()}`);

  process.stdout.write(`\n  ${c.gray}done in ${seconds(startTime)}${c.reset}\n\n`);
  return 0;
}

// ============================== approve ==============================

// Review and approve a CI-staged npm publish in one go, replacing the manual
// `npm stage list` / `npm stage download` / `npm stage approve` dance: lists
// the package's staged versions, downloads the chosen tarball, verifies its
// shasum against the staged metadata, diffs it against the latest published
// release with bismar, then approves (publishes) or rejects it.
// Without a package argument: one line per package with something staged,
// with the staged-version count and the newest staged version.
async function listStaged() {
  const list = runNetwork('npm', ['stage', 'list', '--json'], { settled: npmAuthError });
  if (list.status !== 0) {
    fail('git_release_approve: could not list staged packages');
    note(npmAuthError(list) ? NPM_AUTH_HINT : list.out);
    return 1;
  }
  let items;
  try {
    items = JSON.parse(list.stdout);
  } catch {
    fail('git_release_approve: could not parse `npm stage list --json` output');
    note(list.out);
    return 1;
  }
  if (items.length === 0) {
    process.stdout.write(`\n  ${c.gray}nothing is staged${c.reset}\n\n`);
    return 0;
  }

  const byName = new Map();
  for (const item of items) {
    const name = item.packageName ?? '(unknown)';
    if (!byName.has(name)) byName.set(name, []);
    byName.get(name).push(item);
  }
  for (const versions of byName.values()) {
    versions.sort((a, b) => String(b.createdAt ?? '').localeCompare(String(a.createdAt ?? '')));
  }
  // Most recently staged package first, mirroring the version list in review.
  const packages = [...byName.entries()].sort(([, a], [, b]) =>
    String(b[0].createdAt ?? '').localeCompare(String(a[0].createdAt ?? ''))
  );

  const nameWidth = Math.max(...packages.map(([name]) => name.length));
  process.stdout.write('\n');
  for (const [name, versions] of packages) {
    const newest = versions[0];
    const created = String(newest.createdAt ?? '').slice(0, 10);
    process.stdout.write(
      `  ${c.bold}${name.padEnd(nameWidth)}${c.reset}  ${String(versions.length).padStart(2)} staged` +
        `  ${c.gray}newest ${newest.version}  ${created}${c.reset}\n`
    );
  }
  process.stdout.write(`\n  ${c.gray}git_release_approve <package> to review${c.reset}\n\n`);
  return 0;
}

async function approve(args) {
  let otp = '';
  const positional = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--otp') {
      otp = args[++i] ?? '';
      if (!otp) {
        fail('git_release_approve: --otp needs a code');
        return 2;
      }
    } else if (args[i].startsWith('--otp=')) {
      otp = args[i].slice('--otp='.length);
    } else {
      positional.push(args[i]);
    }
  }
  if (positional.length > 1) {
    fail('Usage: git_release_approve [<package>] [--otp <code>]');
    return 2;
  }
  const nameArg = positional[0];
  if (!nameArg) return listStaged();
  if (!commandExists('bismar')) {
    fail('git_release_approve: bismar is not installed; run: npm install -g bismar');
    return 1;
  }
  const npmName = nameArg;

  process.stdout.write(`\n  ${c.bold}${npmName}${c.reset}\n\n`);

  pending('staged versions');
  const list = runNetwork('npm', ['stage', 'list', '--json', npmName], { settled: npmAuthError });
  if (list.status !== 0) {
    bad('could not list staged packages');
    note(npmAuthError(list) ? NPM_AUTH_HINT : list.out);
    return 1;
  }
  let items;
  try {
    items = JSON.parse(list.stdout);
  } catch {
    bad('could not parse `npm stage list --json` output');
    note(list.out);
    return 1;
  }
  items.sort((a, b) => String(b.createdAt ?? '').localeCompare(String(a.createdAt ?? '')));
  if (items.length === 0) {
    bad(`nothing is staged for ${npmName}`);
    return 1;
  }
  ok('staged versions', String(items.length));

  const describe = (item) => ({
    created: String(item.createdAt ?? '').slice(0, 10),
    actor: item.actorType ? `${item.actor} (${item.actorType})` : item.actor ?? '',
  });

  let item = items[0];
  if (items.length > 1) {
    process.stdout.write('\n');
    items.forEach((entry, i) => {
      const { created, actor } = describe(entry);
      process.stdout.write(
        `  ${c.gray}${i + 1})${c.reset} ${entry.version}  ${c.gray}${entry.tag ?? ''}  ${created}  ${actor}${c.reset}\n`
      );
    });
    const reply = await ask(`\n  which ${c.gray}→${c.reset} `);
    const choice = /^[0-9]+$/.test(reply) ? Number(reply) : NaN;
    if (!(choice >= 1 && choice <= items.length)) {
      fail('git_release_approve: invalid choice');
      return 2;
    }
    item = items[choice - 1];
  }
  const { id, version, tag: distTag, shasum } = item;
  const { created, actor } = describe(item);
  ok(`staged   ${npmName}@${version}`, `${distTag ? `tag ${distTag}, ` : ''}${created} by ${actor}`);

  // The tarball is left behind on purpose: it holds nothing sensitive (it is
  // the package about to be published) and the OS ages out its temp dir, so
  // there is no point deleting what a failed run might want inspected.
  const tmpdir = fs.mkdtempSync(path.join(os.tmpdir(), 'git_release_approve.'));
  pending(`download ${version}`);
  const download = runNetwork('npm', ['stage', 'download', id], { cwd: tmpdir });
  if (download.status !== 0) {
    bad('download failed');
    note(download.out);
    return 1;
  }
  // The tmpdir is fresh, so whatever single .tgz the download produced is the
  // staged tarball — sturdier than reconstructing npm's naming scheme (and a
  // shasum mismatch below would catch a wrong pick anyway).
  const tarballs = fs.readdirSync(tmpdir).filter((name) => name.endsWith('.tgz'));
  if (tarballs.length !== 1) {
    bad(`download succeeded but found ${tarballs.length} .tgz files in ${tmpdir}`);
    return 1;
  }
  const tarball = path.join(tmpdir, tarballs[0]);
  const data = fs.readFileSync(tarball);
  ok(`download ${version}`, `${Math.ceil(data.length / 1024)} kB`);

  if (shasum) {
    const actual = sha1(data);
    if (actual === shasum) {
      ok('shasum matches staged metadata', shasum.slice(0, 7));
    } else {
      bad(`shasum mismatch: staged ${shasum}, downloaded ${actual}`);
      note(`kept for inspection: ${tarball}`);
      return 1;
    }
  }

  pending('previous release');
  let prev = '';
  const view = runNetwork('npm', ['view', npmName, 'version'], {
    settled: (r) => r.out.includes('E404') || npmAuthError(r),
  });
  if (view.status === 0) {
    prev = view.stdout.trim();
    ok('previous release', prev);
  } else if (view.out.includes('E404')) {
    ok('previous release', 'none; first publish, skipping diff');
  } else {
    bad('could not look up the previous release on npm');
    note(npmAuthError(view) ? NPM_AUTH_HINT : view.out);
    return 1;
  }

  if (prev) {
    process.stdout.write(`\n  ${c.gray}bismar diff ${npmName}@${prev} → ${version}${c.reset}\n`);
    runInteractive('bismar', ['--diff', `npm:${npmName}@${prev}`, tarball]);
  }

  // OTP codes expire within seconds, so when --otp was not given the code is
  // asked for only after the final confirm, right before npm needs it. An
  // empty answer falls back to npm's own interactive OTP prompt.
  const otpArgs = async () => {
    if (!otp) otp = (await ask(`  otp ${c.gray}(enter to let npm prompt)${c.reset}: `)).trim();
    return otp ? ['--otp', otp] : [];
  };

  const reply = await ask(`\n  approve ${c.bold}${npmName}@${version}${c.reset}? [y/N] `);
  if (reply === 'y' || reply === 'Y') {
    const approveArgs = ['stage', 'approve', id, ...(await otpArgs())];
    process.stdout.write('\n');
    if (runInteractive('npm', approveArgs) !== 0) {
      bad('approve failed; the package is still staged');
      resume(`npm stage approve ${id}`);
      return 1;
    }
    ok(`published ${npmName}@${version}`);
  } else {
    // N rejects, but rejection removes the staged version for good, so it is
    // guarded by a confirm; declining the confirm leaves the package staged.
    const confirm = await ask(`  really reject and remove the staged ${version}? [y/N] `);
    if (confirm === 'y' || confirm === 'Y') {
      const rejectArgs = ['stage', 'reject', id, ...(await otpArgs())];
      process.stdout.write('\n');
      if (runInteractive('npm', rejectArgs) !== 0) {
        bad('reject failed; the package is still staged');
        resume(`npm stage reject ${id}`);
        return 1;
      }
      ok(`rejected ${npmName}@${version}`);
    } else {
      process.stdout.write(`  ${c.gray}left staged${c.reset}\n`);
    }
  }
  process.stdout.write('\n');
  return 0;
}

const [, , subcommand, ...rest] = process.argv;
let code;
if (subcommand === 'release') {
  code = await release(rest);
} else if (subcommand === 'approve') {
  code = await approve(rest);
} else {
  fail('Usage: git-release.mjs release <tag> | approve [<package>] [--otp <code>]');
  code = 2;
}
rl?.close();
process.exit(code);
