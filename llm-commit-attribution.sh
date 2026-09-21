#!/usr/bin/env bash
# Prints the Assisted-by trailer for the current agent session.
#
# Usage: support/agent-attribution.sh
# Output: Assisted-by: AGENT:MODEL
#
# Detected agents (in order):
#   pi          PI_MODEL is set
#   claude-code CLAUDE_CODE_SESSION_ID is set
#   codex       CODEX_SESSION_ID is set
#   opencode    OPENCODE=1 is set
#
# Exits 1 if the context cannot be determined or the model cannot be resolved.

set -euo pipefail

if [[ -n "${PI_MODEL:-}" ]]; then
    agent="pi"
    model="$PI_MODEL"

elif [[ -n "${CLAUDE_CODE_SESSION_ID:-}" ]]; then
    agent="claude-code"
    f=$(ls -t ~/.claude/projects/*/"$CLAUDE_CODE_SESSION_ID".jsonl 2>/dev/null | head -1)
    if [[ -z "$f" ]]; then
        echo "error: Claude Code session file not found for session $CLAUDE_CODE_SESSION_ID" >&2
        exit 1
    fi
    model=$(jq -r 'select(.type=="assistant" and (.isSidechain|not)) | .message.model' "$f" \
            | grep -v '^null$' | tail -1)
    if [[ -z "$model" ]]; then
        echo "error: could not determine model from Claude Code session $f" >&2
        exit 1
    fi

elif [[ -n "${CODEX_SESSION_ID:-}" ]]; then
    agent="codex"
    f=$(find ~/.codex/sessions -type f -name "*${CODEX_SESSION_ID}.jsonl" -print -quit 2>/dev/null || true)
    if [[ -z "$f" ]]; then
        echo "error: Codex session file not found for session $CODEX_SESSION_ID" >&2
        exit 1
    fi
    model=$(jq -sr '[.[] | select(.type == "turn_context") | .payload.model] | last' "$f")
    if [[ -z "$model" || "$model" == "null" ]]; then
        echo "error: could not determine model from Codex session $f" >&2
        exit 1
    fi

elif [[ "${OPENCODE:-}" == "1" ]]; then
    agent="opencode"
    model=$(opencode db \
        "select data->>'$.modelID' from message where data->>'$.role'='assistant' and data->>'$.finish' is null" \
        2>/dev/null | tail -1)
    if [[ -z "$model" || "$model" == "null" ]]; then
        echo "error: could not determine model from OpenCode session" >&2
        exit 1
    fi

else
    echo "error: unknown agent context" >&2
    echo "       set one of: PI_MODEL, CLAUDE_CODE_SESSION_ID, CODEX_SESSION_ID, OPENCODE=1" >&2
    exit 1
fi

echo "Assisted-by: ${agent}:${model}"
