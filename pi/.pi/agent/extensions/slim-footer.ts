import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 1e4) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1e6) return `${Math.round(count / 1000)}k`;
	if (count < 1e7) return `${(count / 1e6).toFixed(1)}M`;
	return `${Math.round(count / 1e6)}M`;
}

const sanitize = (text: string) => text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsub = footerData.onBranchChange(() => tui.requestRender());
			return {
				dispose: unsub,
				invalidate() {},
				render(width: number): string[] {
					let input = 0;
					let output = 0;
					let cost = 0;
					for (const entry of ctx.sessionManager.getEntries() as any[]) {
						const usage =
							entry.type === "usage"
								? entry.usage
								: entry.type === "message"
									? entry.message.usage
									: entry.usage;
						if (!usage) continue;
						input += usage.input ?? 0;
						output += usage.output ?? 0;
						cost += usage.cost?.total ?? 0;
					}

					const home = process.env.HOME || process.env.USERPROFILE || "";
					let pwd = ctx.sessionManager.getCwd();
					if (home && pwd.startsWith(home)) pwd = `~${pwd.slice(home.length)}`;
					const branch = footerData.getGitBranch();
					if (branch === "gitbutler/workspace") pwd = `${pwd} [but]`;
					else if (branch) pwd = `${pwd} (${branch})`;
					const name = ctx.sessionManager.getSessionName?.() ?? pi.getSessionName();
					if (name) pwd = `${pwd} \u2022 ${name}`;

					const contextUsage = ctx.getContextUsage();
					const contextWindow = contextUsage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
					const pct = contextUsage?.percent ?? 0;
					const pctDisplay =
						contextUsage?.percent == null
							? `?/${formatTokens(contextWindow)}`
							: `${pct.toFixed(1)}%/${formatTokens(contextWindow)}`;

					const statuses = footerData.getExtensionStatuses();
					const statusText = Array.from(statuses.entries())
						.sort(([a], [b]) => a.localeCompare(b))
						.map(([, text]) => sanitize(text))
						.join(" ");

					const stats: string[] = [];
					if (input) stats.push(`\u2191${formatTokens(input)}`);
					if (output) stats.push(`\u2193${formatTokens(output)}`);
					if (cost) stats.push(`$${cost.toFixed(3)}`);
					stats.push(pct > 90 ? theme.fg("error", pctDisplay) : pct > 70 ? theme.fg("warning", pctDisplay) : pctDisplay);
					if (statusText) stats.push(statusText);

					let statsLeft = stats.join(" ");
					if (visibleWidth(statsLeft) > width) statsLeft = truncateToWidth(statsLeft, width, "...");

					const modelName = ctx.model?.id || "no-model";
					let rightSide = modelName;
					if (ctx.model?.reasoning) {
						const level = ctx.thinkingLevel || "off";
						rightSide = level === "off" ? `${modelName} \u2022 thinking off` : `${modelName} \u2022 ${level}`;
					}

					const leftWidth = visibleWidth(statsLeft);
					const rightWidth = visibleWidth(rightSide);
					let statsLine: string;
					if (leftWidth + 2 + rightWidth <= width) {
						statsLine = statsLeft + " ".repeat(width - leftWidth - rightWidth) + rightSide;
					} else {
						const avail = width - leftWidth - 2;
						if (avail > 0) {
							const right = truncateToWidth(rightSide, avail, "");
							statsLine = statsLeft + " ".repeat(Math.max(0, width - leftWidth - visibleWidth(right))) + right;
						} else {
							statsLine = statsLeft;
						}
					}

					return [
						truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
						theme.fg("dim", statsLeft) + theme.fg("dim", statsLine.slice(statsLeft.length)),
					];
				},
			};
		});
	});
}
