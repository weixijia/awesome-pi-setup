# Manual Installation Tutorial

This is the transparent alternative to `./install.sh`. Read the upstream source
linked beside every command before installing it. Pi packages execute with your
user permissions.

## 1. Check prerequisites

```bash
pi --version       # >= 0.83.0
node --version     # >= 22
npm --version
git --version
python3 --version
```

Pi source: [earendil-works/pi](https://github.com/earendil-works/pi).

## 2. Create a private backup

Do not add this backup to Git and do not create extra credential copies:

```bash
stamp="$(date +%Y%m%d-%H%M%S)"
backup="$HOME/.pi/backups/awesome-pi-setup-$stamp"
mkdir -p "$backup"
chmod 700 "$HOME/.pi/backups" "$backup"
cp "$HOME/.pi/agent/settings.json" "$backup/settings.json" 2>/dev/null || true
```

Back up any plugin config you plan to replace. Leave `auth.json` and sessions in
place and untouched.

## 3. Install the exact Pi packages

```bash
# Subagents — https://github.com/gotgenes/pi-packages/tree/main/packages/pi-subagents
pi install npm:@gotgenes/pi-subagents@19.2.1

# Web access — https://github.com/nicobailon/pi-web-access
pi install npm:pi-web-access@0.17.1

# Todo — https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-todo
pi install npm:@juicesharp/rpiv-todo@2.3.1

# Structured questions — https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-ask-user-question
pi install npm:@juicesharp/rpiv-ask-user-question@2.3.1

# Plan mode — https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-plan-mode
pi install npm:@narumitw/pi-plan-mode@0.44.0

# AGENTS/CLAUDE maintenance skills — https://github.com/mrclrchtr/supi/tree/main/packages/supi-claude-md
pi install npm:@mrclrchtr/supi-claude-md@4.4.0

# Cache optimization — https://github.com/jiangge/pi-cache-optimizer
pi install npm:pi-cache-optimizer@2.6.25

# Status line — https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-statusline
pi install npm:@narumitw/pi-statusline@0.43.0

# Optional OpenAI priority toggle — https://github.com/ben-vargas/pi-packages/tree/main/packages/pi-openai-fast
pi install npm:@benvargas/pi-openai-fast@1.0.5

# Usage display — https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-usage
pi install npm:@narumitw/pi-usage@0.43.0

# Long-term context — https://github.com/cortexkit/magic-context/tree/master/packages/pi-plugin
pi install npm:@cortexkit/pi-magic-context@0.33.0

# Audited goals/loops — https://github.com/DraconDev/pi-goal-list-loop-audit
pi install npm:pi-goal-list-loop-audit@0.34.20

# Permission policy — https://github.com/gotgenes/pi-packages/tree/main/packages/pi-permission-system
pi install npm:@gotgenes/pi-permission-system@24.0.0

# LSP tools — https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-lsp
pi install npm:@narumitw/pi-lsp@0.44.0

# Git worktrees — https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-worktree
pi install npm:@narumitw/pi-worktree@0.43.0
```

Use `manifest/packages.json` to compare every downloaded package tarball's
SHA-512 integrity and compare its extracted files with `node_modules` after
installation. Exact settings entries must retain the `@version` suffix. The
automated installer performs both checks.

## 4. Remove unused package identities

Only remove a package if it is present in `pi list`:

```bash
pi remove npm:pi-webdav-sync
pi remove npm:pi-mcp-adapter
pi remove npm:pi-tool-display
```

The rationale is in `docs/PLUGINS.md`; these packages may be installed again
later when you have a concrete, reviewed use case.

## 5. Install LSP executables

```bash
# https://github.com/biomejs/biome
npm install -g @biomejs/biome@2.5.6

# https://github.com/bash-lsp/bash-language-server
npm install -g bash-language-server@5.6.0

# https://github.com/redhat-developer/yaml-language-server
npm install -g yaml-language-server@1.24.0

# uv: https://github.com/astral-sh/uv
# Ruff: https://github.com/astral-sh/ruff
uv tool install --force 'ruff==0.16.1'

# ty: https://github.com/astral-sh/ty
uv tool install --force 'ty==0.0.65'
```

On macOS, `clangd` and `sourcekit-lsp` are normally supplied by Xcode or Xcode
Command Line Tools:

- [llvm/llvm-project](https://github.com/llvm/llvm-project)
- [swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp)

Do not create a custom `pi-lsp.json` unless you want to replace the plugin's
built-in server catalog.

## 6. Review npm lifecycle scripts

Recent npm versions may block lifecycle scripts until reviewed:

```bash
cd "$HOME/.pi/agent/npm"
npm install-scripts ls
```

For this snapshot, required packages are expected to be exactly:

- `tree-sitter-bash@0.25.1` — native parser build
- `onnxruntime-node@1.24.3` — local embedding runtime
- `protobufjs@7.6.5` — dependency compatibility check
- `sharp@0.34.5` — native image runtime check

Inspect the installed scripts and versions before approving them. Do not approve
unexpected package names.

## 7. Install configuration

Review files under `config/` and copy them to the corresponding locations:

| Repository file | Destination |
|---|---|
| `config/agent/subagents.json` | `~/.pi/agent/subagents.json` |
| `config/agent/pi-goal-list-loop-audit.settings.json` | `~/.pi/agent/pi-goal-list-loop-audit.settings.json` |
| `config/agent/pi-plan-mode.json` | `~/.pi/agent/pi-plan-mode.json` |
| `config/agent/extensions/pi-permission-system/config.json` | `~/.pi/agent/extensions/pi-permission-system/config.json` |
| `config/agent/extensions/pi-openai-fast.json` | `~/.pi/agent/extensions/pi-openai-fast.json` |
| `config/web-search.json` | `~/.pi/web-search.json` |
| `config/cortexkit/magic-context.jsonc` | `~/.config/cortexkit/magic-context.jsonc` |
| `config/agent/prompts/*.md` | `~/.pi/agent/prompts/` |

Merge these settings into `~/.pi/agent/settings.json` without replacing its model,
provider, theme, or unrelated packages:

```json
{
  "defaultProjectTrust": "ask",
  "enableInstallTelemetry": false,
  "enableSkillCommands": true
}
```

If you already have `~/.pi/agent/AGENTS.md`, merge it manually rather than
silently overwriting your global instructions.

## 8. Install curated Skills

Source: [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions),
commit `ceaabed6c40ee98ba1b61e264fe1ecf527538770`.

Clone and check out that exact commit, inspect each `SKILL.md`, then copy these
directories from `.agents/skills/` to `~/.agents/skills/`:

- `applying-tdd`
- `reviewing-code`
- `writing-git-commits`
- `hardening-code-paths`
- `designing-user-experiences`

Do not copy a moving `main` branch without reviewing the diff.

## 9. Verify and reload

From this repository:

```bash
./verify.sh
```

Then run `/reload` in Pi or restart the process. Check `/permission-system`,
`/lsp`, and `/worktree`. Use your own `/login` flow for providers; this setup does
not install or migrate credentials.
