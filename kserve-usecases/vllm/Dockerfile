FROM vllm/vllm-openai:nightly

RUN apt update
RUN apt install -y git

RUN uv pip install --system git+https://github.com/huggingface/transformers.git

ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd -f -g ${USER_GID} vllmgroup \
 && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash vllmuser \
 || true

USER vllmuser