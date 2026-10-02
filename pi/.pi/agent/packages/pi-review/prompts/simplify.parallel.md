---
description: "/code-simplify trigger — PARALLEL mode (4-agent fan-out via the subagent tool)"
parallel-when:
  context-below: 0.8
  diff-chars-below: 400000
vars: [target, scope-label, pct, git-command, context-package, skill, verify, simplify-tool-calls]
---
Clean up the changed code now. Target: {{target}}.
Preserve existing observable behavior, including incorrect results. Correctness fixes belong to /code-review, not this cleanup.

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

Write exactly one ```js workflow block in the SAME assistant reply as the tool call (not a fence containing a tool invocation). Then call subagent({workflow:true,async:false,context:"fresh",isolation:"none",mission:false,model:"{{parent-model}}",timeoutMs:{{timeout-ms}}}). If only subagents_enable is active, call it first, then launch on the next reply. Never use MCP search for native tools. The model override includes the parent's CURRENT thinking, independent of review effort.

Each child must receive outputSchema and toolBudget:{soft: Math.max(1,Math.floor(hard/2)),hard,block:["read","grep","find","ls","bash"]}. Native's exact budget field is block (not blockedTools); NEVER block structured_output. Require structured_output({value:{findings:[]}}), not final prose/JSON arrays. Tools remain read-only by instruction, including bash; no nested delegation.

The four labels below are PRIVATE role IDs, not executable agents. Every native agent value is "review-runner". Include the exact role body in each task; missing text is a contract failure, never a generic-review fallback.

Use this workflow block, with the task packet containing the target and exact git command above (do not inline the full diff):

```js workflow
const findingsSchema = {type:"object",required:["findings"],additionalProperties:false,properties:{findings:{type:"array",items:{type:"object",required:["file","category","short_summary","summary","failure_scenario"],properties:{file:{type:"string"},line:{type:"integer"},category:{type:"string"},short_summary:{type:"string",maxLength:60},summary:{type:"string"},failure_scenario:{type:"string"}}}}}};
const rolePrompts = {{role-prompts}};
const angles = ["cleaner-reuse","cleaner-simplification","cleaner-efficiency","cleaner-altitude"];
const results = await runs.all(angles.map(angle => ({key:angle,agent:"review-runner",task:rolePrompts[angle]+"\n\n"+"Review the changed code of {{target}}. Run first: {{git-command}}. Cleanup only: preserve existing observable behavior, including incorrect results. Do not propose correctness fixes. Return structured findings; never apply fixes.",outputSchema:findingsSchema,toolBudget:{soft:Math.max(1,Math.floor({{simplify-tool-calls}}/2)),hard:{{simplify-tool-calls}},block:["read","grep","find","ls","bash"]}})));
return results.map(r => ({key:r.key,ok:r.ok,runId:r.runId,error:r.error,structuredOutput:r.structuredOutput}));
```

Await all four children. Consume ordered results, requiring ok and structuredOutput.findings array. A failed child is missing coverage, NOT an empty angle: report key/runId/error and perform that angle inline or retry a narrower same-protocol task before Phase 2. No nested delegation or external/CLI fallback. Report any unrecovered coverage explicitly.

## Phase 2 — apply, verify, report

When the tool result arrives, merge/dedup the findings against your Phase 0
reading, then load {{skill}} via the read tool and follow its Phase 2
(snapshot → apply → verify → auto-revert on failure → report via
review_report with `fanned_out: true` — the 4-agent fan-out actually ran).
Reject any finding whose fix changes existing outputs, errors or side effects, even if it restores documented behavior or is labeled altitude. Never apply changes the findings don't justify.
{{verify}}
