import json
import os
import subprocess
from pathlib import Path

ALLOWED_TOOLS = [
    # Upsun MCP tools (plugin:upsun:upsun server)
    "mcp__plugin_upsun_upsun__*",
    # Bash fallback for direct CLI usage and auth checks
    "Bash(upsun auth:*)",
    "Bash(upsun environment:*)",
    "Bash(upsun activity:*)",
    "Bash(upsun backup:*)",
    "Bash(upsun project:*)",
    "Bash(upsun projects*)",
    "Bash(upsun environments*)",
    "Bash(upsun push*)",
    "Bash(upsun log*)",
    "Bash(upsun logs:*)",
    "Bash(upsun resources:*)",
    "Bash(upsun metrics:*)",
    "Bash(upsun user:*)",
    "Bash(upsun organization:*)",
    "Bash(which upsun*)",
]


def run_claude_code_json(
    prompt: str,
    trace_path: str,
    allowed_tools: list[str] | None = None,
    timeout: int = 300,
) -> str:
    """
    Run Claude Code CLI with stream-json output format and save the JSONL trace.

    Returns the raw JSONL stdout string. The trace is also written to trace_path
    so callers can inspect it offline.

    Stream-json produces one JSON object per line. Each assistant turn that calls
    a tool emits an 'assistant' event whose message.content list includes
    tool_use blocks. The final 'result' event holds the text answer.

    Note: --verbose is required when combining -p with --output-format stream-json.
    """
    tools = allowed_tools if allowed_tools is not None else ALLOWED_TOOLS

    Path(trace_path).parent.mkdir(parents=True, exist_ok=True)

    result = subprocess.run(
        [
            "claude",
            "-p",
            prompt,
            "--output-format",
            "stream-json",
            "--verbose",
            "--allowedTools",
            ",".join(tools),
            "--dangerously-skip-permissions",
        ],
        capture_output=True,
        text=True,
        timeout=timeout,
    )

    with open(trace_path, "w") as f:
        f.write(result.stdout)

    return result.stdout


def parse_jsonl(jsonl_text: str) -> list[dict]:
    """Parse a JSONL string into a list of event dicts, skipping malformed lines."""
    events = []
    for line in jsonl_text.strip().splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            pass
    return events


def get_final_output(events: list[dict]) -> str:
    """
    Extract the final text answer from a parsed event list.

    Claude Code stream-json emits a 'result' event at the end with a 'result'
    field containing the assistant's final text. Falls back to collecting text
    content blocks from the last 'assistant' event if no result event is found.
    """
    for event in reversed(events):
        if event.get("type") == "result":
            return event.get("result", "")

    # Fallback: collect text from the last assistant message
    for event in reversed(events):
        if event.get("type") == "assistant":
            content = event.get("message", {}).get("content", [])
            texts = [
                block.get("text", "")
                for block in content
                if isinstance(block, dict) and block.get("type") == "text"
            ]
            if texts:
                return "\n".join(texts)

    return ""
