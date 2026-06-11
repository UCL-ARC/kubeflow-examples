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

## Deploy Services
change path to `kserve-predictive-inference-onnx`
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
| `kubectl describe pod style-sample-predictor-00001-deployment` | Inspect a pod |
