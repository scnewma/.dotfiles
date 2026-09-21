---
name: slice-implement
description: |
  Implement a plan document written as vertical slices, one slice
  at a time: implement, verify, commit, then pause for user
  feedback before the next slice. Use when the user says
  "implement the plan slice by slice", "work through the plan",
  "start on slice N", or points at a plan doc with numbered
  slices/stages and wants incremental, reviewable delivery.
disable-model-invocation: true
---

# Slice Implement

Execute a sliced implementation plan as a series of small, verified,
individually committed increments — with a hard stop for user feedback
between slices.

## Core Behavior

- **One slice per cycle.** Implement only the current slice. Never pull
  work forward from a later slice, even when it looks trivial. If the
  current slice genuinely can't land without a piece of a later one,
  stop and say so instead of quietly expanding scope.
- **The plan is the spec; the code is the truth.** Read the plan doc in
  full before starting, and re-read the current slice before
  implementing it. When the codebase contradicts the plan (renamed
  file, missing hook, wrong assumption), stop, explain the mismatch,
  and propose a plan amendment before writing code around it.
- **Hard pause between slices.** After committing a slice, report and
  stop. Do not begin the next slice until the user says to continue.
  "Looks good" on the report is the signal; silence is not.

## Starting

1. Read the entire plan document. List the slices with a one-line
   status for each (done / in progress / not started), inferring "done"
   from the codebase and git history when resuming a partially
   implemented plan.
2. Confirm with the user which slice to start on. Default to the first
   incomplete one.
3. If the plan has no per-slice verify criteria, derive them and state
   them before implementing — a slice without a verification story
   isn't ready to build.

## Per-Slice Cycle

1. **Restate.** Before touching code: the slice's goal, the files it
   touches, and how it will be verified. Flag anything in the plan that
   no longer matches the code.
2. **Implement.** Only this slice. Follow the repo's existing style and
   the project's AGENTS.md rules.
3. **Verify.** Run the slice's verify steps plus the repo's standard
   gates (typecheck, lint, tests). Fix failures in code you wrote and
   re-run until clean. A slice that can't pass its own verify criteria
   doesn't get committed — report the blocker instead.
4. **Commit.** One commit per slice, on top of the previous slice's
   commit. Message names the slice (e.g. `slice 3: replay outstanding
   tool calls on resume`). Use the repo's version-control conventions
   (the `but` skill when GitButler is in use; include commit
   attribution per global rules).
5. **Report and pause.** In a short block:
   - what changed (files, boundaries touched)
   - how it was verified (commands run, what they showed)
   - deviations from the plan and why
   - open questions or decisions punted to the user
   - what the next slice is
   Then stop and wait.

## Handling Feedback

- Revisions to the just-landed slice: apply them, re-verify, and either
  amend the slice's commit (if unpushed and the user's workflow allows)
  or add a small follow-up commit named for the slice. Re-report
  briefly, pause again.
- Feedback that changes a *future* slice: update the plan document in
  the same commit as the revision (or its own commit if standalone), so
  the plan stays the source of truth.
- Feedback that invalidates the current approach: stop implementing,
  discuss, amend the plan, get explicit approval, then resume the
  cycle.

## Tracking Progress

- Mark slice status in the plan document itself (a `Status:` line or
  checklist per slice) as part of each slice's commit, so a fresh
  session can resume from the doc + git log alone.
- When resuming, trust the doc but verify against the code: a slice
  marked done whose verify steps now fail is the first order of
  business.

## Boundaries

- Never merge slices to "save time"; never split one mid-flight without
  saying so.
- Never push, open PRs, or deploy unless the user asks or the plan's
  slice explicitly includes it.
- Refactors discovered mid-slice that aren't needed for the slice go in
  the report as suggestions, not in the commit.
