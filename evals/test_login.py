import subprocess
from deepeval.test_case import LLMTestCase, LLMTestCaseParams
from deepeval.metrics import GEval
from deepeval import assert_test

def run_claude_code(prompt):
  """Execute Claude Code CLI and capture output"""
  allowed_tools = [
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
  result = subprocess.run(
    ['claude', '-p', prompt, '--allowedTools', ','.join(allowed_tools)],
    capture_output=True,
    text=True,
    timeout=3000
  )
  return result.stdout

def test_upsun_login():
  # Run Claude Code
  output = run_claude_code("Am i logged in to Upsun ?")
  
  # Create correctness metric
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
  
  # Evaluate with DeepEval
  test_case = LLMTestCase(
    input="Am i logged in to Upsun ?",
    expected_output="No, you're not currently logged in to Upsun. Your session has expired. To log in, you'll need to run: upsun login",
    actual_output=output
  )
  assert_test(test_case, [correctness_metric])