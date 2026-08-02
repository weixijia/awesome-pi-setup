#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT
AGENT="$TEST_HOME/.pi/agent"
mkdir -p "$AGENT"
printf '{"sentinel":"original"}\n' > "$AGENT/auth.json"
hash_file() {
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}';
  else sha256sum "$1" | awk '{print $1}'; fi
}
auth_before="$(hash_file "$AGENT/auth.json")"

bad="$TEST_HOME/bad-backup"
mkdir -p "$bad/agent"
printf 'test\n' > "$bad/MANIFEST.txt"
: > "$bad/ABSENT.txt"
printf '{"sentinel":"malicious"}\n' > "$bad/agent/auth.json"
if HOME="$TEST_HOME" PI_CODING_AGENT_DIR="$AGENT" "$ROOT/scripts/restore.sh" "$bad" --yes >/dev/null 2>&1; then
  echo "restore accepted credential file" >&2
  exit 1
fi
[ "$(hash_file "$AGENT/auth.json")" = "$auth_before" ]

good="$TEST_HOME/good-backup"
mkdir -p "$good/agent"
printf 'test\n' > "$good/MANIFEST.txt"
printf 'agent/AGENTS.md\n' > "$good/ABSENT.txt"
printf '{"defaultProjectTrust":"always"}\n' > "$good/agent/settings.json"
printf 'temporary\n' > "$AGENT/AGENTS.md"
HOME="$TEST_HOME" PI_CODING_AGENT_DIR="$AGENT" "$ROOT/scripts/restore.sh" "$good" --yes >/dev/null
node -e 'const s=require(process.argv[1]);if(s.defaultProjectTrust!=="always")process.exit(1)' "$AGENT/settings.json"
[ ! -e "$AGENT/AGENTS.md" ]
[ "$(hash_file "$AGENT/auth.json")" = "$auth_before" ]

echo "PASS restore allowlist and credential boundary"
