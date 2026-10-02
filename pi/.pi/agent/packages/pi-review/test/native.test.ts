import { expect, test } from "bun:test";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import {
	fauxAssistantMessage,
	fauxProvider,
	fauxToolCall,
	getCurrentTools,
} from "@earendil-works/pi-ai";
import {
	createAgentSession,
	DefaultResourceLoader,
	ModelRuntime,
	SessionManager,
	SettingsManager,
} from "@earendil-works/pi-coding-agent";
import { createJiti } from "jiti";
import review from "../index.ts";
import { loadRolePrompts } from "../src/dispatch.ts";

test("real native loader and structured child", async () => {
	const root = fs.mkdtempSync(path.join(os.tmpdir(), "review-native-"));
	const cwd = path.join(root, "project"),
		agentDir = path.join(root, "agent");
	fs.mkdirSync(cwd);
	fs.mkdirSync(agentDir);
	fs.mkdirSync(path.join(agentDir, "agents"));
	for (const file of fs.readdirSync(new URL("../agents/", import.meta.url)))
		fs.copyFileSync(
			new URL(`../agents/${file}`, import.meta.url),
			path.join(agentDir, "agents", file),
		);
	const priorHost = process.env.PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT;
	process.env.PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT = path.resolve(
		import.meta.dir,
		"../node_modules/@earendil-works/pi-coding-agent",
	);
	const prior = process.env.PI_CODING_AGENT_DIR;
	process.env.PI_CODING_AGENT_DIR = agentDir;
	let session:
		| Awaited<ReturnType<typeof createAgentSession>>["session"]
		| undefined;
	try {
		const nativePath = path.join(
			os.homedir(),
			".pi/agent/git/github.com/nicobailon/pi-subagents/index.ts",
		);
		const jiti = createJiti(import.meta.url, {
			alias: Object.fromEntries(
				[
					"typebox/compile",
					"typebox/value",
					"@earendil-works/pi-coding-agent",
					"@earendil-works/pi-ai",
					"@earendil-works/pi-tui",
					"@earendil-works/pi-agent-core",
					"typebox",
				].map((name) => [name, fileURLToPath(import.meta.resolve(name))]),
			),
		});
		const native = (await jiti.import(nativePath, {
			default: true,
		})) as typeof review;
		const faux = fauxProvider({
			provider: "review-local",
			models: [{ id: "local" }],
			tokensPerSecond: 100000,
		});
		let childSeen = false;
		const roleBody = loadRolePrompts()["finder-diff-scan"];
		const task = `${roleBody}\n\nScope packet: Submit empty findings via structured_output immediately; do not inspect files.`;
		faux.setResponses([
			(context) => {
				const names = getCurrentTools(context.messages).map((t) => t.name);
				expect(names.filter((n) => n === "subagent")).toHaveLength(1);
				expect(names).toContain("review_report");
				return fauxAssistantMessage(
					fauxToolCall("subagent", {
						agent: "review-runner",
						task,
						async: false,
						context: "fresh",
						isolation: "none",
						mission: false,
						model: "review-local/local:off",
						timeoutMs: 30000,
						toolBudget: {
							soft: 1,
							hard: 2,
							block: ["read", "grep", "find", "ls", "bash"],
						},
						outputSchema: {
							type: "object",
							required: ["findings"],
							properties: {
								findings: { type: "array", items: { type: "object" } },
							},
						},
					}),
					{ stopReason: "toolUse" },
				);
			},
			(context) => {
				const names = getCurrentTools(context.messages).map((t) => t.name);
				expect(names).toContain("structured_output");
				expect(names).not.toContain("subagent");
				expect(names).not.toContain("edit");
				expect(JSON.stringify(context.messages)).toContain(
					JSON.stringify(roleBody).slice(1, -1),
				);
				expect(JSON.stringify(context.messages)).toContain("Scope packet:");
				childSeen = true;
				return fauxAssistantMessage(
					fauxToolCall("structured_output", { value: { findings: [] } }),
					{ stopReason: "toolUse" },
				);
			},
			fauxAssistantMessage("Done."),
			(context) => {
				const result = context.messages.findLast(
					(m) => m.role === "toolResult" && m.toolName === "subagent",
				);
				expect(JSON.stringify(result)).toContain("findings");
				expect(JSON.stringify(result)).not.toContain("Unknown agent");
				return fauxAssistantMessage("Parent done.");
			},
		]);
		const settingsManager = SettingsManager.inMemory({});
		const resourceLoader = new DefaultResourceLoader({
			cwd,
			agentDir,
			settingsManager,
			noExtensions: true,
			noSkills: true,
			noPromptTemplates: true,
			noThemes: true,
			noContextFiles: true,
			extensionFactories: [
				native,
				review,
				(pi) => pi.registerProvider(faux.provider),
			],
		});
		await resourceLoader.reload();
		expect(resourceLoader.getExtensions().errors).toHaveLength(0);
		const extensions = resourceLoader.getExtensions().extensions;
		expect(extensions.filter((e) => e.tools.has("subagent"))).toHaveLength(1);
		expect(extensions.some((e) => e.commands.has("code-review"))).toBe(true);
		expect(extensions.some((e) => e.commands.has("code-simplify"))).toBe(true);
		const modelRuntime = await ModelRuntime.create({
			authPath: path.join(agentDir, "auth.json"),
			modelsPath: path.join(agentDir, "models.json"),
			allowModelNetwork: false,
		});
		({ session } = await createAgentSession({
			cwd,
			agentDir,
			settingsManager,
			resourceLoader,
			modelRuntime,
			model: faux.getModel("local"),
			sessionManager: SessionManager.inMemory(cwd),
			noTools: "builtin",
		}));
		await session.bindExtensions({});
		await session.prompt("Run the authorized review child.");
		expect(childSeen).toBe(true);
		const result = session.state.messages.findLast(
			(m) => m.role === "toolResult" && m.toolName === "subagent",
		);
		expect(result).toBeDefined();
		if (!result || result.role !== "toolResult")
			throw new Error("Missing subagent tool result");
		expect(result.isError).not.toBe(true);
		expect(JSON.stringify(result)).toContain('"findings":[]');
	} finally {
		if (session) {
			await session.extensionRunner.emit({
				type: "session_shutdown",
				reason: "quit",
			});
			session.dispose();
		}
		if (prior === undefined) delete process.env.PI_CODING_AGENT_DIR;
		else process.env.PI_CODING_AGENT_DIR = prior;
		if (priorHost === undefined)
			delete process.env.PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT;
		else process.env.PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT = priorHost;
		fs.rmSync(root, { recursive: true, force: true });
	}
}, 60000);
