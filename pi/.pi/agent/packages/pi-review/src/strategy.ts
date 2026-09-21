/**
 * src/strategy.ts — declarative parallel-strategy evaluation.
 *
 * v1's decideSimplifyMode hardcoded its thresholds in the command handler;
 * v2 declares them as data in the prompt templates' frontmatter and this
 * module evaluates the declared guards against runtime variables. Same
 * semantics, different authority: editing a template's `parallel-when`
 * block changes the strategy with no code change.
 *
 * Fallback-when-unguarded rules (v1 semantics, kept in code because they
 * are safety invariants, not tuning knobs): unmeasurable context and an
 * unavailable fan-out tool always select single-pass.
 */

/** Guards declared in a template's `parallel-when` frontmatter block. */
export interface ParallelGuards {
	/** Select single-pass when context usage is at or above this fraction. */
	readonly contextBelow?: number;
	/** Select single-pass when the diff reaches this many chars. */
	readonly diffCharsBelow?: number;
}

/** Runtime variables gathered by the dispatcher. */
export interface StrategyRuntime {
	readonly tokens: number | null;
	readonly contextWindow: number;
	readonly diffChars: number;
	/** Whether fan-out tools are registered in this process (the recursion
	 *  guard): single-pass is the only option when false. */
	readonly fanoutAvailable: boolean;
}

export type ReviewVariant = "parallel" | "single-pass";

/**
 * Evaluate the declared guards. Returns the variant plus the reasons that
 * produced it (rendered into the trigger message so the decision stays
 * observable). Pure — unit-testable.
 */
export function selectVariant(
	guards: ParallelGuards,
	runtime: StrategyRuntime,
): { variant: ReviewVariant; reasons: string[] } {
	const { tokens, contextWindow, diffChars, fanoutAvailable } = runtime;
	const reasons: string[] = [];
	// Conservative safety invariant (not a tunable): if we can't measure
	// context (tokens unknown / window 0), don't risk fan-out.
	if (tokens == null || contextWindow <= 0) reasons.push("context usage unknown");
	if (
		guards.contextBelow != null &&
		tokens != null &&
		contextWindow > 0 &&
		tokens / contextWindow >= guards.contextBelow
	)
		reasons.push(`context ${Math.round((tokens / contextWindow) * 100)}% full`);
	if (guards.diffCharsBelow != null && diffChars >= guards.diffCharsBelow)
		reasons.push(`diff too large (${Math.round(diffChars / 1024)} KB ≥ fan-out threshold)`);
	if (!fanoutAvailable) reasons.push("fan-out unavailable in this context (subagent recursion guard)");
	return { variant: reasons.length > 0 ? "single-pass" : "parallel", reasons };
}

/** Parse the `parallel-when` block out of a template's frontmatter map.
 *  Unknown/garbage fields are dropped (silent — garbage becomes absent). */
export function parseGuards(frontmatter: Record<string, unknown>): ParallelGuards {
	const raw = frontmatter["parallel-when"];
	if (!raw || typeof raw !== "object") return {};
	const r = raw as Record<string, unknown>;
	const out: { contextBelow?: number; diffCharsBelow?: number } = {};
	if (typeof r["context-below"] === "number" && r["context-below"] > 0 && r["context-below"] <= 1) {
		out.contextBelow = r["context-below"];
	}
	if (typeof r["diff-chars-below"] === "number" && r["diff-chars-below"] > 0) {
		out.diffCharsBelow = r["diff-chars-below"];
	}
	return out;
}
