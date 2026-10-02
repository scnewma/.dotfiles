import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadBudgets } from "../src/config.ts";
import {
	loadRolePrompts,
	nativeFanoutAvailable,
	parentModel,
	render,
	usesFanout,
} from "../src/dispatch.ts";

import { parseGuards, selectVariant } from "../src/strategy.ts";

test("availability requires an active tool or active loader with registered subagent", () => {
	const api = (active: string[], all: string[]) => ({
		getActiveTools: () => active,
		getAllTools: () => all.map((name) => ({ name })),
	});
	expect(nativeFanoutAvailable(api([], ["subagent"]))).toBe(false);
	expect(nativeFanoutAvailable(api(["subagents_enable"], ["subagent"]))).toBe(
		true,
	);
	expect(nativeFanoutAvailable(api(["subagent"], []))).toBe(true);
	expect(nativeFanoutAvailable(api(["subagents_enable"], []))).toBe(false);
});
test("current parent thinking is explicit, including off", () => {
	expect(parentModel({ provider: "anthropic", id: "test" }, "medium")).toBe(
		"anthropic/test:medium",
	);
	expect(parentModel({ provider: "anthropic", id: "test" }, "off")).toBe(
		"anthropic/test:off",
	);
});
test("legacy turns are not calls; loop remains independent", () => {
	const root = mkdtempSync(join(tmpdir(), "review-budget-"));
	mkdirSync(join(root, ".pi"));
	writeFileSync(
		join(root, ".pi/pi-review.json"),
		JSON.stringify({
			maxTurns: { subagent: 99, loop: 7 },
			toolCalls: { verifier: 9 },
			timeoutMs: 12345,
		}),
	);
	try {
		const b = loadBudgets(root, root);
		expect(b.finder).toBe(20);
		expect(b.gapHunt).toBe(20);
		expect(b.verifier).toBe(9);
		expect(b.loop).toBe(7);
		expect(b.timeoutMs).toBe(12345);
	} finally {
		rmSync(root, { recursive: true, force: true });
	}
});

test("manifest owns assets, not a subagent tool; one unpinned runner and twelve private policies", async () => {
	const { readFileSync, readdirSync } = await import("node:fs");
	const manifest = JSON.parse(
		readFileSync(new URL("../package.json", import.meta.url), "utf8"),
	);
	expect(manifest.pi.subagents.agents).toEqual(["./agents"]);
	expect(manifest.dependencies?.["@fyeeme/pi-subagents"]).toBeUndefined();
	const files = readdirSync(new URL("../agents/", import.meta.url));
	expect(files).toEqual(["review-runner.md"]);
	expect(manifest.files).toContain("roles/**/*.md");
	const roles = readdirSync(new URL("../roles/", import.meta.url));
	expect(roles).toHaveLength(12);
	for (const file of roles) {
		const body = readFileSync(
			new URL(`../roles/${file}`, import.meta.url),
			"utf8",
		);
		expect(body).toContain("defaultContext: fresh");
		expect(body).toMatch(/^extensions:$/m);
		if (file !== "verifier.md") {
			expect(body).toContain("short_summary");
			expect(body).toContain("≤60");
		}
		expect(body).toContain("tools: read, grep, find, ls, bash");
		expect(body).toContain("structured_output");
		expect(body).not.toMatch(/^model:|^thinking:/m);
	}
});

test("parallel findings schemas require bounded short summaries", async () => {
	const { readFileSync } = await import("node:fs");
	for (const template of ["review.parallel.md", "simplify.parallel.md"]) {
		const body = readFileSync(
			new URL(`../prompts/${template}`, import.meta.url),
			"utf8",
		);
		const line = body
			.split("\n")
			.find((line) => line.startsWith("const findingsSchema = "));
		if (!line) throw new Error("Missing findings schema");
		const schema = Function(`${line} return findingsSchema;`)();
		expect(schema.properties.findings.items.required).toContain(
			"short_summary",
		);
		expect(schema.properties.findings.items.properties.short_summary).toEqual({
			type: "string",
			maxLength: 60,
		});
	}
});

test("role JSON injection preserves all private bodies and JS escaping", async () => {
	const { readFileSync, readdirSync } = await import("node:fs");
	const { parseFrontmatter } = await import("@earendil-works/pi-coding-agent");
	const roles = loadRolePrompts();
	expect(Object.keys(roles)).toHaveLength(12);
	for (const file of readdirSync(new URL("../roles/", import.meta.url))) {
		expect(roles[file.replace(/\.md$/, "")]).toBe(
			parseFrontmatter(
				readFileSync(new URL(`../roles/${file}`, import.meta.url), "utf8"),
			).body,
		);
	}
	const tricky = {
		...roles,
		escaping: 'quotes " newline\n backticks ` and {{effort}}',
	};
	const rendered = render(
		"const rolePrompts = {{role-prompts}}; return rolePrompts;",
		{ "role-prompts": JSON.stringify(tricky) },
	);
	expect(Function(rendered)()).toEqual(tricky);
	for (const template of ["review.parallel.md", "simplify.parallel.md"]) {
		const body = readFileSync(
			new URL(`../prompts/${template}`, import.meta.url),
			"utf8",
		);
		const line = body
			.split("\n")
			.find((line) => line.startsWith("const rolePrompts = "));
		expect(line).toBeDefined();
		expect(
			Function(
				render(`${line} return rolePrompts;`, {
					"role-prompts": JSON.stringify(roles),
				}),
			)(),
		).toEqual(roles);
		expect(body).not.toMatch(/agent:"(?:finder-|cleaner-|verifier|gap-hunter)/);
		expect(body).toContain('agent:"review-runner"');
	}
});

test("effort split and simplify mode guards remain unchanged", async () => {
	for (const level of ["low", "medium", "high"] as const)
		expect(usesFanout(level)).toBe(false);
	for (const level of ["xhigh", "max"] as const)
		expect(usesFanout(level)).toBe(true);
	const { readFileSync } = await import("node:fs");
	const { parseFrontmatter } = await import("@earendil-works/pi-coding-agent");
	const guards = parseGuards(
		parseFrontmatter<Record<string, unknown>>(
			readFileSync(
				new URL("../prompts/simplify.parallel.md", import.meta.url),
				"utf8",
			),
		).frontmatter,
	);
	expect(guards).toEqual({ contextBelow: 0.8, diffCharsBelow: 400000 });
	const runtime = {
		tokens: 79,
		contextWindow: 100,
		diffChars: 399999,
		fanoutAvailable: true,
	};
	expect(selectVariant(guards, runtime).variant).toBe("parallel");
	for (const override of [
		{ tokens: 80 },
		{ tokens: null },
		{ diffChars: 400000 },
		{ fanoutAvailable: false },
	])
		expect(selectVariant(guards, { ...runtime, ...override }).variant).toBe(
			"single-pass",
		);
});
