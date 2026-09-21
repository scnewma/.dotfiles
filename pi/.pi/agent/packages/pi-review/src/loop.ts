/**
 * src/loop.ts — /code-review --loop: extension-driven fix→re-review cycles.
 *
 * Ported from the standalone Codex-style review extension's loop fixing
 * (review → blocking-check → fix → re-review, bounded), with one deliberate
 * deviation: the blocking decision reads the structured `review_report` JSON
 * the skill must have written under the project's pi config dir
 * (<cwd>/.pi/review/ by default — CONFIG_DIR_NAME) instead of scraping the
 * assistant's markdown. The tool call is the report, so the JSON is the
 * reliable artifact; markdown scraping was only ever a fallback.
 *
 * Loop shape (single-pass levels only — low/medium/high):
 *   review turn → read newest report → OPEN P0/P1 findings (P0/P1 without a
 *     decided outcome — a fix turn's re-report marks its findings
 *     fixed/skipped/no_change_needed)?
 *     none            → done
 *     some, rounds left → fix prompt (followUp) → idle → re-review prompt → next round
 *     some, rounds spent → stop with a safety-limit note
 * Esc/abort or a missing report stops the loop.
 */
import * as fs from "node:fs";
import * as path from "node:path";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { OUTCOME_VALUES } from "./tools/review_report.ts";

// --- pure helpers (unit-tested) ---------------------------------------------

export const BLOCKING_PRIORITIES = ["P0", "P1"] as const;

/** Strip a --loop flag out of the trailing args; report whether it was there.
 *  Pure — unit-testable. */
export function extractLoopFlag(rest: string): { wantLoop: boolean; rest: string } {
	const tokens = (rest ?? "").split(/\s+/).filter(Boolean);
	const kept = tokens.filter((t) => t !== "--loop");
	return { wantLoop: kept.length !== tokens.length, rest: kept.join(" ") };
}

/** A blocking finding as surfaced back to the fix prompt. */
export interface BlockingFinding {
	file: string;
	line?: number;
	priority: string;
	summary: string;
}

/** Extract P0/P1 findings from a parsed review_report JSON (lenient: any
 *  shape mismatch → no findings rather than a throw). Pure — unit-testable. */
export function blockingFindings(report: unknown): BlockingFinding[] {
	if (!report || typeof report !== "object" || Array.isArray(report)) return [];
	const raw = (report as { findings?: unknown }).findings;
	if (!Array.isArray(raw)) return [];
	const out: BlockingFinding[] = [];
	for (const f of raw) {
		if (!f || typeof f !== "object" || Array.isArray(f)) continue;
		const rec = f as Record<string, unknown>;
		if (rec.priority !== "P0" && rec.priority !== "P1") continue;
		if (typeof rec.file !== "string" || rec.file.length === 0) continue;
		// A decided outcome (a fix turn re-reports its findings with one, per
		// the skill's fixed-later obligation) un-blocks the finding —
		// re-prompting a fixed/skipped/declined finding just burns rounds.
		if (typeof rec.outcome === "string" && (OUTCOME_VALUES as readonly string[]).includes(rec.outcome)) {
			continue;
		}
		out.push({
			file: rec.file,
			line: typeof rec.line === "number" ? rec.line : undefined,
			priority: rec.priority,
			summary: typeof rec.summary === "string" ? rec.summary : "",
		});
	}
	return out;
}

/** Newest `*.json` report under `dir` modified after `sinceMs`, or null.
 *  Missing/unreadable dir → null. Pure — unit-testable. */
export function latestReportFile(dir: string, sinceMs: number): string | null {
	let entries: fs.Dirent[];
	try {
		entries = fs.readdirSync(dir, { withFileTypes: true });
	} catch {
		return null;
	}
	let newest: { file: string; mtime: number } | null = null;
	for (const e of entries) {
		if (!e.isFile() || !e.name.endsWith(".json")) continue;
		const file = path.join(dir, e.name);
		try {
			const mtime = fs.statSync(file).mtimeMs;
			if (mtime <= sinceMs) continue;
			if (!newest || mtime > newest.mtime) newest = { file, mtime };
		} catch {
			/* stat failed — skip this entry */
		}
	}
	return newest?.file ?? null;
}

/** Parse a report JSON file; garbage → null (the loop must not crash on a
 *  half-written or hand-edited file). */
function readReport(file: string): unknown {
	try {
		return JSON.parse(fs.readFileSync(file, "utf8"));
	} catch {
		return null;
	}
}

// --- loop driver -------------------------------------------------------------

/** Minimal session view for the quiescence wait — structural, so
 *  ExtensionCommandContext satisfies it and tests can drive the logic
 *  without a live session. */
export interface QuiescenceView {
	isIdle(): boolean;
	hasPendingMessages(): boolean;
	waitForIdle(): Promise<void>;
	signal?: { aborted: boolean };
}

/** Wait until the session is fully quiescent: nothing running AND nothing
 *  queued. A single `waitForIdle()` is NOT enough — it resolves at the first
 *  idle point even while follow-ups are still queued (a queued message does
 *  not flip `isIdle` until its run actually starts), which is exactly the
 *  window between `sendUserMessage(…, followUp)` and that turn's first
 *  token. Aborts return false; there is no timeout — Esc is the escape
 *  hatch, same as for the bare waitForIdle call. */
export async function waitForQuiescent(session: QuiescenceView): Promise<boolean> {
	for (;;) {
		if (session.signal?.aborted) return false;
		if (!session.isIdle() || session.hasPendingMessages()) {
			await session.waitForIdle();
			continue;
		}
		return true;
	}
}

/** Poll until the review turn has started (idle → busy or a new assistant
 *  message appears), then wait for it to finish. Returns false on timeout
 *  or abort. Mirrors the reference extension's waitForLoopTurnToStart. */
async function waitForTurnSettled(ctx: ExtensionCommandContext, baselineAssistantId: string): Promise<boolean> {
	const START_TIMEOUT_MS = 15_000;
	const POLL_MS = 50;
	const deadline = Date.now() + START_TIMEOUT_MS;

	const lastAssistantId = (): string | undefined => {
		const branch = ctx.sessionManager.getBranch();
		for (let i = branch.length - 1; i >= 0; i--) {
			const entry = branch[i]!;
			if (entry.type === "message" && entry.message.role === "assistant") return entry.id;
		}
		return undefined;
	};

	while (Date.now() < deadline) {
		if (ctx.signal?.aborted) return false;
		const current = lastAssistantId();
		if (!ctx.isIdle() || ctx.hasPendingMessages() || (current && current !== baselineAssistantId)) {
			// Wait past every queued message, not merely to the next idle
			// point — waitForIdle() alone returns inside the gap between
			// queueing a followUp and its run actually starting.
			return waitForQuiescent(ctx);
		}
		await new Promise((resolve) => setTimeout(resolve, POLL_MS));
	}
	return false;
}

function baselineAssistantId(ctx: ExtensionCommandContext): string {
	const branch = ctx.sessionManager.getBranch();
	for (let i = branch.length - 1; i >= 0; i--) {
		const entry = branch[i]!;
		if (entry.type === "message" && entry.message.role === "assistant") return entry.id;
	}
	return "";
}

function fixPrompt(findings: BlockingFinding[]): string {
	const list = findings
		.map((f) => `- \`${f.file}${f.line != null ? `:${f.line}` : ""}\` [${f.priority}] ${f.summary}`)
		.join("\n");
	return [
		"Fix the following blocking findings from the code review you just reported",
		"(full failure scenarios are in the latest report JSON under .pi/review/):",
		"",
		list,
		"",
		"Apply minimal, surgical fixes — no drive-by refactors. Then re-report these",
		"findings via the `review_report` tool with `outcome` set per finding",
		"(fixed / skipped / no_change_needed) and run the verification guidance from",
		"the review trigger message. Never leave the working tree verified-broken.",
	].join("\n");
}

function reReviewPrompt(level: string): string {
	return [
		`Fixes applied. Re-run the code-review SINGLE-PASS flow for effort ${level} now`,
		"— the diff has changed: re-resolve it, re-check the fixed locations and",
		"sweep for regressions or newly exposed issues, then report via the",
		"`review_report` tool again (fresh findings list, empty array if clean).",
	].join("\n");
}

export interface LoopOptions {
	/** The effort level the review runs at (echoed in re-review prompts). */
	level: string;
	/** Max fix→re-review rounds (config maxTurns.loop). */
	passes: number;
	/** Directory the review_report JSON files land in. */
	reviewDir: string;
}

/**
 * Drive the fix→re-review rounds after the FIRST review prompt has already
 * been sent by the dispatcher. Each iteration reads the newest report (the
 * first iteration sees the initial review's report, later ones the previous
 * round's re-review) and sends at most one fix prompt. Runs at most `passes`
 * fix→re-review rounds; the final iteration only reads the last re-review's
 * verdict for the safety-limit message. Returns the number of fix rounds run.
 */
export async function runLoopFixing(
	pi: ExtensionAPI,
	ctx: ExtensionCommandContext,
	options: LoopOptions,
): Promise<number> {
	const { level, passes, reviewDir } = options;
	const baseline = baselineAssistantId(ctx);
	const loopStart = Date.now();

	let fixes = 0;
	for (;;) {
		if (!(await waitForTurnSettled(ctx, baseline))) return fixes;

		const reportFile = latestReportFile(reviewDir, loopStart);
		if (reportFile === null) {
			ctx.ui.notify("/code-review --loop: no review_report JSON found — stopping the loop.", "warning");
			return fixes;
		}
		const findings = blockingFindings(readReport(reportFile));
		if (findings.length === 0) {
			ctx.ui.notify(
				fixes === 0
					? "/code-review --loop: no P0/P1 findings — nothing to fix, loop done."
					: `/code-review --loop: clean after ${fixes} fix round(s) — no open P0/P1 findings remain.`,
				"info",
			);
			return fixes;
		}
		if (fixes === passes) {
			ctx.ui.notify(
				`/code-review --loop: ${findings.length} P0/P1 finding(s) still open after ${passes} fix round(s) — safety limit reached, stopping.`,
				"warning",
			);
			return fixes;
		}

		fixes++;
		ctx.ui.notify(
			`/code-review --loop: ${findings.length} blocking finding(s) — fixing (round ${fixes}/${passes})…`,
			"info",
		);
		await pi.sendUserMessage(fixPrompt(findings), { deliverAs: "followUp" });
		if (!(await waitForTurnSettled(ctx, baseline))) return fixes;
		pi.sendUserMessage(reReviewPrompt(level), { deliverAs: "followUp" });
	}
}
