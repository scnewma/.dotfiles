/** Review assets only. The native subagent extension is installed separately. */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerDispatcher } from "./src/dispatch.ts";
import { reviewReportTool } from "./src/tools/review_report.ts";

export default function (pi: ExtensionAPI): void {
	pi.registerTool(reviewReportTool);
	registerDispatcher(pi);
}
