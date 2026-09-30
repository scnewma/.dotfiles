import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const reference = /^\^c[1-9]\d*$/;
const minimumLength = 80;
const instruction =
  "A Bash result may include 'Reusable command: ^cN'. To rerun it, set the entire bash command to ^cN. Otherwise write the full command.";
type SavedCommand = { id: string; command: string };

function savedCommand(entry: unknown): SavedCommand | undefined {
  if (!entry || typeof entry !== "object" || !("message" in entry)) return;
  const message = entry.message;
  if (
    !message || typeof message !== "object" || !("role" in message) ||
    message.role !== "toolResult"
  ) return;
  if (
    !("toolName" in message) || message.toolName !== "bash" ||
    !("details" in message)
  ) return;
  const details = message.details;
  if (
    !details || typeof details !== "object" || !("reusableCommand" in details)
  ) return;
  const value = details.reusableCommand;
  if (
    !value || typeof value !== "object" || !("id" in value) ||
    !("command" in value)
  ) return;
  if (
    typeof value.id !== "string" || !reference.test(value.id) ||
    typeof value.command !== "string"
  ) return;
  return { id: value.id, command: value.command };
}

export default function (pi: ExtensionAPI) {
  const commands = new Map<string, string>();
  const ids = new Map<string, string>();
  const pending = new Map<string, SavedCommand>();
  let nextId = 1;

  const restore = (
    ctx: {
      sessionManager: { getEntries(): unknown[]; getBranch(): unknown[] };
    },
  ) => {
    commands.clear();
    ids.clear();
    pending.clear();
    nextId = 1;
    for (const entry of ctx.sessionManager.getEntries()) {
      const saved = savedCommand(entry);
      if (saved) nextId = Math.max(nextId, Number(saved.id.slice(2)) + 1);
    }
    for (const entry of ctx.sessionManager.getBranch()) {
      const saved = savedCommand(entry);
      if (!saved) continue;
      commands.set(saved.id, saved.command);
      ids.set(saved.command, saved.id);
    }
  };

  pi.on("session_start", (_event, ctx) => restore(ctx));
  pi.on("session_tree", (_event, ctx) => restore(ctx));

  pi.on("before_agent_start", (event) => {
    const guidelines = event.systemPromptOptions.promptGuidelines ??= [];
    if (!guidelines.includes(instruction)) guidelines.push(instruction);
  });

  pi.on("message_end", (event) => {
    const message = event.message;
    if (message.role === "assistant") {
      let changed = false;
      const content = message.content.map((block) => {
        if (block.type !== "toolCall" || block.name !== "bash") return block;
        const command = block.arguments.command;
        if (typeof command !== "string") return block;
        if (reference.test(command)) {
          const expanded = commands.get(command);
          if (!expanded) return block;
          changed = true;
          return {
            ...block,
            arguments: { ...block.arguments, command: expanded },
          };
        }
        if (command.length < minimumLength) return block;
        let id = ids.get(command);
        if (!id) {
          id = `^c${nextId++}`;
          ids.set(command, id);
          commands.set(id, command);
        }
        pending.set(block.id, { id, command });
        return block;
      });
      if (changed) return { message: { ...message, content } };
    }

    if (message.role === "toolResult" && message.toolName === "bash") {
      const saved = pending.get(message.toolCallId);
      if (!saved) return;
      pending.delete(message.toolCallId);
      return {
        message: {
          ...message,
          content: [...message.content, {
            type: "text",
            text: `Reusable command: ${saved.id}`,
          }],
          details: { ...message.details, reusableCommand: saved },
        },
      };
    }
  });

  pi.on("tool_call", (event) => {
    if (
      event.toolName !== "bash" ||
      typeof event.input.command !== "string" ||
      !reference.test(event.input.command)
    ) {
      return;
    }
    return {
      block: true,
      reason:
        `Unknown reusable command: ${event.input.command}. Write the full command instead.`,
    };
  });
}
