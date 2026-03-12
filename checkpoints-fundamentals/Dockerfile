FROM docker.io/pytorch/pytorch:2.7.1-cuda12.8-cudnn9-devel  

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_PROJECT_ENVIRONMENT="/app/.venv"

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /workspace && chmod -R 777 /workspace

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

COPY pyproject.toml ./

RUN uv venv && \
    uv sync

ENV PATH="/app/.venv/bin:${PATH}"

COPY mnist-checkpoints-fundamentals.ipynb .
COPY quickstart-container-registry.ipynb .
COPY entrypoint.sh .
COPY . .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]