---
name: execute-plan
description: Execute a written implementation plan in this session with checkpoints.
disable-model-invocation: true
---

You are running the execute-plan skill. This is manual inline execution of a written plan.

If the skill was invoked with arguments, treat them as the plan path. Otherwise, identify the correct plan file before doing anything else.

# Goal

Load a plan, review it critically, execute it in this session, and stop when blocked instead of guessing.

## Before You Start

1. If work should be isolated and you are not already in an appropriate branch or worktree, suggest or run the setup-worktree skill first.
2. Never begin implementation on `main` or `master` without explicit user consent.
3. Read the entire plan before touching code.

## Phase 1: Review the Plan

Before starting execution:

- read the plan end to end
- identify missing information, contradictions, or risky assumptions
- raise concerns before starting any task

If the plan has critical gaps, stop and ask the user to update the plan instead of improvising around it.

## Phase 2: Create Execution Tracking

Maintain an explicit checklist in the conversation with one entry per plan task.

Rules:

- only one task should be `in_progress` at a time
- mark tasks complete immediately after verification succeeds
- add follow-up items only when they are genuinely required by the plan or by issues discovered during execution

## Phase 3: Execute Tasks Exactly

For each task:

1. Mark it `in_progress`.
2. Follow each step in order.
3. Run the verification commands the plan specifies.
4. If a step fails, stop and resolve the failure before moving on.
5. Mark the task complete only after verification succeeds.

Do not silently skip steps because they feel repetitive.

## TDD Rules

Implementation work in the plan must follow TDD:

- write the failing test first
- run it and confirm it fails for the expected reason
- write the minimal implementation
- rerun the test and confirm it passes
- refactor only while keeping tests green

If code was written before the failing test, acknowledge that and restart the step properly instead of pretending it was test-driven.

## Verification Rules

Do not claim a task is complete without fresh evidence.

Before saying something passes, is fixed, or is complete:

1. identify the command that proves the claim
2. run that command now
3. read the output and exit status
4. report the actual result, not the hoped-for result

Partial checks are not enough when the plan calls for broader verification.

## When to Stop and Ask

Stop immediately when:

- the plan is unclear
- a verification step fails repeatedly
- a dependency or environment issue blocks progress
- the required behavior conflicts with reality in the codebase
- you no longer understand why you are making a change

Do not push through blockers by guessing.

## Handoff

After all tasks are complete and verified, run the finish-development-branch skill.

If the user would benefit from higher-quality task isolation and review gates, recommend the execute-plan-with-subagents skill instead of continuing inline.
