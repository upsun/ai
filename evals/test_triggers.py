import json
from pathlib import Path

import pytest
from deepeval import assert_test
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCase, LLMTestCaseParams

from conftest import run_claude_code

TRIGGERS = json.loads((Path(__file__).parent / "data" / "triggers.json").read_text())


def _trigger_id(trigger: dict) -> str:
    tag = "pos" if trigger["should_trigger"] else "neg"
    # Use first 60 chars of query as a readable id
    slug = trigger["query"][:60].replace(" ", "-").rstrip("-")
    return f"{tag}-{slug}"


@pytest.mark.parametrize("trigger", TRIGGERS, ids=[_trigger_id(t) for t in TRIGGERS])
def test_trigger(trigger):
    output = run_claude_code(trigger["query"])

    if trigger["should_trigger"]:
        expected = (
            "The agent recognizes this as an Upsun platform task "
            "and uses Upsun CLI commands to address it."
        )
        steps = [
            "The output uses or recommends Upsun CLI commands "
            "(e.g., upsun environment:*, upsun backup:*, upsun push, etc.)",
            "The agent treats this as an Upsun platform task, "
            "not a generic infrastructure or unrelated platform question",
        ]
    else:
        expected = (
            "The agent does NOT use Upsun CLI commands "
            "and addresses the question with appropriate non-Upsun tools."
        )
        steps = [
            "The output does NOT reference Upsun CLI commands "
            "(upsun environment:*, upsun backup:*, upsun push, etc.)",
            "The agent addresses the question using tools and approaches "
            "appropriate to the platform mentioned (Vercel, Docker, AWS, Heroku, etc.)",
        ]

    accuracy = GEval(
        name="TriggerAccuracy",
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        evaluation_steps=steps,
    )

    test_case = LLMTestCase(
        input=trigger["query"],
        expected_output=expected,
        actual_output=output,
    )
    assert_test(test_case, [accuracy])
