import { appendFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import {
  type ExtensionAPI,
  withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

export default function (pi: ExtensionAPI) {
  const path = join(homedir(), "VENT.md");
  let attempted = false;

  pi.on("session_start", () => {
    attempted = false;
  });
  pi.on("before_agent_start", (event) => {
    if (event.messageType === "user") attempted = false;
  });

  pi.registerTool({
    name: "vent",
    label: "Vent",
    description:
      "Log feedback about fixable problems in the development environment or workflow to ~/VENT.md. " +
      "For example: a tool rejects valid filenames, required tooling is missing, or instructions conflict. " +
      "Do not report ordinary code bugs, brief reasoning difficulties, or issues already reported. " +
      "Describe the obstacle, its effect, any workaround, and a possible fix when known. " +
      "Omit secrets and private conversation content. Continue the task after logging. " +
      "Only one vent attempt is allowed per user request. Do not use vent to apologize or retract feedback.",
    promptSnippet: "Log fixable development environment or workflow problems",
    parameters: Type.Object({
      title: Type.String({ minLength: 1, maxLength: 160 }),
      description: Type.String({ minLength: 1, maxLength: 8000 }),
    }),
    async execute(_toolCallId, params, signal, _onUpdate, ctx) {
      if (attempted) {
        return {
          content: [
            {
              type: "text",
              text: "Vent skipped: one attempt per user request. Continue the task.",
            },
          ],
          details: { path, logged: false },
        };
      }
      signal?.throwIfAborted();
      const title = params.title.replace(/\s+/g, " ").trim();
      const description = params.description.trim();
      if (!title || !description) {
        throw new Error("Vent title and description must not be blank.");
      }

      const metadata = {
        cwd: ctx.cwd,
        sessionId: ctx.sessionManager.getSessionId(),
        sessionName: ctx.sessionManager.getSessionName() ?? null,
        sessionFile: ctx.sessionManager.getSessionFile() ?? null,
        model: ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : null,
      };
      const entry = `\n\n## ${new Date().toISOString()} | ${title}\n\n\`\`\`json\n${JSON.stringify(metadata, null, 2)}\n\`\`\`\n\n${description}\n`;

      attempted = true;
      try {
        await withFileMutationQueue(path, () =>
          appendFile(path, entry, { encoding: "utf8", mode: 0o600 }),
        );
      } catch (error) {
        throw new Error(
          `Could not append vent to ${path}: ${error instanceof Error ? error.message : String(error)}. Do not retry this request.`,
          { cause: error },
        );
      }

      return {
        content: [
          {
            type: "text",
            text: "Vent logged to ~/VENT.md. Continue the task.",
          },
        ],
        details: { path, logged: true },
      };
    },
  });
}
