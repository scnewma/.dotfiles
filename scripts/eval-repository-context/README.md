# Repository context eval

Run with Bun, Pi, and authenticated Opus/Sonnet models:

```sh
bun scripts/eval-repository-context/run.ts
```

Use specific models and repeat each case:

```sh
VCS_EVAL_REPEATS=3 bun scripts/eval-repository-context/run.ts anthropic/claude-opus-5-5 anthropic/claude-sonnet-5-5 > /tmp/repository-context-eval.jsonl
```

The default run makes 24 model requests. Model calls incur inference costs.

## Cases

- jj-only repository: summarize recent changes.
- Colocated jj/Git repository: summarize uncommitted changes and the latest completed change.
- Git-only repository: summarize recent changes.
- Nested directory in a colocated jj repository: summarize uncommitted changes and the latest completed change.

Each case compares three conditions:

- `baseline`: no VCS hint in AGENTS.md or repository context.
- `rule`: the old conditional AGENTS.md rule.
- `context`: the extension's current repository-context text, with no AGENTS.md VCS rule.

Repeats alternate the two questions. Personal instructions, skills, project configuration, and other extensions are disabled.

All repository paths and markers are synthetic. No fixture directories are created or inspected. Tools are inert, every request is blocked, and runs stop after the first assistant response. Only temporary result files are written; they are removed when the runner finishes. Pi still reads its installation and authentication configuration.

## Results

Each JSONL row records the model, case, condition, proposed tool calls, and outcome:

- `direct`: only the expected VCS is requested, with no detected discovery probe.
- `wrong-vcs`: another VCS is requested, even as a fallback in the same batch.
- `discovery`: file reads, marker checks, or other preliminary investigation.
- `no-tool`: no tool was requested.

The last row contains totals per model and condition. Provider errors fail the run rather than counting as behavioral outcomes.

Compare all three conditions for each case and repeat across models before removing the extension. Treat discovery as startup overhead, not a VCS violation. If baseline runs consistently avoid the wrong VCS, consider whether either hint is needed. If rule-only runs avoid the wrong VCS, consider whether skipping discovery still warrants the extension. Review raw commands for conditional branches and complex shell expressions.

This evaluates first-action behavior, not marker detection, command validity, task completion, or real repository access. No model tools execute.
