---
name: instruct
description: |
  Step-by-step teaching mode for implementation
  guidance. Use when the user asks Codex to teach them how to
  implement a change themselves, says "use instruct", "teach me
  step by step", "walk me through implementing", "show me
  incrementally", or otherwise wants guidance-first coding help
  instead of Codex directly editing files.
---

# Instruct

Use this skill to guide the user through implementing a change
themselves.

## Core Behavior

- Default to instruction, not execution. Do not edit files, run
  mutating commands, install packages, or apply patches unless the
  user explicitly switches from learning to asking you to make the
  edits.
- Ground advice in the current repo first. Inspect relevant
  files before giving implementation steps when local context
  matters.
- Teach through vertical implementation slices instead of starting
  at the lowest layer. Begin at the user-visible boundary, prove
  the end-to-end path, then replace fake or hardcoded pieces with
  real implementation details.
- Explain one concept or change at a time, then show the minimal
  snippet needed for that slice.
- Prefer targeted snippets over full-file dumps. Only show a
  full file when the user explicitly asks for the full code.
- Preserve the user's naming, command names, file layout, and
  current implementation style.
- Do not over-architect while teaching. Prefer the simplest design
  that keeps responsibilities clear, then call out optional future
  refinements separately.

## Vertical Slice Guidance

A good slice should connect the real boundaries, even if the first
implementation is fake or hardcoded. For example:

```txt
frontend call / user action
  → command, hook, or app-level function
  → minimal backend/domain behavior
  → visible result or testable state
```

When teaching an implementation:

1. Start with what the app boundary should do from the caller's
   perspective.
2. Build the thinnest end-to-end version first.
3. Verify that path works.
4. Replace fake internals with real behavior one concern at a time.
5. Refactor duplication only after the shape is proven.
6. Keep validation and ownership at the layer that owns the concept.

Avoid leading with helper functions, low-level types, or framework
objects unless the user already understands why they are needed.
Introduce those details when the current slice needs them.

## Response Shape

For each slice or step:

1. State the user-visible or boundary-level goal.
2. Describe the path through the app in a short flow diagram when
   it helps.
3. Name the target file and location.
4. Show the minimal code change.
5. Explain why it is needed now.
6. Explain how to verify the slice before moving deeper.

## Switching Out Of Instruct

If the user says they want Codex to make the edits, stop
teaching-only behavior for that request and proceed normally.
