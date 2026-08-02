#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/install.sh" "$ROOT/verify.sh" "$ROOT/scripts/restore.sh"
echo "PASS bash syntax"

ROOT="$ROOT" python3 <<'PY'
import json, os, pathlib, re
root = pathlib.Path(os.environ['ROOT'])
json_files = list(root.rglob('*.json'))
for path in json_files:
    json.loads(path.read_text())
manifest = json.loads((root / 'manifest/packages.json').read_text())
assert len(manifest['packages']) == 15
specs = [p['spec'] for p in manifest['packages']]
assert len(specs) == len(set(specs))
for package in manifest['packages']:
    assert package['spec'].startswith('npm:')
    assert re.search(r'@\d+\.\d+\.\d+$', package['spec'])
    assert package['repository'].startswith('https://github.com/')
    assert package['integrity'].startswith('sha512-')
readmes = [
    (root / 'README.md').read_text(),
    (root / 'README.fr.md').read_text(),
    (root / 'README.zh-CN.md').read_text(),
]
manual = (root / 'docs/MANUAL_INSTALL.md').read_text()
for package in manifest['packages']:
    name = package['spec'][4:]
    if name.startswith('@'):
        name = name[:name.rfind('@')]
    else:
        name = name.split('@', 1)[0]
    for index, readme in enumerate(readmes):
        assert name in readme, f'{name} missing from README #{index + 1}'
        assert package['repository'] in readme, f'{name} source missing from README #{index + 1}'
    assert package['spec'] in manual, f'{name} command missing from manual guide'

# Resolve local Markdown links; ignore anchors and remote URLs.
link_re = re.compile(r'\[[^]]*\]\(([^)]+)\)')
for md in root.rglob('*.md'):
    for target in link_re.findall(md.read_text()):
        target = target.split('#', 1)[0]
        if not target or '://' in target or target.startswith('mailto:'):
            continue
        resolved = (md.parent / target).resolve()
        assert resolved.exists(), f'broken local link in {md}: {target}'

# Basic public-repository secret guard. This is intentionally conservative.
for path in root.rglob('*'):
    if not path.is_file() or '.git' in path.parts:
        continue
    text = path.read_text(errors='ignore')
    assert not re.search(r'(?i)(api[_-]?key|token|secret)\s*[=:]\s*["\x27][A-Za-z0-9_\-]{20,}', text), f'possible secret in {path}'
    assert not re.search(r'\bsk-[A-Za-z0-9]{20,}\b', text), f'possible API key in {path}'
print(f'PASS {len(json_files)} JSON files, manifest, docs, local links, and secret guard')
PY

"$ROOT/tests/restore-security.sh"

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "$ROOT/install.sh" "$ROOT/verify.sh" "$ROOT/scripts/restore.sh"
  echo "PASS shellcheck"
else
  echo "SKIP shellcheck (not installed)"
fi
