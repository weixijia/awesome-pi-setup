#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
PI_HOME="$(dirname "$AGENT_DIR")"
BACKUP_ROOT="$PI_HOME/backups"
MAGIC_MODEL="openai/gpt-5.4-mini"
ASSUME_YES=0
SKIP_LSP=0
SKIP_SKILLS=0
BACKUP_DIR=""
TMP_DIR=""
INSTALL_COMMITTED=0
CONFIG_MUTATED=0

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --yes                  Accept installer confirmations (review the script first)
  --magic-model MODEL    Historian/dreamer model (default: openai/gpt-5.4-mini)
  --skip-lsp             Skip global language-server CLI installation
  --skip-skills          Skip curated skill installation
  -h, --help             Show this help

The installer preserves auth.json, model/provider defaults, themes, sessions, and
unrelated packages. It creates a private backup before changing configuration.
EOF
}

confirm() {
  local prompt="$1" reply
  if [ "$ASSUME_YES" -eq 1 ]; then return 0; fi
  if [ ! -t 0 ]; then die "Confirmation required in a non-interactive shell. Re-run interactively or use --yes after review."; fi
  printf '%s [y/N] ' "$prompt"
  read -r reply
  case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

cleanup() {
  local status="$?"
  trap - ERR
  if [ "$status" -ne 0 ] && [ "$INSTALL_COMMITTED" -eq 0 ] && [ "$CONFIG_MUTATED" -eq 1 ] && [ -n "$BACKUP_DIR" ] && [ -f "$BACKUP_DIR/MANIFEST.txt" ]; then
    warn "Restoring the pre-install configuration automatically"
    "$ROOT_DIR/scripts/restore.sh" "$BACKUP_DIR" --yes \
      || warn "Automatic restore failed; run: $ROOT_DIR/scripts/restore.sh '$BACKUP_DIR'"
    warn "Downloaded package files or global LSP tool versions may remain; restored Pi settings keep packages inactive"
  fi
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then rm -rf "$TMP_DIR"; fi
  return "$status"
}
on_error() {
  local line="$1"
  warn "Installation stopped at line $line. Existing credentials were not modified."
}
trap cleanup EXIT
trap 'on_error "$LINENO"' ERR

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes) ASSUME_YES=1 ;;
    --magic-model)
      [ "$#" -ge 2 ] || die "--magic-model requires a value"
      MAGIC_MODEL="$2"; shift
      ;;
    --skip-lsp) SKIP_LSP=1 ;;
    --skip-skills) SKIP_SKILLS=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
  shift
done

case "$MAGIC_MODEL" in
  *[!A-Za-z0-9._:/-]*|'') die "Invalid --magic-model value" ;;
esac

[ "$(id -u)" -ne 0 ] || die "Do not run this installer as root"
for cmd in pi node npm git python3 tar; do
  command -v "$cmd" >/dev/null 2>&1 || die "Missing required command: $cmd"
done

node -e '
const [current, minimum] = process.argv.slice(1);
const parts = v => v.replace(/^v/, "").split(".").map(x => Number.parseInt(x, 10) || 0);
const a = parts(current), b = parts(minimum);
for (let i = 0; i < 3; i++) {
  if ((a[i] || 0) > (b[i] || 0)) process.exit(0);
  if ((a[i] || 0) < (b[i] || 0)) process.exit(1);
}
' "$(node -p 'process.versions.node')" "22.0.0" || die "Node.js 22 or newer is required"

PI_VERSION="$(pi --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
[ -n "$PI_VERSION" ] || die "Could not determine Pi version"
node -e '
const [current, minimum] = process.argv.slice(1);
const p = v => v.split(".").map(Number);
const a=p(current), b=p(minimum);
for(let i=0;i<3;i++){if(a[i]>b[i])process.exit(0);if(a[i]<b[i])process.exit(1)}
' "$PI_VERSION" "0.83.0" || die "Pi 0.83.0 or newer is required (found $PI_VERSION)"

cat <<EOF
This will configure the user-scoped Pi installation at:
  $AGENT_DIR

It will:
  - install 15 exact-pinned Pi packages
  - add a conservative permission policy and bounded agent settings
  - install prompt templates and optionally five pinned skills
  - optionally install pinned language-server CLIs globally

It will NOT read, copy, delete, or overwrite auth.json, models.json, sessions,
defaultProvider, defaultModel, defaultThinkingLevel, or theme. Configuration is
automatically restored on failure; global LSP tool updates cannot be rolled back
safely and may remain.
EOF
confirm "Continue?" || { log "Cancelled"; exit 0; }

mkdir -p "$AGENT_DIR" "$BACKUP_ROOT"
chmod 700 "$BACKUP_ROOT"
BACKUP_DIR="$BACKUP_ROOT/awesome-pi-setup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR/agent" "$BACKUP_DIR/pi" "$BACKUP_DIR/config/cortexkit" "$BACKUP_DIR/skills"
chmod 700 "$BACKUP_DIR"
: > "$BACKUP_DIR/ABSENT.txt"

backup_path() {
  local source="$1" destination="$2"
  if [ -e "$source" ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$destination")"
    cp -R "$source" "$BACKUP_DIR/$destination"
  else
    printf '%s\n' "$destination" >> "$BACKUP_DIR/ABSENT.txt"
  fi
}

log "Creating private backup"
for rel in \
  settings.json AGENTS.md subagents.json pi-goal-list-loop-audit.settings.json \
  pi-plan-mode.json extensions/pi-permission-system/config.json \
  extensions/pi-openai-fast.json prompts/code-review.md prompts/commit.md prompts/doctor.md; do
  backup_path "$AGENT_DIR/$rel" "agent/$rel"
done
backup_path "$PI_HOME/web-search.json" "pi/web-search.json"
backup_path "$HOME/.config/cortexkit/magic-context.jsonc" "config/cortexkit/magic-context.jsonc"
backup_path "$HOME/.agents/skills/.pi-skill-sources.json" "skills/.pi-skill-sources.json"
if [ "$SKIP_SKILLS" -eq 0 ]; then
  while IFS= read -r name; do backup_path "$HOME/.agents/skills/$name" "skills/$name"; done < <(
    node -e 'for(const x of require(process.argv[1]).skills.names) console.log(x)' "$ROOT_DIR/manifest/toolchain.json"
  )
fi
cat > "$BACKUP_DIR/MANIFEST.txt" <<EOF
Created by awesome-pi-setup on $(date -u +%Y-%m-%dT%H:%M:%SZ)
Source repository: https://github.com/weixijia/awesome-pi-setup
Pi agent directory: $AGENT_DIR
Credentials and sessions were intentionally excluded.
EOF
if find "$BACKUP_DIR" ! -type f ! -type d -print -quit | grep -q .; then
  die "Managed configuration contains symlinks or special files; back it up and merge manually"
fi

log "Downloading and verifying pinned npm tarballs"
TMP_DIR="$(mktemp -d)"
PACK_DIR="$TMP_DIR/packs"
mkdir -p "$PACK_DIR"
node - "$ROOT_DIR/manifest/packages.json" "$PACK_DIR" <<'NODE'
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const cp = require('node:child_process');
const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const packDir = process.argv[3];
const verified = [];
for (const pkg of manifest.packages) {
  const target = pkg.spec.slice(4);
  const output = cp.execFileSync(
    'npm', ['pack', target, '--json', '--ignore-scripts', '--pack-destination', packDir],
    { encoding: 'utf8' },
  );
  const payload = JSON.parse(output);
  const result = Array.isArray(payload) ? payload[0] : Object.values(payload)[0];
  if (!result || typeof result.filename !== 'string') throw new Error(`Unexpected npm pack output for ${target}`);
  const tarball = path.join(packDir, path.basename(result.filename));
  const actual = `sha512-${crypto.createHash('sha512').update(fs.readFileSync(tarball)).digest('base64')}`;
  if (result.integrity !== pkg.integrity || actual !== pkg.integrity) {
    throw new Error(`Integrity mismatch for ${target}`);
  }
  const value = target;
  const at = value.lastIndexOf('@');
  verified.push({ spec: pkg.spec, name: value.slice(0, at), filename: path.basename(result.filename) });
  process.stdout.write(`  verified ${target}\n`);
}
fs.writeFileSync(path.join(packDir, 'verified-packs.json'), JSON.stringify(verified, null, 2) + '\n');
NODE

log "Removing replaced package identities while preserving unrelated settings"
CONFIG_MUTATED=1
mkdir -p "$(dirname "$AGENT_DIR/settings.json")"
[ -f "$AGENT_DIR/settings.json" ] || printf '{}\n' > "$AGENT_DIR/settings.json"
SETTINGS_PATH="$AGENT_DIR/settings.json" MANIFEST_PATH="$ROOT_DIR/manifest/packages.json" node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const settingsPath = process.env.SETTINGS_PATH;
const manifest = JSON.parse(fs.readFileSync(process.env.MANIFEST_PATH, 'utf8'));
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
function npmName(entry) {
  const source = typeof entry === 'string' ? entry : entry && entry.source;
  if (typeof source !== 'string' || !source.startsWith('npm:')) return null;
  const value = source.slice(4);
  const at = value.lastIndexOf('@');
  return at > 0 ? value.slice(0, at) : value;
}
const managed = new Set(manifest.packages.map(p => npmName(p.spec)));
const removed = new Set(manifest.removedPackages);
settings.packages = (settings.packages || []).filter(entry => {
  const name = npmName(entry);
  return !name || (!managed.has(name) && !removed.has(name));
});
settings.defaultProjectTrust = 'ask';
settings.enableInstallTelemetry = false;
settings.enableSkillCommands = true;
const temp = `${settingsPath}.awesome-pi-setup.tmp`;
fs.writeFileSync(temp, JSON.stringify(settings, null, 2) + '\n', { mode: 0o600 });
fs.renameSync(temp, settingsPath);
NODE

log "Installing exact-pinned Pi packages"
while IFS= read -r spec; do
  pi install "$spec"
done < <(node -e 'for(const p of require(process.argv[1]).packages) console.log(p.spec)' "$ROOT_DIR/manifest/packages.json")

log "Comparing installed packages with the verified tarballs"
PACK_DIR="$PACK_DIR" NPM_ROOT="$AGENT_DIR/npm" node <<'NODE'
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const cp = require('node:child_process');
const packDir = process.env.PACK_DIR;
const npmRoot = process.env.NPM_ROOT;
const packs = JSON.parse(fs.readFileSync(path.join(packDir, 'verified-packs.json'), 'utf8'));
function snapshot(root, skipRootNodeModules = false) {
  const result = new Map();
  function visit(relative) {
    const absolute = path.join(root, relative);
    const stat = fs.lstatSync(absolute);
    if (stat.isDirectory()) {
      result.set(relative, 'dir');
      for (const name of fs.readdirSync(absolute).sort()) {
        if (skipRootNodeModules && relative === '' && name === 'node_modules') continue;
        visit(path.join(relative, name));
      }
    } else if (stat.isSymbolicLink()) {
      result.set(relative, `link:${fs.readlinkSync(absolute)}`);
    } else if (stat.isFile()) {
      const hash = crypto.createHash('sha256').update(fs.readFileSync(absolute)).digest('hex');
      result.set(relative, `file:${hash}`);
    } else {
      result.set(relative, `other:${stat.mode}`);
    }
  }
  visit('');
  return result;
}
for (const [index, item] of packs.entries()) {
  const extractDir = path.join(packDir, `extract-${index}`);
  fs.mkdirSync(extractDir);
  cp.execFileSync('tar', ['-xzf', path.join(packDir, item.filename), '-C', extractDir]);
  const expectedRoot = path.join(extractDir, 'package');
  const expected = snapshot(expectedRoot);
  const installed = snapshot(
    path.join(npmRoot, 'node_modules', ...item.name.split('/')),
    !fs.existsSync(path.join(expectedRoot, 'node_modules')),
  );
  const keys = new Set([...expected.keys(), ...installed.keys()]);
  const mismatch = [...keys].find(key => expected.get(key) !== installed.get(key));
  if (mismatch !== undefined) throw new Error(`${item.name}: installed artifact differs at ${mismatch || '.'}`);
  process.stdout.write(`  matched ${item.name}\n`);
}
NODE

if npm install-scripts --help >/dev/null 2>&1; then
  log "Refreshing lock metadata without running lifecycle scripts"
  (cd "$AGENT_DIR/npm" && npm install --package-lock-only --ignore-scripts --omit=dev --legacy-peer-deps)
  TOOLCHAIN_PATH="$ROOT_DIR/manifest/toolchain.json" NPM_ROOT="$AGENT_DIR/npm" node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const root = process.env.NPM_ROOT;
const lock = JSON.parse(fs.readFileSync(path.join(root, 'package-lock.json'), 'utf8'));
const expected = JSON.parse(fs.readFileSync(process.env.TOOLCHAIN_PATH, 'utf8')).reviewedInstallScripts;
for (const [name, version] of Object.entries(expected)) {
  const entry = lock.packages?.[`node_modules/${name}`];
  if (entry?.version !== version || typeof entry?.resolved !== 'string') {
    throw new Error(`${name}@${version} lacks version-pinnable lock metadata`);
  }
}
NODE
  log "Reviewing required npm lifecycle scripts"
  UNAPPROVED="$(TOOLCHAIN_PATH="$ROOT_DIR/manifest/toolchain.json" NPM_ROOT="$AGENT_DIR/npm" node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const root = process.env.NPM_ROOT;
const expected = JSON.parse(fs.readFileSync(process.env.TOOLCHAIN_PATH, 'utf8')).reviewedInstallScripts;
const rootPkgPath = path.join(root, 'package.json');
const rootPkg = JSON.parse(fs.readFileSync(rootPkgPath, 'utf8'));
for (const [name, version] of Object.entries(expected)) {
  const installed = JSON.parse(fs.readFileSync(path.join(root, 'node_modules', name, 'package.json'), 'utf8')).version;
  if (installed !== version) throw new Error(`${name}: expected ${version}, found ${installed}`);
  if (rootPkg.allowScripts?.[`${name}@${version}`] !== true) console.log(name);
}
NODE
)"
  if [ -n "$UNAPPROVED" ]; then
    printf 'The following exact versions have reviewed lifecycle scripts:\n%s\n' "$UNAPPROVED"
    confirm "Approve these four known install scripts?" || die "Required install scripts were not approved"
    (cd "$AGENT_DIR/npm" && npm install-scripts approve tree-sitter-bash onnxruntime-node protobufjs sharp)
  fi
  TOOLCHAIN_PATH="$ROOT_DIR/manifest/toolchain.json" NPM_ROOT="$AGENT_DIR/npm" node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const root = process.env.NPM_ROOT;
const pkgPath = path.join(root, 'package.json');
const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
const expected = JSON.parse(fs.readFileSync(process.env.TOOLCHAIN_PATH, 'utf8')).reviewedInstallScripts;
pkg.allowScripts ||= {};
for (const [name, version] of Object.entries(expected)) {
  for (const key of Object.keys(pkg.allowScripts)) {
    if (key === name || key.startsWith(`${name}@`)) delete pkg.allowScripts[key];
  }
  pkg.allowScripts[`${name}@${version}`] = true;
}
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + '\n');
NODE
  (cd "$AGENT_DIR/npm" && npm install-scripts ls)
fi

install_config() {
  local source="$1" destination="$2" mode="${3:-600}"
  mkdir -p "$(dirname "$destination")"
  install -m "$mode" "$source" "$destination"
}

log "Installing hardened extension configuration"
install_config "$ROOT_DIR/config/agent/subagents.json" "$AGENT_DIR/subagents.json"
install_config "$ROOT_DIR/config/agent/pi-goal-list-loop-audit.settings.json" "$AGENT_DIR/pi-goal-list-loop-audit.settings.json"
install_config "$ROOT_DIR/config/agent/pi-plan-mode.json" "$AGENT_DIR/pi-plan-mode.json"
install_config "$ROOT_DIR/config/agent/extensions/pi-permission-system/config.json" "$AGENT_DIR/extensions/pi-permission-system/config.json"
install_config "$ROOT_DIR/config/agent/extensions/pi-openai-fast.json" "$AGENT_DIR/extensions/pi-openai-fast.json"
install_config "$ROOT_DIR/config/web-search.json" "$PI_HOME/web-search.json"

mkdir -p "$HOME/.config/cortexkit"
chmod 700 "$HOME/.config/cortexkit"
MAGIC_MODEL="$MAGIC_MODEL" SOURCE_PATH="$ROOT_DIR/config/cortexkit/magic-context.jsonc" DEST_PATH="$HOME/.config/cortexkit/magic-context.jsonc" node <<'NODE'
const fs = require('node:fs');
let text = fs.readFileSync(process.env.SOURCE_PATH, 'utf8');
text = text.replaceAll('openai/gpt-5.4-mini', process.env.MAGIC_MODEL);
fs.writeFileSync(process.env.DEST_PATH, text, { mode: 0o600 });
NODE

if [ ! -f "$AGENT_DIR/AGENTS.md" ]; then
  install_config "$ROOT_DIR/config/agent/AGENTS.md" "$AGENT_DIR/AGENTS.md" 644
else
  warn "Preserved existing $AGENT_DIR/AGENTS.md; merge config/agent/AGENTS.md manually if desired"
fi
for name in code-review commit doctor; do
  install_config "$ROOT_DIR/config/agent/prompts/$name.md" "$AGENT_DIR/prompts/$name.md" 644
done

if [ "$SKIP_SKILLS" -eq 0 ]; then
  log "Installing curated skills from a pinned Git commit"
  SKILL_REPO="$(node -p 'require(process.argv[1]).skills.repository' "$ROOT_DIR/manifest/toolchain.json")"
  SKILL_COMMIT="$(node -p 'require(process.argv[1]).skills.commit' "$ROOT_DIR/manifest/toolchain.json")"
  SKILL_CHECKOUT="$TMP_DIR/skills-source"
  mkdir -p "$SKILL_CHECKOUT"
  git -C "$SKILL_CHECKOUT" init -q
  git -C "$SKILL_CHECKOUT" remote add origin "$SKILL_REPO"
  git -C "$SKILL_CHECKOUT" fetch -q --depth 1 origin "$SKILL_COMMIT"
  git -C "$SKILL_CHECKOUT" checkout -q --detach FETCH_HEAD
  mkdir -p "$HOME/.agents/skills"
  while IFS= read -r name; do
    source="$SKILL_CHECKOUT/.agents/skills/$name"
    [ -f "$source/SKILL.md" ] || die "Missing skill at pinned commit: $name"
    rm -rf "$HOME/.agents/skills/$name"
    cp -R "$source" "$HOME/.agents/skills/$name"
  done < <(node -e 'for(const x of require(process.argv[1]).skills.names) console.log(x)' "$ROOT_DIR/manifest/toolchain.json")
  SKILL_REPO="$SKILL_REPO" SKILL_COMMIT="$SKILL_COMMIT" TOOLCHAIN_PATH="$ROOT_DIR/manifest/toolchain.json" DEST="$HOME/.agents/skills/.pi-skill-sources.json" node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const dest = process.env.DEST;
let data = {};
if (fs.existsSync(dest)) data = JSON.parse(fs.readFileSync(dest, 'utf8'));
const key = process.env.SKILL_REPO.replace(/^https:\/\/github\.com\//, '').replace(/\.git$/, '');
const skills = JSON.parse(fs.readFileSync(process.env.TOOLCHAIN_PATH, 'utf8')).skills.names;
data[key] = { commit: process.env.SKILL_COMMIT, skills };
fs.writeFileSync(dest, JSON.stringify(data, null, 2) + '\n', { mode: 0o600 });
NODE
fi

if [ "$SKIP_LSP" -eq 0 ]; then
  log "Installing pinned language-server CLIs"
  npm install -g \
    @biomejs/biome@2.5.6 \
    bash-language-server@5.6.0 \
    yaml-language-server@1.24.0
  if ! command -v uv >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      confirm "Install uv with Homebrew for Python language servers?" || die "uv is required unless --skip-lsp is used"
      brew install uv
    else
      die "uv is required for ruff and ty. Install it from https://github.com/astral-sh/uv and re-run."
    fi
  fi
  uv tool install --force 'ruff==0.16.1'
  uv tool install --force 'ty==0.0.65'
  command -v clangd >/dev/null 2>&1 || warn "clangd not found; install Xcode Command Line Tools for C/C++ diagnostics"
  command -v sourcekit-lsp >/dev/null 2>&1 || warn "sourcekit-lsp not found; install Xcode for Swift diagnostics"
fi

log "Running repository verifier"
VERIFY_ARGS=""
[ "$SKIP_LSP" -eq 1 ] && VERIFY_ARGS="$VERIFY_ARGS --skip-lsp"
[ "$SKIP_SKILLS" -eq 1 ] && VERIFY_ARGS="$VERIFY_ARGS --skip-skills"
# Word splitting is intentional for the two fixed flags above.
# shellcheck disable=SC2086
"$ROOT_DIR/verify.sh" $VERIFY_ARGS
INSTALL_COMMITTED=1

log "Installation complete"
printf 'Backup: %s\n' "$BACKUP_DIR"
printf 'Restart Pi or run /reload in an existing session.\n'
