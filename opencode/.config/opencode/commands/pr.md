---
description: "Create commits and pull requests in git repositories."
---

# Git PR Workflow

## Commit

Check current changes and recent commit style before writing the message:

```bash
git status --short
git diff --cached
git diff
git log --oneline -5
```

Stage only the intended files, then commit:

```bash
git add <files>
git commit -m "short descriptive message"
```

Do not commit secrets, credentials, `.env` files, or unrelated worktree changes.

## Push

Push the current branch to the remote. If the branch has no upstream, set one:

```bash
git push -u origin HEAD
```

For subsequent updates to the same branch:

```bash
git push
```

### Push conflicts

If a push is rejected because the remote has new commits, fetch and rebase before pushing again:

```bash
git fetch origin
git rebase origin/<branch-name>
git push
```

## Create a PR

Create the PR with `gh`:

```bash
gh pr create --title "..." --body "$(cat <<'EOF'
...
EOF
)"
```

### PR template

Check for a PR template before creating:

```bash
# Common locations
.github/pull_request_template.md
.github/PULL_REQUEST_TEMPLATE.md
.github/PULL_REQUEST_TEMPLATE/
docs/pull_request_template.md
```

If a template exists, use its structure in the `--body`. Fill in sections appropriately — don't leave TODO placeholders or HTML comments from the template.

## Updating an existing PR

After making changes, commit and push the update:

```bash
git status --short
git add <files>
git commit -m "short descriptive message"
git push
```
