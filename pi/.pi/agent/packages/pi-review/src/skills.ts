/**
 * src/skills.ts — resolve paths to skills bundled inside this extension.
 *
 * Skills ship in <pkg>/skills/ (not under ~/.pi/agent/skills/), so the command
 * handlers need the extension's own install root to point the agent's read tool
 * at the bundled SKILL.md. import.meta.url resolves under node ESM, bun, and
 * jiti 2.x; realpath collapses any symlink in the install path (the extension
 * is often symlinked into the pi extensions dir).
 */
import { fileURLToPath } from "node:url";
import * as fs from "node:fs";
import * as path from "node:path";

// This file lives at <pkg>/src/skills.ts → ".." is the package root.
const PKG_ROOT = fs.realpathSync(
	path.resolve(path.dirname(fileURLToPath(import.meta.url)), ".."),
);

/** Absolute path to a skill file bundled in this extension's skills/ dir. */
export function bundledSkillPath(rel: string): string {
	return path.join(PKG_ROOT, "skills", rel);
}
