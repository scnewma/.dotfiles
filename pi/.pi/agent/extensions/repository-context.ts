import { existsSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export function repositoryContext(root: string, vcs: "jj" | "git") {
	return [
		`Repository root: ${root}`,
		vcs === "jj"
			? "Version control: jj (Jujutsu). Use jj for all VCS operations, never git, even if .git also exists. Do not probe with git. Bookmarks are branches; push with jj git push."
			: "Version control: git. Use git for VCS operations.",
	].join("\n");
}

export default function (pi: ExtensionAPI) {
	pi.on("before_agent_start", (event, ctx) => {
		delete event.systemPromptOptions.sections.repository_context;
		let root = resolve(ctx.cwd);
		while (true) {
			const jj = existsSync(join(root, ".jj"));
			if (jj || existsSync(join(root, ".git"))) {
				event.systemPromptOptions.sections.repository_context =
					repositoryContext(root, jj ? "jj" : "git");
				return;
			}
			const parent = dirname(root);
			if (parent === root) return;
			root = parent;
		}
	});
}
