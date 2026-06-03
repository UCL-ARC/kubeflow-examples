FROM vllm/vllm-openai:nightly

RUN apt update
RUN apt install -y git

RUN uv pip install --system git+https://github.com/huggingface/transformers.git

ARG USER_UID=1000
ARG PROJECT_GID=1000

RUN groupadd -g ${PROJECT_GID} vllmgroup && \
    useradd -u ${USER_UID} -g vllmgroup -m vllmuser

USER vllmuser
