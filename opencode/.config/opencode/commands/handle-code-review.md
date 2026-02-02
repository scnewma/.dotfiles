---
description: Process review feedback with technical rigor before changes
---
You are running the `/handle-code-review` command. This is a manual workflow for processing review feedback.

# Goal

Evaluate feedback technically, not performatively.

## Response Pattern

For each batch of feedback:

1. Read the entire feedback without reacting.
2. Restate the requirements or requested changes in your own words.
3. Ask for clarification if any item is unclear.
4. Verify whether each suggestion is correct for this codebase.
5. Implement fixes one item at a time.
6. Test each fix.

## Clarify Before Implementing

If any item is unclear, stop and clarify before implementing anything from that batch.

Do not implement the items you understand while leaving ambiguous items for later if the feedback is likely interconnected.

## No Performative Agreement

Avoid responses like:

- "You're absolutely right"
- "Great point"
- "Excellent feedback"

Instead:

- state the fix you made
- state the requirement you are verifying
- or state the technical reason you disagree

## Evaluating Feedback

Before implementing a review comment, check:

- does it match the actual codebase?
- does it break existing behavior?
- is it required, or is it YAGNI?
- is the reviewer missing important context?
- does it conflict with prior user direction?

If the answer is unclear, say so and investigate rather than pretending certainty.

## Pushback Rules

Push back when feedback is:

- technically incorrect
- out of scope
- inconsistent with the agreed design
- adding unnecessary complexity
- incompatible with the project's constraints

Push back with technical reasoning, not defensiveness.

## Implementation Order

When feedback is valid, fix in this order:

1. blocking issues
2. correctness issues
3. test gaps
4. maintainability issues
5. minor polish

Re-run the relevant checks after each significant change.

## GitHub Reply Note

If you are replying on GitHub, prefer replying in the existing review thread rather than posting disconnected top-level comments.
