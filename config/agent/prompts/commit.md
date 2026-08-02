---
description: Validate and commit the current coherent change
argument-hint: "[commit instructions]"
---
Prepare and create a Git commit for the current coherent change. ${ARGUMENTS:-Use the repository's existing conventions.}

Inspect status, diffs, and recent commit-message style. Exclude secrets, generated files, and unrelated changes. Run the most relevant practical checks. Stage only intended files, create one concise commit, then report the commit hash, message, checks run, and any remaining uncommitted changes.

Do not amend, push, or bypass failing checks unless explicitly requested.
