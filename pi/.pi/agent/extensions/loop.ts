import { randomBytes } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@mariozechner/pi-coding-agent";

const CUSTOM_TYPE = "loop";
const DEFAULT_INTERVAL_MS = 10 * 60 * 1000;
const MIN_INTERVAL_MS = 60 * 1000;
const MAX_TASKS = 50;
const EXPIRY_MS = 7 * 24 * 60 * 60 * 1000;
const LOOP_MD_LIMIT_BYTES = 25_000;

type LoopTask = {
  id: string;
  prompt: string;
  intervalMs: number;
  intervalLabel: string;
  createdAt: number;
  expiresAt: number;
  nextRunAt: number;
  runCount: number;
  lastRunAt?: number;
};

type RuntimeLoopTask = LoopTask & {
  timer?: NodeJS.Timeout;
  pending?: boolean;
};

type LoopEntryData =
  | { version: 1; action: "upsert"; task: LoopTask }
  | { version: 1; action: "delete"; id: string }
  | { version: 1; action: "delete-all" };

type ParsedLoopArgs = {
  prompt: string;
  intervalMs: number;
  intervalLabel: string;
  intervalWasExplicit: boolean;
};

const UNIT_MS: Record<string, number> = {
  s: 1000,
  sec: 1000,
  secs: 1000,
  second: 1000,
  seconds: 1000,
  m: 60 * 1000,
  min: 60 * 1000,
  mins: 60 * 1000,
  minute: 60 * 1000,
  minutes: 60 * 1000,
  h: 60 * 60 * 1000,
  hr: 60 * 60 * 1000,
  hrs: 60 * 60 * 1000,
  hour: 60 * 60 * 1000,
  hours: 60 * 60 * 1000,
  d: 24 * 60 * 60 * 1000,
  day: 24 * 60 * 60 * 1000,
  days: 24 * 60 * 60 * 1000,
};

function intervalFromParts(
  valueText: string,
  unitText: string,
): { ms: number; label: string } {
  const value = Number(valueText);
  const unit = unitText.toLowerCase();
  const unitMs = UNIT_MS[unit];
  if (!Number.isFinite(value) || value <= 0 || !unitMs) {
    throw new Error(`Invalid interval: ${valueText}${unitText}`);
  }

  const rawMs = value * unitMs;
  const ms = Math.max(
    MIN_INTERVAL_MS,
    Math.ceil(rawMs / MIN_INTERVAL_MS) * MIN_INTERVAL_MS,
  );
  const label = formatDuration(ms);
  return { ms, label };
}

function formatDuration(ms: number): string {
  const minute = 60 * 1000;
  const hour = 60 * minute;
  const day = 24 * hour;

  if (ms % day === 0) return `${ms / day}d`;
  if (ms % hour === 0) return `${ms / hour}h`;
  return `${Math.ceil(ms / minute)}m`;
}

function formatRelativeTime(timestamp: number): string {
  const delta = timestamp - Date.now();
  const abs = Math.abs(delta);
  const suffix = delta >= 0 ? "from now" : "ago";
  const minute = 60 * 1000;
  const hour = 60 * minute;
  const day = 24 * hour;

  if (abs < minute) return delta >= 0 ? "soon" : "just now";
  if (abs < hour) return `${Math.round(abs / minute)}m ${suffix}`;
  if (abs < day) return `${Math.round(abs / hour)}h ${suffix}`;
  return `${Math.round(abs / day)}d ${suffix}`;
}

function truncatePrompt(prompt: string, max = 90): string {
  const oneLine = prompt.replace(/\s+/g, " ").trim();
  return oneLine.length > max ? `${oneLine.slice(0, max - 1)}…` : oneLine;
}

function readFirstExisting(paths: string[]): string | undefined {
  for (const path of paths) {
    if (!existsSync(path)) continue;
    const content = readFileSync(path, "utf8");
    return Buffer.byteLength(content, "utf8") > LOOP_MD_LIMIT_BYTES
      ? content.slice(0, LOOP_MD_LIMIT_BYTES)
      : content;
  }
  return undefined;
}

function defaultPrompt(cwd: string): string {
  const fromFile = readFirstExisting([
    join(cwd, ".pi", "loop.md"),
    join(homedir(), ".pi", "agent", "loop.md"),
    join(cwd, ".claude", "loop.md"),
    join(homedir(), ".claude", "loop.md"),
  ]);

  if (fromFile?.trim()) return fromFile.trim();

  return [
    "Run a maintenance pass for this Pi session.",
    "",
    "Work through these in order:",
    "1. Continue any unfinished work already discussed in this conversation.",
    "2. Tend the current branch or PR if one is in progress: review comments, failed CI, merge conflicts, or requested follow-up.",
    "3. If nothing is pending, do a small cleanup pass such as bug hunting, simplification, or checking for obvious issues.",
    "",
    "Do not start unrelated new initiatives. Do not push, delete, publish, or perform irreversible actions unless the transcript already authorized that direction.",
  ].join("\n");
}

function parseLoopArgs(args: string, cwd: string): ParsedLoopArgs {
  let rest = args.trim();
  let intervalMs = DEFAULT_INTERVAL_MS;
  let intervalLabel = formatDuration(DEFAULT_INTERVAL_MS);
  let intervalWasExplicit = false;

  const leading = rest.match(/^(\d+)([smhd])(?:\s+|$)([\s\S]*)$/i);
  if (leading) {
    const interval = intervalFromParts(leading[1]!, leading[2]!);
    intervalMs = interval.ms;
    intervalLabel = interval.label;
    intervalWasExplicit = true;
    rest = (leading[3] ?? "").trim();
  } else {
    const trailing = rest.match(
      /(?:^|\s)every\s+(\d+)\s*(s|sec|secs|seconds?|m|min|mins|minutes?|h|hr|hrs|hours?|d|days?)\s*$/i,
    );
    if (trailing?.index !== undefined) {
      const interval = intervalFromParts(trailing[1]!, trailing[2]!);
      intervalMs = interval.ms;
      intervalLabel = interval.label;
      intervalWasExplicit = true;
      rest = rest.slice(0, trailing.index).trim();
    }
  }

  const prompt = rest || defaultPrompt(cwd);
  return { prompt, intervalMs, intervalLabel, intervalWasExplicit };
}

function makeId(existing: Map<string, RuntimeLoopTask>): string {
  for (;;) {
    const id = randomBytes(4).toString("hex");
    if (!existing.has(id)) return id;
  }
}

function appendTask(pi: ExtensionAPI, task: LoopTask) {
  pi.appendEntry<LoopEntryData>(CUSTOM_TYPE, {
    version: 1,
    action: "upsert",
    task,
  });
}

function appendDelete(pi: ExtensionAPI, id: string) {
  pi.appendEntry<LoopEntryData>(CUSTOM_TYPE, {
    version: 1,
    action: "delete",
    id,
  });
}

function appendDeleteAll(pi: ExtensionAPI) {
  pi.appendEntry<LoopEntryData>(CUSTOM_TYPE, {
    version: 1,
    action: "delete-all",
  });
}

function renderTask(task: LoopTask): string {
  return [
    `${task.id}  every ${task.intervalLabel}`,
    `  next: ${formatRelativeTime(task.nextRunAt)} | expires: ${
      formatRelativeTime(task.expiresAt)
    } | runs: ${task.runCount}`,
    `  ${truncatePrompt(task.prompt)}`,
  ].join("\n");
}

export default function (pi: ExtensionAPI) {
  const tasks = new Map<string, RuntimeLoopTask>();
  let latestCtx: ExtensionContext | undefined;

  function updateStatus(ctx?: ExtensionContext) {
    if (!ctx?.hasUI) return;
    const active =
      [...tasks.values()].filter((task) => task.expiresAt > Date.now()).length;
    ctx.ui.setStatus("loop", active > 0 ? `loops: ${active}` : undefined);
  }

  function clearTimer(task: RuntimeLoopTask) {
    if (task.timer) clearTimeout(task.timer);
    task.timer = undefined;
  }

  function deleteTask(id: string, persist = true) {
    const task = tasks.get(id);
    if (!task) return false;
    clearTimer(task);
    tasks.delete(id);
    if (persist) appendDelete(pi, id);
    updateStatus(latestCtx);
    return true;
  }

  function scheduleTimer(task: RuntimeLoopTask) {
    clearTimer(task);

    const now = Date.now();
    if (task.expiresAt <= now) {
      deleteTask(task.id);
      return;
    }

    const delay = Math.max(
      0,
      Math.min(task.nextRunAt - now, task.expiresAt - now),
    );
    task.timer = setTimeout(() => {
      task.timer = undefined;
      if (Date.now() >= task.expiresAt) {
        deleteTask(task.id);
        return;
      }
      task.pending = true;
      flushPending();
    }, delay);
  }

  function sendPrompt(task: RuntimeLoopTask, ctx: ExtensionContext) {
    task.pending = false;
    task.runCount += 1;
    task.lastRunAt = Date.now();
    task.nextRunAt = Date.now() + task.intervalMs;
    appendTask(pi, task);
    scheduleTimer(task);

    const content = task.prompt;
    if (ctx.isIdle()) {
      pi.sendUserMessage(content);
    } else {
      pi.sendUserMessage(content, { deliverAs: "followUp" });
    }
  }

  function flushPending() {
    const ctx = latestCtx;
    if (!ctx) return;

    const task = [...tasks.values()]
      .filter((task) => task.pending && task.expiresAt > Date.now())
      .sort((a, b) => a.nextRunAt - b.nextRunAt)[0];

    if (!task) return;
    sendPrompt(task, ctx);
  }

  function restoreTasks(ctx: ExtensionContext) {
    for (const task of tasks.values()) clearTimer(task);
    tasks.clear();

    const entries = [...ctx.sessionManager.getBranch()].sort(
      (a: any, b: any) => {
        return new Date(a.timestamp).getTime() -
          new Date(b.timestamp).getTime();
      },
    );

    for (const entry of entries as any[]) {
      if (entry.type !== "custom" || entry.customType !== CUSTOM_TYPE) continue;
      const data = entry.data as LoopEntryData | undefined;
      if (!data || data.version !== 1) continue;

      if (data.action === "delete-all") {
        tasks.clear();
      } else if (data.action === "delete") {
        tasks.delete(data.id);
      } else if (data.action === "upsert" && data.task.expiresAt > Date.now()) {
        tasks.set(data.task.id, { ...data.task });
      }
    }

    for (const task of tasks.values()) {
      if (task.nextRunAt <= Date.now()) task.pending = true;
      else scheduleTimer(task);
    }
    updateStatus(ctx);
    setTimeout(() => flushPending(), 0);
  }

  pi.on("session_start", async (_event, ctx) => {
    latestCtx = ctx;
    restoreTasks(ctx);
  });

  pi.on("agent_end", async (_event, ctx) => {
    latestCtx = ctx;
    flushPending();
  });

  pi.on("session_shutdown", async () => {
    for (const task of tasks.values()) clearTimer(task);
    latestCtx = undefined;
  });

  pi.registerCommand("loop", {
    description:
      "Run a prompt repeatedly on an interval, e.g. /loop 5m check the deploy",
    handler: async (args, ctx) => {
      latestCtx = ctx;
      await ctx.waitForIdle();

      if (tasks.size >= MAX_TASKS) {
        ctx.ui.notify(`Loop limit reached (${MAX_TASKS})`, "warning");
        return;
      }

      let parsed: ParsedLoopArgs;
      try {
        parsed = parseLoopArgs(args, ctx.cwd);
      } catch (error) {
        ctx.ui.notify(
          error instanceof Error ? error.message : String(error),
          "error",
        );
        return;
      }

      const now = Date.now();
      const task: RuntimeLoopTask = {
        id: makeId(tasks),
        prompt: parsed.prompt,
        intervalMs: parsed.intervalMs,
        intervalLabel: parsed.intervalLabel,
        createdAt: now,
        expiresAt: now + EXPIRY_MS,
        nextRunAt: now + parsed.intervalMs,
        runCount: 0,
      };

      tasks.set(task.id, task);
      appendTask(pi, task);
      scheduleTimer(task);
      updateStatus(ctx);

      const defaultNote = args.trim() && !parsed.intervalWasExplicit
        ? " (default interval)"
        : "";
      ctx.ui.notify(
        `Loop ${task.id}: every ${task.intervalLabel}${defaultNote}, expires in 7d. Use /unloop ${task.id} to cancel.`,
        "info",
      );

      sendPrompt(task, ctx);
    },
  });

  pi.registerCommand("loops", {
    description: "List active /loop tasks",
    handler: async (_args, ctx) => {
      latestCtx = ctx;
      const active = [...tasks.values()].filter((task) =>
        task.expiresAt > Date.now()
      );
      const content = active.length === 0
        ? "No active loops."
        : active.map(renderTask).join("\n\n");
      pi.sendMessage({ customType: CUSTOM_TYPE, content, display: true });
    },
  });

  pi.registerCommand("unloop", {
    description: "Cancel a loop by ID, or /unloop all",
    handler: async (args, ctx) => {
      latestCtx = ctx;
      const target = args.trim();
      if (!target) {
        ctx.ui.notify("Usage: /unloop <id|all>", "warning");
        return;
      }

      if (target === "all") {
        for (const task of tasks.values()) clearTimer(task);
        const count = tasks.size;
        tasks.clear();
        appendDeleteAll(pi);
        updateStatus(ctx);
        ctx.ui.notify(
          `Cancelled ${count} loop${count === 1 ? "" : "s"}.`,
          "info",
        );
        return;
      }

      const matches = [...tasks.keys()].filter((id) => id.startsWith(target));
      if (matches.length === 0) {
        ctx.ui.notify(`No loop matches ${target}`, "warning");
        return;
      }
      if (matches.length > 1) {
        ctx.ui.notify(`Ambiguous loop ID: ${matches.join(", ")}`, "warning");
        return;
      }

      deleteTask(matches[0]!);
      ctx.ui.notify(`Cancelled loop ${matches[0]}.`, "info");
    },
  });
}
