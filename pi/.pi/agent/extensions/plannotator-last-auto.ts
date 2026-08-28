import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const STATUS_ID = "plannotator-last-auto";
const STATE_ENTRY_TYPE = "plannotator-last-auto-state";

type AutoReviewAction = "on" | "off" | "status" | "toggle";

function parseAction(args: string): AutoReviewAction | null {
	const action = args.trim().toLowerCase() || "toggle";
	if (action === "on" || action === "off" || action === "status" || action === "toggle") {
		return action;
	}
	return null;
}

export default function (pi: ExtensionAPI) {
	let enabled = false;
	let lastRunAborted = false;

	function updateStatus(ctx: ExtensionContext): void {
		ctx.ui.setStatus(
			STATUS_ID,
			enabled ? ctx.ui.theme.fg("accent", "🥔 Plannotator auto: ON") : undefined,
		);
	}

	function openLastReview(): void {
		pi.sendUserMessage("/plannotator-last", { expandPromptTemplates: true });
	}

	function setEnabled(ctx: ExtensionContext, next: boolean): void {
		const wasEnabled = enabled;
		enabled = next;
		updateStatus(ctx);
		ctx.ui.notify(`Plannotator auto review ${enabled ? "enabled" : "disabled"}.`, "info");

		if (wasEnabled !== enabled) {
			pi.appendEntry(STATE_ENTRY_TYPE, { enabled });
		}
		if (!wasEnabled && enabled && ctx.isIdle()) {
			openLastReview();
		}
	}

	pi.on("session_start", (event, ctx) => {
		enabled = false;
		lastRunAborted = false;
		if (event.reason === "reload") {
			const stateEntry = [...ctx.sessionManager.getBranch()]
				.reverse()
				.find(
					(entry) => entry.type === "custom" && entry.customType === STATE_ENTRY_TYPE,
				);
			const state = stateEntry?.data as { enabled?: unknown } | undefined;
			enabled = state?.enabled === true;
		}
		updateStatus(ctx);
	});

	pi.on("session_shutdown", (_event, ctx) => {
		ctx.ui.setStatus(STATUS_ID, undefined);
	});

	pi.on("agent_start", () => {
		lastRunAborted = false;
	});

	pi.on("agent_end", (event, ctx) => {
		const lastAssistant = [...event.messages]
			.reverse()
			.find((message) => message.role === "assistant");
		lastRunAborted =
			(lastAssistant?.role === "assistant" && lastAssistant.stopReason === "aborted") ||
			ctx.signal?.aborted === true;
	});

	pi.on("agent_settled", () => {
		const aborted = lastRunAborted;
		lastRunAborted = false;
		if (!enabled || aborted) return;
		openLastReview();
	});

	pi.registerShortcut("ctrl+alt+l", {
		description: "Toggle automatic Plannotator review",
		handler: (ctx) => {
			setEnabled(ctx, !enabled);
		},
	});

	pi.registerCommand("plannotator-last-auto", {
		description: "Toggle automatic Plannotator review of settled responses",
		handler: async (args, ctx) => {
			const action = parseAction(args);
			if (!action) {
				ctx.ui.notify("Usage: /plannotator-last-auto [on|off|toggle|status]", "warning");
				return;
			}

			if (action === "status") {
				ctx.ui.notify(`Plannotator auto review is ${enabled ? "on" : "off"}.`, "info");
				return;
			}

			setEnabled(ctx, action === "toggle" ? !enabled : action === "on");
		},
	});
}
