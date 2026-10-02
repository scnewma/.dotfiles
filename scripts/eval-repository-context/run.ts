import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { repositoryContext } from "../../pi/.pi/agent/extensions/repository-context";

const fixtures = [
	{
		id: "jj-only",
		markers: [".jj"],
		root: "/fixtures/project",
		cwd: "/fixtures/project",
	},
	{
		id: "colocated",
		markers: [".jj", ".git"],
		root: "/fixtures/project",
		cwd: "/fixtures/project",
	},
	{
		id: "git-only",
		markers: [".git"],
		root: "/fixtures/project",
		cwd: "/fixtures/project",
	},
	{
		id: "nested-jj",
		markers: [".jj", ".git"],
		root: "/fixtures/project",
		cwd: "/fixtures/project/src",
	},
];
const questions = [
	"What are the three most recent completed changes in this repository? Summarize the version history. Don't modify anything.",
	"Does this repository have uncommitted changes? Summarize their scope and the latest completed change. Don't modify anything.",
];
const conditions = ["baseline", "rule", "context"];
const oldRule =
	"If the repo has a `.jj` directory, use `jj` for all VCS operations, never `git`. Bookmarks are branches; push with `jj git push`.";

type Fixture = (typeof fixtures)[number];
type Call = { name: string; arguments: { command?: string; path?: string } };

export default async function (pi: ExtensionAPI) {
	const { Type } = await import("@earendil-works/pi-ai");
	for (const [name, parameters] of [
		[
			"bash",
			Type.Object({
				command: Type.String(),
				timeout: Type.Optional(Type.Number()),
			}),
		],
		[
			"read",
			Type.Object({
				path: Type.String(),
				offset: Type.Optional(Type.Number()),
				limit: Type.Optional(Type.Number()),
			}),
		],
	] as const) {
		pi.registerTool({
			name,
			label: name,
			description: name === "bash" ? "Execute a bash command" : "Read a file",
			parameters,
			execute: async () => {
				throw new Error("Synthetic evaluation: tools never execute");
			},
		});
	}
	pi.on("session_start", () => pi.setActiveTools(["read", "bash"]));
	const fixtureJson = process.env.VCS_EVAL_FIXTURE;
	const resultPath = process.env.VCS_EVAL_RESULT;
	const condition = process.env.VCS_EVAL_CONDITION;
	if (!fixtureJson || !resultPath || !conditions.includes(condition ?? "")) {
		throw new Error("Run this extension through the evaluation script");
	}
	const fixture: Fixture = JSON.parse(fixtureJson);
	pi.on("before_agent_start", (event) => {
		event.systemPromptOptions.cwd = fixture.cwd;
		event.systemPromptOptions.contextFiles = [];
		delete event.systemPromptOptions.sections.repository_context;
		if (condition === "rule") {
			event.systemPromptOptions.contextFiles.push({
				path: "/fixtures/AGENTS.md",
				content: oldRule,
			});
		} else if (condition === "context") {
			event.systemPromptOptions.sections.repository_context = repositoryContext(
				fixture.root,
				fixture.markers.includes(".jj") ? "jj" : "git",
			);
		}
	});
	let captured = false;
	pi.on("message_end", (event, ctx) => {
		if (event.message.role !== "assistant" || captured) return;
		captured = true;
		writeFileSync(
			resultPath,
			JSON.stringify({
				model: `${event.message.provider}/${event.message.model}`,
				stopReason: event.message.stopReason,
				error: event.message.errorMessage,
				calls: event.message.content.filter(
					(block) => block.type === "toolCall",
				),
			}),
		);
		ctx.abort();
	});
	pi.on("tool_call", () => ({
		block: true,
		reason: "Synthetic evaluation: no tools may execute",
	}));
}

function score(calls: Call[], expected: "jj" | "git") {
	const commands = calls
		.filter((call) => call.name === "bash")
		.map((call) => call.arguments.command ?? "");
	const vcs = commands.flatMap((command) =>
		[
			...command.matchAll(
				/(?:^|[;&|(\n]|\b(?:then|do|if))\s*(git|jj)\s+(?:(?:-C|-R|--repository)\s+(?:"[^"]*"|'[^']*'|\S+)\s+|--[\w-]+\s+)*([a-z][\w-]*)/g,
			),
		].map((match) => ({ name: match[1], operation: match[2] })),
	);
	if (!calls.length) return "no-tool";
	if (vcs.some((command) => command.name !== expected)) return "wrong-vcs";
	if (
		!vcs.length ||
		calls.some((call) => call.name !== "bash") ||
		vcs.some(
			(command) =>
				!["status", "st", "diff", "log", "show"].includes(command.operation),
		) ||
		commands.some((command) =>
			/(?:\.jj\b|\.git\b|\b(?:ls|find|test|which)\b|command\s+-v|\[\s)/.test(
				command,
			),
		)
	) {
		return "discovery";
	}
	return "direct";
}

if (import.meta.main) {
	const repeats = Number(process.env.VCS_EVAL_REPEATS ?? 1);
	if (!Number.isSafeInteger(repeats) || repeats < 1)
		throw new Error("VCS_EVAL_REPEATS must be a positive integer");
	const models = Bun.argv.slice(2);
	if (!models.length)
		models.push("anthropic/claude-opus-5-5", "anthropic/claude-sonnet-5-5");
	const directory = mkdtempSync(join(tmpdir(), "pi-vcs-eval-"));
	const totals: Record<string, Record<string, number>> = {};
	try {
		for (const model of models) {
			for (const fixture of fixtures) {
				for (let repeat = 0; repeat < repeats; repeat++) {
					for (const condition of conditions) {
						const resultPath = join(directory, "result.json");
						rmSync(resultPath, { force: true });
						const child = Bun.spawn(
							[
								"pi",
								"--model",
								model,
								"--thinking",
								"medium",
								"--mode",
								"json",
								"--no-session",
								"--no-extensions",
								"--no-context-files",
								"--no-skills",
								"--no-prompt-templates",
								"--no-mcp",
								"--no-approve",
								"--no-builtin-tools",
								"--extension",
								import.meta.path,
								questions[
									(fixtures.indexOf(fixture) + repeat) % questions.length
								],
							],
							{
								cwd: directory,
								env: {
									...process.env,
									VCS_EVAL_FIXTURE: JSON.stringify(fixture),
									VCS_EVAL_CONDITION: condition,
									VCS_EVAL_RESULT: resultPath,
								},
								stdin: "ignore",
								stdout: "ignore",
								stderr: "pipe",
								timeout: 120_000,
							},
						);
						const [exit, stderr] = await Promise.all([
							child.exited,
							new Response(child.stderr).text(),
						]);
						if (exit !== 0 || !(await Bun.file(resultPath).exists()))
							throw new Error(
								`${model}: evaluation failed (${exit}) ${stderr}`,
							);
						const result = await Bun.file(resultPath).json();
						if (["error", "aborted"].includes(result.stopReason))
							throw new Error(`${model}: ${result.error ?? result.stopReason}`);
						const expected = fixture.markers.includes(".jj") ? "jj" : "git";
						const outcome = score(result.calls, expected);
						const key = `${result.model} ${condition}`;
						totals[key] ??= {
							direct: 0,
							discovery: 0,
							"wrong-vcs": 0,
							"no-tool": 0,
						};
						totals[key][outcome]++;
						console.log(
							JSON.stringify({
								fixture: fixture.id,
								repeat: repeat + 1,
								condition,
								expected,
								outcome,
								...result,
							}),
						);
					}
				}
			}
		}
		console.log(JSON.stringify({ totals }));
	} finally {
		rmSync(directory, { recursive: true, force: true });
	}
}
