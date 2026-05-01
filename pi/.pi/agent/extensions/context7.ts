import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "typebox";

type JsonRpcResponse = {
  jsonrpc?: "2.0";
  id?: number | string;
  result?: {
    content?: Array<{ type: string; text?: string }>;
    isError?: boolean;
  };
  error?: { code?: number; message?: string; data?: unknown };
};

const ENDPOINT = "https://mcp.context7.com/mcp";

function parseMcpResponse(text: string): JsonRpcResponse {
  const trimmed = text.trim();
  if (trimmed.startsWith("{")) return JSON.parse(trimmed) as JsonRpcResponse;

  for (const line of trimmed.split(/\r?\n/)) {
    if (!line.startsWith("data:")) continue;
    const data = line.slice("data:".length).trim();
    if (!data || data === "[DONE]") continue;
    return JSON.parse(data) as JsonRpcResponse;
  }

  throw new Error(`Context7 returned an unrecognized response: ${trimmed.slice(0, 500)}`);
}

async function callContext7Tool(
  name: "resolve-library-id" | "query-docs",
  args: Record<string, unknown>,
  signal?: AbortSignal,
) {
  const headers: Record<string, string> = {
    "content-type": "application/json",
    accept: "application/json, text/event-stream",
  };

  if (process.env.CONTEXT7_API_KEY) {
    headers.CONTEXT7_API_KEY = process.env.CONTEXT7_API_KEY;
  }

  const response = await fetch(ENDPOINT, {
    method: "POST",
    headers,
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: Date.now(),
      method: "tools/call",
      params: { name, arguments: args },
    }),
    signal,
  });

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`Context7 request failed (${response.status}): ${text.slice(0, 1000)}`);
  }

  const payload = parseMcpResponse(text);
  if (payload.error) {
    throw new Error(`Context7 MCP error ${payload.error.code ?? ""}: ${payload.error.message}`.trim());
  }

  const content = payload.result?.content ?? [];
  const output = content
    .map((item) => (item.type === "text" ? (item.text ?? "") : JSON.stringify(item)))
    .filter(Boolean)
    .join("\n\n");

  if (payload.result?.isError) {
    throw new Error(output || "Context7 returned an error");
  }

  return output || "Context7 returned no content.";
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "context7_resolve_library_id",
    label: "Context7 Resolve Library",
    description:
      "Resolve a package/product name to a Context7-compatible library ID. Use before querying docs unless the user gave an ID like /org/project or /org/project/version.",
    promptSnippet: "Resolve a library name to a Context7-compatible library ID for documentation lookup",
    promptGuidelines: [
      "Use context7_resolve_library_id and context7_get_library_docs when you need library/API documentation, code generation, setup, configuration, migration, or CLI usage details.",
      "Do not send secrets, credentials, proprietary code, or personal data to Context7 queries.",
    ],
    parameters: Type.Object({
      libraryName: Type.String({
        description: "Official library/package/product name, e.g. 'Next.js', 'React', 'Django'.",
      }),
      query: Type.String({
        description:
          "The user's specific question/task, used by Context7 to rank matches. Do not include secrets or confidential data.",
      }),
    }),
    async execute(_toolCallId, params, signal) {
      const text = await callContext7Tool(
        "resolve-library-id",
        { libraryName: params.libraryName, query: params.query },
        signal,
      );
      return { content: [{ type: "text", text }], details: { libraryName: params.libraryName } };
    },
  });

  pi.registerTool({
    name: "context7_get_library_docs",
    label: "Context7 Docs",
    description:
      "Fetch current Context7 documentation for a library ID returned by context7_resolve_library_id, or an explicit /org/project[/version] ID.",
    promptSnippet: "Fetch current documentation and code examples from Context7 for a resolved library ID",
    promptGuidelines: [
      "Use context7_get_library_docs after resolving a library ID, unless the user explicitly provided a Context7 ID like /org/project or /org/project/version.",
      "Keep Context7 queries focused and never include secrets, credentials, proprietary code, or personal data.",
    ],
    parameters: Type.Object({
      libraryId: Type.String({
        description: "Exact Context7 library ID, e.g. '/vercel/next.js' or '/vercel/next.js/v14.3.0'.",
      }),
      query: Type.String({
        description: "Specific documentation question/task. Do not include secrets or confidential data.",
      }),
      researchMode: Type.Optional(
        Type.Boolean({
          description:
            "Set true only on retry when deeper research is needed. Requires a Context7 API key.",
        }),
      ),
    }),
    async execute(_toolCallId, params, signal) {
      const text = await callContext7Tool(
        "query-docs",
        {
          libraryId: params.libraryId,
          query: params.query,
          ...(params.researchMode === undefined ? {} : { researchMode: params.researchMode }),
        },
        signal,
      );
      return { content: [{ type: "text", text }], details: { libraryId: params.libraryId } };
    },
  });
}
