import subprocess


ALLOWED_TOOLS = [
    "mcp__upsun__*",
    "Bash(upsun auth:*)",
    "Bash(upsun environment:*)",
    "Bash(upsun activity:*)",
    "Bash(upsun backup:*)",
    "Bash(upsun project:*)",
    "Bash(upsun logs:*)",
    "Bash(upsun resources:*)",
    "Bash(upsun metrics:*)",
    "Bash(upsun user:*)",
    "Bash(upsun organization:*)",
    "Bash(upsun domain:*)",
    "Bash(upsun certificate:*)",
    "Bash(upsun variable:*)",
    "Bash(upsun db:*)",
    "Bash(upsun service:*)",
    "Bash(upsun ssh:*)",
    "Bash(upsun tunnel:*)",
    "Bash(upsun autoscaling:*)",
]


def run_claude_code(prompt: str) -> str:
    """Execute Claude Code CLI and capture output."""
    result = subprocess.run(
        [
            "claude",
            "-p",
            prompt,
            "--allowedTools",
            ",".join(ALLOWED_TOOLS),
            "--dangerously-skip-permissions",
        ],
        capture_output=True,
        text=True,
        timeout=3000,
    )
    return result.stdout
