---
description: Review current changes for actionable defects
argument-hint: "[scope or instructions]"
---
Review ${ARGUMENTS:-the current working-tree and staged changes}.

Do not edit files. Inspect the relevant surrounding code and tests. Prioritize:
- correctness and regressions
- security and unsafe failure modes
- concurrency, state, and resource-lifecycle problems
- missing or inadequate tests

Report findings in severity order with file and line references. Avoid style-only comments unless they affect maintainability or correctness. If there are no findings, say so and note residual risks or untested areas.
