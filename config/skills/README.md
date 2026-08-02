# Skills

The repository does not vendor third-party Skill content. `install.sh` fetches
only the five names listed in `manifest/toolchain.json` from the recorded commit
of [narumiruna/pi-extensions](https://github.com/narumiruna/pi-extensions).

This preserves upstream attribution and makes prompt changes explicit during a
future commit-pin update.
