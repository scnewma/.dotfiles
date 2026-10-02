import { type ChildProcess, spawn } from "node:child_process";
import type {
	ExtensionAPI,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	if (process.platform !== "darwin") return;

	let enabled = true;
	let running = false;
	let inhibitor: ChildProcess | undefined;

	function stop(ctx: ExtensionContext) {
		const child = inhibitor;
		inhibitor = undefined;
		child?.kill();
		ctx.ui.setStatus("caffeinate", undefined);
	}

	function start(ctx: ExtensionContext) {
		if (!enabled || !running || inhibitor) return;
		const child = spawn(
			"/usr/bin/caffeinate",
			["-i", "-w", String(process.pid)],
			{
				stdio: "ignore",
			},
		);
		inhibitor = child;
		child.unref();

		child.on("spawn", () => {
			if (inhibitor === child) ctx.ui.setStatus("caffeinate", "☕");
		});
		child.on("error", (error) => {
			if (inhibitor !== child) return;
			inhibitor = undefined;
			ctx.ui.setStatus("caffeinate", undefined);
			ctx.ui.notify(`Caffeinate failed: ${error.message}`, "error");
		});
		child.on("exit", (code, signal) => {
			if (inhibitor !== child) return;
			inhibitor = undefined;
			ctx.ui.setStatus("caffeinate", undefined);
			ctx.ui.notify(
				`Caffeinate exited unexpectedly (${signal ?? code}).`,
				"error",
			);
		});
	}

	pi.on("agent_start", (_event, ctx) => {
		running = true;
		start(ctx);
	});
	pi.on("agent_settled", (_event, ctx) => {
		running = false;
		stop(ctx);
	});
	pi.on("session_shutdown", (_event, ctx) => {
		running = false;
		stop(ctx);
	});

	pi.registerCommand("caffeinate", {
		description: "Toggle keeping your Mac awake during agent runs",
		handler: async (args, ctx) => {
			if (args.trim()) {
				ctx.ui.notify("Usage: /caffeinate", "warning");
				return;
			}
			enabled = !enabled;
			if (enabled) start(ctx);
			else stop(ctx);
			ctx.ui.notify(`Caffeinate ${enabled ? "enabled" : "disabled"}.`, "info");
		},
	});
}
