import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const localInstructionsPath = join(homedir(), ".pi", "agent", "AGENTS.md.local");

export default function (pi: ExtensionAPI) {
	pi.on("before_agent_start", async (event) => {
		try {
			const instructions = await readFile(localInstructionsPath, "utf8");
			if (instructions.trim()) {
				event.systemPromptOptions.sections.local_machine_global_agents_instructions = instructions;
			} else {
				delete event.systemPromptOptions.sections.local_machine_global_agents_instructions;
			}
		} catch (error) {
			if ((error as { code?: string }).code !== "ENOENT") throw error;
			delete event.systemPromptOptions.sections.local_machine_global_agents_instructions;
		}
	});
}
