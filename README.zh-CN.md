# Awesome Pi Setup

[English](README.md) | [Français](README.fr.md) | **简体中文**

一套经过真实环境验证、兼顾安全性与工程效率的 [Pi Coding Agent](https://github.com/earendil-works/pi) 全局配置。

这不是“插件越多越好”的大杂烩，而是一套边界清晰、各司其职的配置：

- **安全防护**：访问敏感路径、项目外目录或执行危险 Shell 操作时，需要确认或直接拒绝
- **代码智能**：提供 LSP 诊断、定义跳转、引用查找、符号检索和自动修复
- **长任务工作流**：支持规划、Todo、子代理，以及带独立审计的 Goal/List/Loop
- **联网研究**：支持搜索、网页/PDF/GitHub/视频内容提取和来源核查
- **长期上下文**：支持跨会话记忆、语义检索和持久化项目知识
- **可恢复安装**：安装前创建私有备份，并通过严格白名单恢复
- **供应链可审计**：固定精确版本，校验安装包完整性，并逐文件核对实际安装内容

> 当前快照：**2026-08-02**；最低要求：Pi **0.83.0**、Node.js **22**。

## 安装前请先阅读

Pi 扩展会以当前用户权限运行，因此能够读写文件、执行命令和访问网络。安装前至少应检查：

```bash
less install.sh
less SECURITY.md
cat manifest/packages.json
```

本项目有意**不提供** `curl ... | bash` 安装命令。安装器不会读取、上传、删除或修改：

- `~/.pi/agent/auth.json`
- 自定义 Provider 或 `models.json`
- 默认模型、默认 Provider、Thinking Level 或主题
- 历史会话或 Magic Context 数据库

## 复制给 Pi，一键完成配置

把下面整段复制到 Pi。Pi 会先审计仓库，再询问你是否安装：

```text
请为我安装并验证公开仓库 https://github.com/weixijia/awesome-pi-setup 。

要求：
1. 先克隆到临时目录，完整阅读 README.md、SECURITY.md、install.sh、verify.sh、manifest/*.json 和 scripts/restore.sh。
2. 核对仓库所有者、当前 Git commit，以及 15 个 npm 包的精确版本、integrity 和对应 GitHub 源码地址；代码与文档不一致时立即停止。
3. 检查我现有的 ~/.pi/agent/settings.json，但绝对不要读取或输出 auth.json、Cookie、API Key、会话内容或其他凭据。
4. 先说明哪些内容会保留、增加或替换，并在执行前征得我的确认。
5. 确认后运行 ./install.sh；不要使用 curl|bash，也不要加 --yes，保留所有交互式审批。
6. 安装后运行 ./verify.sh，逐项报告结果、备份目录和 npm audit 风险；不得为了通过检查而执行 npm audit fix。
7. 不要改变我的默认模型、Provider、主题或现有登录状态。完成后提醒我运行 /reload 或重启 Pi。
```

单独的可复制版本见 [`PROMPT.md`](PROMPT.md)。

## 手动快速安装

### 1. 环境要求

- macOS 或 Linux
- [Pi](https://github.com/earendil-works/pi) `>= 0.83.0`
- [Node.js](https://github.com/nodejs/node) `>= 22`
- `git`、`python3`、`npm` 和 `tar`
- Python 语言服务器需要 [uv](https://github.com/astral-sh/uv)；macOS 可通过 Homebrew 安装

### 2. 克隆、审阅并安装

```bash
gh repo clone weixijia/awesome-pi-setup
cd awesome-pi-setup
less install.sh
./install.sh
```

可选参数：

```bash
./install.sh --magic-model 'anthropic/claude-sonnet-4-5'
./install.sh --skip-lsp
./install.sh --skip-skills
```

`--yes` 只适合已经审阅并固定仓库 commit 的自动化环境，首次安装不建议使用。

### 3. 重新加载 Pi

在当前 Pi 会话中运行：

```text
/reload
```

也可以退出后重新启动 Pi。

如需逐条手动执行，请参阅 [`docs/MANUAL_INSTALL.md`](docs/MANUAL_INSTALL.md)。

## Pi 插件清单

所有插件均固定到精确版本；链接直接指向维护者的 GitHub 源码。

| 插件 | 版本 | 用途 | GitHub |
|---|---:|---|---|
| `@gotgenes/pi-subagents` | 19.2.1 | 前台/后台子代理、恢复和 Steering | [gotgenes/pi-packages](https://github.com/gotgenes/pi-packages/tree/main/packages/pi-subagents) |
| `pi-web-access` | 0.17.1 | 搜索、网页/PDF/视频/GitHub 提取和来源核查 | [nicobailon/pi-web-access](https://github.com/nicobailon/pi-web-access) |
| `@juicesharp/rpiv-todo` | 2.3.1 | 基于会话持久化的 Todo | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-todo) |
| `@juicesharp/rpiv-ask-user-question` | 2.3.1 | 结构化澄清问题 | [juicesharp/rpiv-mono](https://github.com/juicesharp/rpiv-mono/tree/main/packages/rpiv-ask-user-question) |
| `@narumitw/pi-plan-mode` | 0.44.0 | 使用受限工具集的规划模式 | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-plan-mode) |
| `@mrclrchtr/supi-claude-md` | 4.4.0 | 维护 AGENTS.md/CLAUDE.md 的 Skills | [mrclrchtr/supi](https://github.com/mrclrchtr/supi/tree/main/packages/supi-claude-md) |
| `pi-cache-optimizer` | 2.6.25 | Prompt/KV Cache 优化和诊断 | [jiangge/pi-cache-optimizer](https://github.com/jiangge/pi-cache-optimizer) |
| `@narumitw/pi-statusline` | 0.43.0 | 显示模型、Git、上下文、活动和用量 | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-statusline) |
| `@benvargas/pi-openai-fast` | 1.0.5 | 可选 OpenAI Priority Tier；默认关闭 | [ben-vargas/pi-packages](https://github.com/ben-vargas/pi-packages/tree/main/packages/pi-openai-fast) |
| `@narumitw/pi-usage` | 0.43.0 | 查询 Codex、Copilot 和 OpenRouter 用量 | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-usage) |
| `@cortexkit/pi-magic-context` | 0.33.0 | 跨会话记忆和语义上下文 | [cortexkit/magic-context](https://github.com/cortexkit/magic-context/tree/master/packages/pi-plugin) |
| `pi-goal-list-loop-audit` | 0.34.20 | 带独立审计的 Goal/List/Loop | [DraconDev/pi-goal-list-loop-audit](https://github.com/DraconDev/pi-goal-list-loop-audit) |
| `@narumitw/pi-lsp` | 0.44.0 | LSP 诊断、定义、引用和修复 | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-lsp) |
| `@narumitw/pi-worktree` | 0.43.0 | 安全管理 Git Worktree | [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions/tree/main/extensions/pi-worktree) |

各插件的配置要求、命令和注意事项见 [`docs/PLUGINS.md`](docs/PLUGINS.md)。npm integrity 和机器可读的源码地址见 [`manifest/packages.json`](manifest/packages.json)。

## LSP 工具链

| 工具 | 固定版本 | GitHub |
|---|---:|---|
| Biome | 2.5.6 | [biomejs/biome](https://github.com/biomejs/biome) |
| Bash Language Server | 5.6.0 | [bash-lsp/bash-language-server](https://github.com/bash-lsp/bash-language-server) |
| YAML Language Server | 1.24.0 | [redhat-developer/yaml-language-server](https://github.com/redhat-developer/yaml-language-server) |
| Ruff | 0.16.1 | [astral-sh/ruff](https://github.com/astral-sh/ruff) |
| ty | 0.0.65 | [astral-sh/ty](https://github.com/astral-sh/ty) |
| clangd（可选系统工具） | 由 Xcode/LLVM 提供 | [llvm/llvm-project](https://github.com/llvm/llvm-project) |
| SourceKit-LSP（macOS 可选） | 由 Xcode 提供 | [swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp) |

Pi LSP 默认使用插件自带的 Server Catalog。本项目不会写入一个全局配置去替换它。

## 精选 Skills

安装器会从 [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions) 的固定 commit 获取 5 个 Skills：

```text
ceaabed6c40ee98ba1b61e264fe1ecf527538770
```

安装内容：

- `applying-tdd`
- `reviewing-code`
- `writing-git-commits`
- `hardening-code-paths`
- `designing-user-experiences`

固定 commit 可以避免未来安装时静默执行上游最新 Prompt。更新 commit 前应先审查差异。

## 加固后的默认配置

安装器只会把以下字段合并进 `settings.json`，不会覆盖模型、Provider、主题或无关插件：

```json
{
  "enableInstallTelemetry": false,
  "enableSkillCommands": true
}
```

`defaultProjectTrust` 刻意不做处理：这是用户的个人选择，安装器不应在每次运行时静默重置它。

同时应用：

- 子代理并发数为 `2`，默认最多 `30` turns
- 关闭 GLLA 的自动接受草稿、自动恢复和激进模式
- 未知 Shell 命令默认询问
- 访问 `.env`、密钥/证书、凭据相关路径和项目外目录时默认询问
- 明确禁止 `rm -rf /`
- 关闭 Gemini Web 的浏览器 Cookie 读取
- 安装 OpenAI Fast，但默认关闭
- 关闭 Magic Context Sidekick，避免出现第二套后台代理
- 关闭 Magic Context Todo，避免与 `rpiv-todo` 重复
- Plan Mode 只增加联网研究和只读 LSP 工具

Permission System 不是操作系统级 Sandbox。处理不可信仓库时仍应使用容器或虚拟机。

## 常用命令

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

## 验证

```bash
./verify.sh
```

验证器会检查：

- 15 个插件的精确版本和待移除插件清单
- 实际安装的插件文件是否与独立校验过的 tarball 一致
- JSON/JSONC 配置
- Skills 的固定 commit
- LSP CLI 版本
- 是否存在未审查的 npm lifecycle scripts，以及审批是否精确到版本
- Pi RPC 启动、扩展错误、超时和 Slash Command 冲突
- `npm audit` 风险（只报告，不自动修复）

完整模型请求需要你自己的 Provider 登录，因此公共验证器不会发送 LLM 请求。

## 备份与恢复

每次安装都会创建：

```text
~/.pi/backups/awesome-pi-setup-YYYYMMDD-HHMMSS/
```

凭据、自定义模型文件和会话不会进入备份。安装失败时会自动恢复 Pi 配置；已经下载但未引用的包文件可能保留，但不会被 Pi 加载；已经更新的全局 LSP CLI 版本也可能保留，因为在没有独立包管理器快照的情况下，无法安全恢复用户原先的全局工具版本。

手动恢复：

```bash
./scripts/restore.sh ~/.pi/backups/awesome-pi-setup-YYYYMMDD-HHMMSS
```

恢复脚本只接受文档列出的配置和 Skill 白名单，并拒绝凭据、会话、软链接、特殊文件或其他意外条目。

## 有意不安装的内容

- **Provider 凭据**：请自行通过 Pi 的 `/login` 配置
- **MCP**：没有明确的 Server 时，不额外增加攻击面
- **WebDAV 同步**：它可能复制凭据、会话或可执行扩展
- **浏览器自动化**：应按项目启用，并使用独立的低权限 Profile
- **第二套 Memory/Todo/Plan/Subagent**：避免功能重叠和事件冲突
- **名不副实的“Sandbox”**：权限确认无法替代容器或虚拟机

## 已知风险

- 截至当前快照，Magic Context 的本地 Embedding 依赖链可能让 `npm audit` 报告 High 级别问题。不要盲目执行 `npm audit fix`，应先确认上游是否发布了兼容修复。
- 启用 `pi-openai-fast` 后会请求 OpenAI Priority Tier，可能影响计费；本配置默认关闭。
- GLLA 的 4,000,000 Token 是停止上限，不是预算承诺。请在 `/glla` 中按账户额度调低。
- Plan Mode 的受限 Bash 和 Permission System 都不是内核级隔离。
- `supi-claude-md` 目前仍是 Beta；只应在可信仓库中使用其指令文件维护 Skills。

完整威胁模型和供应链说明见 [`SECURITY.md`](SECURITY.md)。

## 如何更新这套配置

不要设置无人值守的定时任务，把所有插件自动升级到最新版。建议按以下流程更新：

1. 通过 Issue 或 Pull Request 修改 `manifest/*.json`。
2. 阅读上游 Changelog 和源码差异。
3. 更新精确版本、integrity 和已审查 lifecycle script 版本。
4. 在隔离的 `PI_CODING_AGENT_DIR` 中测试安装。
5. 运行 `./verify.sh`。
6. 人工确认后再合并。

## 许可证

本项目使用 [MIT](LICENSE) 许可证。第三方插件和 Skills 仍受各自仓库许可证约束。
