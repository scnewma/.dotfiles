# Personal Global Rules

## Communication

- Be brief.
- Keep it casual

## Tooling

- `nix` is available. If you are missing a tool, you can use `nix` to execute
it if it's from `nixpkgs`, do not execute random nix flakes automatically.
- prefer `bun` over `node`

## Code Style

- Use automatic formatters
- Composition over inheritance
- Strike a balance between pure functions and structs/classes — don't over-abstract, but don't write spaghetti either
- Default to no comment. Only add one when it explains *why* something exists (a constraint, a gotcha, a non-obvious tradeoff), never *what* the code is doing.
- Keep comments short — a line or two. Don't write paragraphs, restate the code, or narrate structure. Prefer deleting a comment over expanding it.

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
- **Do ask** about product decisions, logic, or design tradeoffs. Ask before committing code
- **Don't ask** about trivial choices (variable names, import ordering, minor style)

### File Operations
- Act with agency — create files when the task requires it
- Never create unnecessary "nice to have" files

### Prohibited Actions
- Never run `sudo` commands
- Never read, write, or commit `.env` files
- Never commit secrets, credentials, or API keys
