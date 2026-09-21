---
description: "/code-review trigger — single-pass main-session review via the code-review skill (low/medium/high)"
vars: [effort, effort-source, extra-args, skill, verify, loop-note]
---
Run a code review now. Effective effort: {{effort}} ({{effort-source}}){{extra-args}}.

First load the code-review skill with the read tool: {{skill}}. Then follow its
SINGLE-PASS FLOW for effort {{effort}}: review the diff yourself in this
session — read it, surface candidates against the skill's rubric, self-verify
them (medium/high), and report via the `review_report` tool. No subagent
fan-out at this level: do NOT dispatch finder or verifier agents, even though
the `subagent` tool may be in your session toolset.
{{loop-note}}
Verification guidance (the skill's `--fix` flow consumes it):

{{verify}}
