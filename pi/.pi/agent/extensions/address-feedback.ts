import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const PROMPT =
	"Load the hunk review skill by running the command `hunk skill path`. Address review feedback.";

export default function (pi: ExtensionAPI) {
	pi.registerCommand("address-feedback", {
		description: "Load the hunk review skill and address review feedback",
		handler: async (_args, ctx) => {
			if (ctx.isIdle()) {
				pi.sendUserMessage(PROMPT);
				return;
			}

			pi.sendUserMessage(PROMPT, { deliverAs: "followUp" });
		},
	});
}
