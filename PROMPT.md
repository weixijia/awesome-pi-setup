# Copy this prompt into Pi

```text
Please install and verify the public repository https://github.com/weixijia/awesome-pi-setup for me.

Requirements:
1. Clone it into a temporary directory first. Read README.md, SECURITY.md, install.sh, verify.sh, manifest/*.json, and scripts/restore.sh in full.
2. Verify the repository owner and current Git commit, plus the exact versions, integrity values, and linked GitHub sources of all 15 npm packages. Stop if the code and documentation disagree.
3. Inspect my existing ~/.pi/agent/settings.json, but never read or print auth.json, cookies, API keys, session contents, or any other credentials.
4. Explain what will be preserved, added, and replaced, then ask for my confirmation before making changes.
5. After confirmation, run ./install.sh. Do not use curl|bash and do not add --yes; keep all interactive approvals.
6. Run ./verify.sh afterwards. Report every result, the backup path, and any npm audit findings. Never run npm audit fix just to make the check pass.
7. Do not change my default model, provider, theme, or existing login state. When finished, remind me to run /reload or restart Pi.
```

## Why this prompt is intentionally not shorter

A one-line `curl | bash` command asks users to execute mutable remote code without
review. This prompt makes Pi inspect exact package pins, source links, integrity,
backup behavior, and credential boundaries before asking for approval.
