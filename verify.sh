#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
PI_HOME="$(dirname "$AGENT_DIR")"
SKIP_LSP=0
SKIP_SKILLS=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-lsp) SKIP_LSP=1 ;;
    --skip-skills) SKIP_SKILLS=1 ;;
    -h|--help)
      echo "Usage: ./verify.sh [--skip-lsp] [--skip-skills]"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

pass() { printf '\033[1;32mPASS\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31mFAIL\033[0m %s\n' "$*" >&2; exit 1; }

for cmd in pi node npm python3; do command -v "$cmd" >/dev/null 2>&1 || fail "Missing command: $cmd"; done

AGENT_DIR="$AGENT_DIR" PI_HOME="$PI_HOME" ROOT_DIR="$ROOT_DIR" SKIP_SKILLS="$SKIP_SKILLS" node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const agent = process.env.AGENT_DIR;
const root = process.env.ROOT_DIR;
const manifest = JSON.parse(fs.readFileSync(path.join(root, 'manifest/packages.json'), 'utf8'));
const settings = JSON.parse(fs.readFileSync(path.join(agent, 'settings.json'), 'utf8'));
function npmName(entry) {
  const source = typeof entry === 'string' ? entry : entry && entry.source;
  if (typeof source !== 'string' || !source.startsWith('npm:')) return null;
  const value = source.slice(4), at = value.lastIndexOf('@');
  return at > 0 ? value.slice(0, at) : value;
}
const sources = new Set((settings.packages || []).map(x => typeof x === 'string' ? x : x.source));
for (const pkg of manifest.packages) {
  if (!sources.has(pkg.spec)) throw new Error(`Missing exact package: ${pkg.spec}`);
  const value = pkg.spec.slice(4), at = value.lastIndexOf('@');
  const name = value.slice(0, at), expected = value.slice(at + 1);
  const installedPath = path.join(agent, 'npm/node_modules', ...name.split('/'), 'package.json');
  const actual = JSON.parse(fs.readFileSync(installedPath, 'utf8')).version;
  if (actual !== expected) throw new Error(`${name}: expected ${expected}, found ${actual}`);
}
const names = new Set((settings.packages || []).map(npmName).filter(Boolean));
for (const removed of manifest.removedPackages) if (names.has(removed)) throw new Error(`Removed package still configured: ${removed}`);
if (settings.defaultProjectTrust !== 'ask') throw new Error('defaultProjectTrust must be ask');
if (settings.enableInstallTelemetry !== false) throw new Error('enableInstallTelemetry must be false');
if (settings.enableSkillCommands !== true) throw new Error('enableSkillCommands must be true');
const jsonFiles = [
  'subagents.json',
  'pi-goal-list-loop-audit.settings.json',
  'pi-plan-mode.json',
  'extensions/pi-permission-system/config.json',
  'extensions/pi-openai-fast.json'
];
for (const rel of jsonFiles) JSON.parse(fs.readFileSync(path.join(agent, rel), 'utf8'));
JSON.parse(fs.readFileSync(path.join(process.env.PI_HOME, 'web-search.json'), 'utf8'));
JSON.parse(fs.readFileSync(path.join(process.env.HOME, '.config/cortexkit/magic-context.jsonc'), 'utf8'));
for (const name of ['code-review', 'commit', 'doctor']) {
  if (!fs.existsSync(path.join(agent, `prompts/${name}.md`))) throw new Error(`Missing prompt: ${name}`);
}
if (process.env.SKIP_SKILLS !== '1') {
  const toolchain = JSON.parse(fs.readFileSync(path.join(root, 'manifest/toolchain.json'), 'utf8'));
  for (const name of toolchain.skills.names) {
    if (!fs.existsSync(path.join(process.env.HOME, `.agents/skills/${name}/SKILL.md`))) throw new Error(`Missing skill: ${name}`);
  }
  const sourceMap = JSON.parse(fs.readFileSync(path.join(process.env.HOME, '.agents/skills/.pi-skill-sources.json'), 'utf8'));
  const key = toolchain.skills.repository.replace(/^https:\/\/github\.com\//, '').replace(/\.git$/, '');
  if (sourceMap[key]?.commit !== toolchain.skills.commit) throw new Error('Skill source commit mismatch');
}
NODE
pass "Pinned packages, settings, configs, prompts, and skills"

if [ "$SKIP_LSP" -eq 0 ]; then
  command -v biome >/dev/null 2>&1 || fail "biome is missing"
  command -v bash-language-server >/dev/null 2>&1 || fail "bash-language-server is missing"
  command -v yaml-language-server >/dev/null 2>&1 || fail "yaml-language-server is missing"
  command -v ruff >/dev/null 2>&1 || fail "ruff is missing"
  command -v ty >/dev/null 2>&1 || fail "ty is missing"
  biome --version | grep -q '2.5.6' || fail "Unexpected Biome version"
  bash-language-server --version | grep -q '5.6.0' || fail "Unexpected bash-language-server version"
  yaml-language-server --version 2>/dev/null | grep -q '1.24.0' || fail "Unexpected yaml-language-server version"
  ruff --version | grep -q '0.16.1' || fail "Unexpected Ruff version"
  ty --version | grep -q '0.0.65' || fail "Unexpected ty version"
  pass "Pinned language-server toolchain"
  if command -v clangd >/dev/null 2>&1; then pass "clangd available"; else warn "clangd unavailable (optional)"; fi
  if command -v sourcekit-lsp >/dev/null 2>&1; then pass "sourcekit-lsp available"; else warn "sourcekit-lsp unavailable (optional)"; fi
fi

if npm install-scripts --help >/dev/null 2>&1; then
  INSTALL_SCRIPT_OUTPUT="$(cd "$AGENT_DIR/npm" && npm install-scripts ls)"
  printf '%s\n' "$INSTALL_SCRIPT_OUTPUT"
  printf '%s' "$INSTALL_SCRIPT_OUTPUT" | grep -q 'No packages with unreviewed install scripts' \
    || fail "Unreviewed npm lifecycle scripts remain"
  TOOLCHAIN_PATH="$ROOT_DIR/manifest/toolchain.json" NPM_ROOT="$AGENT_DIR/npm" node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const rootPkg = JSON.parse(fs.readFileSync(path.join(process.env.NPM_ROOT, 'package.json'), 'utf8'));
const expected = JSON.parse(fs.readFileSync(process.env.TOOLCHAIN_PATH, 'utf8')).reviewedInstallScripts;
for (const [name, version] of Object.entries(expected)) {
  if (rootPkg.allowScripts?.[name] === true) throw new Error(`${name} is approved for all versions`);
  if (rootPkg.allowScripts?.[`${name}@${version}`] !== true) throw new Error(`${name}@${version} is not exactly approved`);
}
NODE
  pass "No unreviewed npm lifecycle scripts; approvals are version-scoped"
fi

python3 - "$AGENT_DIR" <<'PY'
import collections, json, os, selectors, subprocess, sys, time
agent_dir = sys.argv[1]
env = os.environ.copy()
env['PI_CODING_AGENT_DIR'] = agent_dir
p = subprocess.Popen(
    ['pi', '--mode', 'rpc', '--no-session'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    text=True, env=env, bufsize=1,
)
p.stdin.write('{"id":"commands","type":"get_commands"}\n')
p.stdin.flush()
errors = []
stderr_lines = []
response = None
selector = selectors.DefaultSelector()
selector.register(p.stdout, selectors.EVENT_READ, 'stdout')
selector.register(p.stderr, selectors.EVENT_READ, 'stderr')
deadline = time.monotonic() + 60
try:
    while response is None:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError('Pi RPC get_commands timed out after 60 seconds')
        ready = selector.select(remaining)
        if not ready:
            raise TimeoutError('Pi RPC get_commands timed out after 60 seconds')
        for key, _ in ready:
            line = key.fileobj.readline()
            if not line:
                selector.unregister(key.fileobj)
                if p.poll() is not None and response is None:
                    raise RuntimeError(f'Pi RPC exited before get_commands (code {p.returncode})')
                continue
            if key.data == 'stderr':
                stderr_lines.append(line)
                continue
            event = json.loads(line)
            if event.get('type') == 'extension_error':
                errors.append(event)
            if event.get('id') == 'commands':
                response = event
                break
finally:
    selector.close()
    if p.poll() is None:
        p.terminate()
    try:
        remaining_out, remaining_err = p.communicate(timeout=10)
    except subprocess.TimeoutExpired:
        p.kill()
        remaining_out, remaining_err = p.communicate()
    stderr_lines.append(remaining_err)
stderr = ''.join(stderr_lines).strip()
if not response or not response.get('success'):
    raise SystemExit('RPC get_commands failed')
commands = response['data']['commands']
names = [item['name'] for item in commands]
required = {
    'worktree', 'lsp', 'permission-system', 'code-review', 'commit', 'doctor'
}
missing = sorted(required.difference(names))
duplicates = sorted(name for name, count in collections.Counter(names).items() if count > 1)
if missing or duplicates or errors or stderr:
    raise SystemExit(f'missing={missing} duplicates={duplicates} extension_errors={len(errors)} stderr={stderr!r}')
print(f'RPC_COMMANDS_OK count={len(commands)}')
PY
pass "Pi starts without extension errors or command collisions"

if [ -d "$AGENT_DIR/npm" ]; then
  AUDIT_LOG="$(mktemp "${TMPDIR:-/tmp}/awesome-pi-setup-audit.XXXXXX")"
  if (cd "$AGENT_DIR/npm" && npm audit --omit=dev --audit-level=high >"$AUDIT_LOG" 2>&1); then
    pass "npm audit reports no high-severity findings"
    rm -f "$AUDIT_LOG"
  else
    warn "npm audit reported dependency findings; inspect $AUDIT_LOG and do not run npm audit fix blindly"
  fi
fi

pass "Verification complete"
