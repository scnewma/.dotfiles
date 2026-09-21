---
description: "/code-simplify trigger — PARALLEL mode (4-agent fan-out via the subagent tool)"
parallel-when:
  context-below: 0.8
  diff-chars-below: 400000
vars: [target, scope-label, pct, git-command, context-package, skill, verify, simplify-max-turns]
---
Clean up the changed code now. Target: {{target}}.

Dispatcher decided PARALLEL mode (context {{pct}} full; scope {{scope-label}}).
Follow the phases IN ORDER — do not launch anything before Phase 0 is done.

## Phase 0 — read the diff (visible, before any agent launches)

{{context-package}}

Run exactly this command (the dispatcher already resolved the scope — do not
re-derive a different range):

    {{git-command}}

Read the full diff, then write a 2–4 line change-intent summary BEFORE
launching anything — that summary and your first-hand reading are what you
will use to merge, dedup, and judge the agents' findings in Phase 2.

## Phase 1 — launch the 4 cleanup agents

Call the `subagent` tool in parallel mode with 4 tasks, one per agent —
cleaner-reuse, cleaner-simplification, cleaner-efficiency, cleaner-altitude —
each task being: "Review the changed code of {{target}} for <angle> findings.
Run this first to see the diff: {{git-command}}. Report file:line — one-line
summary — the concrete cost." Set `maxTurns: {{simplify-max-turns}}` on the call (the slowest
agent pins the wave's wall time; a capped agent still owes partial output).
The agents' angle guidance rides their own definitions — do not write the
agent prompts yourself or inline the diff anywhere. The tool's result carries
the four findings reports.

## Phase 2 — apply, verify, report

When the tool result arrives, merge/dedup the findings against your Phase 0
reading, then load {{skill}} via the read tool and follow its Phase 2
(snapshot → apply → verify → auto-revert on failure → report via
review_report with `fanned_out: true` — the 4-agent fan-out actually ran).
Never apply changes the findings don't justify.
{{verify}}
