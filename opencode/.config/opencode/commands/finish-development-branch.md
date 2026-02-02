---
description: Verify tests, present merge options, and clean up a finished branch
---
You are running the `/finish-development-branch` command. This is a manual workflow for wrapping up completed implementation work.

# Goal

Verify the work, present clear integration choices, execute the chosen path, and clean up safely.

## Step 1: Verify Before Any Success Claim

Before presenting options, run the full relevant test suite or other required verification.

Rules:

- do not claim the work is complete without fresh verification evidence
- if tests fail, stop here and fix or report the failures
- do not offer merge/PR/discard choices for known-broken work unless the user explicitly wants that anyway

## Step 2: Determine the Base Branch

Identify the base branch, typically `main` or `master`.

If uncertain, confirm with the user before continuing.

## Step 3: Present Exactly Four Options

Present these options and nothing extra:

1. Merge back to `<base-branch>` locally
2. Push and create a Pull Request
3. Keep the branch as-is
4. Discard this work

Keep the wording concise.

## Step 4: Execute the Chosen Option

### Option 1: Merge Locally

1. switch to the base branch
2. update it if appropriate
3. merge the feature branch
4. rerun verification on the merged result
5. delete the feature branch if the merge succeeds
6. remove the worktree if one was used

### Option 2: Push and Create a PR

1. push the branch to the remote
2. create the PR with a concise summary and test plan
3. return the PR URL

By default, keep the branch and worktree after creating the PR unless the user asks for cleanup.

### Option 3: Keep As-Is

Report the branch name and worktree path and leave everything intact.

### Option 4: Discard

Before deleting anything, require exact confirmation from the user.

Use a message like:

> This will permanently delete branch `<name>` and remove worktree `<path>`. Type `discard` to confirm.

Only proceed if the user replies with the explicit confirmation.

## Safety Rules

Never:

- proceed with failing tests as if the work is finished
- delete work without explicit confirmation
- force-push unless the user explicitly requests it

## Cleanup Rules

- Option 1: clean up merged branch/worktree
- Option 2: keep branch/worktree by default
- Option 3: keep branch/worktree
- Option 4: remove branch/worktree after confirmation
