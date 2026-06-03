---
title: KServe with gpt-oss-20b
description:
weight: 2
---

This guide walks you through setting up a unified-ai environment for generative inference with the `gpt-oss-20b` model.

## Prerequisites

Before starting, create a new Unified AI Notebook.
Under **Data Volumes**, select `scratch-volume`, this is required for storing datasets, models, and outputs.

## 1. Download openai/gpt-oss-20b

Navigate to your scratch volume and download the model.

You may experience crashes due to concurrency issues; if so, use `--max-workers 1`.
We recommend starting the process and running it until the model download completes.

```bash
cd $HOME/scratch-volume && mkdir -p models && cd models
pip install -U "huggingface_hub[cli]"
export PATH="$HOME/.local/bin:$PATH"
hf download openai/gpt-oss-20b --local-dir gpt-oss-20b/ --max-workers 1
# Download complete: 100%, 41.3G/41.3G
```


<details>
<summary>Expected directory structure after download</summary>

```bash
~/scratch-volume/models/gpt-oss-20b/
├── chat_template.jinja
├── config.json
├── generation_config.json
├── LICENSE
├── metal/
├── model-00000-of-00002.safetensors   (4.8 GB)
├── model-00001-of-00002.safetensors   (4.8 GB)
├── model-00002-of-00002.safetensors   (4.2 GB)
├── model.safetensors.index.json
├── original/
├── README.md
├── special_tokens_map.json
├── tokenizer_config.json
├── tokenizer.json
└── USAGE_POLICY
```
</details>

## 2. Deploy Services

Apply the serving runtime and inference service manifests.

We recommend using `cd` to navigate to the configuration directory at `kserve-usecases/vllm/`, and `cd ..` to return to the root repository path.

You need to apply `serving-runtime.yaml` first, followed by `inference-service.yaml`.

```bash
kubectl apply -f serving-runtime.yaml
kubectl apply -f inference-service.yaml
```

You can then use the following commands to inspect and manage the deployment:

```bash
kubectl get inferenceservice
kubectl describe inferenceservice gpt-oss-20b-vllm
```

## 3. Service Endpoint

The inference service is accessible at:
http://gpt-oss-20b-vllm.kubeflow-${USERNAME}.svc.cluster.local


## 4. Send Requests

A complete working example is available in [hello-world-gpt-oss-20b.ipynb](../../kserve-usecases/vllm/hello-world-gpt-oss-20b.ipynb).

### Get the inference service URL

```python
import requests

# 1. Resolve the inference service URL
result = !kubectl get inferenceservices gpt-oss-20b-vllm \
    -o jsonpath='{.status.address.url}'

HOSTED_VLLM_API_BASE = result[0].strip()
print(f"Service URL: {HOSTED_VLLM_API_BASE}")
# e.g. http://gpt-oss-20b-vllm.kubeflow-${USERNAME}.svc.cluster.local
```

### Call the API and display the result
```python
# 2. Build and send the chat-completion request
API_ENDPOINT = f"{HOSTED_VLLM_API_BASE}/v1/chat/completions"
MODEL_PATH    = "/mnt/models/models/gpt-oss-20b"

payload = {
    "model": MODEL_PATH,
    "messages": [
        {
            "role": "user",
            "content": (
                "Translate the following sentence into Portuguese, German, and Spanish.\n"
                "Return each translation on a separate line, labelled by language.\n\n"
                "Sentence: How old are you?"
            ),
        }
    ],
    "max_tokens": 500,
    "temperature": 0.2,   # low temp → consistent, literal translations
}

response = requests.post(API_ENDPOINT, json=payload, timeout=60)
response.raise_for_status()           # surface HTTP errors immediately

# 3. Display the result
data    = response.json()
message = data["choices"][0]["message"]["content"]
print(message)
```


## 5. Inspect Services

Common `kubectl` commands for inspecting the deployment:

| Command | Purpose |
|---|---|
| `kubectl get inferenceservice` | List all inference services |
| `kubectl describe inferenceservice gpt-oss-20b-vllm` | Inspect the service |
| `kubectl delete inferenceservice gpt-oss-20b-vllm` | Remove the service |
| `kubectl get pods` | List pods |
| `kubectl describe pod gpt-oss-20b-vllm-predictor-00001-deployment` | Inspect a pod |
