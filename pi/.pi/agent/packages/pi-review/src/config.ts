/** Native tool-call budgets and deadlines; legacy maxTurns.loop remains rounds. */
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

export interface Budgets {
	finder: number;
	verifier: number;
	gapHunt: number;
	simplify: number;
	timeoutMs: number;
	loop: number;
}
export const DEFAULT_BUDGETS: Budgets = {
	finder: 20,
	verifier: 15,
	gapHunt: 20,
	simplify: 15,
	timeoutMs: 1800000,
	loop: 3,
};
function positive(value: unknown): value is number {
	return typeof value === "number" && Number.isSafeInteger(value) && value > 0;
}
function read(path: string): Partial<Budgets> {
	if (!existsSync(path)) return {};
	try {
		const raw = JSON.parse(readFileSync(path, "utf8"));
		if (!raw || typeof raw !== "object" || Array.isArray(raw)) return {};
		const out: Partial<Budgets> = {};
		for (const key of ["subagent", "verifier", "gapHunt", "simplify"]) {
			if (raw.maxTurns && key in raw.maxTurns)
				console.warn(
					`[pi-review] ${path}: legacy maxTurns.${key} ignored; configure toolCalls and timeoutMs explicitly (turns are not calls).`,
				);
		}
		for (const key of ["finder", "verifier", "gapHunt", "simplify"] as const)
			if (positive(raw.toolCalls?.[key])) out[key] = raw.toolCalls[key];
		if (positive(raw.timeoutMs)) out.timeoutMs = raw.timeoutMs;
		if (positive(raw.maxTurns?.loop)) out.loop = raw.maxTurns.loop;
		return out;
	} catch (error) {
		console.warn(
			`[pi-review] Ignoring malformed config at ${path}: ${String(error)}`,
		);
		return {};
	}
}
export function loadBudgets(
	cwd = process.cwd(),
	agentDir = getAgentDir(),
): Budgets {
	return {
		...DEFAULT_BUDGETS,
		...read(join(agentDir, "pi-review.json")),
		...read(join(cwd, ".pi", "pi-review.json")),
	};
}
