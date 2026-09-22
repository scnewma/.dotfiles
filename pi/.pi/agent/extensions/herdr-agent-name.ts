import process from "node:process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("herdr-agent-name", {
    description: "Rename the current agent in Herdr",
    handler: async (args, ctx) => {
      const name = args.trim();
      if (!name) {
        ctx.ui.notify("Usage: /herdr-agent-name <name>", "warning");
        return;
      }

      const paneId = process.env.HERDR_PANE_ID;
      if (!paneId) {
        ctx.ui.notify("This Pi session is not running inside Herdr.", "error");
        return;
      }

      const herdr = process.env.HERDR_BIN_PATH ?? "herdr";
      const renameArgs = name === "--clear"
        ? ["agent", "rename", paneId, "--clear"]
        : ["agent", "rename", paneId, name];
      const result = await pi.exec(herdr, renameArgs, { timeout: 5_000 });

      if (result.code !== 0) {
        const message = result.stderr.trim() || result.stdout.trim() ||
          "Unknown Herdr error";
        ctx.ui.notify(`Could not rename agent: ${message}`, "error");
        return;
      }

      ctx.ui.notify(
        name === "--clear"
          ? "Herdr agent name cleared."
          : `Herdr agent renamed to ${name}.`,
        "info",
      );
    },
  });
}
