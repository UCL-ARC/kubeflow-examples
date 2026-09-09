---
title: KServe - gpt-oss-20b
description:
weight: 1
---

This guide walks you through setting up a unified-ai environment for generative inference with the `gpt-oss-20b` model.

## Prerequisites

Before starting, create a new Unified AI Notebook.
Under **Data Volumes**, select `scratch-volume`, this is required for storing datasets, models, and outputs.

## 1. Download `openai/gpt-oss-20b` model

Navigate to your scratch volume and download the model using the `hf` CLI.
Set `--local-dir` to the target download location and `--revision` to the commit hash of the required model version from the [huggingface.co/openai/gpt-oss-20b](https://huggingface.co/openai/gpt-oss-20b) repository.

You may experience crashes due to concurrency issues; if so, use `--max-workers 1`.
We recommend starting the process and running it until the model download completes.

```bash
cd $HOME/scratch-volume && mkdir -p models && cd models
pip install -U "huggingface_hub[cli]"
export PATH="$HOME/.local/bin:$PATH"
hf download openai/gpt-oss-20b --local-dir gpt-oss-20b/ --max-workers 1 --revision 6cee5e81ee83917806bbde320786a8fb61efebee #commited on Aug 26, 2025
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



## 2. Create a custom image

* Prerequisites.

Set these variables once, they're reused in every command below:

```bash
IMAGENAME=unified-ai-kserve-vllm
VERSION_ID=v0.0.2
```

* Build the Docker image.

Run from the directory containing your `Dockerfile`:

```bash
docker build -t ${IMAGENAME}:${VERSION_ID} -f Dockerfile .
```


* Tag the image for GitHub Container Registry

Replace `YOUR_GITHUB_ORG` and `YOUR_GITHUB_USERNAME_ID` with your own values:

```bash
GITHUB_ORG=YOUR_GITHUB_ORG        # or YOUR_GITHUB_USERNAME_ID
PROJECT_NAME=kserve-vllm

docker tag ${IMAGENAME}:${VERSION_ID} \
  ghcr.io/${GITHUB_ORG}/${PROJECT_NAME}/${IMAGENAME}:${VERSION_ID}
```


Verify the tag was applied (`docker images`):

```bash
$ docker images
REPOSITORY                                              TAG       IMAGE ID       CREATED         SIZE
ghcr.io/mxochicale/kserve-vllm/unified-ai-kserve-vllm   v0.0.2    c4ab68f6e4f6   2 minutes ago   26.2GB
unified-ai-kserve-vllm                                  v0.0.2    c4ab68f6e4f6   2 minutes ago   26.2GB
```

* Authenticate with a personal access token

Create a [classic PAT](https://github.com/settings/tokens) with the `write:packages` scope, then log in:

```bash
GITHUB_USERNAME=YOUR_GITHUB_USERNAME_ID
export CR_PAT=YOUR_PERSONAL_ACCESS_TOKEN

echo ${CR_PAT} | docker login ghcr.io \
  -u ${GITHUB_USERNAME} --password-stdin
# Login Succeeded
```

* Push the image

```bash
docker push ghcr.io/${GITHUB_ORG}/${PROJECT_NAME}/${IMAGENAME}:${VERSION_ID}
```

**After pushing:** go to `https://github.com/orgs/${GITHUB_ORG}/packages`, open the package settings, and change visibility to **public**.


## 3. Deploy Services

Apply the serving runtime and inference service manifests.

We recommend using `cd` to navigate to the configuration directory at `kserve-usecases/vllm/`, and `cd ..` to return to the root repository path.

You need to apply `serving-runtime.yaml` first, followed by `inference-service.yaml`.
Please note that the initial deployment may take some time, as the container image needs to be pulled onto the cluster.
Subsequent deployments will typically be much faster, as the image will already be cached on the node.

```bash
kubectl apply -f serving-runtime.yaml
kubectl apply -f inference-service.yaml
```

You can then use the following commands to inspect and manage the deployment:

```bash
kubectl get inferenceservice
kubectl describe inferenceservice gpt-oss-20b
```

## 4. Service Endpoint

The inference service is accessible at:
http://gpt-oss-20b.kubeflow-${USERNAME}.svc.cluster.local


## 5. Send Requests

A complete working example is available in [hello-world-gpt-oss-20b.ipynb](https://github.com/UCL-ARC/kubeflow-examples/blob/main/kserve-usecases/vllm/hello-world-gpt-oss-20b.ipynb).

### Get the inference service URL

```python
import requests

# 1. Resolve the inference service URL
result = !kubectl get inferenceservices gpt-oss-20b \
    -o jsonpath='{.status.address.url}'

HOSTED_VLLM_API_BASE = result[0].strip()
print(f"Service URL: {HOSTED_VLLM_API_BASE}")
# e.g. http://gpt-oss-20b.kubeflow-${USERNAME}.svc.cluster.local
```

### Call the API and display the result
```python
# 2. Build and send the chat-completion request
API_ENDPOINT = f"{HOSTED_VLLM_API_BASE}/v1/chat/completions"
MODEL_PATH    = "/mnt/models/models/gpt-oss-20b"

user_text = "Translate: hi, how are you?"

payload = {
    "model": MODEL_PATH,
    "messages": [
        {"role": "system", "content": "You are a multilingual translator. Translate user input into Portuguese, German, and Spanish."},
        {"role": "user", "content": user_text},
    ],
    "max_tokens": 200,
    "temperature": 0.2,   # low temp → consistent, literal translations
}

response = requests.post(API_ENDPOINT, json=payload, timeout=60)
response.raise_for_status()           # surface HTTP errors immediately

# 3. Display the result
print(response.json()["choices"][0]["message"]["content"])
```


## 6. Inspect Services

Common `kubectl` commands for inspecting the deployment:

| Command | Purpose |
|---|---|
| `kubectl get inferenceservice` | List all inference services |
| `kubectl describe inferenceservice gpt-oss-20b` | Inspect the service |
| `kubectl delete inferenceservice gpt-oss-20b` | Remove the service |
| `kubectl get pods` | List pods |
| `kubectl describe pod gpt-oss-20b-predictor-00001-deployment` | Inspect a pod |
