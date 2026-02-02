import { HOOK_EVENTS } from "npm:@anthropic-ai/claude-agent-sdk";
import type {
  HookInput,
  PostToolUseHookInput,
} from "npm:@anthropic-ai/claude-agent-sdk";

type Formatter = {
  name: string;
  extensions: string[];
  command: (filePath: string) => string[];
};

const formatters: Formatter[] = [
  {
    name: "terraform fmt",
    extensions: [".tf", ".tfvars"],
    command: (filePath) => ["terraform", "fmt", "-write", filePath],
  },
  {
    name: "go fmt",
    extensions: [".go"],
    command: (filePath) => ["go", "fmt", filePath],
  },
  {
    name: "ruff format",
    extensions: [".py"],
    command: (filePath) => ["uvx", "ruff", "format", filePath],
  },
  {
    name: "deno fmt",
    extensions: [".js", ".ts", ".jsx", ".tsx"],
    command: (filePath) => ["deno", "fmt", filePath],
  },
];

const inputText = await new Response(Deno.stdin.readable).text();
if (!inputText.trim()) {
  Deno.exit(0);
}

let payload: HookInput | undefined;
try {
  payload = JSON.parse(inputText) as HookInput;
} catch (error) {
  console.error("[format] Failed to parse hook payload:", error);
  Deno.exit(1);
}

if (!payload || typeof payload !== "object") {
  Deno.exit(0);
}

const hookEventName = (payload as HookInput).hook_event_name;
if (!HOOK_EVENTS.includes(hookEventName)) {
  Deno.exit(0);
}

if (hookEventName !== "PostToolUse") {
  Deno.exit(0);
}

const hookInput = payload as PostToolUseHookInput;

const filePaths = new Set<string>();
const toolInput = asRecord(hookInput.tool_input);
const directPath = getStringValue(toolInput, ["file_path", "filePath", "path"]);
if (directPath) {
  filePaths.add(directPath);
}

const patchText = getStringValue(toolInput, ["patchText", "patch_text"]);
if (patchText) {
  for (const path of extractPathsFromPatch(patchText)) {
    filePaths.add(path);
  }
}

let hasFailure = false;

for (const filePath of filePaths) {
  const formatter = findFormatter(filePath, formatters);
  if (!formatter) {
    continue;
  }

  const commandArgs = formatter.command(filePath);
  if (commandArgs.length === 0) {
    continue;
  }

  console.log(`[format] ${formatter.name}: ${filePath}`);
  const [command, ...args] = commandArgs;
  const process = new Deno.Command(command, {
    args,
    stdout: "inherit",
    stderr: "inherit",
  }).spawn();

  const status = await process.status;
  if (!status.success) {
    hasFailure = true;
    console.error(
      `[format] ${formatter.name} failed with exit code ${status.code}: ${filePath}`,
    );
  }
}

if (hasFailure) {
  Deno.exit(1);
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === "object"
    ? (value as Record<string, unknown>)
    : {};
}

function getStringValue(
  record: Record<string, unknown>,
  keys: string[],
): string | undefined {
  for (const key of keys) {
    const value = record[key];
    if (typeof value === "string" && value.trim()) {
      return value;
    }
  }
  return undefined;
}

function extractPathsFromPatch(patchText: string): string[] {
  const paths: string[] = [];
  for (const line of patchText.split("\n")) {
    if (line.startsWith("*** Update File: ")) {
      paths.push(line.replace("*** Update File: ", "").trim());
    }
    if (line.startsWith("*** Add File: ")) {
      paths.push(line.replace("*** Add File: ", "").trim());
    }
    if (line.startsWith("*** Move to: ")) {
      paths.push(line.replace("*** Move to: ", "").trim());
    }
  }
  return paths;
}

function findFormatter(
  filePath: string,
  rules: Formatter[],
): Formatter | undefined {
  const lowerPath = filePath.toLowerCase();
  return rules.find((rule) =>
    rule.extensions.some((extension) => lowerPath.endsWith(extension))
  );
}
