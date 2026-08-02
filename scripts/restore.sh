#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
PI_HOME="$(dirname "$AGENT_DIR")"
BACKUP_DIR="${1:-}"
ASSUME_YES="${2:-}"

[ -n "$BACKUP_DIR" ] || { echo "Usage: scripts/restore.sh BACKUP_DIR [--yes]" >&2; exit 2; }
[ -d "$BACKUP_DIR" ] || { echo "Backup directory not found: $BACKUP_DIR" >&2; exit 1; }
[ -f "$BACKUP_DIR/MANIFEST.txt" ] || { echo "Not an awesome-pi-setup backup: $BACKUP_DIR" >&2; exit 1; }
[ -f "$BACKUP_DIR/ABSENT.txt" ] || { echo "Backup is missing ABSENT.txt: $BACKUP_DIR" >&2; exit 1; }

map_target() {
  local rel="$1"
  case "$rel" in
    agent/settings.json|agent/AGENTS.md|agent/subagents.json|agent/pi-goal-list-loop-audit.settings.json|agent/pi-plan-mode.json)
      printf '%s/%s\n' "$AGENT_DIR" "${rel#agent/}" ;;
    agent/extensions/pi-permission-system/config.json|agent/extensions/pi-openai-fast.json|agent/prompts/code-review.md|agent/prompts/commit.md|agent/prompts/doctor.md)
      printf '%s/%s\n' "$AGENT_DIR" "${rel#agent/}" ;;
    pi/web-search.json)
      printf '%s/web-search.json\n' "$PI_HOME" ;;
    config/cortexkit/magic-context.jsonc)
      printf '%s/.config/cortexkit/magic-context.jsonc\n' "$HOME" ;;
    skills/.pi-skill-sources.json)
      printf '%s/.agents/skills/.pi-skill-sources.json\n' "$HOME" ;;
    skills/applying-tdd|skills/reviewing-code|skills/writing-git-commits|skills/hardening-code-paths|skills/designing-user-experiences)
      printf '%s/.agents/skills/%s\n' "$HOME" "${rel#skills/}" ;;
    *) return 1 ;;
  esac
}

# Reject forged backups, symlinks, credentials, sessions, and files outside the
# installer's explicit allowlist. Skill directory contents are allowed only
# beneath one of the five fixed skill roots.
if find "$BACKUP_DIR" ! -type f ! -type d -print -quit | grep -q .; then
  echo "Backup contains symlinks or special files and cannot be restored automatically" >&2
  exit 1
fi
while IFS= read -r file; do
  rel="${file#"$BACKUP_DIR"/}"
  case "$rel" in
    MANIFEST.txt|ABSENT.txt) ;;
    skills/applying-tdd/*|skills/reviewing-code/*|skills/writing-git-commits/*|skills/hardening-code-paths/*|skills/designing-user-experiences/*) ;;
    *) map_target "$rel" >/dev/null || { echo "Unexpected backup file: $rel" >&2; exit 1; } ;;
  esac
done < <(find "$BACKUP_DIR" -type f -print)

while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  map_target "$rel" >/dev/null || { echo "Unexpected ABSENT entry: $rel" >&2; exit 1; }
done < "$BACKUP_DIR/ABSENT.txt"

cat "$BACKUP_DIR/MANIFEST.txt"
if [ "$ASSUME_YES" != "--yes" ]; then
  [ -t 0 ] || { echo "Interactive confirmation required" >&2; exit 1; }
  printf 'Restore this configuration backup? [y/N] '
  read -r reply
  case "$reply" in y|Y|yes|YES) ;; *) echo "Cancelled"; exit 0 ;; esac
fi

restore_item() {
  local rel="$1" source="$BACKUP_DIR/$1" target
  target="$(map_target "$rel")"
  if [ -e "$source" ]; then
    mkdir -p "$(dirname "$target")"
    rm -rf "$target"
    cp -R "$source" "$target"
  fi
}

for rel in \
  agent/settings.json agent/AGENTS.md agent/subagents.json \
  agent/pi-goal-list-loop-audit.settings.json agent/pi-plan-mode.json \
  agent/extensions/pi-permission-system/config.json \
  agent/extensions/pi-openai-fast.json \
  agent/prompts/code-review.md agent/prompts/commit.md agent/prompts/doctor.md \
  pi/web-search.json config/cortexkit/magic-context.jsonc \
  skills/.pi-skill-sources.json skills/applying-tdd skills/reviewing-code \
  skills/writing-git-commits skills/hardening-code-paths \
  skills/designing-user-experiences; do
  restore_item "$rel"
done

while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  target="$(map_target "$rel")"
  rm -rf "$target"
done < "$BACKUP_DIR/ABSENT.txt"

chmod 600 "$AGENT_DIR/settings.json" 2>/dev/null || true
echo "Configuration restored. Credentials, models, and sessions were never changed."
echo "Restart Pi or run /reload. Unreferenced npm package files are inactive and may be pruned by Pi later."
