/**
 * src/diff.ts — deterministic diff resolution for the review prompts (v1
 * semantics, relocated verbatim from src/commands/code-simplify.ts).
 *
 * The candidate ladder widens "changed code" as far as it resolves:
 * upstream merge-base → HEAD worktree → staged-fresh → unstaged-fresh, and
 * covers git submodules (a target inside a submodule resolves to the
 * submodule's own root, so the real changes are reviewed instead of a dirty
 * pointer). Pure functions — unit-testable, injected GitRunner.
 */
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import * as fs from "node:fs";
import * as path from "node:path";

/** Soft cap on the changed-file list in the context package (see buildContextPackage). */
export const CONTEXT_PACKAGE_MAX_FILES = 200;

/**
 * Walk up from `from` to the nearest directory containing `.git` (a directory
 * or a submodule pointer file). Returns that root or null.
 */
export function findGitRoot(from: string): string | null {
	let dir = path.resolve(from);
	for (;;) {
		if (fs.existsSync(path.join(dir, ".git"))) return dir;
		const parent = path.dirname(dir);
		if (parent === dir) return null;
		dir = parent;
	}
}

/** Normalize a /code-simplify target argument: trimmed, with an optional
 *  path-prefix `@` PRESERVED — a real directory may itself start with `@`
 *  (e.g. node_modules/@scope/pkg), so the resolver tries the literal path
 *  first and only falls back to the @-stripped form when it does not exist. */
function normalizeTarget(target: string | undefined): string {
	return (target ?? "").trim();
}

/** Resolve the diff scope for a code-review/code-simplify target. Pure — unit-testable.
 *
 *  - target absent/unresolvable → the nearest git root of `cwd`, full diff.
 *  - target is a path → its nearest git root; the relative path inside that
 *    root is the diff scope. Crucially this covers git SUBMODULES: a target
 *    like `@packages/extensions/pi-review/` resolves to the submodule's own
 *    git root, so the real changes inside it (invisible to the parent repo's
 *    `git diff`) are reviewed instead of a dirty-submodule pointer.
 *  - target at the git root itself (e.g. the whole submodule) → full diff.
 * Returns null when no git root exists.
 */
export function resolveDiffScope(
	cwd: string,
	target: string | undefined,
): { gitRoot: string; relPath: string | null } | null {
	const raw = normalizeTarget(target);
	// The `@`-prefix path convention (`@packages/extensions/pi-review/`): try
	// the literal path FIRST (a real directory may itself start with `@`, e.g.
	// node_modules/@scope/pkg) and only fall back to the @-stripped form.
	let abs: string | null = null;
	if (raw) {
		for (const candidate of raw.startsWith("@") ? [raw, raw.slice(1)] : [raw]) {
			const resolved = path.resolve(cwd, candidate);
			if (fs.existsSync(resolved)) {
				abs = resolved;
				break;
			}
		}
	}
	// Unresolvable target — absent, or a non-path (branch / PR number) that
	// doesn't exist on disk — keeps the whole-diff scope of cwd's git root.
	if (abs == null) {
		const gitRoot = findGitRoot(cwd);
		return gitRoot ? { gitRoot, relPath: null } : null;
	}
	const gitRoot = findGitRoot(abs);
	if (!gitRoot) return null;
	const relPath = path.relative(gitRoot, abs);
	return { gitRoot, relPath: relPath === "" || relPath === "." ? null : relPath };
}

/** Injectably run `git` (defaults to promisified execFile — array argv, no
 *  shell, and non-blocking: the caller is async, so git runs on the event
 *  loop instead of freezing the TUI for the whole diff duration). `signal`
 *  (optional) lets the caller abort an in-flight diff via ctx.signal. */
export type GitRunner = (args: string[], opts: { cwd: string; signal?: AbortSignal }) => Promise<string>;

const execFileAsync = promisify(execFile);

const defaultGitRunner: GitRunner = async (args, opts) =>
	(await execFileAsync("git", args, {
		cwd: opts.cwd,
		encoding: "utf8",
		maxBuffer: 10 * 1024 * 1024,
		signal: opts.signal,
	})).stdout;

/** Which diff range produced the diff (drives scope reporting in prompts/messages). */
export type DiffScopeKind = "upstream" | "worktree" | "staged-fresh" | "unstaged-fresh";

/** Human label per scope kind — the single place the wording lives. */
export const DIFF_SCOPES: Record<DiffScopeKind, string> = {
	upstream: "unpushed commits + uncommitted changes (merge-base of @{upstream} → working tree)",
	worktree: "uncommitted changes (HEAD → working tree)",
	"staged-fresh": "staged changes (repo has no commits yet)",
	"unstaged-fresh": "unstaged changes (repo has no commits yet)",
};

/**
 * Result of resolving the diff. `ok` carries the diff plus the scope kind
 * that produced it and `gitCommand` — a shell-ready command that reproduces
 * the exact diff invocation (range + path limiter + git root), so the
 * rendered prompt can have the model re-read the SAME diff visibly instead
 * of re-deriving a different range; the failure kinds are distinguishable so
 * the caller can report WHY nothing was reviewed instead of a blanket "no
 * changes".
 */
export type DiffOutcome =
	| { kind: "ok"; diff: string; gitRoot: string; scopeKind: DiffScopeKind; gitCommand: string }
	| { kind: "no-repo" }
	| { kind: "empty" }
	| { kind: "git-error"; message: string };

/**
 * Resolve the diff for the resolved scope (see resolveDiffScope), widening
 * the view to the full "changed code":
 *
 *  1. upstream — `git diff <merge-base @{upstream} HEAD>`: everything since
 *     divergence from the tracked upstream (unpushed commits + staged +
 *     unstaged) in one range. Skipped when no upstream is configured.
 *  2. worktree — `git diff HEAD`: all uncommitted (staged + unstaged).
 *  3. staged-fresh / unstaged-fresh — repos with no commits yet (HEAD doesn't
 *     resolve): index vs empty tree, then worktree vs index.
 *
 * The first candidate that yields a non-empty diff wins. All empty → `empty`;
 * every candidate erroring (broken repo, diff exceeding maxBuffer) →
 * `git-error` carrying the last error message; no git root → `no-repo`.
 */
export async function getRepoDiff(
	cwd: string,
	target: string | undefined,
	run: GitRunner = defaultGitRunner,
	signal?: AbortSignal,
): Promise<DiffOutcome> {
	const scope = resolveDiffScope(cwd, target);
	if (!scope) return { kind: "no-repo" };
	const { gitRoot, relPath } = scope;
	const pathArgs: string[] = relPath ? ["--", relPath] : [];
	/** argv of one diff invocation — the single construction shared by the
	 *  executed call (diffAttempt) and the reproduction command (commandFor),
	 *  so the command shown to the model cannot drift from what ran. */
	const diffArgs = (range: string[]): string[] => ["diff", "--no-color", ...range, ...pathArgs];
	/** Shell-ready reproduction of a diff invocation (JSON.stringify quotes each
	 *  path — valid POSIX quoting that also escapes embedded quotes). The
	 *  relPath is re-quoted here for the DISPLAY only; the executed call uses
	 *  the raw argv (diffArgs). A shell interpreting the displayed command
	 *  produces the same argv, so the two cannot drift. */
	const commandFor = (range: string[]): string => {
		// Only shell-unsafe relPaths get quoted — a plain path stays clean in
		// the displayed command, a path with spaces/glob metachars is quoted
		// (JSON.stringify = valid POSIX quoting) so the visible re-run
		// reproduces it exactly.
		const safeRelPath = (p: string): string => (/^[A-Za-z0-9_./-]+$/.test(p) ? p : JSON.stringify(p));
		return [
			"git",
			"-C",
			JSON.stringify(gitRoot),
			"diff",
			"--no-color",
			...range,
			...(relPath ? ["--", safeRelPath(relPath)] : []),
		].join(" ");
	};

	let lastError: string | undefined;
	/** `recordError` false = a failure that is a legitimate fallback signal
	 *  (git diff HEAD on a repo with no commits yet) — it must not be mistaken
	 *  for a broken repo, or an empty fresh repo would report git-error
	 *  instead of empty. */
	const diffAttempt = async (range: string[], recordError = true): Promise<string | null> => {
		try {
			const out = (await run(diffArgs(range), { cwd: gitRoot, signal })).trim();
			return out || null;
		} catch (err) {
			if (recordError) lastError = err instanceof Error ? err.message : String(err);
			return null;
		}
	};
	const mergeBaseWithUpstream = async (): Promise<string | null> => {
		try {
			return (await run(["merge-base", "@{upstream}", "HEAD"], { cwd: gitRoot, signal })).trim() || null;
		} catch {
			return null;
		}
	};

	// Candidate ladder in priority order — the first non-empty diff wins.
	// `git diff HEAD` failing (recordError false) is the EXPECTED fresh-repo
	// signal, not a broken repo; the later staged/unstaged candidates carry
	// the real errors so a genuinely broken repo still surfaces git-error.
	const candidates: { scopeKind: DiffScopeKind; range: string[]; recordError: boolean }[] = [];
	const mb = await mergeBaseWithUpstream();
	if (mb) candidates.push({ scopeKind: "upstream", range: [mb], recordError: true });
	candidates.push(
		{ scopeKind: "worktree", range: ["HEAD"], recordError: false },
		{ scopeKind: "staged-fresh", range: ["--staged"], recordError: true },
		{ scopeKind: "unstaged-fresh", range: [], recordError: true },
	);
	for (const c of candidates) {
		const out = await diffAttempt(c.range, c.recordError);
		if (out) return { kind: "ok", diff: out, gitRoot, scopeKind: c.scopeKind, gitCommand: commandFor(c.range) };
	}
	return lastError ? { kind: "git-error", message: lastError } : { kind: "empty" };
}

/**
 * Build the zero-token context package injected into every rendered prompt:
 * repo root, the resolved diff scope, and a changed-file index with
 * add/remove line counts, parsed straight out of the diff — no extra git
 * calls, no drift from the diff embedded below. Gathered dispatcher-side
 * where it costs no parent-context tokens, so each agent skips its own 1–3
 * exploration rounds of `git diff --stat`. Pure — unit-testable.
 */
export function buildContextPackage(diff: string, gitRoot: string, scopeLabel: string): string {
	const churn = new Map<string, { added: number; removed: number; binary: boolean }>();
	let current: string | null = null;
	/** git quotes path headers with non-ASCII/special chars (core.quotepath
	 *  default true) — accept both the plain and the quoted "a/…" "b/…" forms. */
	const FILE_HEADER = /^diff --git (?:a\/(.*) b\/(.*)|"a\/(.*)" "b\/(.*)")$/;
	/** `--- a/…` / `+++ b/…` (or /dev/null, or quoted variants) are file
	 *  headers, not content lines — but a CONTENT line may itself start with
	 *  `+`/`-` (rendered `+++x`), so only the exact header prefixes skip. */
	const HEADER_PREFIXES = [
		"--- a/",
		"--- /dev/null",
		"+++ b/",
		"+++ /dev/null",
		'--- "a/',
		'+++ "b/',
	];
	for (const line of diff.split("\n")) {
		const m = FILE_HEADER.exec(line);
		if (m) {
			current = m[2] ?? m[4]!;
			if (!churn.has(current)) churn.set(current, { added: 0, removed: 0, binary: false });
			continue;
		}
		if (current == null) continue;
		const c = churn.get(current)!;
		if (line.startsWith("Binary files")) c.binary = true;
		else if (HEADER_PREFIXES.some((p) => line.startsWith(p))) continue;
		else if (line.startsWith("+")) c.added++;
		else if (line.startsWith("-")) c.removed++;
	}

	// Map iterates in insertion order — the keys ARE the first-seen file order.
	const files = [...churn.keys()];
	const lines: string[] = [`Repo root: ${gitRoot}`, `Diff scope: ${scopeLabel}`];
	if (files.length > 0) {
		lines.push("Changed files (added/removed lines):");
		for (const f of files.slice(0, CONTEXT_PACKAGE_MAX_FILES)) {
			const c = churn.get(f)!;
			lines.push(`  ${f}${c.binary ? " (binary)" : ` +${c.added} -${c.removed}`}`);
		}
		if (files.length > CONTEXT_PACKAGE_MAX_FILES)
			lines.push(`  … and ${files.length - CONTEXT_PACKAGE_MAX_FILES} more (see the diff below)`);
	}
	return lines.join("\n");
}

/** Priority order for picking a verification command from package.json scripts. */
const VERIFY_SCRIPT_PRIORITY = ["check", "test", "lint", "typecheck"] as const;

/**
 * Pick the project verification command from a package.json `scripts` map, in
 * priority order (check → test → lint → typecheck). Pure — unit-testable.
 * Returns the runnable command (e.g. `npm run check`) or null when none exists.
 */
export function detectVerifyCommand(scripts: Record<string, string> | null): string | null {
	if (!scripts) return null;
	for (const key of VERIFY_SCRIPT_PRIORITY) {
		const v = scripts[key];
		if (typeof v === "string" && v.trim() !== "") return `npm run ${key}`;
	}
	return null;
}

/** Read package.json scripts from `cwd`; returns null when absent/unparseable. */
export function readScriptsAt(cwd: string): Record<string, string> | null {
	try {
		const pkg = JSON.parse(fs.readFileSync(path.join(cwd, "package.json"), "utf8")) as {
			scripts?: Record<string, string>;
		};
		return pkg.scripts ?? null;
	} catch {
		return null;
	}
}

/** Build the "verify/apply" guidance line rendered into the prompts. */
export function verifyLine(cwd: string): string {
	const verifyCmd = detectVerifyCommand(readScriptsAt(cwd));
	return verifyCmd
		? `Verification command: \`${verifyCmd}\` (detected from package.json scripts). After applying fixes, run it; on failure, follow the skill's auto-revert procedure — never leave the working tree verified-broken.`
		: `No verification command detected in package.json (looked for check/test/lint/typecheck). Apply fixes and report outcomes, but state in the report that no verification was run (verification is opportunistic, never blocking).`;
}
