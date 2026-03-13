"""
Structured evals for the `using-upsun` skill.

Evaluation approach mirrors the OpenAI blog post "Testing Agent Skills
Systematically with Evals" (https://developers.openai.com/blog/eval-skills/),
adapted for Claude Code CLI instead of Codex:

Layer 1 — Prompt CSV
    A small CSV of explicit, implicit, contextual, and negative-control cases
    drives all parametrized test runs.

Layer 2 — Deterministic trace checks
    Claude Code is invoked with --output-format stream-json so every tool call
    is captured as a JSONL event. Fast, explainable checks run against the
    trace before any model-based grading — they surface regressions cheaply.

Layer 3 — Rubric-based GEval grading
    For positive cases that pass deterministic checks, a GEval metric scores
    the final answer against a structured rubric (auth check, task addressed,
    correct CLI usage, actionable output).
"""

import csv
import os

import pytest
from deepeval import assert_test
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCase, LLMTestCaseParams

from utils.checks import (
    check_ran_any_upsun_tool,
    check_ran_auth_check,
    get_command_count,
    get_upsun_tools_used,
)
from utils.runner import get_final_output, parse_jsonl, run_claude_code_json

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

PROMPTS_FILE = os.path.join(os.path.dirname(__file__), "prompts", "using-upsun.prompts.csv")
ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "artifacts")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def load_test_cases() -> list[dict]:
    with open(PROMPTS_FILE, newline="") as f:
        return list(csv.DictReader(f))


def _rubric_metric() -> GEval:
    """Build the shared GEval rubric for positive test cases."""
    return GEval(
        name="Upsun Skill Quality",
        evaluation_params=[LLMTestCaseParams.INPUT, LLMTestCaseParams.ACTUAL_OUTPUT],
        evaluation_steps=[
            "Check that the agent verified or attempted to verify Upsun authentication "
            "(e.g. ran upsun auth:info or mentioned auth status) before executing commands.",
            "Verify that the response directly addresses the user's Upsun-related request "
            "rather than deflecting or providing only generic advice.",
            "Confirm that the agent used appropriate Upsun CLI commands for the task "
            "(e.g. upsun projects, upsun backup:create, upsun push, upsun logs).",
            "Check that the response provides actionable information — concrete commands, "
            "output summaries, or clear next steps — not just a description of what could be done.",
            "Verify the response contains no hallucinated Upsun project IDs, environment names, "
            "or CLI flags that were not present in the tool output.",
        ],
    )


# ---------------------------------------------------------------------------
# Parametrized tests
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "case",
    load_test_cases(),
    ids=lambda c: c["id"],
)
def test_using_upsun_skill(case: dict) -> None:
    """
    End-to-end eval for one row from using-upsun.prompts.csv.

    Negative control cases (should_trigger=false):
        Only the deterministic 'skill did not trigger' check runs.

    Positive cases (should_trigger=true):
        1. Deterministic: at least one Upsun tool was invoked (Bash or MCP).
        2. Informational: whether an explicit auth check was performed.
        3. GEval rubric on the final answer (model-based, scored 0-100).
    """
    os.makedirs(ARTIFACTS_DIR, exist_ok=True)
    trace_path = os.path.join(ARTIFACTS_DIR, f"{case['id']}.jsonl")

    jsonl_text = run_claude_code_json(case["prompt"], trace_path)
    events = parse_jsonl(jsonl_text)

    should_trigger = case["should_trigger"].strip().lower() == "true"

    # ------------------------------------------------------------------
    # Negative control — skill must NOT trigger
    # ------------------------------------------------------------------
    if not should_trigger:
        triggered = check_ran_any_upsun_tool(events)
        assert not triggered, (
            f"[{case['id']}] Skill triggered unexpectedly for prompt: {case['prompt']!r}\n"
            f"Upsun tools found: {get_upsun_tools_used(events)}"
        )
        return

    # ------------------------------------------------------------------
    # Positive case — Layer 2: deterministic checks
    # ------------------------------------------------------------------
    ran_upsun = check_ran_any_upsun_tool(events)
    assert ran_upsun, (
        f"[{case['id']}] Skill did not trigger — no Upsun CLI commands or MCP tools were invoked.\n"
        f"Trace saved to: {trace_path}"
    )

    # Informational: log whether an explicit auth check was performed.
    # Not a hard assertion — the agent may skip upsun auth:info if the MCP
    # server is already authenticated or it proceeds directly to the task.
    ran_explicit_auth = check_ran_auth_check(events)
    if not ran_explicit_auth:
        print(
            f"\n[{case['id']}] Note: no explicit upsun auth:info check observed "
            f"(tools used: {get_upsun_tools_used(events)})"
        )

    cmd_count = get_command_count(events)
    # Efficiency signal — warn if thrashing (> 15 bash commands), but don't fail
    if cmd_count > 15:
        pytest.warns(
            UserWarning,
            match=f"[{case['id']}] High command count ({cmd_count}) — possible thrashing.",
        )

    # ------------------------------------------------------------------
    # Positive case — Layer 3: rubric-based GEval grading
    # ------------------------------------------------------------------
    final_output = get_final_output(events)

    test_case = LLMTestCase(
        input=case["prompt"],
        actual_output=final_output,
    )
    assert_test(test_case, [_rubric_metric()])
