# Security Policy

## Threat model

Pi extensions execute inside the Pi process with the permissions of the current
user. They can read files, invoke programs, access the network, register tools,
and alter prompts. A permission dialog reduces accidental damage but is not an
OS sandbox and cannot defend against every malicious extension or compromised
user account.

Use this setup only after reviewing the exact commit you cloned. Use a container,
VM, or disposable account for untrusted repositories.

## Supply-chain controls in this repository

- Every Pi package uses an exact version in `manifest/packages.json`.
- Every npm tarball has its expected `dist.integrity` recorded. The installer
  downloads and hashes that tarball, then compares installed package files with
  the verified archive before approving lifecycle scripts.
- Every package entry links to its authoritative GitHub repository.
- Curated Skills are fetched from one pinned Git commit, not a moving branch.
- Known npm lifecycle-script packages must match reviewed versions before they
  are approved.
- The installer refuses to run as root.
- The project deliberately provides no `curl | bash` command.

These controls do not prove that an upstream package is harmless. They make the
installed artifact identifiable and changes reviewable.

## Credential boundaries

The installer does not read, copy, remove, print, or modify:

- `~/.pi/agent/auth.json`
- browser cookies or Keychain credentials
- Pi session files
- Magic Context's SQLite database
- custom `models.json`
- environment variables containing provider keys

Backups intentionally exclude credentials, custom model files, and sessions.
The restore script accepts only an explicit configuration/Skill allowlist and
rejects symlinks or unexpected files. Backups are stored with owner-only
directory permissions under `~/.pi/backups/`. A failed install automatically
restores Pi configuration; inactive downloaded package files and already changed
global LSP CLI versions may remain because replacing a user's prior global tools
cannot be rolled back safely without a separate package-manager snapshot.

Never paste API keys into Pi prompts, issues, logs, or Git commits. Authenticate
with Pi's `/login` flow or environment variables supported by the provider.

## Permission policy limitations

`@gotgenes/pi-permission-system` is configured to:

- ask for sensitive file paths and project-external directories;
- allow common read-only inspection and test commands;
- ask for unknown commands and destructive/system/network operations;
- deny the explicit `rm -rf /` pattern.

Limitations:

- permitted build or test commands can execute repository-controlled hooks;
- interpreters can hide behavior inside scripts;
- a compromised extension runs before or beside normal model behavior;
- user approval can still authorize a dangerous operation;
- this is not kernel-enforced filesystem or network isolation.

## Browser cookies

`pi-web-access` supports optional browser-cookie access. This setup explicitly
sets `allowBrowserCookies` to `false`. If you enable it, use a dedicated,
low-privilege browser profile without email, banking, cloud-console, or admin
sessions.

## Dependency audit findings

`verify.sh` runs `npm audit` as a report-only check. It never runs
`npm audit fix`. Automated fixes can introduce incompatible major versions or
break the local embedding runtime.

At the 2026-08-02 snapshot, the Magic Context local-embedding dependency chain
may report High-severity findings involving native/ML dependencies. Check the
current upstream advisories and compatible releases rather than suppressing the
finding or weakening tests.

## Reporting a vulnerability

Do not open a public issue containing a working exploit, credential, private
path, or session data. Use GitHub's private vulnerability reporting feature for
this repository when available. Include:

- affected commit and platform;
- the exact package and version;
- reproduction steps with synthetic data;
- impact and a suggested mitigation.

For vulnerabilities in third-party packages, also report them to the upstream
repository linked in `manifest/packages.json`.
