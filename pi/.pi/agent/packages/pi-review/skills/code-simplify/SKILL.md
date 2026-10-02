---
name: code-simplify
description: "Review the changed code for reuse, simplification, efficiency, and altitude cleanups, then apply the fixes. Quality only — it does not hunt for bugs; use /code-review for that. v3 (from Claude Code CLI v2.1.227, symbol-level verified; re-verified against v2.1.261 on 2026-09-05 — bodies unchanged except Altitude) — 4 cleanup agents fan out in parallel when context allows, else a single-pass inline cleanup; either way the fixes are applied, verified against the project's check command, and auto-reverted on failure, then reported as structured outcomes via review_report."
---

<!--
  Reverse-engineering history: README.md

  Bundled: ships inside the pi-review extension (skills/code-simplify/SKILL.md).

  Invocation: /code-simplify [<target>]
    target = file path | PR number | branch name

  ════════════════════════════════════════════════════════════════════════
  Pi ADAPTATIONS (differ from the CC runtime)
  ════════════════════════════════════════════════════════════════════════
    1. Fan-out tool — CC uses the Agent tool; Pi uses the `subagent` tool
       (native workflow runs.all). Where CC says "the Agent tool", read `subagent`.
    2. Mode guard  — CC's Dii has two clauses: (a) spawn-depth — single-pass when
       agent depth >= CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH (default 3); (b) the
       Agent tool must be in the allowlist. On Pi: (a) is N/A — the `subagent`
       tool spawns a fresh subprocess (always depth 0), so depth never accumulates
       — so decideSimplifyMode substitutes three Pi-added guards: a context-fraction
       heuristic (tokens/contextWindow >= 0.8 → single-pass), a diff-size
       guard (diff >= 400K chars → single-pass; the 4-copy fan-out would burn
       ~400K input tokens on prompt text alone), and fan-out availability
       (the fan-out tools must be registered for this process — the Pi
       counterpart of Dii's allowlist clause) — Pi additions NOT mirrors of
       Dii. The cleanup agents' tool whitelist (read/grep/find/ls/bash) never
       includes a fan-out tool, so recursion stays physically bounded
       regardless of tool registration. The decision is made
       DETERMINISTICALLY by the /code-simplify handler — it can
       read ctx.getContextUsage(), which a pure-prompt skill cannot — and announced
       in the trigger message; this skill just provides the two mode bodies.
    3. Command     — CC: /simplify; Pi: /code-simplify.
    4. Dispatch    — CC's lead model writes the 4 Agent prompts itself after its
       visible Phase 0. Pi keeps the same TIMELINE but moves the packaging into
       code: the trigger message carries the handler-resolved scope, the
       changed-file index, and the exact `git -C … diff …` command; the model
       runs it, reads the diff, writes a change-intent summary, and THEN calls
       the `subagent` tool through a native workflow (the counterpart of CC's Agent
       call) with 4 independent review-runner sessions using private cleaner policies; the tool result carries the
       findings back into the same turn for Phase 2.

  Prerequisite: the `review_report` tool (provided by the pi-review extension)
                for the Phase 2 structured outcome report. PARALLEL MODE
                additionally needs the `subagent` tool (separately installed nicobailon/pi-subagents;
                registered whenever fan-out is allowed for this process — the
                recursion guard; the dispatcher only picks PARALLEL when it
                is) plus review-runner and the private policies cleaner-reuse /
                cleaner-simplification / cleaner-efficiency / cleaner-altitude.
                SINGLE-PASS MODE runs standalone apart from `review_report`.
-->

You are improving the quality of the changed code, not hunting for bugs. Review
it for reuse, simplification, efficiency, and altitude issues, then fix what you
find. Preserve existing observable behavior, including incorrect results. Do not look for or fix correctness bugs — that is what `/code-review` is for.

The `/code-simplify` handler has already chosen the mode (PARALLEL or
SINGLE-PASS) from real context usage and announced it in the trigger message.
Follow the body that matches; do not fake the mode you weren't asked to run.
Both modes open the same way: the trigger message carries the handler-resolved
scope, a changed-file index, and the exact git command — Phase 0 below is a
VISIBLE, model-run step before anything launches.

## Phase 0 — Gather the diff

When the trigger message carries a handler-resolved scope (it always does for
/code-simplify), use THAT: run the exact `git -C … diff …` command the trigger
provides — the handler already ran the cascade (merge-base → HEAD → staged →
unstaged) to pick it — read the full diff, and write a 2–4 line change-intent
summary before anything else. Do not re-derive a different range. That summary
and your first-hand reading are what you will use to merge, dedup, and judge
findings in Phase 2.

(No trigger scope — e.g. the skill invoked standalone? Then: run
`git diff @{upstream}...HEAD` (or `git diff main...HEAD` / `git diff HEAD~1`
if there's no upstream) to get the unified diff under review. If there are
uncommitted changes, or the range diff is empty, also run `git diff HEAD` and
include the working-tree changes in scope — the review often runs before the
commit. If a PR number, branch name, or file path was passed as an argument,
review that target instead. Treat this diff as the review scope.)

---

# PARALLEL MODE  (context not near-full AND diff under the fan-out threshold AND fan-out available)

`/code-simplify → visible Phase 0 (read the diff, summarize) → subagent tool (parallel, 4 cleaner agents) → apply the fixes`

## Private policies and the sole executable agent

`review-runner` is the ONLY executable package agent; cleaner labels are
PRIVATE policy IDs and result keys, never agent values. Each task still runs
in its own independent fresh session. Before assembling tasks, read the
required files with `read`, resolving paths relative to this SKILL.md:

- `../../roles/cleaner-reuse.md`
- `../../roles/cleaner-simplification.md`
- `../../roles/cleaner-efficiency.md`
- `../../roles/cleaner-altitude.md`

Use each full body AFTER frontmatter verbatim, not the abbreviated summaries
below. This applies to direct skill invocation too. Command-rendered workflows
already supply exact bodies in `rolePrompts`; reuse that map if present.
Set every task's `agent` to `"review-runner"`, `key` to the cleaner ID, and
`task` to its body plus the parent target/scope packet (including the exact git
command). Append the cleanup-only constraint: preserve existing observable behavior, including incorrect results; do not propose correctness fixes. Missing/unreadable policy text is a contract failure: disclose the
gap, never silently fall back to a generic reviewer or execute a private label.

## Phase 1 — Review (4 cleanup agents in parallel)

After Phase 0, write one `js workflow` block in the SAME reply as subagent({workflow:true,async:false,context:"fresh",isolation:"none",mission:false,model:"<parent-provider>/<parent-id>:<current-thinking>",timeoutMs:1800000}). If only subagents_enable is active, activate it first. Await runs.all([{key,agent:"review-runner",task,outputSchema,toolBudget},...]) for the four private role keys cleaner-reuse, cleaner-simplification, cleaner-efficiency, cleaner-altitude. Each task contains its exact specialist body plus the trigger's target and exact git command; do not inline the diff. Each child has toolBudget:{soft:7,hard:15,block:["read","grep","find","ls","bash"]} (trigger overrides win), and an object schema requiring findings array, entries requiring file/category/short_summary/summary/failure_scenario and optional integer line. short_summary is required, a ≤60-character bare declarative label (schema maxLength:60). Require structured_output({value:{findings:[]}}); NEVER block structured_output.

Results are an ordered array {key,ok,runId,error,structuredOutput}. Await all children before merging/dedup. Failed or missing output is missing coverage, not an empty angle: record failure evidence and self-run that angle or retry narrowly via the same native protocol. Disclose unrecovered coverage. Children only inspect via read/grep/find/ls/bash, never mutate or delegate. If fan-out becomes unavailable, run the single-pass body and report fanned_out:false. Only the parent applies/verifies/rolls back/reports.

### Reuse

Flag new code that re-implements something the codebase
already has — Grep shared/utility modules and files adjacent to the change,
and name the existing helper to call instead.

### Simplification

Flag unnecessary complexity the diff adds: redundant or derivable state,
copy-paste with slight variation, deep nesting, dead code left behind. Name
the simpler form that does the same job.

### Efficiency

Flag wasted work the diff introduces: redundant computation or repeated I/O,
independent operations run sequentially, blocking work added to startup or
hot paths. Also flag long-lived objects built from closures or captured
environments — they keep the entire enclosing scope alive for the object's
lifetime (a memory leak when that scope holds large values); prefer a
class/struct that copies only the fields it needs. Name the cheaper
alternative.

### Altitude

Check that each change fixes the root cause at the right depth rather than
patching a symptom with a fragile bandaid. Special cases layered on shared
infrastructure are a sign the fix isn't deep enough — prefer the simpler,
more general change to the underlying mechanism over adding special cases,
and name that change.
## Phase 2 — Apply, verify, and report

Follow the shared **Phase 2** procedure at the end of this skill (snapshot → apply → verify → auto-revert on failure → report via `review_report`). The parallel fan-out only changes how findings are gathered (Phase 1 — done by the handler); applying, verifying, and reporting are identical across modes. Set `fanned_out: true` in the report since the 4-agent fan-out actually ran.

---

# SINGLE-PASS MODE  (context near-full OR diff too large OR fan-out unavailable)

`/code-simplify → handler decided single-pass (reasons in the trigger message) → inline cleanup → apply the fixes`

The handler decided against the 4-agent fan-out (context near-full, diff too
large, fan-out unavailable, or usage unmeasurable — the exact reasons are in
the trigger message), so work through all four angles below yourself, in this
same context, in one pass — do not skip an angle for lack of fan-out. Phase 0
is the same visible opening: run the exact git command from the trigger
message, read the diff, write the change-intent summary.

## Phase 1 — Review (4 cleanup angles, single pass)

Review the diff against each angle below in turn. For each, note findings with
`file`, `line`, a one-line `summary`, and the concrete cost (what is
duplicated, wasted, or harder to maintain).

### Reuse

Flag new code that re-implements something the codebase
already has — Grep shared/utility modules and files adjacent to the change,
and name the existing helper to call instead.

### Simplification

Flag unnecessary complexity the diff adds: redundant or derivable state,
copy-paste with slight variation, deep nesting, dead code left behind. Name
the simpler form that does the same job.

### Efficiency

Flag wasted work the diff introduces: redundant computation or repeated I/O,
independent operations run sequentially, blocking work added to startup or
hot paths. Also flag long-lived objects built from closures or captured
environments — they keep the entire enclosing scope alive for the object's
lifetime (a memory leak when that scope holds large values); prefer a
class/struct that copies only the fields it needs. Name the cheaper
alternative.

### Altitude

Check that each change fixes the root cause at the right depth rather than
patching a symptom with a fragile bandaid. Special cases layered on shared
infrastructure are a sign the fix isn't deep enough — prefer the simpler,
more general change to the underlying mechanism over adding special cases,
and name that change.
## Phase 2 — Apply, verify, and report

Follow the shared **Phase 2** procedure at the end of this skill (snapshot → apply → verify → auto-revert on failure → report via `review_report`). Single-pass vs parallel only changes how findings are gathered (Phase 1); applying, verifying, and reporting are identical across modes. Set `fanned_out: false` in the report so a reader is not misled into thinking the 4-agent fan-out ran.

---

# Phase 2 — Apply, verify, and report (shared by both modes)

Dedup findings that point at the same line or mechanism first. Then apply,
verify, and report. This safety net is what distinguishes `/code-simplify` from
a blind cleanup: a finding is only "done" once it is applied AND the project
still verifies — otherwise it is reverted.

## Step 1 — Snapshot the baseline

Before applying any fix, snapshot every file you are about to edit so a failed
verification can be reverted cleanly. For each touched file, copy its current
content into a temp dir:

```
mkdir -p /tmp/pi-simplify-baseline/$(dirname <file>)
cp <file> /tmp/pi-simplify-baseline/<file>
```

`$(dirname <file>)` keeps the target's parent dir (e.g. `src/`) inside the
baseline — a bare `cp <file> /tmp/pi-simplify-baseline/<file>` fails with ENOENT
for any file in a subdirectory. If a fix CREATES a new file, record its path so
Step 3a can remove it on rollback (it has no baseline entry).

This baseline captures the working-tree state **including** the user's
uncommitted changes — reverting to it undoes only `/code-simplify`'s fixes,
never the user's diff. Do **not** use `git checkout` / `git restore` to revert:
that would discard the user's intended changes too.

## Step 2 — Apply the fixes

Apply each surviving finding directly. Skip any finding whose fix would change
existing outputs, errors or side effects, even if it restores documented behavior or is labeled altitude. Also skip fixes that require changes well outside the reviewed diff, or that you
judge to be a false positive — note the skip (it will be reported as
`skipped`).

## Step 3 — Verify, branching on the result

Run the verification command the handler injected in the trigger message (e.g.
`npm run check`), then branch:

- **No verification command was detected** → keep the applied changes, mark each
  applied finding `fixed`, and say in the report that NO verification
  was run. Verification is opportunistic — never block on its absence.
- **Verification passes** → keep the changes; applied findings are
  `fixed`.
- **Verification fails** → the working tree is verified-broken; go to Step 3a.

### Step 3a — Auto-revert (hybrid granularity, only on failure)

1. Revert ALL touched files from the Step 1 baseline (working-tree parent dirs
already exist, so copying back is safe):
   ```
   cp /tmp/pi-simplify-baseline/<file> <file>
   ```
2. Remove any files the fixes CREATED (they have no baseline entry and would
otherwise survive the rollback).
3. Re-apply ONE file's findings at a time, running the verification command
   after each file. Keep only files whose verification passes; revert any file
   whose verification fails back to its baseline.
4. If NO file passes on its own, leave everything reverted and mark every
   finding `skipped` — a clean tree is the safe outcome, not a broken one.

This caps the cost: the common case (clean apply) runs verification exactly
once; only a failure escalates to one verification per touched file.

## Step 4 — Report via `review_report`

Call the `review_report` tool **once** with `level: "simplify"` and one finding
entry per cleanup, ranked most-severe first. Generate a `report_id` (e.g.
`review-<ts>`) on this first call; reuse it on any re-report (fixed-later
obligation: if later work in this session fixes an already-reported item, you
must call `review_report` again to update `outcome` before any prose summary).
Each entry carries `file`, `line` (optional),
`category` (`reuse` / `simplification` / `efficiency` / `altitude`),
`short_summary` (≤60-char bare declarative label, no reasoning or consequence
— the summary table prefers it),
`summary` (one English line including the reasoning and consequence),
`failure_scenario` (the concrete cost — English), and `outcome`:

- `fixed` — applied and verification passed (or no verification command existed
  and the change was kept).
- `skipped` — real but not applied: judged a false positive / behavior-
  changing, or reverted by the auto-revert in Step 3a. Partial applies (per-file
  rollback kept only some files) also count as `skipped` — the per-file detail
  goes into `summary`.
- `no_change_needed` — not applicable or already handled.

Do **not** write a free-text summary as the primary record — the structured
`review_report` call IS the summary (it renders the report AND writes JSON to
`<cwd>/.pi/review/` for CI). If `review_report` is unavailable, fall back to a
brief text summary listing each finding's outcome.

Set `fanned_out` honestly in the call: `true` only if the 4-agent fan-out
(subagent) actually ran; `false` for single-pass. The report header shows this
so a reader is not misled about what ran.

## Step 5 — Clean up

```
rm -rf /tmp/pi-simplify-baseline
```

Remove the baseline snapshots once the report is delivered.
