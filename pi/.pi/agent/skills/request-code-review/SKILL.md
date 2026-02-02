---
name: request-code-review
description: Request a focused code review before merging or continuing work.
disable-model-invocation: true
---

You are running the request-code-review skill. This is a manual review workflow.

# Goal

Catch issues before they compound or before the work is merged.

## When to Use It

Use this skill:

- after completing a meaningful task
- after implementing a major feature
- before merging
- when you want a fresh technical read on recent changes

## Review Inputs

Gather the minimum context a reviewer needs:

1. the review range (`BASE_SHA` and `HEAD_SHA`)
2. what was implemented
3. what the code was supposed to do
4. any plan or spec file that defines the expected behavior

If a natural review range is unclear, determine it before asking for review.

## Review Process

If a dedicated reviewer workflow or external review tool is available, use it with focused context rather than the whole session history.

The reviewer should inspect:

- requirements coverage
- behavioral regressions
- tests and verification quality
- risky edge cases
- unnecessary complexity
- mismatch with existing project patterns

If no dedicated reviewer workflow is available, perform the same review yourself explicitly and report findings first.

## Reviewer Prompt Template

```text
Review the changes from <BASE_SHA> to <HEAD_SHA>.

What was implemented:
<summary>

Requirements or plan:
<summary or pasted excerpt>

Focus on:
- bugs or regressions
- missing requirements
- incorrect or weak tests
- error handling gaps
- maintainability concerns

Return findings ordered by severity. Cite files and lines when possible.
```

## Acting on Review Feedback

- fix critical issues immediately
- fix important issues before proceeding
- note minor issues for later if appropriate
- push back with technical reasoning when review feedback is wrong

Do not proceed to the next task or to merge while important review findings remain unresolved.

## Verification Rule

If review feedback results in changes, re-run the relevant verification and, if needed, request review again.
