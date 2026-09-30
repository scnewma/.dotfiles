---
description: Run code-review and ponytail-review in parallel subagents, merge results
argument-hint: "[low|medium|high|xhigh|max] [target]"
---
Review a change with two independent subagents and merge their output. Don't review anything yourself.

Review args: `${@:-<none, review the current diff>}`

1. Run `echo "$PI_PROVIDER/$PI_MODEL $PI_REASONING_LEVEL"` with bash. The first field is MODEL, the second is THINKING.
2. Split the args: LEVEL is a leading `low|medium|high|xhigh|max` if present, otherwise `medium`; TARGET is the rest.
3. Set REVIEW_DIR to the current cwd. If TARGET is a PR (a number, `owner/repo#N`, or a GitHub PR URL):
   - PROJECT is the repo name from the URL or `owner/repo`, or the current repo for a bare number. REPO_DIR is `~/supabase/<PROJECT>`. If it doesn't exist, stop and ask.
   - Run `but -C REPO_DIR status --json`. If it fails, the repo isn't set up for GitButler: use the git fallback below.
   - **GitButler, clean** (`uncommittedChanges` and `stacks` both empty): run `git -C REPO_DIR fetch origin pull/N/head:pr-N`, then `but -C REPO_DIR apply pr-N`. Set REVIEW_DIR to REPO_DIR.
   - **GitButler, not clean:** set REVIEW_DIR to `~/supabase/.worktrees/<PROJECT>-pr-<N>`. If it doesn't exist, create it with `git -C REPO_DIR worktree add --detach REVIEW_DIR`. Then run `gh pr checkout N --detach --force` in REVIEW_DIR. Never run `but setup` there.
   - **Git fallback:** if `git -C REPO_DIR status --porcelain` is empty, run `gh pr checkout N` in REPO_DIR and set REVIEW_DIR to REPO_DIR. Otherwise use the worktree steps above.
   - Never run `git checkout`, `git switch`, or `gh pr checkout` in a GitButler workspace.
   - Record CHECKOUT as `<REVIEW_DIR> (<but apply|git checkout|new worktree|existing worktree>, <branch or commit>)`.
   If TARGET isn't a PR, CHECKOUT is `<REVIEW_DIR> (no checkout)`.
4. In a single message, launch two `Agent` calls (`subagent_type: general-purpose`, `model: MODEL`, `thinking: THINKING`, `run_in_background: false`) so they run concurrently. Both agents work only in REVIEW_DIR: run every command with it as the cwd, read files from it, and don't edit anything.
   - **code-review**: "Load the `code-review` skill and run it with args `<LEVEL> <TARGET>` in `<REVIEW_DIR>`. Ignore --fix/--loop/--comment/--share. Don't call `review_report`. Return the final verified findings as Markdown (priority, file:line, summary, failure scenario), most severe first, or `No findings.`"
   - **ponytail-review**: "Load the `ponytail-review` skill and run it in `<REVIEW_DIR>` against <the PR diff from `gh pr diff N` | TARGET | the current uncommitted diff>. Return findings in the skill's one-line format, or `No findings.`"
5. Once both return, output exactly:

```
**Checked out at:** <CHECKOUT>

## Code review
<code-review agent output, verbatim>

## Ponytail review
<ponytail-review agent output, verbatim>

## Overlap
<one bullet per location both agents flagged, or "None">
```

If an agent fails, put its error under its heading instead of retrying. Don't add any other commentary.
