---
name: write-plan
description: Create a detailed implementation plan from an approved spec.
disable-model-invocation: true
---

You are running the write-plan skill. This is a manual planning workflow. Use it only because the user explicitly invoked it.

# Goal

Turn an approved spec into a detailed implementation plan that another agent could execute reliably without guessing.

# Hard Gate

Do not implement code while running this skill.

Do not write full function bodies, full test bodies, full component implementations, or other copy-paste-ready source into the plan.

The plan should describe what to build, where to build it, how to verify it, and what patterns to follow. It should not contain the full implementation.

If the design is not yet approved, stop and suggest running the brainstorm skill first.

## Scope Check

If the spec covers multiple independent subsystems, say so and suggest splitting the work into separate plans. Each plan should produce working, testable software on its own.

## File Structure First

Before writing tasks, map the files that will be created or modified and what each one is responsible for.

Use that structure to lock in decomposition decisions:

- clear boundaries
- one responsibility per file where practical
- files that change together should live together
- follow existing project conventions

Do not propose gratuitous restructuring. If a file is already unwieldy and this work would benefit from a split, include that targeted improvement in the plan.

## Plan Location

Write the plan to:

`docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

If the user prefers another location, use that instead.

## Required Header

Every plan must start with this header:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SKILL: use the execute-plan-with-subagents skill (recommended) or the execute-plan skill to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Granularity

Each task should be made of small, concrete steps that take about 2-5 minutes each.

Examples of the right granularity:

- write the failing test
- run it and confirm it fails for the expected reason
- write the minimal implementation
- run the test to confirm it passes
- run broader verification if needed
- commit after review if the user wants a commit-based workflow

## Task Format

Use a structure like this:

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/new-file.ts`
- Modify: `exact/path/to/existing-file.ts`
- Test: `exact/path/to/test-file.test.ts`

- [ ] **Step 1: Add the failing test coverage**

Add test coverage for:
- rejects invalid input
- accepts valid input
- preserves existing behavior for `<case>`

- [ ] **Step 2: Run the test to verify it fails**

Run: `npm test -- path/to/test`
Expected: fail for the missing behavior, not for a typo or setup issue

- [ ] **Step 3: Implement the minimal behavior**

Implementation notes:
- add `parseThing(input)` in `src/thing.ts`
- reuse the existing validation pattern from `src/shared/validation.ts`
- return the existing error shape used by `src/api/errors.ts`

- [ ] **Step 4: Run the test to verify it passes**

Run: `npm test -- path/to/test`
Expected: pass

- [ ] **Step 5: Run broader verification**

Run: `npm test`
Expected: no regressions in affected areas

- [ ] **Step 6: Commit after verification**

Stage the task changes and create one clean commit only after the task's verification succeeds, if the user wants per-task commits.

**Done when:**
- behavior matches the spec
- the named files are updated
- task-level tests pass
- broader verification passes
- the task is ready for review without unrelated changes
````

## Allowed Detail vs. Forbidden Detail

The plan must be specific, but specificity should come from behavior and boundaries, not from writing the whole solution.

Include:

- exact file paths
- exact symbols, types, functions, components, routes, or commands to add or modify
- concrete behavior to implement
- test cases to cover
- commands to run
- success criteria
- references to existing patterns to follow

Avoid:

- full function bodies
- full test files or test bodies
- full component or module implementations
- long code blocks that the executor could mostly copy-paste as the final solution

Tiny snippets are allowed only when they clarify a non-obvious interface, data shape, regex, SQL fragment, migration shape, or other tricky detail. Prefer small signatures or examples over full implementations.

## No Placeholders

Never write:

- `TBD`
- `TODO`
- "implement later"
- "add appropriate error handling"
- "write tests for the above"
- "similar to Task N"
- "see code below" followed by the full implementation

Every task must contain the actual material the executor needs:

- exact file paths
- concrete behavior
- named symbols and responsibilities
- exact commands
- expected outputs or outcomes
- verification and completion criteria

## Planning Rules

- Assume the executor has little codebase context.
- Repeat necessary context instead of relying on task ordering.
- Be DRY in design, not vague in instructions.
- Prefer the minimal correct implementation.
- Use TDD throughout the plan.
- Include verification steps explicitly.
- Prefer references to existing code patterns over rewriting those patterns inline.
- If a task reads like a full pull request or full source file, it is over-specified and should be trimmed back to behavior, boundaries, and verification.

## Self-Review

After writing the plan, review it against the spec:

1. Spec coverage: every requirement should map to a task.
2. Placeholder scan: remove vague wording and missing details.
3. Type and naming consistency: later tasks must match earlier definitions.
4. Scope: if the plan has ballooned, split it before handing it off.

Fix issues inline.

## Handoff

When the plan is complete, end with this choice for the user:

> Plan complete and saved to `<path>`. Two execution options:
>
> 1. `execute-plan-with-subagents` (recommended) for fresh subagent per task plus review gates
> 2. `execute-plan` for inline execution in this session
>
> Which approach do you want?
