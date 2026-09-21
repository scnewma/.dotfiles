/**
 * pi-review v2 — extension entry.
 *
 * Sandwich architecture (see openspec change subagent-sandwich-refactor):
 *
 *   Skills  skills/code-review, skills/code-simplify — review methodology,
 *           registered natively via the pi manifest (`pi.skills`); they
 *           reference capabilities by stable tool/agent names only.
 *   Prompts prompts/ — the orchestration strategy as data: parallel-when
 *           guards in frontmatter, phases/agents in the body. Rendered by
 *           the generic dispatcher (src/dispatch.ts) which gathers the
 *           deterministic runtime variables (diff, context usage, sticky
 *           effort) and picks the template variant.
 *   Agents  agents/ — the review angles materialized as subagent definitions
 *           (finder-*, cleaner-*, verifier, gap-hunter) invoked via the
 *           `subagent` tool.
 *   Plugin  this entry composes @fyeeme/pi-subagents' extension factory
 *           (subagent tool + agent UI + /agents, from the SAME dependency
 *           copy this package's imports resolve to — version-pinned, no
 *           manifest path wiring and no separate install step), registers
 *           this package's agents directory as a discovery source, and adds
 *           the `review_report` structured findings sink plus the
 *           /code-review and /code-simplify dispatcher commands.
 *
 * The `subagent` tool registers exactly once per process: if pi-subagents
 * is ALSO installed standalone (or another consumer composes it), the guard
 * in pi-subagents' index.ts keeps ownership single (pi fatal-exits on
 * the same tool name in two extensions' maps).
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import piSubagents, { addAgentDir } from "@fyeeme/pi-subagents";
import { fileURLToPath } from "node:url";
import * as path from "node:path";
import { registerDispatcher } from "./src/dispatch.ts";
import { reviewReportTool } from "./src/tools/review_report.ts";

export default function (pi: ExtensionAPI): void {
	// subagent tool + live agent UI, from this package's pinned dependency
	// copy. <pkg>/index.ts → sibling agents/ dir registers the review roles.
	piSubagents(pi);
	addAgentDir(path.join(path.dirname(fileURLToPath(import.meta.url)), "agents"));

	pi.registerTool(reviewReportTool);
	registerDispatcher(pi);
}
