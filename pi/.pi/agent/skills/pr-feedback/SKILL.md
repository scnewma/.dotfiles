---
name: pr-feedback
description: Work through review feedback on a pull request one comment at a time, pairing with the user — show each comment, evaluate whether it's valid, propose a fix, get approval before changing anything, then commit/push and print the commit hash. The user writes all replies. Use when the user asks to address PR feedback, review comments, or reviewer questions.
---

# Addressing PR feedback, paired

The user drives. You gather context, judge each comment on the merits, and propose —
but you do not edit code until they say go. You never draft or post replies; the user writes those.

## Phase 1 — gather context (once, up front)

Before touching any comment, get the full picture. Do it in one batch:

```bash
gh pr view <N> --repo <owner>/<repo> --json title,body,headRefName,baseRefName,state,author

# review comments (inline, threaded) — these are the ones you work through
gh api repos/<owner>/<repo>/pulls/<N>/comments --paginate \
  --jq '.[] | {id, user: .user.login, path, line, in_reply_to_id, body}'

# top-level PR comments + review summaries — context, not usually work items
gh api repos/<owner>/<repo>/issues/<N>/comments --jq '.[] | {user: .user.login, body}'
gh api repos/<owner>/<repo>/pulls/<N>/reviews --jq '.[] | {user: .user.login, state, body}'
```

Then:
- Confirm the PR branch is checked out / applied locally (`but status` if GitButler, else `git branch`).
- Read every file+line a comment targets. Read enough surrounding code to have your own opinion.
- Skip comments that already have replies (`in_reply_to_id` set on a later comment) unless the user says otherwise.
- Follow cross-repo references (dependent PRs, linked issues) — `gh pr view <N> --repo <other>/<repo> --json state,mergedAt`.

Report back a short lay-of-the-land: what the PR does, how many unaddressed comments, one line each.
Then ask which to start with (default: first).

## Phase 2 — per comment, one at a time

For each comment, output exactly this shape and then **stop and wait**:

```
## Comment N of M

**Link:** https://github.com/<owner>/<repo>/pull/<N>#discussion_r<comment id>
**File:** `path/to/file.go:LINE` (`FunctionName`)

> the comment body, verbatim

### Current code

```lang
the relevant snippet as it exists today
```

### Evaluation: **valid** ✅ / **partly valid** ⚠️ / **invalid** ❌

- Is the described mechanism real? Trace it in the code, don't take the reviewer's word.
- Is the failure scenario reachable?
- Is the consequence as bad as claimed?
- Is it a demand for a change, or a question wanting an answer? Say which.

### Suggested fix

Concrete: the diff you'd write, or "no code change", or "needs a product decision from you".
```

Rules for this phase:
- **Never edit files before explicit approval. Never draft or post replies.** "Suggest a fix" means describe it.
- **Disagree with the reviewer when the code is right.** A comment that would reintroduce a bug gets `invalid`, with the reasoning spelled out. Compare failure modes side by side (a small table works well) rather than asserting.
- **Take the user's pushback seriously.** If they poke a hole in your evaluation, re-derive from the code — don't defend a position you just adopted. Flipping your recommendation is a good outcome.
- Separate the fully-valid sliver from the rest. "The doc comment does contradict the code — but the short-circuit itself is intentional" is usually the truthful shape.

## Phase 3 — the change

After approval:
1. Make the edit.
2. Run the package's tests (and update/delete tests that encoded the removed behavior — dropping a code path means dropping its test).
3. Show the diff before committing.
4. Commit with a short freeform message describing the behavior change, not the comment number. Push.
5. Print the commit hash. Nothing else: no reply draft, no summary prose. Then offer the next comment.

## Cadence

One comment per turn. End every turn with an explicit handoff — "Ready for comment 3?" — and stop.
Never batch two comments' changes into one commit, and never run ahead to the next comment
because the current one looked easy.
