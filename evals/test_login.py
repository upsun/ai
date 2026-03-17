import json
import os
import subprocess
from deepeval.test_case import LLMTestCase, LLMTestCaseParams, ToolCall, ToolCallParams
from deepeval.metrics import GEval, ToolCorrectnessMetric
from deepeval import assert_test

def run_claude_code(prompt):
  """Execute Claude Code CLI and capture output with tool call traces"""
  allowed_tools = [
    'Skill',
    'ToolSearch',
    'mcp__upsun__*',
    'Bash(upsun auth:*)',
    'Bash(upsun environment:*)',
    'Bash(upsun activity:*)',
    'Bash(upsun backup:*)',
    'Bash(upsun project:*)',
    'Bash(upsun logs:*)',
    'Bash(upsun resources:*)',
    'Bash(upsun metrics:*)',
    'Bash(upsun user:*)',
    'Bash(upsun organization:*)',
  ]
  env = {k: v for k, v in os.environ.items() if k != 'CLAUDECODE'}
  result = subprocess.run(
    ['claude', '-p', prompt,
     '--allowedTools', ','.join(allowed_tools),
     '--output-format', 'stream-json',
     '--verbose',
     '--dangerously-skip-permissions'],
    capture_output=True,
    text=True,
    timeout=3000,
    env=env
  )

  if result.returncode != 0:
    raise RuntimeError(
      f"Claude CLI failed with exit code {result.returncode}.\n"
      f"STDOUT:\n{result.stdout}\n"
      f"STDERR:\n{result.stderr}"
    )

  tool_calls = []
  final_output = ""

  for line in result.stdout.splitlines():
    if not line.strip():
      continue
    try:
      event = json.loads(line)
    except json.JSONDecodeError:
      continue

    if event.get("type") == "assistant":
      for block in event.get("message", {}).get("content", []):
        if block.get("type") == "tool_use":
          tool_calls.append(ToolCall(
            name=block["name"],
            input_parameters=block.get("input", {})
          ))
    elif event.get("type") == "result":
      final_output = event.get("result", "")

  return final_output, tool_calls

def test_upsun_login():
  output, tool_calls = run_claude_code("Am i logged in to Upsun ?")

  correctness_metric = GEval(
    name="Correctness",
    evaluation_params=[LLMTestCaseParams.ACTUAL_OUTPUT, LLMTestCaseParams.EXPECTED_OUTPUT],
    evaluation_steps=[
      "Check if the actual output correctly identifies that the user is not logged in to Upsun",
      "Verify that the actual output mentions the session has expired or similar authentication issue",
      "Confirm that the actual output provides the correct command 'upsun login' to authenticate",
      "Compare the actual output with the expected output to ensure they convey the same information"
    ]
  )

  skill_name = "upsun:check-upsun-auth" if os.environ.get("CI") else "check-upsun-auth"

  tool_correctness_metric = ToolCorrectnessMetric(
    threshold=0.5,
    evaluation_params=[ToolCallParams.INPUT_PARAMETERS],
    include_reason=True
  )

  test_case = LLMTestCase(
    input="Am i logged in to Upsun ?",
    expected_output="No, you're not currently logged in to Upsun. Your session has expired. To log in, you'll need to run: upsun login",
    actual_output=output,
    tools_called=tool_calls,
    expected_tools=[ToolCall(name="Skill", input_parameters={"skill": skill_name})]
  )

  assert_test(test_case, [correctness_metric, tool_correctness_metric])
