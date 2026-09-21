---
description: "/code-simplify trigger — SINGLE-PASS mode (angles worked inline, no fan-out)"
vars: [target, reasons, scope-label, too-large, git-command, context-package, skill, verify]
---
Clean up the changed code now. Target: {{target}}.

Dispatcher decided SINGLE-PASS mode ({{reasons}}). Scope: {{scope-label}}.

## Phase 0 — read the diff first

{{context-package}}

Run exactly this command (the dispatcher already resolved the scope — do not
re-derive a different range):

    {{git-command}}

Read the full diff, then write a 2–4 line change-intent summary before
reviewing.{{too-large}}

Then load {{skill}} via the read tool and follow its single-pass body. Work
the four angles inline — do not fake fan-out.
{{verify}}
