/**
 * src/tools/review_report.ts — the `review_report` LLM tool.
 *
 * Structured findings sink for the code-review skill — Pi's counterpart to
 * CC's native `ReportFindings` tool (verified in CC v2.1.226 binary: "Report
 * code-review findings as a typed list so the host UI can render them"). Pi has
 * no host finding-renderer, so this tool does double duty: it renders a tidy
 * English Markdown report (table + details) back to the conversation AND writes
 * a machine-readable JSON (findings + level + outcome) to
 * `<cwd>/<CONFIG_DIR_NAME>/review/<id>.json` so CI / --fix / --comment can
 * consume it.
 *
 * `verdict` (CONFIRMED/PLAUSIBLE) and `outcome` (fixed/skipped/no_change_needed)
 * enums follow the CC ReportFindings shape — values verified against the CC
 * v2.1.227 binary (consistent across 2.1.223/226/227). REFUTED is deliberately
 * absent: the verify flow drops it before reporting. The tool entry also
 * normalizes stray invalid values (drop the finding / coerce to skipped) rather
 * than failing the whole call.
 */
import { defineTool, getMarkdownTheme, CONFIG_DIR_NAME } from "@earendil-works/pi-coding-agent";
import { Markdown } from "@earendil-works/pi-tui";
import { StringEnum } from "@earendil-works/pi-ai";
import { type Static, Type } from "typebox";
import * as fs from "node:fs";
import { execFile } from "node:child_process";
import * as path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

// --- enums following the CC ReportFindings shape ----------------------------
// Value domains taken from CC v2.1.227 bin/claude.exe (ReportFindings schema).
// The two verdicts and three outcomes are identical across 2.1.223/226/227.

const VERDICT_VALUES = ["CONFIRMED", "PLAUSIBLE"] as const;
const Verdict = StringEnum(VERDICT_VALUES);

/** CC ReportFindings `outcome`, three values (verified in the 2.1.227 binary). Updated on a fixed-later re-report. */
export const OUTCOME_VALUES = ["fixed", "skipped", "no_change_needed"] as const;
const Outcome = StringEnum(OUTCOME_VALUES);

/** --loop blocking threshold: P0/P1 trigger a fix -> re-review round (P2/P3 are report-only). */
const PRIORITY_VALUES = ["P0", "P1", "P2", "P3"] as const;
const Priority = StringEnum(PRIORITY_VALUES, {
	description:
		"Priority P0 (blocking, fix now) / P1 (high) / P2 (medium) / P3 (low). --loop treats P0/P1 as blocking; omitted counts as P2.",
});

// Referenced by the SKILL-schema sync test (drift guard: the SKILL flow contract must match these constants).
export { PRIORITY_VALUES, VERDICT_VALUES };

const Level = StringEnum([
	"low",
	"medium",
	"high",
	"xhigh",
	"max",
	// simplify reuses this tool for structured apply-outcome reporting
	// (harden-code-simplify). Not a review effort level — carries no verdict.
	"simplify",
] as const);

// --- schema -----------------------------------------------------------------

const FindingParams = Type.Object({
	file: Type.String({ description: "File path relative to the repo root." }),
	line: Type.Optional(Type.Number({ description: "Line number (1-based). Omit for a file-level finding." })),
	category: Type.String({
		description:
			"Slug of the angle that produced the finding: correctness / reuse / simplification / efficiency / altitude / conventions (or something more specific like test-coverage).",
	}),
	verdict: Type.Optional(Verdict),
	priority: Type.Optional(Priority),
	short_summary: Type.Optional(
		Type.String({
			description:
				"A ≤60-character bare declarative label (drop the reasoning and consequence). The summary table prefers it; the detail block still shows the full summary. Required by the flow (CC output-template contract), optional in the schema (matching the CC tool schema). English.",
		}),
	),
	summary: Type.String({ description: "One-line explanation (≤80 words), doubling as a compact label. English." }),
	failure_scenario: Type.String({
		description:
			"Concrete scenario: input/state -> wrong output/crash. For cleanup findings, state the concrete cost (what is duplicated, wasted, harder to maintain, or which rule is broken). English.",
	}),
	outcome: Type.Optional(Outcome),
});

const ReviewReportParams = Type.Object({
	level: Level,
	target: Type.Optional(Type.String({ description: "Review target (diff command/range, or PR/branch/path), shown in the report header." })),
	files_changed: Type.Optional(Type.Number({ description: "Number of changed files, shown in the report header." })),
	fanned_out: Type.Optional(
		Type.Boolean({ description: "Whether multi-agent fan-out actually ran (single-pass honesty). false/omitted means a single-pass self-review." }),
	),
	findings: Type.Array(FindingParams, {
		description: "Verified, deduplicated findings ranked most-severe first. An empty array means nothing survived.",
	}),
	report_id: Type.Optional(
		Type.String({
			description:
				"Report id (e.g. review-<ts>). Generate it on the first report; pass the same id on a fixed-later re-report so consumers merge by id, the latest generatedAt for an id winning.",
		}),
	),
});

interface ReviewReportDetails {
	level: string;
	findingsCount: number;
	/** Path of the structured JSON on disk; null if the write failed (the rendered report is still returned). */
	outFile: string | null;
	reportId: string | null;
}

/**
 * Loose finding shape for the execute entry point: direct calls that bypass schema
 * validation (e.g. unit tests) may still carry the old five outcomes or the retired REFUTED verdict.
 */
type LooseFinding = {
	file: string;
	line?: number;
	category: string;
	verdict?: string;
	priority?: string;
	short_summary?: string;
	summary: string;
	failure_scenario: string;
	outcome?: string;
};

/**
 * Sanitize one finding: an illegal verdict (including the retired REFUTED) returns null (dropped);
 * an illegal outcome is normalized to skipped with a note carrying the original value. The schema
 * stays strict; sanitizing happens before schema validation.
 */
function sanitizeFinding(f: LooseFinding): { f: LooseFinding; note?: string } | null {
	if (f.verdict !== undefined && !(VERDICT_VALUES as readonly string[]).includes(f.verdict)) return null;
	let outcome = f.outcome;
	let note: string | undefined;
	if (outcome !== undefined && !(OUTCOME_VALUES as readonly string[]).includes(outcome)) {
		note = `(outcome "${outcome}" is invalid; normalized to skipped)`;
		outcome = "skipped";
	}
	// An invalid priority is dropped silently (finding becomes unprioritized) without killing the finding.
	const priority =
		f.priority !== undefined && (PRIORITY_VALUES as readonly string[]).includes(f.priority) ? f.priority : undefined;
	return { f: { ...f, outcome, priority }, note };
}

/**
 * Sanitize a batch; notes are keyed by post-sanitize array index (used by the render layer).
 * Shared by `prepareArguments` (primary defense, before schema validation) and the `execute`
 * entry point (belt-and-braces for direct calls that bypass prepareArguments), so model-path
 * illegal values are cleaned before execute and validateToolArguments never throws away a
 * whole report over an edge value.
 */
function normalizeFindings(findings: LooseFinding[]): { findings: LooseFinding[]; notes: Map<number, string> } {
	const out: LooseFinding[] = [];
	const notes = new Map<number, string>();
	for (const raw of findings) {
		const s = sanitizeFinding(raw);
		if (!s) continue;
		const idx = out.length;
		out.push(s.f);
		if (s.note) notes.set(idx, s.note);
	}
	return { findings: out, notes };
}

// --- render -----------------------------------------------------------------

interface FindingInput {
	file: string;
	line?: number;
	category: string;
	verdict?: string;
	priority?: string;
	short_summary?: string;
	summary: string;
	failure_scenario: string;
	outcome?: string;
	/** Normalization note (e.g. an illegal outcome being coerced); rendered only into the detail block. */
	note?: string;
}
interface ReportInput {
	level: string;
	target?: string;
	files_changed?: number;
	fanned_out?: boolean;
	reportId?: string;
	findings: FindingInput[];
}

function fmtLoc(f: { file: string; line?: number }): string {
	return f.line != null ? `${f.file}:${f.line}` : f.file;
}

/** Escape a value for a GFM table cell: backslash-escape pipes and collapse
 *  newlines. Free-text fields (summary/category/verdict/loc) are LLM-provided
 *  and routinely contain `||`, `|`, regex, or shell pipes that would otherwise
 *  split the row into extra columns and break the whole summary table. */
function escapeCell(v: string): string {
	return v.replace(/\|/g, "\\|").replace(/\r?\n/g, " ");
}

/** Render the English Markdown report (header line + summary table + detail blocks). */
function renderReport(p: ReportInput): string {
	const lines: string[] = [];
	const fanLabel = p.fanned_out === true ? "fanned out" : p.fanned_out === false ? "single-pass self-review" : "fan-out unstated";
	const targetStr = (p.target ?? "(whole diff)").replace(/`/g, "\\`"); // backtick inside the inline-code cell would close it early
	const filesStr = p.files_changed != null ? `${p.files_changed} file${p.files_changed === 1 ? "" : "s"} changed` : "files changed unstated";
	const idStr = p.reportId ? ` · report \`${escapeCell(p.reportId)}\`` : "";
	lines.push(`\`${p.level}\` · \`${targetStr}\` · ${filesStr} · ${p.findings.length} finding${p.findings.length === 1 ? "" : "s"} · ${fanLabel}${idStr}`);
	lines.push("");

	if (p.findings.length === 0) {
		lines.push("(No findings survived verification.)");
		return lines.join("\n");
	}

	lines.push("| # | Verdict | Category | Location | Summary |");
	lines.push("|---|------|------|------|------|");
	for (let i = 0; i < p.findings.length; i++) {
		const f = p.findings[i]!;
		const verdictCell = [f.priority, f.verdict].filter(Boolean).join(" · ");
		lines.push(`| ${i + 1} | ${escapeCell(verdictCell)} | ${escapeCell(f.category)} | ${escapeCell(fmtLoc(f))} | ${escapeCell(f.short_summary ?? f.summary)} |`);
	}
	lines.push("");
	lines.push("**Details**");
	lines.push("");
	p.findings.forEach((f, i) => {
		const v = [f.priority, f.verdict].filter(Boolean).length > 0 ? ` *(${[f.priority, f.verdict].filter(Boolean).join(" · ")})*` : "";
		const out = f.outcome ? `\nOutcome: \`${f.outcome}\`` : "";
		const note = f.note ? `\n${f.note}` : "";
		lines.push(`**${i + 1}. ${fmtLoc(f)} — ${f.category}**${v}`);
		lines.push(`Summary: ${f.summary}`);
		lines.push(`Failure scenario: ${f.failure_scenario}${out}${note}`);
		lines.push("");
	});
	return lines.join("\n").trimEnd();
}

// --- tool -------------------------------------------------------------------

async function ignoreReviewReports(cwd: string): Promise<void> {
	const { stdout } = await execFileAsync(
		"git",
		["rev-parse", "--path-format=absolute", "--git-path", "info/exclude"],
		{ cwd, encoding: "utf8" },
	);
	const excludePath = stdout.trim();
	if (!excludePath) return;

	let contents = "";
	try {
		contents = await fs.promises.readFile(excludePath, "utf8");
	} catch (err) {
		if ((err as NodeJS.ErrnoException).code !== "ENOENT") throw err;
	}

	const pattern = `/${CONFIG_DIR_NAME}/review/`;
	if (contents.split(/\r?\n/).includes(pattern)) return;

	await fs.promises.mkdir(path.dirname(excludePath), { recursive: true });
	const separator = contents.length > 0 && !contents.endsWith("\n") ? "\n" : "";
	await fs.promises.appendFile(excludePath, `${separator}${pattern}\n`, "utf8");
}

export const reviewReportTool = defineTool<typeof ReviewReportParams, ReviewReportDetails>({
	name: "review_report",
	label: "Report review findings",
	description:
		"Report code-review findings as a typed list — Pi's counterpart to CC's ReportFindings. Use this only when the active code-review instructions tell you to report findings with this tool. Call it once with the verified findings ranked most-severe first (empty array if nothing survived verification) and do not also print the findings as text — the tool renders a tidy English Markdown report back to the conversation AND writes a machine-readable JSON to the project's pi config dir (CONFIG_DIR_NAME, typically `.pi`) under review/ for CI / --fix / --comment. When re-reporting after applying fixes, set `outcome` on each finding. All finding text must be in English.",
	promptSnippet: "review_report — report structured code-review findings (renders Markdown + writes JSON for CI)",
	promptGuidelines: [
		"After verify + dedup, call `review_report` once with { level, findings } (most-severe first; empty array if none survived). Do not also hand-write the Markdown table — this tool renders it.",
		"On re-report after --fix, set each finding's `outcome` (fixed / skipped / no_change_needed).",
		"Use `review_report` only when the code-review skill instructs reporting findings; otherwise follow the active output format.",
	],
	parameters: ReviewReportParams,

	// Primary defense: sanitize illegal values before schema validation (on the model path a
	// validation failure throws and the tool never runs, so execute's guard is unreachable there).
	// Returns a schema-conforming object: illegal-verdict findings dropped, illegal outcomes
	// normalized to skipped; notes are regenerated in execute (the schema object has no note field).
	prepareArguments(args) {
		if (typeof args !== "object" || args === null) return args as Static<typeof ReviewReportParams>;
		const raw = args as { findings?: unknown };
		if (!Array.isArray(raw.findings)) return args as Static<typeof ReviewReportParams>;
		const { findings } = normalizeFindings(raw.findings as unknown as LooseFinding[]);
		return { ...raw, findings } as Static<typeof ReviewReportParams>;
	},

	async execute(toolCallId, params, _signal, _onUpdate, ctx) {
		// Belt-and-braces normalize: direct calls bypassing prepareArguments (e.g. unit tests) may
		// carry the old five outcomes or the retired REFUTED verdict. Normalize instead of rejecting
		// the whole report, so render and disk only ever contain legal values.
		const { findings: cleaned, notes } = normalizeFindings(
			(params.findings ?? []) as unknown as LooseFinding[],
		);
		const findings: FindingInput[] = cleaned.map((f, i) => ({ ...f, note: notes.get(i) }));

		const report = renderReport({
			level: params.level,
			target: params.target,
			files_changed: params.files_changed,
			fanned_out: params.fanned_out,
			reportId: params.report_id,
			findings,
		});

		let outFile: string | null = null;
		let writeError: string | null = null;
		const now = new Date();
		try {
			await ignoreReviewReports(ctx.cwd);
		} catch {}
		try {
			const dir = path.join(ctx.cwd, CONFIG_DIR_NAME, "review");
			await fs.promises.mkdir(dir, { recursive: true });
			const safeId = toolCallId.replace(/[^\w.-]+/g, "_");
			const ts = now.toISOString().replace(/[:.]/g, "-");
			const fp = path.join(dir, `${ts}-${safeId}.json`);
			await fs.promises.writeFile(
				fp,
				JSON.stringify(
					{
						level: params.level,
						reportId: params.report_id ?? null,
						target: params.target ?? null,
						filesChanged: params.files_changed ?? null,
						fannedOut: params.fanned_out ?? null,
						generatedAt: now.toISOString(),
						findings,
					},
					null,
					2,
				),
				{ encoding: "utf-8", mode: 0o600 },
			);
			outFile = fp;
		} catch (err) {
			/* A failed write is non-blocking: still return the rendered report, with the error for CI/--fix triage. */
			writeError = err instanceof Error ? err.message : String(err);
		}

		const tail = outFile
			? `\n\n[Structured findings written to \`${outFile}\`]`
			: `\n\n[Failed to write structured findings (${writeError ?? "unknown cause"}); rendered report only]`;
		const details: ReviewReportDetails = {
			level: params.level,
			findingsCount: findings.length,
			outFile,
			reportId: params.report_id ?? null,
		};
		return {
			content: [{ type: "text" as const, text: report + tail }],
			details,
		};
	},

	// Render the returned Markdown report through pi's width-aware Markdown component
	// (the same path assistant text takes), not the plain-Text tool-result fallback that
	// renderer-less extension tools get. Without this, the GFM table is shown as raw
	// `|`/`|---|` wrapped to terminal width — no borders, no alignment.
	// tool-execution.ts wraps renderResult in try/catch and falls back to plain Text on
	// throw, so a failure here degrades to the pre-change behavior rather than erroring.
	renderResult(result, _options, _theme, _context) {
		const text = result.content
			.filter((c): c is Extract<(typeof result.content)[number], { type: "text" }> => c.type === "text")
			.map((c) => c.text)
			.join("\n");
		return new Markdown(text, 0, 0, getMarkdownTheme());
	},
});
