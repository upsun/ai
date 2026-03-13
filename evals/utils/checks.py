"""
Deterministic checks over Claude Code stream-json event traces.

Each check takes a parsed list of event dicts (from runner.parse_jsonl) and
returns a bool. These are fast, explainable signals that run before any
model-based grading — they surface regressions without needing an LLM judge.

Claude Code stream-json event shape for a Bash tool call:
    {
        "type": "assistant",
        "message": {
            "content": [
                {"type": "tool_use", "name": "Bash", "input": {"command": "upsun auth:info"}}
            ]
        }
    }

MCP tool call (Upsun plugin):
    {
        "type": "assistant",
        "message": {
            "content": [
                {"type": "tool_use", "name": "mcp__plugin_upsun_upsun__list-project", "input": {}}
            ]
        }
    }

The using-upsun skill can fulfil requests via either mechanism, so checks
must cover both to avoid false negatives.
"""

_MCP_PREFIX = "mcp__plugin_upsun_upsun__"
_MCP_LEGACY_PREFIX = "mcp__upsun__"


def _iter_tool_uses(events: list[dict]):
    """Yield (name, input_dict) for every tool_use block in assistant events."""
    for event in events:
        if event.get("type") != "assistant":
            continue
        content = event.get("message", {}).get("content", [])
        for block in content:
            if not isinstance(block, dict):
                continue
            if block.get("type") == "tool_use":
                yield block.get("name", ""), block.get("input", {})


def _iter_bash_commands(events: list[dict]):
    """Yield every bash command string found in assistant tool_use events."""
    for name, inp in _iter_tool_uses(events):
        if name == "Bash":
            cmd = inp.get("command", "")
            if cmd:
                yield cmd


def _iter_upsun_mcp_calls(events: list[dict]):
    """Yield tool names for every Upsun MCP tool call."""
    for name, _ in _iter_tool_uses(events):
        if name.startswith(_MCP_PREFIX) or name.startswith(_MCP_LEGACY_PREFIX):
            yield name


def check_ran_bash_command(events: list[dict], pattern: str) -> bool:
    """Return True if any executed bash command contains the given pattern."""
    return any(pattern in cmd for cmd in _iter_bash_commands(events))


def check_ran_auth_check(events: list[dict]) -> bool:
    """
    Return True if the agent ran an explicit auth check.

    Accepts either:
    - Bash: upsun auth:info
    - MCP:  any mcp__plugin_upsun_upsun__* call (MCP server auth is pre-validated;
            any MCP call implies the agent confirmed connectivity)
    """
    return check_ran_bash_command(events, "upsun auth:info") or any(
        True for _ in _iter_upsun_mcp_calls(events)
    )


def check_ran_any_upsun_tool(events: list[dict]) -> bool:
    """
    Return True if any Upsun capability was invoked — either via Bash CLI
    ('upsun ...') or via a Upsun MCP tool call.
    """
    ran_bash = check_ran_bash_command(events, "upsun ")
    ran_mcp = any(True for _ in _iter_upsun_mcp_calls(events))
    return ran_bash or ran_mcp


def check_skill_did_not_trigger(events: list[dict]) -> bool:
    """
    Return True if the skill was NOT triggered (negative control check).
    Passes when the agent produced no Upsun CLI calls and no Upsun MCP calls.
    """
    return not check_ran_any_upsun_tool(events)


def get_command_count(events: list[dict]) -> int:
    """Count total bash command executions (efficiency signal)."""
    return sum(1 for _ in _iter_bash_commands(events))


def get_upsun_tools_used(events: list[dict]) -> list[str]:
    """
    Return all Upsun tools invoked (bash commands + MCP calls) for
    debugging / reporting.
    """
    bash = [cmd for cmd in _iter_bash_commands(events) if "upsun " in cmd]
    mcp = list(_iter_upsun_mcp_calls(events))
    return bash + mcp
