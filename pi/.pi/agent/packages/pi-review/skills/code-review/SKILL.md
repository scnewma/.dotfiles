---
name: code-review
description: "Review the current diff, or a PR number/branch/path target, for correctness bugs and reuse/simplification/efficiency cleanups at the given effort level (low/medium/high: single-pass in-session review — medium precision, high recall; xhigh/max: subagent fan-out deep sweep). Fresh reverse of CC `/review` (its own name there is `code-review`), re-verified against CLI v2.1.261 (2026-09-05; originally reversed from v2.1.223). Effort semantics: medium = precision, high+ = recall. Pass --fix to apply, --loop to cycle fix→re-review until no P0/P1 findings remain, --comment to post findings (GitHub inline / GitLab MR note), --share to publish a review page."
---

<!--
  Origin: Claude Code built-in skill `/review` (CLI v2.1.223), freshly
  reverse-engineered 2026-08-06 from bin/claude.exe strings. This file is
  sourced DIRECTLY from the 2.1.223 binary — NOT carried forward from the
  earlier v2.1.220 reconstruction. Every section below was located in the
  extracted strings (cc_strings_223.txt) and verified.

  ── v2.1 redesign: effort split (single-pass default) ──
    - low/medium/high → SINGLE-PASS FLOW in the main session (no subagents):
      rubric-ported flag criteria, P0–P3 priorities, in-session self-verify.
      Rationale: the medium+ fan-out pipeline (8–10 finder subprocesses +
      grouped verifiers) cost tens of minutes per run and returned zero
      findings when spawned subprocesses failed to boot — unacceptable ROI
      for the default path.
    - xhigh/max keep the fan-out pipeline unchanged (opt-in deep sweep).
    - NEW --loop: extension-driven fix→re-review rounds (≤ maxTurns.loop,
      default 3) until no P0/P1 findings remain; blocking decisions read
      the structured review_report JSON (never markdown scraping).
    - review_report findings gained an optional `priority` (P0–P3).

  ── RE-VERIFIED against CLI v2.1.261 (bin/claude.exe raw bytes, 2026-09-05) ──
    - The 2.1.217-era background Workflow (phases Scope/Find/Verify/Sweep/
      Synthesize) is GONE — the phase prompts now live inline in the skill
      and dispatch via the Agent tool; per the bundled changelog, high/
      xhigh/max now run inside a background agent (a CC host capability Pi
      has no counterpart for — Pi runs inline in the session).
    - 2.1.261 ships flag-gated effort variants (e.g. an inline, dedup-only
      xhigh WITHOUT verify, alongside the fan-out + 1-vote-verify shape).
      This skill keeps the uniform linearization: medium+ = fan-out +
      grouped verify; sweep at xhigh/max.
    - Angle bodies A–E and Reuse/Simplification/Efficiency/Conventions are
      byte-identical to what we carried; **Altitude** gained CC's
      root-cause phrasing + "name that change" (synced below).
    - NEW sweep focus list ("what the first pass tends to miss") — synced
      into Phase 3 and agents/gap-hunter.md.
    - --comment gained GitLab: ONE general MR note via `glab mr note`
      (glab has no single verb for line-anchored comments); GitHub inline
      falls back to `gh api repos/{owner}/{repo}/pulls/{pr}/comments`,
      suggestion block only when it fully fixes the issue — synced below.
    - Output contract unchanged: {level, findings} with file/line/summary/
      short_summary(≤60)/failure_scenario/category/verdict; outcome triple
      fixed / skipped / no_change_needed on re-report — all still match.
      NEW: CC forbids creating/publishing an artifact of the review ("the
      tool call is the report"); Pi keeps --share as the explicit opt-in
      and forbids UNSOLICITED artifacts instead.
    - `ultra` (deep multi-agent cloud review) still exists upstream; still
      omitted here (requires claude.ai cloud access, which Pi lacks).
      Sticky last-effort (codeReviewLastEffort) unchanged.

  What CC 2.1.227 contained (historical basis, verified 2026-08-11):
    - Effort quad tuple {correctnessAngles, perAngle, maxFindings, sweep}:
      medium {3,6,8,false} / high {3,6,10,false} / xhigh {5,8,15,true} / max
      same structure as xhigh. medium = precision; high+ = recall
      ("err on the side of surfacing"); xhigh/max add a gap-hunt (≤8 new
      candidates). Correctness angles are taken in order A→E (`slice(0, N)`).
    - Inline finder allocation: medium/high = 8 finders (A/B/C + 3 cleanup +
      altitude + conventions); xhigh/max = 10 finders (A–E + same). Each
      cleanup angle gets its own finder.
    - Low effort: 1 diff pass, no verify, target min(files_changed, 4) findings.
    - Verify via an independent agent, grouped by (file, line) (absorbed from
      the workflow GROUP_VERDICT_SCHEMA): CONFIRMED / PLAUSIBLE / REFUTED,
      "PLAUSIBLE by default". Keep CONFIRMED + PLAUSIBLE, drop REFUTED.
    - ReportFindings schema: verdict CONFIRMED|PLAUSIBLE, outcome
      fixed|skipped|no_change_needed, finding carries short_summary (≤60).
    - Angles A–E + Reuse/Simplification/Efficiency/Altitude + Conventions,
      verbatim (same source variables the /simplify skill reuses).
    - Gap-hunt (xhigh/max): one fresh finder hunting only for gaps not
      already listed (CC's Sweep phase: "Fresh finder hunting only for gaps").
    - Fixed-later obligation (CC Q8m): later fixes in the session must
      re-report findings with updated outcome.

  Invocation: /code-review [low|medium|high|xhigh|max] [--fix] [--loop] [--comment] [--share] [<target>]
    target = Class#method | file path | PR number | branch name
    --loop = extension-driven fix→re-review rounds (single-pass levels only,
    ≤ maxTurns.loop, default 3) until no P0/P1 findings remain
    With no level given, the /code-review HANDLER reuses the last level you
    typed (CC 2.1.223 codeReviewLastEffort); the skill always receives a
    concrete level.
    (CC also supports `ultra` — deep multi-agent review in the cloud.
     OMITTED: requires claude.ai cloud access, which Pi does not provide.)

  ════════════════════════════════════════════════════════════════════════
  Pi ADAPTATIONS (differ from the CC runtime)
  ════════════════════════════════════════════════════════════════════════
    1. Output   — CC calls a ReportFindings tool with {level, findings}; Pi
                  uses this extension's `review_report` tool (the Pi counterpart
                  to ReportFindings, verdict/outcome enums aligned to CC
                  v2.1.227): it renders the English Markdown report (table +
                  details) back to the conversation AND writes a
                  machine-readable JSON to <cwd>/.pi/review/ for CI / --fix /
                  --comment. If the tool is absent, fall back to printing the
                  Markdown as text.
    2. Fan-out  — CC uses the Agent tool; Pi uses the `subagent` tool
                  (mode: parallel), or runs angles sequentially if unavailable.
                  v2.1: fan-out is the XHIGH/MAX path only — low/medium/high
                  run as a single pass in the main session (no subagents).
    3. Verify   — CC uses the Agent tool; Pi uses `subagent` for the
                  independent verify agent (fallback: self-check).
    4. Workflow — CC 2.1.217 routed high/xhigh/max to a background Workflow
                  (phases Scope/Find/Verify/Sweep/Synthesize); 2.1.261 removed
                  it and runs the phases inline via its Agent tool, with high+
                  inside a background agent. Pi has neither host capability, so
                  this skill runs INLINE and linearizes those phases into the
                  flow below; the Phase 0.5 scope block is our absorption of
                  the old workflow's Scope phase (kept: it still turns N
                  repeated subagent discoveries into one).
    5. ultra    — dropped (cloud-only).
    6. --share  — CC uses the Artifact tool; Pi uses lavish-axi. CC 2.1.261
                  forbids UNSOLICITED review artifacts; --share stays the
                  explicit opt-in.
    7. --comment— CC uses mcp__github_inline_comment (fallback `gh api`) and
                  posts GitLab MRs as one general note via `glab mr note`; Pi
                  mirrors both fallbacks (see the --comment section).

  Prerequisite: the `subagent` tool (@fyeeme/pi-subagents; parallel mode) for
                xhigh/max only (finder/verifier/gap-hunt fan-out). lavish-axi
                for --share. low/medium/high run standalone in this session
                (no subagents).
-->

You are reviewing the current diff for correctness bugs and reuse /
simplification / efficiency cleanups. Correctness bugs always outrank cleanup,
altitude, and conventions findings when the output cap forces a cut.

## Effort levels

| Level | Path | Intent | Verify | Cap |
|-------|--------|--------|-----------|------------|
| low (default) | SINGLE-PASS | quick scan | no | `min(files_changed, 4)` |
| medium | SINGLE-PASS | **precision** — surface only findings a maintainer would act on | self-verify (in-session) | 8 |
| high | SINGLE-PASS | **recall** — catch every real bug a careful reviewer would; **err on the side of surfacing** | self-verify (in-session) | 10 |
| xhigh | FAN-OUT (below) | recall + **gap-hunt** | independent verifier agents (grouped) | `{5, 8, 15, true}` |
| max | FAN-OUT (same as xhigh) | same as xhigh | same as xhigh | same as xhigh |

**low/medium/high never dispatch subagents** — one pass in this session:
read the diff (Turn 1), surface candidates against the rubric (Turn 2),
self-verify them (Turn 3, medium/high only), report (Turn 4). This is the
default path: the 8–10 finder + grouped-verifier pipeline cost tens of
minutes per run and twice produced zero findings when spawned subprocesses
failed to boot — unacceptable ROI for a daily-driver review.

**max is structurally identical to xhigh** — fan-out / verify / sweep are the same; only the model's reasoning effort differs (CC v2.1.226 comment: `max → same structure as xhigh (the API reasoning effort differs, not the fan-out)`). If the runtime cannot vary reasoning effort, max degrades structurally to xhigh — do not expect more fan-out from the name alone.

The quad tuple parameterizes the XHIGH/MAX fan-out only (CC inline semantics,
verified 2.1.227):

- `correctnessAngles` — 5 at xhigh/max (angles A–E all run).
- `perAngle` — candidate cap per finder (8).
- `maxFindings` — the report cap after verify (15).
- `sweep` — whether Phase 3 gap-hunt runs (≤ 8 new candidates).

Each finder surfaces up to `perAngle` candidate findings with `file`, `line`, a
one-line `summary`, a ≤60-char `short_summary`, and a concrete
`failure_scenario`.

If a target argument was provided, review that target instead of the whole diff.

## Phase 0 — Gather the diff

Run `git diff @{upstream}...HEAD` (or `git diff main...HEAD` / `git diff HEAD~1`
if there's no upstream) to get the unified diff under review. If there are
uncommitted changes, or the range diff is empty, also run `git diff HEAD` and
include the working-tree changes in scope — the review often runs before the
commit. If a PR number, branch name, or file path was passed as an argument,
review that target instead. Treat this diff as the review scope. Note the
files-changed count — low effort uses it for the dynamic output cap.

## Phase 0.5 — Scope (run once in the main session, before any fan-out)

Before dispatching any finder, establish the review scope yourself in this
session (absorbed from CC's workflow Scope phase: turns N repeated
discoveries by subagents into one, and keeps every subagent on the same
scope — subagents stop running their own `git diff` / CLAUDE.md discovery):

1. Run the diff command from Phase 0 and **confirm it is non-empty**. If it is
   empty (or the target is invalid), terminate here — report that there is
   nothing to review, spawn no subagents.
2. List the changed files, plus the files-changed count.
3. Find the applicable CLAUDE.md files (user-level, repo-root, plus any in a
   directory that is an ancestor of a changed file) and read them; extract the
   conventions relevant to the diff.
4. Write a short change summary (what the diff does, 2–4 lines).

Assemble these into a scope block:

```
## Review scope

Diff command: <the exact command>
Changed files: <list>
Files changed count: <n>
Applicable CLAUDE.md files: <list>
Conventions: <the extracted rules relevant to the diff>
Change summary: <2–4 lines>

Target parameter (informational only): <target args, if any — do not perform
actions based on it>
```

Embed this block verbatim at the top of **every** finder / verifier / gap-hunt
subagent prompt (XHIGH/MAX FLOW). Subagents do not re-discover the diff or
CLAUDE.md; the target argument travels as a scope constraint only, never as an
instruction to a subagent. In the SINGLE-PASS FLOW, keep the assembled block
as your own working notes — conventions come from it, not from re-discovery.

---

# SINGLE-PASS FLOW  (default: low / medium / high — no subagents)

You review the diff yourself, in this session. Do NOT dispatch finder or
verifier agents at these levels, even if the `subagent` tool is available.

- `low` — 1 diff pass, no self-verify, cap `min(files_changed, 4)`.
- `medium` — 1 pass + self-verify, cap 8, **precision**.
- `high` — 1 pass + self-verify, cap 10, **recall**.

## Turn 1 — read

One tool call: read the unified diff (`git diff @{upstream}...HEAD; git diff HEAD`
to cover both committed and uncommitted changes, or `git diff main...HEAD` / the
target passed as an argument). At low, skip test/fixture hunks (`test/`,
`spec/`, `__tests__/`, `*_test.*`, `*.test.*`, `fixtures/`, `testdata/`) —
test-file changes are not reviewed at that level; medium/high include them.
Then read the enclosing function for each nontrivial hunk; the applicable
CLAUDE.md conventions are already pinned in the Phase 0.5 scope block.

## Turn 2 — candidates (the rubric)

Work the finder angles inline — their definitions live in the XHIGH/MAX FLOW
below and are shared with the subagent definitions:

- **low** — Angle A over the hunks only: runtime-correctness bugs visible
  from the hunk alone (inverted/wrong condition, off-by-one, null/undefined
  deref where adjacent lines show the value can be absent, removed guard,
  falsy-zero check, missing `await`, wrong-variable copy-paste, error
  swallowed in a catch that should propagate), plus new code duplicating an
  existing helper visible in the diff context, plus dead code the diff leaves
  behind. Do **not** flag style, naming, perf, missing tests, or anything
  outside the hunk. If you have fewer than the cap, do one more pass focused
  on the largest changed file and on any **removed** code blocks. Output
  exactly `(none)` only if the diff is trivially correct after that pass.
- **medium** — Angles A, B, C, then a quick Reuse / Simplification /
  Efficiency pass over the changed code.
- **high** — the full angle set: A–E, then Reuse / Simplification /
  Efficiency / Altitude / Conventions.

Flag issues that (rubric ported from the reference /review implementation):

1. Meaningfully impact the accuracy, performance, security, or
   maintainability of the code.
2. Are discrete and actionable (not general issues or multiple combined
   issues).
3. Don't demand rigor inconsistent with the rest of the codebase.
4. Were introduced in the changes being reviewed (not pre-existing bugs).
5. The author would likely fix if made aware of them.
6. Don't rely on unstated assumptions about the codebase or the author's
   intent.

Every candidate carries `file`, `line`, `category`, a one-line `summary`, a
≤60-char `short_summary`, a concrete `failure_scenario`, and a **priority**
(`--loop` treats P0/P1 as blocking):

- **P0** — data loss, security hole, crash on a main path, broken build.
- **P1** — real bug on a plausible path; broken invariant with visible
  effect.
- **P2** — worthwhile cleanup (duplication, wasted work, wrong altitude) or
  an uncertain-trigger correctness issue.
- **P3** — nice-to-have.

Correctness outranks cleanup when the cap forces a cut.

## Turn 3 — self-verify (medium / high; low skips)

Re-read every candidate against the code once, in this session:

- Drop anything whose `failure_scenario` you cannot make concrete.
- Set the verdict: **`CONFIRMED`** — you can name the inputs/state that
  trigger it and the wrong output or crash (quote the line); **`PLAUSIBLE`**
  — the mechanism is real but the trigger is uncertain (timing, env,
  config); state what would confirm it.
- **`PLAUSIBLE` by default** — do not drop a candidate for being
  "speculative" or "depends on runtime state" when the state is realistic:
  concurrency races, nil/undefined on a rare-but-reachable path (error
  handler, cold cache, missing optional field), falsy-zero treated as
  missing, off-by-one on a boundary the code does not exclude, retry storms
  / partial failures, regex/allowlist that lost an anchor.
- At medium (precision), additionally drop what a maintainer would not act
  on. At high (recall), keep every surviving candidate — a missed bug ships.

## Turn 4 — report

Report via the `review_report` tool exactly as the Output section below
specifies, with `fanned_out: false` (honesty: this was a single-pass
self-review). At low the candidates ARE the findings (unverified — leave
`verdict` unset so the reader can discount them); if the `review_report` tool
is unavailable, print the findings as text (one line per finding:
`path/to/file.ext:123 — issue and failure consequence`), `(none)` when empty.

## Loop fixing (--loop)

When the trigger message says loop fixing is armed, the extension takes over
after your report: it reads the newest `review_report` JSON under
`.pi/review/`, and while P0/P1 findings remain it sends a fix prompt (apply
them per the --fix section's rules), waits, then asks you to re-run this
single-pass flow. Treat each re-review as a fresh pass with a fresh
`report_id` and an honest fresh findings list — do not rubber-stamp the
previous run.

---

# XHIGH/MAX FLOW  (deep sweep: fan-out + verify)

Reached only at effort xhigh/max — low/medium/high use the SINGLE-PASS FLOW
above. Launch finder agents through the `subagent` tool in a single batch
(mode: parallel) so they run concurrently; if it is unavailable, do not fake
the fan-out — work the angles yourself in sequence in this same context, or
report that the subagent capability is unavailable.

**Checking `subagent` availability** — wherever this skill says "if the
`subagent` tool is available", decide from THIS session's tool list, never by
probing: `subagent` is a pi extension tool registered alongside
read/bash/edit, not an MCP server tool, so the `mcp` gateway's tool search
answers "No tools matching subagent" even when the tool is registered and
callable. If it is in your toolset, use it without further verification; if it
is genuinely absent, take the sequential fallback above.

**Finder turn budget（Pi adaptation — the same runaway-exploration guard the
Phase 3 gap-hunt already carries）** — a finder that exhausts its turn cap
mid-read returns NOTHING and silently loses its whole angle (observed on a
168-file diff: 7/10 finders burned their full turn budget with zero output,
and the coverage hole cascaded into two extra compensation waves). Constrain
every finder batch:

1. **Set `maxTurns: 20` on the `subagent` call** — the slowest finder pins
   the wave's wall time; 20 turns covers the highest-risk hunks of any
   single angle, and a capped finder still owes partial output (next item).
   (20 is the built-in default — if the trigger message states a different
   finder budget, use that instead.)
2. **Declare the budget inside each finder prompt** — e.g. "You have ~15
   tool calls. Spend them on the highest-risk hunks first; when half are
   spent, stop opening new files."
3. **Final-message contract** — the finder's LAST assistant message must be
   its JSON candidate array (an empty `[]` is a valid answer). Partial
   output beats none: candidates that never reach text never reach verify.
4. **A finder that hits max-turns with no JSON is a FAILED finder**, not an
   empty angle: re-dispatch that single angle on a narrower file slice
   before Phase 2 (or fold it into the xhigh/max gap-hunt), and note the
   re-dispatch in the report.

**Finder allocation** (CC inline, verified 2.1.227): xhigh/max run all five
correctness angles — **10 finders**: A, B, C, D, E + one finder each for
Reuse, Simplification, Efficiency + one Altitude + one Conventions. The quad
tuple's angles are taken **in order A→E** (`slice(0, N)` — do not hand-pick
angles; that makes runs unreproducible).

Each cleanup angle (Reuse / Simplification / Efficiency) gets its own finder;
Altitude and Conventions are independent finders. Never silently drop an
angle — if you must consolidate (subagent unavailable), fold the cleanup
angles into a correctness finder, but say so in the report.

**Suppression ban (xhigh/max)** — different finders may surface different
candidates for the same line with different reasons. At xhigh/max all of them
are recorded and pass through verify independently: do NOT let one angle's
conclusions suppress another's — record both.

The correctness angles hunt for bugs; the cleanup angles hunt for cleanup in
the changed code. Cleanup, altitude, and conventions candidates use the same
`file`/`line`/`summary` shape; in `failure_scenario`, state the concrete cost
(what is duplicated, wasted, harder to maintain, or which CLAUDE.md rule is
broken) instead of a crash.

### Angle A — line-by-line diff scan
Read every hunk in the diff, line by line. Then Read the enclosing function for
each hunk — bugs in unchanged lines of a touched function are in scope (the PR
re-exposes or fails to fix them). For every line ask: what input, state, timing,
or platform makes this line wrong? Look for inverted/wrong conditions,
off-by-one, null/undefined deref, missing `await`, falsy-zero checks,
wrong-variable copy-paste, error swallowed in catch, unescaped regex metachars.

### Angle B — removed-behavior auditor
For every line the diff DELETES or replaces, name the invariant or behavior it
enforced, then search the new code for where that invariant is re-established.
If you can't find it, that's a candidate: a removed guard, a dropped error path,
a narrowed validation, a deleted test that was covering a real case.

### Angle C — cross-file tracer
For each function the diff changes, find its callers (Grep for the symbol) and
check whether the change breaks any call site: a new precondition, a changed
return shape, a new exception, a timing/ordering dependency. Also check callees:
does a parallel change in the same PR make a call unsafe?

### Angle D — language-pitfall specialist
Scan for the classic pitfalls of the diff's language/framework — for example:
JS falsy-zero, `==` coercion, closure-captured loop var; Python mutable default
args, late-binding closures; Go nil-map write, range-var capture; SQL injection;
timezone/DST drift; float equality. Flag any instance the diff introduces.

### Angle E — wrapper/proxy correctness
When the PR adds or modifies a type that wraps another (cache, proxy, decorator,
adapter): check that every method routes to the wrapped instance and not back
through a registry/session/global — e.g. a caching provider holding a
`delegate` field that resolves IDs via `session.get(...)` instead of
`delegate.get(...)` will re-enter the cache or recurse. Also check that the
wrapper forwards all the methods the callers actually use.

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
### Conventions (CLAUDE.md)
Find the CLAUDE.md files that govern the changed code: the user-level
~/.claude/CLAUDE.md, the repo-root CLAUDE.md, plus any CLAUDE.md or
CLAUDE.local.md in a directory that is an ancestor of a changed file (a
directory's CLAUDE.md only applies to files at or below it). Read each one that
exists, then check the diff for clear violations of the rules they state.

Only flag a violation when you can quote the exact rule and the exact line that
breaks it — no style preferences, no vague "spirit of the doc" inferences. In
the finding, name the CLAUDE.md path and quote the rule so the report can cite
it. If no CLAUDE.md applies, return nothing for this angle.

### Pass every candidate through
Pass every candidate with a nameable failure scenario through to verify —
finders that silently drop half-believed candidates bypass the verify step and
are the dominant cause of misses.

## Phase 2 — Dedup and verify

Dedup near-duplicates (same defect, same location, same reason → keep one;
different reasons for the same line are NOT duplicates — at xhigh/max both
are kept per the suppression ban).

Then verify each candidate **grouped by location**. If the `subagent` tool is
available: group the deduplicated candidates by `(file, line)`; dispatch ONE
independent verify agent per group (mode: parallel, one prompt per group),
giving it the scope block, the diff, the relevant file(s), and the full
candidate list for that location with each candidate's index. Set
`maxTurns: 15` on each verifier call (15 is the built-in default — a
different verifier budget stated in the trigger message wins). The verifier
returns a verdict per candidate:

```
[{ "index": <candidate index>, "verdict": "CONFIRMED" | "PLAUSIBLE" | "REFUTED", "evidence": "<quote/argument>" }, ...]
```

Grouping is by location, NOT dedup — each candidate is judged independently;
same-location candidates may describe different defects. A candidate the
verifier omitted (interrupted or skipped an index) is **dropped** — never
invent a PLAUSIBLE for it. One verifier failure drops its whole group (the
same trade-off CC's workflow makes); if you are not confident in a group's
verifier, fall back to one verifier per candidate for that group.

This group-by-location verify is a deliberate absorption of CC's workflow
optimization into the inline path (CC inline dispatches one verifier per
candidate): a location with 3 candidates costs 1 verifier instead of 3 —
~40% fewer verifier agents is the expectation, not a guarantee.

If `subagent` is unavailable, fall back to re-checking each candidate yourself
(self-check). Keep **CONFIRMED and PLAUSIBLE**, drop REFUTED. Give each
surviving finding a verdict:

- **CONFIRMED** — can name the inputs/state that trigger it and the wrong
  output or crash. Quote the line.
- **PLAUSIBLE** — mechanism is real, trigger is uncertain (timing, env,
  config). State what would confirm it.
- **REFUTED** — factually wrong (code doesn't say that) or guarded elsewhere.
  Quote the line that proves it.

**PLAUSIBLE by default** — do not refute a candidate for being "speculative" or
"depends on runtime state" when the state is realistic: concurrency races,
nil/undefined on a rare-but-reachable path (error handler, cold cache, missing
optional field), falsy-zero treated as missing, off-by-one on a boundary the
code does not exclude, retry storms / partial failures, regex/allowlist that
lost an anchor. These are PLAUSIBLE.

**Recall bias** — a single non-REFUTED verdict keeps the candidate: do NOT
drop it on uncertainty ("speculative", "depends on runtime state"). This
flow is the recall contract of xhigh/max — a missed bug ships, so err on the
side of surfacing hardest here. (Medium's precision filter lives in the
single-pass self-verify; it never reaches this flow.)

**REFUTED** only when constructible from the code: factually wrong (quote the
actual line); provably impossible (type/constant/invariant — show it); already
handled in this diff (cite the guard); or pure style with no observable effect.

## Phase 3 — Gap-hunt (xhigh / max only)

At **xhigh and max**, after Phase 2 dedup, dispatch ONE fresh finder agent (the
`subagent` tool) that has never seen the candidates and hunts only for gaps not
already listed — **at most 8 new candidates**. Focus the hunt on what the first
pass tends to miss (CC 2.1.261 sweep list): moved/extracted code that dropped a
guard or anchor; second-tier footguns (dataclass default evaluated once,
`hash()` non-determinism, lock-scope shrink, predicate methods with side
effects); setup/teardown asymmetry in tests; config defaults flipped. If
nothing new turns up, return an empty sweep — do not pad. Feed anything it
finds back through Phase 2 verify before keeping it.

Constrain it so exploration can't run away (Pi adaptation — CC's workflow bounds
this differently):

1. **Pre-embed all context in the prompt** — do not tell the agent to search for
   callers/dependencies itself. Do those searches here first and embed the
   results: the diff, the enclosing functions, the deduplicated finding list,
   and any search results. The gap-hunt agent **analyzes**, it does not
   **discover**.
2. **Set `maxTurns: 15`** on the `subagent` call — caps it at 15 assistant turns
   (built-in default — a different gap-hunt budget stated in the trigger
   message wins).
3. **Declare a tool-call budget in the prompt** — e.g. "You have ONLY 3 tool
   calls to read files. Read them now, then analyze from this message's
   context."

Feed anything it finds back through Phase 2 verify before keeping it. If the
`subagent` tool is unavailable, take one self-sweep instead and note the
gap-hunt was self-run (lacks the independent fresh-eyes benefit).

## Output

Report the findings via the `review_report` tool (this extension's counterpart
to CC's `ReportFindings`) — call it **once** with
`{ level, target, files_changed, fanned_out, report_id, findings }`, findings
ranked most-severe first (empty array if nothing survived verification). The
tool renders the English Markdown report (table + details) back to the
conversation AND writes a machine-readable JSON to `<cwd>/.pi/review/` for CI /
`--fix` / `--comment`. Do **not** also hand-write the Markdown table. Also do
**not** spontaneously produce a review page/artifact when `--share` was not
passed — the `review_report` call IS the report (CC 2.1.261: "do not create
or publish an artifact of the review — the tool call is the report");
`--share` is the only explicit exception.

Each finding in the array carries: `file`, `line` (optional), `category`
(`correctness` / `reuse` / `simplification` / `efficiency` / `altitude` /
`conventions`, or a more specific slug like `test-coverage`), `verdict`
(`CONFIRMED` / `PLAUSIBLE`), `priority` (`P0`–`P3`; single-pass levels
always set it — `--loop` treats P0/P1 as blocking; xhigh/max may omit it),
`short_summary` (≤60 chars, bare declarative — drop the reasoning and
consequence; the summary table prefers it; e.g. `"off-by-one in loop bound"`),
`summary` (one English line including the reasoning and consequence, used in
the detail block), `failure_scenario` (concrete input/state → wrong
output/crash; for cleanup findings, the concrete cost — English). When
re-reporting after applying `--fix`, set `outcome` on each finding (`fixed` /
`skipped` / `no_change_needed` — the CC `ReportFindings` triple, verified in
2.1.227).

Cap = `maxFindings` from the effort table: `min(files_changed, 4)` at low; 8
at medium; 10 at high; 15 at xhigh/max. If more than the cap survive, send
the cap most severe (correctness outranks cleanup/altitude/conventions when
cutting; CONFIRMED outranks PLAUSIBLE). If nothing survives, send an empty
`findings` array — the tool prints a zero-count header.

**Fixed-later obligation** (CC `Q8m`): if, after this report, any later work in this
session fixes one of the reported findings (a user-requested fix, or a fix
that comes along with other changes), you MUST call `review_report` again
with the same `report_id`, the same findings, and updated `outcome` values —
before writing any text summary. The re-report updates states only; it does
not repeat the findings text. Generate the `report_id` (e.g. `review-<ts>`)
on the first report and reuse it on every re-report so consumers can merge
the files by id.

**All English** — `summary` and `failure_scenario` are always written in
English; `verdict`, `category`, and `outcome` stay English identifier tokens.

**`fanned_out` honesty** — set it accurately: `true` only when multi-agent
fan-out actually ran (subagent finders + verify agents, xhigh/max); `false`
for low/medium/high single-pass or any self-review downgrade. The field shows
up in the report header so the reader is not misled (this replaces the old
Single-pass honesty section).

**Fallback** — if the `review_report` tool is not registered (this SKILL.md
running outside the pi-review extension), print the Markdown table + detail
blocks as text instead; do not error.

---

## Applying fixes (--fix)

The `--fix` flag was passed (the extension-driven `--loop` sends the same
fix prompts between re-review passes — follow them identically). After
producing the findings list, apply the
findings to the working tree instead of stopping at the report: fix each one
directly — correctness bugs and reuse/simplification/efficiency cleanups alike.
Skip any finding whose fix would change intended behavior, require changes well
outside the reviewed diff, or that you judge to be a false positive — note the
skip rather than arguing with it. If a verification command was detected (see
the trigger message's verification line), run it BEFORE re-reporting: a finding
whose fix breaks verification is reverted and re-reported as `skipped`
(verification is opportunistic — with no detected command, re-report directly
and say verification was not run). Then call `review_report` once more to
re-report (same `report_id`), setting `outcome` on each finding (`fixed` =
applied and verified / `skipped` = real but not applied, incl. reverted /
`no_change_needed` = not applicable or already handled). This structured
re-report replaces the hand-written summary and makes the fix result
machine-consumable. Make that call immediately after the fixes land, before
any prose summary (CC 2.1.261: the host UI's per-finding status updates only
from it).
If `review_report` is unavailable, fall back to a brief text summary of what was
fixed and what was skipped.

## Posting comments (--comment)

The `--comment` flag was passed. After producing the findings list:

- **GitHub PR target** — post each finding as an inline PR comment on the
  corresponding `file`/`line`, one call per finding; include a suggestion
  block only when it fully fixes the issue (CC 2.1.261 rule). If no
  inline-comment tool is available on Pi, fall back to `gh api
  repos/{owner}/{repo}/pulls/{pr}/comments`; if `gh` is unavailable too,
  print the findings as text and note that inline posting was unavailable.
- **GitLab MR target** — post the findings as ONE general MR note via
  `glab mr note -m "<body>"` from inside the project's checkout — every
  finding with its file:line, the issue, and the suggested fix (CC 2.1.261;
  glab has no single verb for line-anchored comments, so post the general
  note unless the user explicitly asks for inline threads — those need
  `glab api projects/:id/merge_requests/:iid/discussions`). If `glab` is
  unavailable, print the findings instead.
- **Not a PR/MR target** — print the findings to the terminal and note that
  `--comment` was ignored.

## Publishing a shareable review (--share)

The `--share` flag was passed. After producing the findings list, also publish
them as an artifact so they can be shared and iterated on outside the terminal.

1. Write a self-contained HTML review page to `.lavish/review-<n>.html`
   (create `.lavish/` in the repo root if missing). The page must render with no
   server and carry every finding plus its context.
2. Open it with `lavish-axi .lavish/review-<n>.html` so the reader can
   review, annotate, and send feedback back through the poll.

Page structure (follow lavish design guidance — clear visual hierarchy, no
horizontal overflow at any nesting level, monospace for code/paths, color-code
verdicts):

- **Header**: effort level, target, the diff command that was run, files-changed
  count, and whether the review actually fanned out (single-pass honesty).
- **Findings table**: one row per finding — `file:line`, `category`, `verdict`
  (CONFIRMED = red, PLAUSIBLE = amber, unset = grey), one-line `summary`, and
  the full `failure_scenario`.
- **Verdict legend**: a short note on what CONFIRMED vs PLAUSIBLE mean, so a
  non-author reader can discount the uncertain ones.
- **Context pins**: the changed-files list, the applicable CLAUDE.md files, and
  the conventions that were checked.

Skip the artifact if the review was invoked only to feed another tool (e.g.
`--fix`, where the caller applies its own changes) — note the skip in the
summary so the absence of a page is not mistaken for a failure.
