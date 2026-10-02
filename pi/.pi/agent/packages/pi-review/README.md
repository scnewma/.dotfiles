# pi-review (native trial fork)

Credit: local fork of `@fyeeme/pi-review` v2.1.0 by fyeeme (MIT, see LICENSE), derived from Claude Code review/simplify methodology. Reports remain English. Reviews do not edit, post comments or publish pages unless explicitly authorized by their flags or the extension's loop fix prompt. This trial replaces the bundled fan-out backend with separately installed nicobailon/pi-subagents, pinned in this profile at `5da808168c097ea0d56616644773efe0f6f87938`.

The entry registers only `review_report`, `/code-review` and `/code-simplify`. Only one executable agent, `review-runner`, is discovered through `pi.subagents.agents: ["./agents"]`. The twelve original specialist policies live unchanged in private `roles/`, shipped but not discovered. Dispatcher workflows JSON-inject their bodies into individual role tasks; keys remain private angle/group IDs, while every native agent value is `review-runner`. Direct skill usage reads the needed private policy paths before task assembly. No second subagent tool is registered here.

- `/code-review [low|medium|high|xhigh|max] [--fix] [--loop] [--comment] [--share] [target]`: low/medium/high remain single-pass with existing self-verification; xhigh/max run ten finders, grouped independent verification, then a fresh gap-hunt and verification. Sticky effort and parent fix/report behavior remain.
- `/code-simplify [target]`: four cleaners when context <80%, diff <400k and native tools are available, otherwise inline. Parent snapshot/apply/verify/rollback/report is unchanged.

Children explicitly use the parent's qualified model and current thinking (including off), fresh context, no isolation, no missions, inspection builtin tool allowlist (including unrestricted bash), read-only instructions, no ambient extensions and no nested delegation. Findings require a bare declarative `short_summary` of at most 60 characters. Foreground native workflows await ordered results and require structured_output. Failed children are missing coverage, not empty findings.

## Configuration

Global `<agentDir>/pi-review.json`, overridden by `<cwd>/.pi/pi-review.json`, read per invocation:

```json
{
  "toolCalls": {"finder":20,"verifier":15,"gapHunt":20,"simplify":15},
  "timeoutMs":1800000,
  "maxTurns":{"loop":3}
}
```

Positive integers only. Child soft nudges occur at half the hard tool-call budget. Native `toolBudget.block` explicitly lists read/grep/find/ls/bash; structured_output is never blocked. Deadline defaults to 30 minutes. Legacy maxTurns.subagent/verifier/gapHunt/simplify warn and are ignored, never reinterpreted as calls. maxTurns.loop still means fix/re-review rounds, preserving project defaults.

## Runnable checks

```sh
bun install --ignore-scripts
bun test
bun run typecheck
bun run format
bun run lint
```

The native smoke uses the separately installed trial backend at its profile path, SDK faux provider, an isolated temporary agent directory, empty credential paths and no model network. It checks one native child submits structured output with restricted tools. Unit tests cover availability, model/thinking, config, bounded short-summary schemas and lossless JSON injection of all twelve policies (including quotes/newlines/backticks). A read-only discovery test checks exactly one manifest-owned runner and no old role agents against the actual trial profile settings; native discovery requires the package entry `./packages/pi-review` or an absolute path, not the bare relative `packages/pi-review`. These are not live-model quality tests; run the parent-controlled live trial separately in a disposable fixture. No production profile settings or original package are changed by this fork.
