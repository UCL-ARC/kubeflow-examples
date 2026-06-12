---
title: Deploying ONNX Models with KServe
description:
weight: 2
---

## Prerequisites

Before starting, create a new Unified AI Notebook with default settings (2cpu, 4Gi memory).
Under **Data Volumes**, select `scratch-volume`, this is required for storing datasets, models, and outputs.

## Download model and sample image
```bash
cd $HOME/scratch-volume && mkdir -p models/mosaic/1 && cd models/mosaic/1 # file permissions drwxr-sr-x.
wget -O model.onnx https://huggingface.co/onnxmodelzoo/mosaic-9/resolve/main/mosaic-9.onnx # file permissions -rw-r--r--.
wget https://raw.githubusercontent.com/pytorch/examples/main/fast_neural_style/images/content-images/amber.jpg
```

* Path layout for models
```bash
~/scratch-volume/models
   mosaic/
      1/
         model.onnx
```

## Create config for inference service

The [onnx.yaml](../../kserve-predictive-inference-onnx/onnx.yaml) is as follows

```bash
apiVersion: "serving.kserve.io/v1beta1"
kind: "InferenceService"
metadata:
  annotations:
    sidecar.istio.io/inject: "false"
  name: "style-sample"
spec:
  predictor:
    model:
      protocolVersion: v2
      modelFormat:
        name: onnx
      storageUri: "pvc://scratch-volume"
      runtime: kserve-tritonserver
      args:
        - --model-repository=/mnt/models/models
        - --model-control-mode=explicit
        - --load-model=mosaic
      resources:
        requests:
          cpu: "100m"
          memory: "512Mi"
        limits:
          cpu: "1"
          memory: "1Gi"
```


## Deploy Services
change path to `kserve-predictive-inference-onnx`
```bash
cd kserve-predictive-inference-onnx
kubectl apply -f onnx.yaml
```

## Run Inference Using Python

All steps are in [mosaic-onnx.ipynb](../../kserve-predictive-inference-onnx/mosaic-onnx.ipynb) for explcity,


### Add imports

```python
import json
import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import requests
from PIL import Image
```

### Configuration
```python
MODEL_NAME = 'mosaic'
IMAGE_PATH = '/home/jovyan/scratch-volume/models/mosaic/amber.jpg'
IMAGE_SIZE = (224, 224)

# Resolve inference service URL
result = !kubectl get inferenceservices style-sample -o jsonpath='{.status.address.url}'
SERVICE_HOSTNAME = result[0].strip()

print(f'SERVICE_HOSTNAME: {SERVICE_HOSTNAME}')
```

### Load image

```python
def load_image(path: str, size=(224, 224)):
    image = Image.open(path).convert('RGB')
    image = image.resize(size, Image.Resampling.LANCZOS)

    array = np.array(image, dtype=np.float32)
    tensor = np.transpose(array, (2, 0, 1))
    tensor = np.expand_dims(tensor, axis=0)

    return image, tensor

image, input_tensor = load_image(IMAGE_PATH, IMAGE_SIZE)
print('Input tensor shape:', input_tensor.shape)
image
```


### Build inference request
```python
payload = {
    'inputs': [{
        'name': 'input1',
        'shape': list(input_tensor.shape),
        'datatype': 'FP32', # ONNX model expects float32
        'data': input_tensor.tolist(),
    }]
}

payload.keys()
```

### Run inference
```python
api_endpoint = f'{SERVICE_HOSTNAME}/v2/models/{MODEL_NAME}/infer'

headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Host': SERVICE_HOSTNAME.replace('http://', '').replace('https://', '')
}

response = requests.post(
    api_endpoint,
    headers=headers,
    data=json.dumps(payload),
    timeout=60,
)

print('Status code:', response.status_code)
response.raise_for_status()
```

### Post-process and display result


```python
response_json = response.json()

output = np.array(response_json['outputs'][0]['data'], dtype=np.float32)
output = output.reshape(3, 224, 224)

result = np.clip(output, 0, 255)
result = result.transpose(1, 2, 0).astype(np.uint8)

result_image = Image.fromarray(result)

plt.imshow(result_image)
plt.axis('off')
plt.show()
```


## Inspect Services

Common `kubectl` commands for inspecting the deployment:

| Command | Purpose |
|---|---|
| `kubectl get inferenceservice` | List all inference services |
| `kubectl describe inferenceservice style-sample` | Inspect the service |
| `kubectl delete inferenceservice style-sample` | Remove the service |
| `kubectl get pods` | List pods |
| `kubectl describe pod style-sample-predictor-00001-deployment` | Inspect a pod |


## References

* https://kserve.github.io/website/docs/model-serving/predictive-inference/frameworks/onnx
* https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/user_guide/model_management.html#model-control-mode-explicit
