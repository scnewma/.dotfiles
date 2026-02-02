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

## Memory System

### Semantic Memory
Read `~/.claude/memory/MEMORY.md` at the start of every session. Silent — do not announce it.

### Episodic Memory
Read today's episodic log at `~/.claude/memory/episodic/YYYY-MM-DD.md` at session start (if it exists). Load relevant past episode files when the user references prior work ("earlier", "last time", "remember when", "we did X before").

### Writing Memories
At the end of sessions with meaningful work:
- Append an entry to today's episodic file (create if needed). Announce: "Logged to episodic memory."
- Update `~/.claude/memory/MEMORY.md` if stable preferences changed. Announce: "Updated MEMORY.md."
- For multi-step tasks with significant decisions, offer to write `.claude/memories/<task-slug>.md` in the project. Write only if agreed.

Only add memories for things not already covered in `~/.claude/CLAUDE.md` or `~/.claude/skills/`. Do not duplicate rules or preferences that live there.

Do not announce memory reads.
