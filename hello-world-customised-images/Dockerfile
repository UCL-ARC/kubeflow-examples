# Use Python 3.11 as base image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_PROJECT_ENVIRONMENT="/app/.venv" \
    PATH="/root/.local/bin:${PATH}"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install UV package manager (standalone installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set working directory
WORKDIR /app

# Copy dependency files (prioritize pyproject.toml/uv.lock)
COPY pyproject.toml ./

# Just create venv and install dependencies without frozen mode
RUN uv venv && \
    uv sync


# Copy application files
COPY quickstart-container-registry.py .
COPY my-entrypoint.sh .
COPY . .

# Make entrypoint executable
RUN chmod +x my-entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["./my-entrypoint.sh"]
