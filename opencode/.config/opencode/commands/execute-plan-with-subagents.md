---
description: Execute a written plan by dispatching a fresh subagent per task with review gates
---
You are running the `/execute-plan-with-subagents` command. This is a manual workflow for executing a written plan by using a fresh subagent per task.

If the user passed `$ARGUMENTS`, treat that as the plan path. Otherwise, identify the correct plan file before proceeding.

# Goal

Execute the plan task by task with isolated subagent context and two review gates after each task:

1. spec compliance
2. code quality

## When This Command Fits

Use this when:

- a written implementation plan already exists
- tasks are mostly independent
- you want to stay in this session
- you want tighter quality control than inline execution provides

If tasks are tightly coupled or there is no plan, stop and redirect accordingly.

## Before You Start

1. If work should be isolated and you are not already in an appropriate branch/worktree, suggest or run `/setup-worktree` first.
2. Never start implementation on `main` or `master` without explicit user consent.
3. Read the full plan once before dispatching anything.
4. Ensure the worktree is clean before starting the first task and before starting each later task.

If the worktree is not clean before a new task starts, stop and resolve that before continuing. Do not let unrelated or leftover changes bleed into the next task.

## Task Isolation Model

Each task should use this lifecycle:

1. start from a clean worktree
2. record a task baseline before dispatching the implementer
3. let the implementer work without committing
4. review only the diff for that task
5. fix and re-review until both reviews pass
6. commit once, after approval, to create a clean baseline for the next task

This keeps prior approved work out of later task reviews while still preserving a clean `HEAD` between tasks.

## Controller Responsibilities

You are the coordinator, not the implementer.

Your job is to:

- read the plan once
- extract all tasks with their full text and relevant context
- create and maintain the task list
- dispatch one implementer subagent per task
- run review loops after each task
- decide whether a task is truly complete

Do not make subagents rediscover the plan by reading the whole file unless that is unavoidable. Give them the exact task text and scene-setting context they need.

## Execution Flow

### 1. Read and Extract

Read the plan and extract:

- the overall goal
- architecture notes that matter for every task
- each task's full text
- dependencies between tasks
- required verification commands

### 2. Create Tracking

Create a todo list with one item per plan task.

Only one task should be `in_progress` at a time.

### 3. Per-Task Loop

For each task:

1. Mark the task `in_progress`.
2. Confirm the worktree is clean.
3. Record `TASK_BASE_SHA` before any task work begins.
4. Dispatch an implementer subagent with the full task text and scene-setting context.
5. If the implementer requests context, answer clearly and re-dispatch.
6. Keep the task changes uncommitted during implementation and review.
7. Once the implementer reports completion, review only the task-scoped diff from `TASK_BASE_SHA` to the current worktree state.
8. Run a spec-compliance review against that task-scoped diff.
9. Treat spec review outcomes as `PASS`, `PASS_WITH_NOTES`, or `FAIL`.
10. Only after spec compliance returns `PASS` or `PASS_WITH_NOTES`, run a code-quality review against that same task-scoped diff.
11. Treat code-quality review outcomes as `PASS`, `PASS_WITH_NOTES`, or `FAIL`.
12. If either reviewer returns `FAIL`, send the implementer back to fix the material issues and then re-run only the failed review.
13. If reviewers return `PASS_WITH_NOTES`, use judgment: address the notes now only if they materially improve correctness, maintainability, or user-requested process compliance.
14. When neither review is `FAIL`, create one clean commit for the task so the next task starts from a clean `HEAD`.
15. Mark the task complete only after there are no `FAIL` outcomes and the task commit succeeds.

The important rule is that reviewers examine only the current task diff, not cumulative branch changes.

The second important rule is that reviewers should block only on material issues. Trivial process omissions, historical evidence recovery, and ceremonial proof requests should become notes, not failures, unless they materially reduce confidence in the task.

### 4. Final Review

After all tasks are complete, perform or dispatch one final whole-change review before wrapping up.

### 5. Finish the Branch

When the full implementation is complete and verified, run `/finish-development-branch`.

## Implementer Status Handling

Expect implementers to return one of these statuses and handle them explicitly:

- `DONE`: proceed to spec review
- `DONE_WITH_CONCERNS`: read the concerns before review; address if needed
- `NEEDS_CONTEXT`: provide missing context and re-dispatch
- `BLOCKED`: change something before retrying; do not blindly resend the same task

If an implementer says `BLOCKED`, respond by doing one of the following:

1. provide missing context
2. break the task into smaller parts
3. use a more capable subagent if available
4. escalate to the user if the plan itself is wrong

## Implementer Prompt Template

Use a prompt along these lines:

```text
You are implementing Task <N> from an approved implementation plan.

Overall context:
- Goal: <goal>
- Architecture notes: <relevant context>
- Plan file: <path>
- Task base: <TASK_BASE_SHA>

Task text:
<paste the full task exactly>

Rules:
- Stay within the scope of this task.
- Follow TDD: write the failing test first, run it, then write the minimal implementation.
- Run the exact verification commands called for by the plan.
- Do not commit the task changes yourself unless the controller explicitly instructs you to do so after reviews pass.
- If something is unclear or missing, stop and return NEEDS_CONTEXT.
- If blocked, explain exactly why.

Return one of:
- DONE
- DONE_WITH_CONCERNS
- NEEDS_CONTEXT
- BLOCKED

Also include:
- files changed
- tests/verification run
- a concise summary of the current task diff
- any concerns or gaps
```

## Spec Reviewer Prompt Template

```text
Review the implementation for Task <N> against the plan task text below.

Review scope:
- Only review the diff from <TASK_BASE_SHA> to the current task state.
- Do not raise issues from earlier approved tasks unless the current task clearly regressed them.

Task text:
<paste full task>

Review data:
- `git diff --stat <TASK_BASE_SHA>`
- `git diff <TASK_BASE_SHA>`
- changed files list
- verification output for this task

Review philosophy:
- Focus on substantive compliance with the task, not ceremonial process enforcement.
- Do not fail the task for trivial process omissions if the task outcome is still clear and verified.
- Do not require reconstructed historical proof of intermediate TDD steps unless the missing evidence materially reduces confidence in correctness.
- Prefer `PASS_WITH_NOTES` over `FAIL` for non-blocking process hygiene issues.

Check for:
- missing requirements
- extra behavior not requested
- deviations from the documented file boundaries
- missing final or task-critical verification that materially affects confidence
- task scope drift

Return:
- PASS, PASS_WITH_NOTES, or FAIL
- specific findings with references to the task text
- clearly separate blocking issues from non-blocking notes
```

## Code Quality Reviewer Prompt Template

```text
Review the implementation for Task <N> for correctness and code quality.

Review scope:
- Only review the diff from <TASK_BASE_SHA> to the current task state.
- Treat earlier approved work as baseline unless the current task changed or regressed it.

Review data:
- `git diff --stat <TASK_BASE_SHA>`
- `git diff <TASK_BASE_SHA>`
- changed files list
- verification output for this task

Review philosophy:
- Focus on material correctness, regressions, test quality, and maintainability.
- Do not fail the task for nits, formatting preferences, or ceremonial process evidence.
- Prefer `PASS_WITH_NOTES` when the implementation is acceptable but there are minor or optional improvements.

Check for:
- correctness and regressions
- clarity and maintainability
- adequate tests
- unnecessary complexity
- mismatch with existing project patterns

Return:
- PASS, PASS_WITH_NOTES, or FAIL
- issues ordered by severity
- concise rationale
- clearly separate blocking issues from non-blocking notes
```

## Rules and Red Flags

Never:

- dispatch multiple implementers in parallel for overlapping code changes
- start a task from a dirty worktree
- let task N+1 begin before task N is committed or otherwise resolved
- start code-quality review before spec compliance passes
- move to the next task while review issues remain open
- let reviewers inspect cumulative branch changes when the intent is task review
- let reviewers block on trivia, nits, or reconstructed historical proof that does not materially change confidence in the task
- let implementer self-review replace actual review
- let the implementer commit before both reviews pass, unless the user explicitly wants a different workflow
- claim completion without fresh verification evidence

If multiple independent debugging or investigation tasks appear during execution, you may parallelize those investigations, but not overlapping implementation edits.

## Commit Timing

If the written plan includes a per-task commit step, interpret that as:

1. implement the task
2. review the uncommitted task diff
3. fix review findings
4. commit once, after approval

Do not commit before review unless the user explicitly wants a commit-first review workflow.
