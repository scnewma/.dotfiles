---
name: setup-worktree
description: Create an isolated worktree with safety checks and a clean baseline.
disable-model-invocation: true
---

You are running the setup-worktree skill. This is a manual workflow for creating an isolated workspace.

If the skill was invoked with arguments, treat them as the feature or branch name if applicable.

# Goal

Create an isolated git worktree with the right directory, safety checks, project setup, and a verified clean baseline.

## Directory Selection Order

Choose the location in this order:

1. `.worktrees/` if it exists
2. `worktrees/` if it exists
3. a preference documented in `CLAUDE.md` or local project docs
4. ask the user

If both `.worktrees/` and `worktrees/` exist, prefer `.worktrees/`.

## Safety Check for Project-Local Worktrees

If using `.worktrees/` or `worktrees/`, verify the directory is ignored before creating the worktree.

Use a check like:

```bash
git check-ignore -q .worktrees || git check-ignore -q worktrees
```

If the directory is not ignored:

1. explain the issue
2. add the minimal `.gitignore` entry needed
3. do not create a commit unless the user explicitly asks for one
4. continue only once the ignore issue is resolved

## Worktree Creation

After selecting the directory:

1. detect the repo root and project name
2. derive a branch or worktree name from the feature if the user has not supplied one
3. create the worktree on a new branch
4. enter the new worktree

## Project Setup

Run the setup appropriate to the repo.

Examples:

- Node: `npm install`, `pnpm install`, or project equivalent
- Python: `uv sync`, `poetry install`, or project equivalent
- Go: `go mod download`
- Rust: `cargo build` or dependency fetch as appropriate

Use the repo's actual tooling. Do not invent setup steps.

## Baseline Verification

Run the relevant test command to confirm the worktree starts from a known-good baseline.

If tests fail:

- report the failures clearly
- do not blur pre-existing failures with new work
- ask whether to proceed anyway or investigate first

If tests pass, report that the worktree is ready.

## Final Report

Report:

- the full worktree path
- the branch name
- the setup command(s) run
- baseline test status

If there is any ambiguity about location or branch naming, ask instead of guessing.
