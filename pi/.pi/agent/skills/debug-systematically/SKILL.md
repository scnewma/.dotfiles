---
name: debug-systematically
description: Debug issues using a structured, evidence-first process.
disable-model-invocation: true
---

You are running the debug-systematically skill. This is a manual debugging workflow.

# Goal

Find the root cause before proposing or implementing fixes.

## Iron Law

No fixes without root-cause investigation first.

Random patches waste time, mask the real issue, and create new bugs.

## When to Use This Skill

Use it for:

- test failures
- broken behavior
- regressions
- build failures
- integration issues
- performance problems

Use it especially when:

- the issue seems obvious
- time pressure makes guessing tempting
- several quick fixes already failed
- you do not fully understand the behavior yet

## Phase 1: Root-Cause Investigation

Before proposing any fix:

1. Read the full error output carefully.
2. Reproduce the problem consistently.
3. Identify the smallest reliable reproduction.
4. Check recent changes that could explain the break.
5. Trace the failing data or control flow backward until you find the source.

If the system has multiple layers or components, gather evidence at component boundaries instead of guessing where the problem lives.

Examples of useful evidence gathering:

- log what enters and exits each layer
- confirm config/env propagation
- compare working and failing paths
- capture exact timing or state differences

If you cannot reproduce the issue reliably, gather more evidence. Do not guess.

## Phase 2: Pattern Analysis

Once you understand the failure shape:

1. Find similar working code in the same codebase.
2. Compare working and broken cases carefully.
3. List the concrete differences.
4. Identify assumptions or dependencies the broken path violates.

Do not skim reference implementations and then freestyle the pattern.

## Phase 3: Hypothesis and Experiment

State a single, concrete hypothesis:

> I think `<cause>` is the root cause because `<evidence>`.

Then test that hypothesis with the smallest possible experiment.

Rules:

- one hypothesis at a time
- one variable at a time
- do not bundle multiple fixes into one test

If the experiment disproves the hypothesis, return to evidence gathering and form a new one.

## Phase 4: Fix with TDD

Once the root cause is understood:

1. Write a failing test that reproduces the bug.
2. Run it and confirm it fails for the expected reason.
3. Write the minimal fix.
4. Re-run the test and confirm it passes.
5. Run broader relevant verification to catch regressions.

Do not fix bugs without a reproducing test unless the user explicitly agrees that the situation does not allow one.

## Multiple Failures

If multiple failures are independent, split them into separate investigations.

Good candidates for parallel investigation:

- different test files with different failure modes
- different subsystems
- unrelated race conditions or integrations

Bad candidates for parallel investigation:

- failures that likely share a root cause
- anything editing the same code paths
- situations where fixing one failure may resolve others

## Red Flags

If you catch yourself thinking any of these, stop and return to the process:

- "just try this"
- "quick fix for now"
- "it is probably X"
- "I already know the problem"
- "I'll write the test after"
- "let me change three things and see"

If several fix attempts have already failed, question the architecture or assumptions instead of piling on more patches.

## Completion Rule

Before claiming the issue is fixed, run the command that proves it and report the actual output.
