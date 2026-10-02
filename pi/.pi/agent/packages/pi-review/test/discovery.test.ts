import { expect, test } from "bun:test";
import { mkdtempSync, realpathSync, rmSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { createJiti } from "jiti";

test("installed configuration discovers only the review runner from the package manifest", async () => {
	const profile = join(homedir(), ".pi", "agent");
	const cwd = mkdtempSync(join(tmpdir(), "review-profile-discovery-"));
	const prior = process.env.PI_CODING_AGENT_DIR;
	process.env.PI_CODING_AGENT_DIR = profile;
	try {
		const jiti = createJiti(import.meta.url, {
			alias: Object.fromEntries(
				[
					"@earendil-works/pi-ai",
					"@earendil-works/pi-coding-agent",
					"@earendil-works/pi-tui",
				].map((name) => [name, fileURLToPath(import.meta.resolve(name))]),
			),
		});
		// Only the result fields asserted below cross this dynamic native-module boundary.
		type DiscoveredRole = {
			name: string;
			localName?: string;
			source: string;
			filePath: string;
			packageSourceRoot?: string;
			extensions?: string[];
			defaultContext?: string;
			tools?: string[];
		};
		const { discoverAgentSnapshot } = (await jiti.import(
			`${profile}/git/github.com/nicobailon/pi-subagents/src/agents/agents.ts`,
		)) as {
			discoverAgentSnapshot(
				cwd: string,
				scope: "both",
				provider: undefined,
				options: { globalNpmRoot: null; includeChains: false },
			): {
				effective: { agents: DiscoveredRole[] };
				all: { package: DiscoveredRole[] };
			};
		};
		const discovered = discoverAgentSnapshot(cwd, "both", undefined, {
			globalNpmRoot: null,
			includeChains: false,
		});
		const packageRoot = realpathSync(resolve(import.meta.dir, ".."));
		const owned = discovered.all.package.filter(
			(agent) =>
				agent.packageSourceRoot &&
				realpathSync(agent.packageSourceRoot) === packageRoot,
		);
		const expected = ["review-runner"];
		if (owned.length === 0)
			throw new Error(
				'Native discovery found no review roles. The profile package entry "packages/pi-review" must be "./packages/pi-review" or an absolute path; native discovery does not resolve bare relative paths. Profile settings were not modified by this test.',
			);
		expect(owned).toHaveLength(1);
		expect(
			owned.some((agent) =>
				/finder-|cleaner-|verifier|gap-hunter/.test(
					agent.localName ?? agent.name,
				),
			),
		).toBe(false);
		expect(owned.map((agent) => agent.localName ?? agent.name).sort()).toEqual(
			expected.sort(),
		);
		for (const role of owned) {
			expect(role.source).toBe("package");
			expect(role.extensions).toEqual([]); // Blank frontmatter parsed as an empty allowlist, never ["[]"].
			expect(role.defaultContext).toBe("fresh");
			expect(role.tools).toEqual(["read", "grep", "find", "ls", "bash"]);
			expect(
				discovered.effective.agents.some(
					(agent) =>
						agent.name === role.name &&
						agent.source === "package" &&
						agent.filePath === role.filePath,
				),
			).toBe(true);
		}
	} finally {
		if (prior === undefined) delete process.env.PI_CODING_AGENT_DIR;
		else process.env.PI_CODING_AGENT_DIR = prior;
		rmSync(cwd, { recursive: true, force: true });
	}
});
