/**
 * src/config.ts — file-based turn-budget configuration, mirroring the
 * pi-subagents `pi-subagent.json` pattern (read-only, lenient, two layers
 * with project overriding global):
 *
 *   - Global:  <agentDir>/pi-review.json   (user-wide defaults)
 *   - Project: <cwd>/.pi/pi-review.json    (overrides global on load)
 *
 * Schema (all keys optional):
 *
 *   {
 *     "maxTurns": {
 *       "subagent": 20,   // per-call budget for each /code-review finder batch (xhigh/max)
 *       "gapHunt":  15,   // budget for the /code-review Phase 3 gap-hunter (xhigh/max)
 *       "simplify": 15,   // budget for each /code-simplify PARALLEL cleaner agent
 *       "loop": 3         // --loop fix→re-review round cap (single-pass levels)
 *     }
 *   }
 *
 * The defaults here are the numbers the bundled prompts and skills were
 * written with (finder 20 / gap-hunt 15 / simplify 15 / loop 3). With no config file
 * — or with any key absent or invalid — the rendered instructions carry
 * exactly those numbers, so absence of configuration changes nothing.
 *
 * Read at command time (like pi-subagents' maxConcurrency): an edited file
 * takes effect on the next /code-review or /code-simplify without a restart. Malformed
 * files are ignored with a stderr warning (never fatal); unknown/garbage
 * fields are dropped on read.
 */
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

/** Settings file name (both layers). */
const CONFIG_FILE = "pi-review.json";

/** The dispatchable turn budgets, keyed by what they throttle. */
export interface TurnBudgets {
	/** `maxTurns` set on each /code-review finder-batch `subagent` call. */
	subagent: number;
	/** `maxTurns` set on each /code-review Phase 2 verifier `subagent` call. */
	verifier: number;
	/** `maxTurns` set on the /code-review Phase 3 gap-hunt `subagent` call. */
	gapHunt: number;
	/** `maxTurns` set on each /code-simplify PARALLEL cleaner `subagent` call. */
	simplify: number;
	/** Max fix→re-review rounds when /code-review runs with --loop. */
	loop: number;
}

/** Built-in budgets — identical to the literals in prompts/ and skills/. */
export const DEFAULT_TURN_BUDGETS: TurnBudgets = {
	subagent: 20,
	verifier: 15,
	gapHunt: 15,
	simplify: 15,
	loop: 3,
};

function globalPath(): string {
	return join(getAgentDir(), CONFIG_FILE);
}

function projectPath(cwd: string): string {
	return join(cwd, ".pi", CONFIG_FILE);
}

/** Positive integers only; anything else (floats, 0, negatives, strings) is
 *  dropped so the built-in default applies. */
function sanitizeBudget(value: unknown): number | undefined {
	return typeof value === "number" && Number.isInteger(value) && value >= 1 ? value : undefined;
}

/** Read one config file; missing file → {} (the normal case, silent).
 *  Unparseable file → warn + {}. Unknown fields are dropped. */
function readBudgetsFile(path: string): Partial<TurnBudgets> {
	if (!existsSync(path)) return {};
	try {
		const raw: unknown = JSON.parse(readFileSync(path, "utf8"));
		if (!raw || typeof raw !== "object") return {};
		const maxTurns = (raw as Record<string, unknown>).maxTurns;
		const mt = maxTurns && typeof maxTurns === "object" ? (maxTurns as Record<string, unknown>) : {};
		const out: Partial<TurnBudgets> = {};
		const subagent = sanitizeBudget(mt.subagent);
		if (subagent !== undefined) out.subagent = subagent;
		const verifier = sanitizeBudget(mt.verifier);
		if (verifier !== undefined) out.verifier = verifier;
		const gapHunt = sanitizeBudget(mt.gapHunt);
		if (gapHunt !== undefined) out.gapHunt = gapHunt;
		const simplify = sanitizeBudget(mt.simplify);
		if (simplify !== undefined) out.simplify = simplify;
		const loop = sanitizeBudget(mt.loop);
		if (loop !== undefined) out.loop = loop;
		return out;
	} catch (err) {
		const reason = err instanceof Error ? err.message : String(err);
		console.warn(`[pi-review] Ignoring malformed config at ${path}: ${reason}`);
		return {};
	}
}

/** Load the effective turn budgets: built-in defaults ← global ← project. */
export function loadTurnBudgets(cwd: string = process.cwd()): TurnBudgets {
	return {
		...DEFAULT_TURN_BUDGETS,
		...readBudgetsFile(globalPath()),
		...readBudgetsFile(projectPath(cwd)),
	};
}
