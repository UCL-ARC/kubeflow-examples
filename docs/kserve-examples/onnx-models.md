---
title: Deploying ONNX Models with KServe
description:
weight: 2
---

## Prerequisites

Before starting, create a new Unified AI Notebook.
Under **Data Volumes**, select `scratch-volume`, this is required for storing datasets, models, and outputs.

## Download model and sample image
```bash
mkdir -p mosaic && cd mosaic
wget -O mosaic-9.onnx https://huggingface.co/onnxmodelzoo/mosaic-9/resolve/main/mosaic-9.onnx
wget https://raw.githubusercontent.com/pytorch/examples/main/fast_neural_style/images/content-images/amber.jpg
```

## Deploy Services
change path to `kserve-predictive-infence-onnx`
```bash
kubectl apply -f onnx.yaml
```


## Inspect Services

Common `kubectl` commands for inspecting the deployment:

| Command | Purpose |
|---|---|
| `kubectl get inferenceservice` | List all inference services |
| `kubectl describe inferenceservice style-sample` | Inspect the service |
| `kubectl delete inferenceservice style-sample` | Remove the service |
| `kubectl get pods` | List pods |
| `kubectl describe pod gpt-oss-20b-predictor-00001-deployment` | Inspect a pod |
