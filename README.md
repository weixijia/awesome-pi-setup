# Awesome Pi Setup

**English** | [Francais](README.fr.md) | [Chinese](README.zh-CN.md)

A practical, security-conscious global configuration for [Pi Coding Agent](https://github.com/earendil-works/pi), verified against a real installation.

This is not a "more plugins must be better" bundle. It is a deliberately bounded setup focused on:

- **Safety controls** - confirmation or denial for sensitive paths, external directories, and dangerous shell operations
- **Code intelligence** - LSP diagnostics, definitions, references, symbols, and source fixes
- **Long-running work** - planning, todos, subagents, and audited Goal/List/Loop workflows
- **Web research** - search, webpage/PDF/GitHub/video extraction, and source checking
- **Long-term context** - cross-session memory, semantic search, and durable project knowledge
- **Recovery** - private pre-install backups and an allowlisted restore script
- **Auditable supply chain** - exact package versions, verified tarball integrity, installed-file comparison, and source links

> Snapshot: **2026-08-02**. Minimum versions: Pi **0.83.0**, Node.js **22**.

## Read this before installing

Pi extensions run with your user permissions. They can read and write files, execute commands, and access the network. Review at least these files before installation:

```bash
less install.sh
less SECURITY.md
cat manifest/packages.json
```

This repository intentionally provides **no** `curl ... | bash` command. The installer does not read, upload, remove, or modify:

- `~/.pi/agent/auth.json`
- custom providers or `models.json`
- your default model, provider, thinking level, or theme
- session history or the Magic Context database

## One-click installation through Pi

Copy the entire prompt below into Pi. Pi will audit the repository first and ask before installing:

```text
Install and verify the public repository https://github.com/weixijia/awesome-pi-setup for me.

Requirements:
1. Clone it into a temporary directory first. Read README.md, SECURITY.md, install.sh, verify.sh, manifest/*.json, and scripts/restore.sh in full.
2. Verify the repository owner and current Git commit, plus the exact versions, integrity values, and linked GitHub sources of all 15 npm packages. Stop if the code and documentation disagree.
3. Inspect my existing ~/.pi/agent/settings.json, but never read or print auth.json, cookies, API keys, session contents, or any other credentials.
4. Explain what will be preserved, added, and replaced, then ask for my confirmation before making changes.
5. After confirmation, run ./install.sh. Do not use curl|bash and do not add --yes; keep all interactive approvals.
6. Run ./verify.sh afterwards. Report every result, the backup path, and any npm audit findings. Never run npm audit fix just to make the check pass.
7. Do not change my default model, provider, theme, or existing login state. When finished, remind me to run /reload or restart Pi.
```

A standalone copy is available in [`PROMPT.md`](PROMPT.md).

## Manual quick start

### 1. Requirements

- macOS or Linux
- [Pi](https://github.com/earendil-works/pi) `>= 0.83.0`
- [Node.js](https://github.com/nodejs/node) `>= 22`
- `git`, `python3`, `npm`, and `tar`
- [uv](https://github.com/astral-sh/uv) for Python language servers; on macOS it can be installed with Homebrew

### 2. Clone, review, and install

```bash
gh repo clone weixijia/awesome-pi-setup
cd awesome-pi-setup
less install.sh
./install.sh
```

Optional flags:

```bash
./install.sh --magic-model 'anthropic/claude-sonnet-4-5'
./install.sh --skip-lsp
./install.sh --skip-skills
```

Use `--yes` only in automation after reviewing and pinning the repository commit. It is not recommended for a first installation.

### 3. Reload Pi

Run this in an existing Pi session:

```text
/reload
```

Alternatively, exit and restart Pi.

For a transparent command-by-command walkthrough, see [`docs/MANUAL_INSTALL.md`](docs/MANUAL_INSTALL.md).

## Included Pi packages

Every package is pinned to an exact version. Each link points to the maintainer's GitHub source.

| Package | Version | Purpose | GitHub |
|---|---:|---|---|
| `@gotgenes/pi-subagents` | 19.2.1 | Foreground/background subagents, resume, and steering | [gotgenes/pi-packages](https://github.com/gotgenes/pi-packages/tree/main/packages/pi-subagents) |
| `pi-web-access` | 0.17.1 | Search, webpage/PDF/video/GitHub extraction, and source checks | [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) |
| `@juicesharp/rpiv-todo` | 2.3.1 | Session-backed todo management | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-todo) |
| `@juicesharp/rpiv-ask-user-question` | 2.3.1 | Structured clarification questions | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-ask-user-question) |
| `@narumitw/pi-plan-mode` | 0.44.0 | Planning workflow with a restricted tool set | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-plan-mode) |
| `@mrclrchtr/supi-claude-md` | 4.4.0 | Skills for maintaining AGENTS.md and CLAUDE.md | [mrclrchtr/supi](https://github.com/mrclrchtr/supi/tree/main/packages/supi-claude-md) |
| `pi-cache-optimizer` | 2.6.25 | Prompt/KV cache optimization and diagnostics | [jiangge/pi-cache-optimizer](https://github.com/jiangge/pi-cache-optimizer) |
| `@narumitw/pi-statusline` | 0.43.0 | Model, Git, context, activity, and usage status line | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-statusline) |
| `@benvargas/pi-openai-fast` | 1.0.5 | Optional OpenAI Priority Tier toggle; disabled by default | [ben-vargas/pi-packages](https://github.com/ben-vargas/pi-packages/tree/main/packages/pi-openai-fast) |
| `@narumitw/pi-usage` | 0.43.0 | Codex, Copilot, and OpenRouter usage display | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-usage) |
| `@cortexkit/pi-magic-context` | 0.33.0 | Cross-session memory and semantic context | [cortexkit/magic-context](https://github.com/cortexkit/magic-context/tree/master/packages/pi-plugin) |
| `pi-goal-list-loop-audit` | 0.34.20 | Audited Goal/List/Loop workflows | [DraconDev/pi-goal-list-loop-audit](https://github.com/DraconDev/pi-goal-list-loop-audit) |
| `@narumitw/pi-lsp` | 0.44.0 | LSP diagnostics, definitions, references, and fixes | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-lsp) |
| `@narumitw/pi-worktree` | 0.43.0 | Safe interactive Git worktree management | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-worktree) |

Configuration requirements, commands, and caveats are documented in [`docs/PLUGINS.md`](docs/PLUGINS.md). Exact npm integrity values and machine-readable source links are in [`manifest/packages.json`](manifest/packages.json).

## LSP toolchain

| Tool | Pinned version | GitHub |
|---|---:|---|
| Biome | 2.5.6 | [biomejs/biome](https://github.com/biomejs/biome) |
| Bash Language Server | 5.6.0 | [bash-lsp/bash-language-server](https://github.com/bash-lsp/bash-language-server) |
| YAML Language Server | 1.24.0 | [redhat-developer/yaml-language-server](https://github.com/redhat-developer/yaml-language-server) |
| Ruff | 0.16.1 | [astral-sh/ruff](https://github.com/astral-sh/ruff) |
| ty | 0.0.65 | [astral-sh/ty](https://github.com/astral-sh/ty) |
| clangd (optional system tool) | Provided by Xcode/LLVM | [llvm/llvm-project](https://github.com/llvm/llvm-project) |
| SourceKit-LSP (optional on macOS) | Provided by Xcode | [swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp) |

The Pi LSP extension uses its built-in server catalog. This setup deliberately does not create a global configuration that would replace that catalog.

## Curated Skills

The installer fetches five Skills from a pinned commit of [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions):

```text
ceaabed6c40ee98ba1b61e264fe1ecf527538770
```

Installed Skills:

- `applying-tdd`
- `reviewing-code`
- `writing-git-commits`
- `hardening-code-paths`
- `designing-user-experiences`

Pinning the commit prevents a future installation from silently executing the latest upstream prompt. Review the upstream diff before changing the pin.

## Hardened defaults

The installer merges these keys into `settings.json`; it does not replace model, provider, theme, or unrelated package settings:

```json
{
  "enableInstallTelemetry": false,
  "enableSkillCommands": true
}
```

`defaultProjectTrust` is intentionally left alone: it is a per-user decision, and
the installer must not silently reset it on every run.

It also applies the following defaults:

- subagent concurrency of `2`, with `30` default turns
- GLLA automatic draft acceptance, automatic resume, and aggressive mode disabled
- unknown shell commands require confirmation
- `.env`, key/certificate, credential, and external-directory paths require confirmation
- `rm -rf /` is explicitly denied
- browser-cookie access for Gemini Web is disabled
- OpenAI Fast is installed but disabled
- Magic Context Sidekick is disabled to avoid a duplicate background agent
- Magic Context Todo is disabled to avoid duplicating `rpiv-todo`
- Plan Mode receives web-research and read-only LSP tools only

The Permission System is not an operating-system sandbox. Use a container or VM for untrusted repositories.

## Useful commands

```text
/lsp
/worktree
/plan
/usage
/code-review
/commit
/doctor
/skill:applying-tdd
/skill:reviewing-code
/skill:writing-git-commits
/skill:hardening-code-paths
/skill:designing-user-experiences
```

## Verification

```bash
./verify.sh
```

The verifier checks:

- all 15 exact package versions and the removed-package list
- installed package-owned files against independently hashed tarballs
- JSON/JSONC configuration
- the pinned Skill commit
- language-server CLI versions
- unreviewed npm lifecycle scripts and version-scoped approvals
- Pi RPC startup, extension errors, timeouts, and slash-command collisions
- `npm audit` findings in report-only mode

A full model request requires your own provider login, so the public verifier does not send LLM requests.

## Backup and recovery

Each installation creates:

```text
~/.pi/backups/awesome-pi-setup-YYYYMMDD-HHMMSS/
```

Credentials, custom model files, and sessions are excluded. On failure, the installer automatically restores Pi configuration. Downloaded but unreferenced package files may remain inactive, and global LSP CLI versions already changed may remain. Replacing a user's previous global tools cannot be rolled back safely without a separate package-manager snapshot.

To restore manually:

```bash
./scripts/restore.sh ~/.pi/backups/awesome-pi-setup-YYYYMMDD-HHMMSS
```

The restore script accepts only the documented configuration and Skill allowlist. It rejects credentials, sessions, symlinks, special files, and unexpected backup entries.

## Deliberately not installed

- **Provider credentials** - configure them yourself with Pi's `/login`
- **MCP** - do not add its attack surface without a concrete server
- **WebDAV sync** - it can copy credentials, sessions, or executable extensions
- **Browser automation** - enable it per project with a dedicated low-privilege profile
- **A second memory, todo, planner, or subagent system** - avoid overlapping behavior and event conflicts
- **A fake "sandbox" label** - permission prompts do not replace a container or VM

## Known risks

- At the snapshot date, Magic Context's local-embedding dependency chain may produce High-severity `npm audit` findings. Do not run `npm audit fix` blindly; first verify that upstream has released a compatible fix.
- Enabling `pi-openai-fast` requests OpenAI Priority Tier and may affect billing. It is disabled by default.
- GLLA's 4,000,000-token value is a stopping limit, not a budget guarantee. Lower it in `/glla` to match your account.
- Plan Mode's restricted Bash and the Permission System are not kernel-level isolation.
- `supi-claude-md` is currently Beta; use its instruction-file maintenance Skills only in trusted repositories.

See [`SECURITY.md`](SECURITY.md) for the full threat model and supply-chain notes.

## Updating this setup

Do not schedule an unattended job that upgrades every plugin to the latest version. Instead:

1. Open an issue or pull request updating `manifest/*.json`.
2. Read upstream changelogs and source diffs.
3. Update exact versions, integrity values, and reviewed lifecycle-script versions.
4. Test installation with an isolated `PI_CODING_AGENT_DIR`.
5. Run `./verify.sh`.
6. Merge only after manual review.

## License

[MIT](LICENSE). Third-party plugins and Skills remain subject to their own licenses.
