# Plugin Guide

This document explains why each package is present. Package versions, npm
integrity values, and machine-readable source links live in
[`manifest/packages.json`](../manifest/packages.json).

## 1. Subagents

### [`@gotgenes/pi-subagents`](https://github.com/gotgenes/pi-packages/tree/main/packages/pi-subagents)

Provides foreground/background subagents, custom agent types, steering, status,
and resume. This setup limits concurrency to two and default runs to 30 turns in
`~/.pi/agent/subagents.json`.

Key tools: `subagent`, `get_subagent_result`, `steer_subagent`.

Security: subagents do not automatically receive worktree or process isolation.
The companion Permission System supplies the policy gate; prompts alone are not
a security boundary.

## 2. Research

### [`pi-web-access`](https://github.com/nicobailon/pi-web-access)

Adds `web_search`, `fetch_content`, `source_check`, and bounded retrieval. It can
extract pages, PDFs, GitHub repositories, YouTube transcripts, and video frames.

This setup writes `~/.pi/web-search.json` with browser-cookie access disabled.
Search-provider keys remain user-managed. `ffmpeg` and `yt-dlp` are optional for
precise video frames and are not silently installed by this repository.

Security: do not bind the optional curator to `0.0.0.0` unless you understand its
network exposure. Use a separate low-privilege browser profile if you later turn
cookie access on.

## 3. Structured workflow

### [`@juicesharp/rpiv-todo`](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-todo)

Adds the `todo` tool and interactive task overlay. State is reconstructed from
the current Pi session and is isolated per session.

### [`@juicesharp/rpiv-ask-user-question`](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-ask-user-question)

Adds `ask_user_question` for structured, consequential choices. The tool is
removed automatically in non-interactive runs, where no user can answer.

### [`@narumitw/pi-plan-mode`](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-plan-mode)

Adds `/plan` and a planning workflow with a restricted tool set. The included
configuration adds web research and read-only LSP inspection.

Security: restricted Bash is fail-closed but not an OS sandbox. Builds and tests
can still execute repository hooks or generate files.

### [`pi-goal-list-loop-audit`](https://github.com/DraconDev/pi-goal-list-loop-audit)

Adds `/goal`, `/list`, `/loop`, `/glla`, and independent auditing. The setup turns
off automatic draft acceptance, automatic resume, and aggressive mode; it also
sets a finite token limit and audit cap.

Security: do not combine it with another `agent_end` autonomous loop driver. Its
configured token limit is a stop condition, not a spending guarantee.

## 4. Context and prompt quality

### [`@cortexkit/pi-magic-context`](https://github.com/cortexkit/magic-context/tree/master/packages/pi-plugin)

Adds cross-session context, semantic search, durable memory, compaction history,
and optional background components. This setup uses local MiniLM embeddings,
disables Sidekick, and disables Magic Context's Todo so those functions do not
duplicate Subagents and `rpiv-todo`.

Key tools: `ctx_search`, `ctx_memory`, `ctx_note`, `ctx_expand`, `ctx_reduce`.

Configuration: `~/.config/cortexkit/magic-context.jsonc`. The default historian
and dreamer model is `openai/gpt-5.4-mini`; pass `--magic-model` to the installer
if your authenticated provider uses another model.

Security: its SQLite database can contain prompts, code, command output, and
accidentally pasted secrets. Protect the local disk and do not upload the
database to an untrusted sync service.

### [`pi-cache-optimizer`](https://github.com/jiangge/pi-cache-optimizer)

Improves prompt-cache affinity and exposes cache diagnostics. Use
`/cache-optimizer doctor` and preview any proposed model-configuration changes.
Only its explicit, confirmed fix flow edits `models.json`.

Security: caching behavior is provider-specific and best effort. Proxies may
reject cache parameters or omit usage details.

### [`@mrclrchtr/supi-claude-md`](https://github.com/mrclrchtr/supi/tree/main/packages/supi-claude-md)

Provides Skills for reviewing and improving `AGENTS.md`/`CLAUDE.md` instruction
files. This is a Beta package and does not itself inject directory instructions
or register tools.

Security: project instruction files are executable guidance for the model. Only
trust and revise them in repositories whose authors you trust.

## 5. Code intelligence and Git isolation

### [`@narumitw/pi-lsp`](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-lsp)

Adds diagnostics, definitions, references, symbols, hover, and source fixes. It
uses a built-in language-server catalog when no custom `pi-lsp.json` is present.
This setup installs pinned Biome, Bash, YAML, Ruff, and ty executables while
leaving the built-in catalog intact.

Key command/tool: `/lsp`, `lsp_diagnostics`, `lsp_fix`.

Security: language servers run as local processes with Pi's environment. A clean
LSP report does not replace project tests, linters, or compiler checks.

### [`@narumitw/pi-worktree`](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-worktree)

Adds `/worktree` for interactive Git worktree creation, switching, pruning, and
safe removal. It refuses unsafe removal conditions and does not force-delete
branches.

Security: Worktrees isolate files and branches, not processes, credentials, or
network access. The command is intentionally unavailable in headless modes.

## 6. Interface and account visibility

### [`pi-compact-transcript`](https://github.com/avhagedorn/pi-compact-transcript)

Collapses thinking summaries and renders tool calls as one-line previews. Pi's
native transcript gives every tool call its own block (command, output, timing),
which gets noisy in long agentic runs.

Pi already truncates long output on its own and `ctrl+o` (`app.tools.expand`)
toggles collapse at runtime, but there is no persistent setting for the default
state — that gap is what this extension fills.

Chosen over [`pi-tool-display`](https://github.com/MasuRii/pi-tool-display),
which targets the same problem but whose peer range still stops at
`pi-coding-agent ^0.80.0`; this profile tracks 0.83.x.

Pairs well with two personal display settings the installer deliberately does
not manage: `"hideThinkingBlock": true` and `"outputPad": 0`.

### [`@narumitw/pi-statusline`](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-statusline)

Provides a responsive footer showing model, Git, context, activity, and usage.
Do not install another extension that replaces Pi's footer.

### [`@narumitw/pi-usage`](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-usage)

Adds `/usage` for supported Codex, Copilot, and OpenRouter authentication. It
fails closed for custom origins so matching credentials are not sent to official
endpoints unexpectedly.

### [`@benvargas/pi-openai-fast`](https://github.com/ben-vargas/pi-packages/tree/main/packages/pi-openai-fast)

Adds `/fast` and optional OpenAI Priority Tier requests for explicitly supported
models. It is installed but **disabled by default** because enabling priority can
change billing and quota behavior.

## Why four packages are removed

The installer removes these package identities from Pi settings if present:

- `pi-webdav-sync`: unused remote sync can copy credentials, sessions, or
  executable extensions and has no default client-side encryption boundary.
- `pi-mcp-adapter`: useful only when a concrete MCP server is configured; an idle
  adapter adds supply-chain surface without capability.
- `pi-tool-display`: its deep renderer override lagged the target Pi version and
  overlapped native/extension rendering.
- `@gotgenes/pi-permission-system`: in-process allow/ask/deny gating is not a
  security boundary (Pi has no sandbox), while it adds a confirmation prompt to
  every non-allowlisted tool call. Session files already record every command
  for after-the-fact audit. Install it yourself if you want the policy layer.

They are not universally bad packages. The default profile omits them because a
capability should have a current, explicit use case.
