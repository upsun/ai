# Evaluations

DeepEval tests for the Upsun CLI agent skill.

## Test suites

**Scenario tests** (`test_scenarios.py`): 10 end-to-end tests that run Claude Code with a realistic user prompt and evaluate the output against expected behavior using GEval. Scenarios cover deployments, backups, scaling, SSH, domains, variables, environment cleanup, and database operations.

**Trigger tests** (`test_triggers.py`): 20 classification tests (10 positive, 10 negative) that verify the skill activates for Upsun-related prompts and stays silent for unrelated platforms (Vercel, Heroku, Docker, Kubernetes, etc.).

Test data lives in `data/scenarios.json` and `data/triggers.json`.

## Prerequisites

1. **Python environment**:
   ```bash
   uv sync
   source .venv/bin/activate
   ```

2. **AI Gateway** (for Gemini-based evaluation):
   ```bash
   eval "$(ai-gateway env)"
   gcloud auth application-default login
   ```

3. **Claude Code CLI** must be installed and on PATH.

4. **Upsun CLI** must be installed (skill under test).

## Running tests

All tests:
```bash
deepeval test run .
```

Scenarios only:
```bash
deepeval test run test_scenarios.py
```

Triggers only:
```bash
deepeval test run test_triggers.py
```

Single scenario by id:
```bash
deepeval test run test_scenarios.py -k "scenario-4"
```

With HTML report:
```bash
deepeval test run . --html=report.html --self-contained-html
```
