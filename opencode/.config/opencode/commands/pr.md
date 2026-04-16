---
description: "Create commits and pull requests in jj (Jujutsu) repositories."
---

# jj PR Workflow

## Commit

Set the commit message on the working copy with `jj describe`:

```bash
jj describe -m "$(cat <<'EOF'
short summary line

Optional longer explanation.
EOF
)"
```

Use `jj log --limit 5` to check recent commit style before writing the message.

## Push

Push the current change to a remote bookmark:

```bash
jj git push -c @
```

This creates a bookmark named `push-<change-id>` and pushes it. Note the bookmark name from the output — it's needed for PR creation.

### Bookmark conflicts

If a push fails with "stale info" or bookmark conflict:

```bash
jj git fetch
jj bookmark set <bookmark-name> -r @
jj git push
```

## Create a PR

`gh` doesn't work with jj's detached HEAD, so always pass `--head` explicitly:

```bash
gh pr create --head <bookmark-name> --title "..." --body "$(cat <<'EOF'
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

After making changes to the working copy, push the update:

```bash
jj git push
```

If the bookmark has diverged (e.g. after the remote branch was deleted by a merged PR), resolve with the bookmark conflict steps above.
