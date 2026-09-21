# Personal Global Rules

## Communication

- Be brief.
- Keep it casual
- Don't use `--`.

## Tooling

- `mise` is available. If you are missing a tool, you can use `mise` to execute it.
- prefer `bun` over `node`

## Code Style

- Use automatic formatters
- Composition over inheritance
- Strike a balance between pure functions and structs/classes — don't over-abstract, but don't write spaghetti either
- Default to no comments. Before keeping one, delete it and re-read the code: keep it only if a competent reader would then reach a *wrong* conclusion. "Useful context" is not the bar.
- Never comment a constant, a type field, or a config key. Never explain why code is unconditional, or why a value is fixed rather than configurable — that's design rationale, and it belongs in the PR or ticket.
- Two lines maximum. Over that, delete it rather than trim it.

## Workflow

### After Making Changes
- Run the relevant linter
- Run tests if they exist
- If there are failures in code you wrote, fix them automatically and re-run until clean

### Explanations
- Default to a brief synopsis, highlighting the most important parts
- In docs you write: runbooks and reference docs say what to do, never why
- I'll ask for a detailed walkthrough if I need one

### Commits
- Freeform commit messages — no conventional commits
- Keep messages short and descriptive
- Always include a commit attribution in any commits/PRs you write. Run $HOME/.dotfiles/llm-commit-attribution.sh to get the correct value.
- When creating branches, prefix them with `sn-` (i.e. `sn-<branch-name>`).

## Agent Behavior

### Asking Questions
- **Do ask** about product decisions, logic, or design tradeoffs. Ask before committing code
- **Don't ask** about trivial choices (variable names, import ordering, minor style)

### File Operations
- Act with agency — create files when the task requires it
- Never create unnecessary "nice to have" files
- Never create a docs file unless I asked for one. A plan you wrote yourself is not a request from me.
- Never commit plan, scratch, or report files

### Prohibited Actions
- Never run `sudo` commands
- Never read, write, or commit `.env` files
- Never commit secrets, credentials, or API keys
