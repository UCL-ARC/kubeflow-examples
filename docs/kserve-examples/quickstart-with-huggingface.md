---
title: Kserve quickstart with huggingface model
description:
weight: 1
---

Hello World example for deploying a Hugging Face FLAN-T5 model with KServe, including a kserve-service.yaml for configuring resources and a Jupyter notebook for running inference.

For context, FLAN-T5 was released  in [huggingface](https://huggingface.co/docs/transformers/model_doc/flan-t5) in the paper [Scaling Instruction-Finetuned Language Models](https://arxiv.org/pdf/2210.11416).
It is an enhanced version of T5 that has been finetuned in a mixture of tasks.

## Setting up Unified-AI notebook

Follow [documentation](https://kubeflow.arc-unified-ai.condenser.arc.ucl.ac.uk/docs/kubeflow_notebooks/) to create notebooks using the default options (for example, CPU: 2 cores; RAM: 4 GB; Workspace volume: 10 GB; GPUs: none).

## Setting up kserve resources

In the terminal of your notebook namespace run:
```bash
kubectl apply -f kserve-service.yaml
```
where `kserve-service.yaml` is defined as:

```json
apiVersion: serving.kserve.io/v1beta1
kind: InferenceService
metadata:
  annotations:
    sidecar.istio.io/inject: "false"
    # Disables injection of an Istio sidecar proxy.
    # Istio is often used for traffic management, but here it is turned off
  name: huggingface-flan-t5-large
spec:
  predictor:
    model:
      args:
      - --model_name=flan-t5-large
      - --model_dir=/mnt/models
      modelFormat:
        name: huggingface
      resources:
        limits: # Maximum resources the container can use.
          cpu: "6"
          memory: 18Gi
          nvidia.com/gpu: "0"
          ephemeral-storage: 20Gi
        requests: # Minimum guaranteed resources.
          cpu: "6"
          memory: 18Gi
          nvidia.com/gpu: "0"
          ephemeral-storage: 20Gi
      storageUri: hf://google/flan-t5-large
```

## Jupyter notebook for model inference

Get the inference service URL:
```python
result = !kubectl get inferenceservices huggingface-flan-t5-large \
    -o jsonpath='{.status.address.url}'

HUGGINGFACE_URL = result[0].strip()

print(HUGGINGFACE_URL)
# Example:
# http://huggingface-flan-t5-large.kubeflow-${USERNAME}.svc.cluster.local/
```

You can also go to the Unified-AI API under KServe Endpoints and use the "Copy" option to copy the endpoint URL (e.g. `http://huggingface-flan-t5-large.kubeflow-${USERNAME}.svc.cluster.local/`)

Test model inference
```python
import requests

API_ENDPOINT = f"{HUGGINGFACE_URL}/openai/v1/completions"
HEADERS = {"Content-Type": "application/json"}
PAYLOAD = {
    "model": "flan-t5-large",
    "prompt": "translate English to German: How old are you?",
    "max_tokens": 50, # Max Output length
    "temperature": 0.7, # Higher = more creative/random
}

response = requests.post(API_ENDPOINT, headers=HEADERS, json=PAYLOAD)

if response.status_code == 200:
    output = response.json()
    print("Generated text:", output["choices"][0]["text"])
else:
    print("Request failed:", response.status_code, response.text)
```

Jupyter notebook is here [kubeflow-trainer-hello-world](https://github.com/ucl-arc-unified-ai//kubeflow-examples/tree/main/kserve-hello-world/model-inference.ipynb)
