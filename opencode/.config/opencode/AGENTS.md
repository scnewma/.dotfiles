# Personal Global Rules

## Languages & Tooling

- **Python** for small tasks and scripts
- **Go** for larger programs and CLI tools

## Code Style

- Use automatic formatters
- Composition over inheritance
- Strike a balance between pure functions and structs/classes — don't over-abstract, but don't write spaghetti either
- Only add comments when they explain something non-obvious. Never add comments that repeat what the code does.

## Workflow

### After Making Changes
- Run the relevant linter
- Run tests if they exist
- If there are failures in code you wrote, fix them automatically and re-run until clean

### Explanations
- Default to a brief synopsis, highlighting the most important parts
- I'll ask for a detailed walkthrough if I need one

### Commits
- Freeform commit messages — no conventional commits
- Keep messages short and descriptive

## Agent Behavior

### Asking Questions
- **Do ask** about product decisions, logic, or design tradeoffs
- **Don't ask** about trivial choices (variable names, import ordering, minor style)

### File Operations
- Act with agency — create files when the task requires it
- Never modify files outside the current working directory
- Never create unnecessary "nice to have" files

### Prohibited Actions
- Never run `sudo` commands
- Never read, write, or commit `.env` files
- Never commit secrets, credentials, or API keys

## Communication

- Keep it casual
- Be direct, skip the fluff
- When in doubt, ask
