# Evaluations

DeepEval tests for evaluating AI coding agent skills.

## Prerequisites

1. **Virtual Environment**: Activate the Python virtual environment
   ```bash
   source .venv/bin/activate.fish  # for fish shell
   # or
   source .venv/bin/activate       # for bash/zsh
   ```

2. **AI Gateway Environment**: Set up environment variables for AI Gateway
   ```bash
   eval "$(ai-gateway env)"
   ```

3. **Google Cloud Authentication**: Authenticate for Vertex AI/Gemini access
   ```bash
   gcloud auth application-default login
   ```


## Running Tests

To run all tests:
```bash
deepeval test run
```

To run a specific test:
```bash
deepeval test run test_login.py
```

## Test Structure

Tests use:
- **DeepEval**: Testing framework for LLM applications
- **GEval**: Metric for evaluating outputs using Gemini 3.1 Pro
- **Claude Code CLI**: The agent being evaluated

Each test:
1. Executes Claude Code CLI with a prompt
2. Captures the output
3. Evaluates it against expected behavior using LLM-based metrics
