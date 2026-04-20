# Kubeflow examples

A collection of Python scripts, projects, and Jupyter notebooks demonstrating how to build, train, and deploy machine learning models using Kubeflowl, the foundation of tools for AI platforms on Kubernetes within Unified-AI.

## Building documentation locally

This section describes how to install dependencies and to build the documentation for the project.
```bash
# 1. Install uv (macOS and Linux)
curl -LsSf https://astral.sh/uv/install.sh | sh
# 2. Install dependencies and run mkdocs serve
uv sync
uv run mkdocs serve
```

The site will be served at: <http://127.0.0.1:8000/>

Pre-commit hooks for end-of-file-fixer, mixed-line-ending, trailing-whitespace and detect-secrets
```bash
uv run pre-commit run -a
```

## Launch Jupyter locally
```bash
uv run jupyter notebook
```

## Clone repository
You need to [authorize a personal access token for use with single sign-on](https://docs.github.com/en/enterprise-cloud@latest/authentication/authenticating-with-single-sign-on/authorizing-a-personal-access-token-for-use-with-single-sign-on)
```bash
git clone https://github.com/ucl-arc-unified-ai/kubeflow-examples.git
```
