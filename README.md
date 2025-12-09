# kubeflow-trainer-examples

Examples of python scripts, projects and Jupyter notebooks, demonstrating how to build, train, and deploy ML models using Kubeflow Trainer for unified AI.

## Building documentation locally

This section describes how to install dependencies and to build the documentation for the project.
```sh
# 1. Install uv (macOS and Linux)
curl -LsSf https://astral.sh/uv/install.sh | sh
# 2. Install dependencies and run mkdocs serve
uv sync
uv run mkdocs serve
```

The site will be served at: <http://127.0.0.1:8000/>

Pre-commit hooks for end-of-file-fixer, mixed-line-ending, trailing-whitespace and detect-secrets
```sh
uv run pre-commit run -a
```

## Clone repository
You need to [authorize a personal access token for use with single sign-on](https://docs.github.com/en/enterprise-cloud@latest/authentication/authenticating-with-single-sign-on/authorizing-a-personal-access-token-for-use-with-single-sign-on)
```sh
git clone https://github.com/ucl-arc-environments/kubeflow-trainer-examples.git
```
