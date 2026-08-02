# Copy this prompt into Pi

```text
请为我安装并验证公开仓库 https://github.com/weixijia/awesome-pi-setup 。

要求：
1. 先克隆到临时目录，完整阅读 README.md、SECURITY.md、install.sh、verify.sh、manifest/*.json 和 scripts/restore.sh。
2. 核对仓库 owner、当前 Git commit、15 个 npm 包的精确版本、integrity 和对应 GitHub 源码地址；发现内容与文档不一致就停止。
3. 检查我现有的 ~/.pi/agent/settings.json，但绝对不要读取或输出 auth.json、Cookie、API Key、会话内容或其他凭据。
4. 告诉我会保留、增加和替换什么，并在执行前向我确认。
5. 确认后运行 ./install.sh；不要使用 curl|bash，不要加 --yes，保留交互式审批。
6. 安装后运行 ./verify.sh，报告每项结果、备份目录和任何 npm audit 风险；不得为了通过检查而执行 npm audit fix。
7. 不要改变我的默认模型、Provider、主题或现有登录状态。完成后提醒我 /reload 或重启 Pi。
```

## Why this prompt is intentionally not shorter

A one-line `curl | bash` command asks users to execute mutable remote code without
review. This prompt makes Pi inspect exact package pins, source links, integrity,
backup behavior, and credential boundaries before asking for approval.
