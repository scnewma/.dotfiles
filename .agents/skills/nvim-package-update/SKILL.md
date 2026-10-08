---
name: nvim-package-update
description: Use Lazy to update nvim packages, fix breaking changes, and simplify configuration due to upstream changes. Always use when asked about updating nvim packages.
---

Use `:Lazy sync` to update packages. The diff of `nvim/.config/nvim/lazy-lock.json` will show the commit changes for each package. View the diff for each to determine what has changed.

If any changes are breaking, confirm with the local `nvim/` configuration if the breaking changes affect usage. If it affects local usage and it's a mechanical change that isn't a preference, update it. If it will affect the user's preference, then ask them for how they want it fixed.

Summarize breaking changes and new features for the user for each package. Only include substatial features, not minor bug fixes.
