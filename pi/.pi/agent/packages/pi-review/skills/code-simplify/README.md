# Code simplify skill provenance

`SKILL.md` is derived from Claude Code's built-in `/simplify` skill and adapted for Pi.

## Reverse-engineering process

1. Reconstructed the first version from Claude Code CLI v2.1.220.
2. Extracted strings from the v2.1.223 binary and verified the skill body, Phase 0, four cleanup angles, Phase 2, and parallel/single-pass split.
3. Inspected v2.1.227 symbols to identify the command registration, mode guard, mode-body templates, shared prompt variables, concurrency limit, and agent turn limit.
4. Re-verified the two mode bodies and cleanup-angle prompts against v2.1.261 raw binary bytes.
5. Synced the later Altitude wording while preserving Pi-specific dispatch behavior in `SKILL.md`.

## Findings

- Claude Code registers `/simplify` for inline execution and asks the model to launch all four cleanup agents concurrently.
- Its mode guard chooses single-pass execution when maximum agent depth is reached or the Agent tool is unavailable.
- The parallel and single-pass templates share the same four cleanup-angle bodies as the review skill.
- The upstream defaults observed in v2.1.227 were 20 concurrent subagents and 50 turns per forked agent.
- v2.1.261 retained the mode bodies and Phase 2 behavior; only the Altitude angle's root-cause wording changed.

## Intentional Pi differences

The operational Pi adaptations, invocation syntax, and prerequisites remain in `SKILL.md` because they affect execution.
