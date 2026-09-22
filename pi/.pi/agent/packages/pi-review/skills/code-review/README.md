# Code review skill provenance

`SKILL.md` is derived from Claude Code's built-in `/review` skill and adapted for Pi.

## Reverse-engineering process

1. Extracted strings from the Claude Code CLI v2.1.223 binary (`bin/claude.exe`).
2. Located the review prompts, effort-level branching, finder allocations, verifier schema, output contract, and flag behavior.
3. Reconstructed the skill from those strings rather than carrying forward the earlier v2.1.220 reconstruction.
4. Re-verified the result against v2.1.227 at symbol level and v2.1.261 from raw binary bytes.
5. Compared each later version with the reconstructed skill and synced behavioral changes while retaining explicit Pi adaptations in `SKILL.md`.

## Findings by version

### v2.1.223

- `low`, `medium`, and `high` use an in-session single-pass flow.
- `xhigh` and `max` retain finder fan-out and grouped verification.
- `--loop` repeats fix and review until no P0/P1 findings remain, bounded by the configured loop limit.
- Findings include P0–P3 priority and structured outcomes.

### v2.1.227

- Effort tuple: `medium {3,6,8,false}`, `high {3,6,10,false}`, and `xhigh`/`max {5,8,15,true}`.
- Medium/high allocate eight finders; xhigh/max allocate ten.
- Verification groups candidates by file and line, producing `CONFIRMED`, `PLAUSIBLE`, or `REFUTED`.
- The report schema includes `short_summary`, `verdict`, and `outcome`.
- xhigh/max add a fresh gap-hunting pass.
- Cleanup-angle prompt bodies are shared with the simplify skill.

### v2.1.261

- The former background Workflow was removed; phases dispatch inline through the Agent tool.
- Flag-gated effort variants exist upstream; this port keeps a uniform linear flow.
- Cleanup angle bodies remained unchanged except for Altitude's root-cause wording.
- The sweep focus list and GitLab/GitHub comment behavior were updated.
- Unsolicited review artifacts were forbidden upstream; this port retains explicit `--share` behavior.
- Upstream `ultra` remains omitted because it requires Claude cloud access.

## Intentional Pi differences

The operational Pi adaptations, invocation syntax, and prerequisites remain in `SKILL.md` because they affect execution.
