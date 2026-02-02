---
name: brainstorm
description: Turn a rough idea into a reviewed design spec before any implementation.
disable-model-invocation: true
---

You are running the brainstorm skill. This is a manual workflow. Use it only because the user explicitly invoked it.

# Goal

Turn the user's idea into a reviewed design before any implementation work begins.

# Hard Gate

Do not write code, scaffold files, invoke implementation workflows, or take implementation actions until all of the following are true:

1. You explored the current project context.
2. You clarified the user's intent and constraints.
3. You proposed alternatives with trade-offs.
4. You presented a design and got approval.
5. You wrote the approved spec to disk.
6. You self-reviewed the spec.
7. You asked the user to review the written spec.

## Required Progress Tracking

Track progress through each step internally and complete them in order. Do not print a checklist by default; only summarize progress when it is useful for orientation or when the user asks for it.

1. Explore project context.
2. Ask clarifying questions one at a time.
3. Propose 2-3 approaches with trade-offs.
4. Present the design in sections and validate each section.
5. Write the design doc.
6. Self-review the design doc.
7. Ask the user to review the written spec.
8. Hand off to the write-plan skill.

## Process

### 1. Explore Context First

Before asking design questions, inspect the current project:

- read relevant docs, READMEs, and existing patterns
- inspect the code areas likely to be affected
- review recent changes if they help explain current direction

Build enough context to ask good questions and avoid proposing designs that fight the existing codebase.

If the request spans multiple independent subsystems, say so early and help the user decompose the work. Brainstorm only the first coherent slice instead of trying to design everything at once.

### 2. Ask Clarifying Questions

Ask one question per message.

Focus on:

- purpose
- constraints
- success criteria
- user-visible behavior
- non-goals

Prefer multiple-choice questions when possible, but use open-ended questions when needed.

If the topic is likely to involve visual layout or structure, you may offer to use mockups or diagrams, but keep that offer separate from the clarifying question itself.

### 3. Explore Alternatives

When you understand the problem well enough, propose 2-3 approaches.

For each approach, cover:

- core idea
- main benefits
- main trade-offs
- why it does or does not fit this codebase

Lead with the recommended option and explain why.

### 4. Present the Design Incrementally

Present the design in sections sized to the complexity of the work. Typical sections:

- architecture
- components and responsibilities
- data flow
- edge cases and error handling
- testing strategy

After each section, ask whether it looks right so far before moving on.

Keep the design concrete. Avoid vague statements like "add error handling" or "write tests" without specifying what errors matter or what behavior must be tested.

### 5. Design for Isolation and Clarity

Prefer designs with:

- clear boundaries
- well-defined responsibilities
- focused files and modules
- testable units

Follow the existing project's patterns. If the current codebase has an issue that materially affects this work, include the smallest targeted improvement needed to support the feature cleanly. Do not turn the session into unrelated refactoring.

## Write the Spec

After the user approves the design, write it to:

`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

If the user prefers a different location, use that instead.

The written spec should be precise enough that the write-plan skill can turn it into an implementation plan without having to rediscover the design.

## Self-Review Checklist

After writing the spec, read it again and fix issues inline:

1. Placeholder scan: remove `TBD`, `TODO`, and vague requirements.
2. Internal consistency: make sure sections do not contradict each other.
3. Scope check: confirm this is small enough for a single implementation plan.
4. Ambiguity check: rewrite anything that could be interpreted in multiple ways.

## User Review Gate

After self-review, ask the user to review the written spec before moving on.

Use this handoff:

> Spec written to `<path>`. Please review it and let me know what you want to change before we move on to planning.

Wait for the user's response.

If they request changes, update the spec and re-run the self-review.

## Handoff

Once the user approves the written spec, recommend the write-plan skill as the next step.
