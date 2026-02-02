---
name: write-skill
description: Create or edit an agent skill using a test-driven documentation process.
disable-model-invocation: true
---

You are running the write-skill skill. This is a manual workflow for creating or editing a reusable skill.

# Goal

Write a skill using test-driven documentation: prove the agent fails without the skill, then write the smallest skill that fixes that failure.

## Iron Law

No new skill or skill edit without a failing baseline scenario first.

If you did not observe the failure without the skill, you do not know whether the skill actually teaches the intended behavior.

## TDD Mapping for Skills

- failing test -> pressure scenario or usage scenario
- production code -> `SKILL.md`
- red -> agent fails without the skill
- green -> agent succeeds with the skill
- refactor -> tighten wording, close loopholes, retest

## When to Create a Skill

Create a skill when:

- the technique or rule is reusable
- it is not obvious without guidance
- it is likely to matter again across projects

Do not create skills for:

- one-off solutions
- project-specific conventions that belong in repo instructions
- purely mechanical constraints that should be enforced by tooling instead

## File Structure

In this repository, use:

`agent/skills/<skill-name>/SKILL.md`

Add supporting files only when they are truly needed for heavy reference material or reusable tooling.

## Required Frontmatter

Each skill needs YAML frontmatter with at least:

- `name`
- `description`

Rules:

- the directory name and `name` must match
- lowercase letters, numbers, and hyphens only
- the description should say what the skill does and when to use it
- set `disable-model-invocation: true` for manual-only workflow skills

## Process

### RED: Baseline Failure

1. Create a scenario that should reveal the missing behavior.
2. Run it without the skill.
3. Capture the exact failure, rationalization, or confusion.

### GREEN: Write the Minimal Skill

Write the smallest `SKILL.md` that addresses the specific failure you observed.

The skill should include:

- what it is for
- when to use it
- the key process or technique
- important guardrails
- examples only where they add real clarity

### REFACTOR: Close Loopholes

Re-run the scenario.

If the agent finds a new loophole or rationalization:

1. update the skill to address it explicitly
2. re-run the scenario
3. repeat until the skill is reliable

## Quality Checklist

Before finishing, verify:

- the frontmatter is valid
- the description is discoverable and specific
- the skill body is concise but complete
- the examples are concrete, not filler
- the skill addresses the actual observed failure
- the skill works in testing, not just in theory

## Deployment

After testing passes, save the skill, report what it teaches, and only commit if the user explicitly asks for a commit.
