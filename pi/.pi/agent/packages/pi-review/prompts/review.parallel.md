---
description: "Native xhigh/max review workflow"
---
Run a code review now. Effective effort: {{effort}} ({{effort-source}}){{extra-args}}.
Review-only unless the extra args explicitly include --fix: stop after reporting without editing files. For --loop, wait for the extension’s fix prompt. Post comments or publish a page only with explicit --comment or --share.
Read {{skill}} and follow its scope/rubric/output rules. Native fan-out available: {{fanout-available}}. If false, work all ten angles sequentially yourself, self-verify, self-sweep, and report fanned_out:false; explicitly note lost independent coverage. Never fake child success.

Resolve the review scope as the skill instructs. Read the diff, enclosing functions and relevant search results before launching. Embed this context in a task packet. Private role labels (not executable agents); use ten independent finder sessions in order: finder-diff-scan, finder-removed-behavior, finder-cross-file, finder-language-pitfall, finder-wrapper-proxy, cleaner-reuse, cleaner-simplification, cleaner-efficiency, cleaner-altitude, finder-conventions.

Write exactly one ```js workflow block in the SAME assistant reply as the tool call (not a fence containing a tool invocation). Then call subagent({workflow:true,async:false,context:"fresh",isolation:"none",mission:false,model:"{{parent-model}}",timeoutMs:{{timeout-ms}}}). If only subagents_enable is active, call it first, then launch on the next reply. Never use MCP search for native tools. The model override includes the parent's CURRENT thinking, independent of review effort.

Each child must receive outputSchema and toolBudget:{soft: Math.max(1,Math.floor(hard/2)),hard,block:["read","grep","find","ls","bash"]}. Native's exact budget field is block (not blockedTools); NEVER block structured_output. Require structured_output({value:{findings:[]}}), not final prose/JSON arrays. Tools remain read-only by instruction, including bash; no nested delegation.

Construct the workflow using the following plain JS pattern, replacing packet with the parent-gathered scope, diff, relevant file context and searches. Do not leave placeholders. All children inherit the top-level model and fresh context. No child async:true. Every native agent value is "review-runner"; keys are private angle IDs. Each task MUST include its exact rolePrompts body plus the parent scope packet; missing role text is a contract failure, never a generic-review fallback.

```js workflow
const findingsSchema = {type:"object",required:["findings"],additionalProperties:false,properties:{findings:{type:"array",items:{type:"object",required:["file","category","short_summary","summary","failure_scenario"],properties:{file:{type:"string"},line:{type:"integer"},category:{type:"string"},short_summary:{type:"string",maxLength:60},summary:{type:"string"},failure_scenario:{type:"string"}}}}}};
const verdictSchema = {type:"object",required:["verdicts"],additionalProperties:false,properties:{verdicts:{type:"array",items:{type:"object",required:["index","verdict","evidence"],properties:{index:{type:"integer"},verdict:{type:"string",enum:["CONFIRMED","PLAUSIBLE","REFUTED"]},evidence:{type:"string"}}}}}};
const rolePrompts = {{role-prompts}};
const packet = "REPLACE WITH GATHERED CONTEXT";
const budget = hard => ({soft:Math.max(1,Math.floor(hard/2)),hard,block:["read","grep","find","ls","bash"]});
const angles = ["finder-diff-scan","finder-removed-behavior","finder-cross-file","finder-language-pitfall","finder-wrapper-proxy","cleaner-reuse","cleaner-simplification","cleaner-efficiency","cleaner-altitude","finder-conventions"];
const finders = await runs.all(angles.map(angle => ({key:angle,agent:"review-runner",task:rolePrompts[angle]+"\n\n"+packet,outputSchema:findingsSchema,toolBudget:budget({{finder-tool-calls}})})));
// Return evidence to the parent; never treat failed/missing structured output as an empty angle.
return finders.map(r => ({key:r.key,ok:r.ok,runId:r.runId,error:r.error,structuredOutput:r.structuredOutput}));
```

Await ALL finders before dedup. A result is usable only when ok and structuredOutput.findings is an array. Failed children are missing coverage: record key/runId/error, retry that angle on a narrower scope with a unique key or include its gap in the gap-hunt; disclose anything unrecovered. Do not retry through external/CLI execution modes.

Then dedup same defect/location/reason ONLY; different reasons at one line survive independently. Group candidates by (file,line), preserving globally numbered candidate indices. In the next same-reply workflow block, define rolePrompts from the JSON map above and the verdictSchema above and await runs.all of {key:"verify-<group>",agent:"review-runner",task:rolePrompts["verifier"]+"\n\n"+<scope/diff/relevant files and numbered group>,outputSchema:verdictSchema,toolBudget:budget({{verifier-tool-calls}})}. Use the same top-level launch controls. Consume the ORDERED ARRAY by iteration, never results.<key>. Keep CONFIRMED and PLAUSIBLE only; failed groups and omitted indices are dropped, never invent verdicts. Reject duplicate or foreign indices and note missing verification coverage.

After ALL verifiers settle, define rolePrompts from the JSON map above and dispatch ONE fresh gap-hunter role session using runs.all([{key:"gap-hunt",agent:"review-runner",task:rolePrompts["gap-hunter"]+"\n\n"+<pre-embedded diff/enclosing functions/searches and deduplicated findings>,outputSchema:findingsSchema,toolBudget:budget({{gap-hunt-tool-calls}})}]). At most 8 new candidates. Verify these with independent grouped verifiers and the same index-coverage rules before keeping them. No compensation waves without reporting missing coverage.

Finally the PARENT calls review_report once, applying the skill's ranking/caps and honest fanned_out. Only the parent applies --fix, verifies, rolls back and re-reports outcomes; children never mutate. Preserve --comment/--share rules.

{{verify}}
