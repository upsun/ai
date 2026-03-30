import json
from pathlib import Path

import pytest
from deepeval import assert_test
from deepeval.metrics import GEval
from deepeval.test_case import LLMTestCase, LLMTestCaseParams

from conftest import run_claude_code

DATA = json.loads((Path(__file__).parent / "data" / "scenarios.json").read_text())
SCENARIOS = DATA["evals"]


@pytest.mark.parametrize(
    "scenario",
    SCENARIOS,
    ids=[f"scenario-{s['id']}" for s in SCENARIOS],
)
def test_scenario(scenario):
    output = run_claude_code(scenario["prompt"])

    correctness = GEval(
        name="Correctness",
        evaluation_params=[
            LLMTestCaseParams.ACTUAL_OUTPUT,
            LLMTestCaseParams.EXPECTED_OUTPUT,
        ],
        evaluation_steps=scenario["expectations"],
    )

    test_case = LLMTestCase(
        input=scenario["prompt"],
        expected_output=scenario["expected_output"],
        actual_output=output,
    )
    assert_test(test_case, [correctness])
